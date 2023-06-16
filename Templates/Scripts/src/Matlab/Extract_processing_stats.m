% Extract processing stats
% 
% Adds processing information to trial_metadata sheet
% 
% Processing stats:
% - start_theia_processing (cal.txt)
% - end_theia_processing (pose_0.c3d)
% - theia_processing_time

%% Parameters
% - Admin info
% admin_file = 'admin.xlsx';
% meta_sheet = 'trial_metadata';

d2s = 24*3600; % days-to-seconds conversion factor

% verbose = true;

%% Read admin
% meta_tab = readtable(admin_file,'Sheet',meta_sheet);
n_rows = height(meta_tab);

% project_path = pwd;

%% Convert variables back to string type (if needed)
% Convert back to string after reading from table, otherwise it is not
% possibe to fill in string values

% string_vars = {'start_theia_processing','end_theia_processing'};
% meta_tab = convertvars(meta_tab,string_vars,'string');

%% Loop per trial

for i_trial = 1:n_rows
    if meta_tab{i_trial,'n_skel'} < 1
        continue;
    end
    
    % Trial path
    fn = fullfile(working_path,theia_data_path,...
        char(meta_tab{i_trial,'trial'})...
        );
    
    if verbose
        fprintf('- Processing trial %d/%d: %s\n', i_trial, n_rows, fn);
    end
    
    d_cal = dir(fullfile(fn, 'cal.txt'));
    d_pose = dir(fullfile(fn, 'pose*.c3d'));
    
    t_start = d_cal.datenum;
    [t_end,i_pose] = max([d_pose.datenum]);
    
    % Add row to meta_tab
    meta_tab{i_trial,'start_theia_processing'} = string(d_cal.date);
    meta_tab{i_trial,'end_theia_processing'} = string(d_pose(i_pose).date);
    meta_tab{i_trial,'theia_processing_time'} = (t_end-t_start)*d2s;
    
end

%% Grouping per session
% cal.txt has same time stamp for all subsequent trials
% Identify trials from same session (processed at same time)
% Correct start times and durations

if verbose
    disp('- Calculating processing times')
end

% % Grouping of trials per session
% G = findgroups(meta_tab(:,{'subject_folder', 'session_folder', 'data_folder'}));
% g_vals = unique(G);
% n_grps = length(g_vals);
n_grps = 1;

for i_grp=1:n_grps
    % g_sel = ismember(G,g_vals(i_grp)); % logical index to table rows belonging to the group
    g_sel = true(1,n_rows); % All trials in table for a single session
    n_trials = sum(g_sel); % Number of trials in group
    if n_trials < 2
        continue;
    end
    
    % Extract time values from table
    te_array = meta_tab{g_sel,'end_theia_processing'};
    tp_array = meta_tab{g_sel,'theia_processing_time'};
    
    g_idx = find(g_sel); % convert logical index to row numbers
    [~,tp_sortidx]=sort(tp_array); % sort in order of end time (same as duration since start time is the same)
    
    for i_sub=2:n_trials
        % Index mapping
        i_current = tp_sortidx(i_sub);
        i_prev = tp_sortidx(i_sub-1);
        i_row = g_idx(i_current);
        
        % Set start processing time of current trial to that of previously finished trial
        meta_tab{i_row,'start_theia_processing'} = ...
            te_array(i_prev);
        
        % Corrected processing duration for current trial
        meta_tab{i_row,'theia_processing_time'} = ...
            tp_array(i_current)-tp_array(i_prev);
    end
end

%% Calculate processing time in fps

for i_trial = 1:n_rows
    if meta_tab{i_trial,'n_skel'} < 1 || ...
            isempty(meta_tab{i_trial,'n_videoframes'})
        continue;
    end
    
    meta_tab{i_trial,'theia_processing_fps'} = ...
        meta_tab{i_trial,'n_videoframes'} / meta_tab{i_trial,'theia_processing_time'};
end

%% Write output table to Excel sheet

writetable(meta_tab,admin_file,...
    'Sheet',meta_sheet,'WriteMode','overwritesheet');

if verbose
    disp('Done!')
end