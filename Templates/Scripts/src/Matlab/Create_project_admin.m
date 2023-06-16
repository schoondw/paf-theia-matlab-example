% Create_project_admin

%% Initiate trial table

% Output variable definitions: name and type
% - Columns: trial, n_skel
trialVarDef = {... 
    'trial','string';...
    'n_skel','double';...
    'processing_date','string'...
    };
n_vars=size(trialVarDef,1);

% Initialize table
trial_tab = table('Size',[max_rows n_vars],...
    'VariableTypes',trialVarDef(:,2),'VariableNames',trialVarDef(:,1));

%% Loop through folder structure

row_counter = 0; % Counter for total number of trials

% Identify trial folders that may contain data
D = dir(theia_data_path);
trial_list = {D([D.isdir]).name};
trial_list(1:2) = [];

n_trials = length(trial_list);

for i_tr = 1:n_trials
    current_trial = trial_list{i_tr};
    
    % Count number of exported skeletons
    D = dir([theia_data_path, '/', current_trial, '/pose_filt_*.c3d']);
    n_skel = length(D);
    
    % Write row
    row_counter = row_counter+1;
    
    trial_tab{row_counter,'trial'} = string(current_trial);
    trial_tab{row_counter,'n_skel'} = n_skel;
    
    if n_skel > 0
        trial_tab{row_counter,'processing_date'} = string(D(1).date);
    end
end

%% Write output to Excel

trial_tab = trial_tab(1:row_counter,:);

writetable(trial_tab,admin_file,...
    'Sheet',trial_sheet,'WriteMode','overwritesheet');

if verbose
    disp('Done!')
end