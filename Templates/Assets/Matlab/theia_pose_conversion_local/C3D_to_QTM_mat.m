function status = C3D_to_QTM_mat(varargin)
% Convert C3D mat files to QTM skeleton
%
% Steps:
% - Read trial admin
% - Loop through skeletons per trial
% - Add skeleton information to skeleton admin ("skeletons" sheet in admin.xlsx)
% - Save QTM mat containing all skeletons to subfolder QTM_format

%% Parameters
status = false;

admin_file_default = 'admin.xlsx';
trial_sheet_default = 'trials';

write_skeleton_info_default = true;
skeleton_info_sheet_default = 'skeleton_info';

add_theia_version_to_trial_sheet_default = true;

theia_pose_base_default = 'pose_filt';

rot_suffix = '_4X4';
ignore_segments = {'worldbody'}; % List of rotation segments to ignore (without suffix)

default_model_default = 'standard';
animation_model_default = 'animation';
animation_model_segments_default = {'abdomen','thorax','neck'};

verbose_default = true;

trialVarDef_default = {... 'subject_folder','string';... 'session_folder','string';... 'qtm_project_name','string';... 'qtm_trial_path','string';...
    'theia_data_path','string';...
    'qtm_data_path','string';...
    'qtm_format_output_path','string';...    'qtm_format_output_suffix','string';...
    'trial','string';...
    'n_skel','double';...
    'processing_date','string'};

skelVarDef_default = {... 
    'theia_version','string';...
    'skel_id','string';...
    'model','string';...
    'n_frames','double';...
    'frame_rate','double';...
    'n_segments','double';...
    'fill_level_av','double';...
    'fill_level_sd','double';...
    'fill_level_min','double';...
    'fill_level_max','double'...
    };

% Fixed parameters
rmTrialVars = {'n_skel'};
admin_only = false; % Only adds info to admin/skip writing mat file when true (for debugging)

%% Parse input
p = inputParser;
p.KeepUnmatched = true;

istext = @(x) isstring(x) || ischar(x);

addParameter(p,'admin_file', admin_file_default, istext);
addParameter(p,'trial_sheet', trial_sheet_default, istext);
addParameter(p,'write_skeleton_info', write_skeleton_info_default, @islogical);
addParameter(p,'add_theia_version_to_trial_sheet', add_theia_version_to_trial_sheet_default, @islogical);
addParameter(p,'skeleton_info_sheet', skeleton_info_sheet_default, istext);
addParameter(p,'theia_pose_base', theia_pose_base_default, istext);
addParameter(p,'default_model', default_model_default, istext);
addParameter(p,'animation_model', animation_model_default, istext);
addParameter(p,'animation_model_segments', animation_model_segments_default, @iscell);
addParameter(p,'verbose', verbose_default, @islogical);
addParameter(p,'trialVarDef', trialVarDef_default, @iscell);
addParameter(p,'skelVarDef', skelVarDef_default, @iscell);

parse(p,varargin{:});

Opts = p.Results;

%% Read admin
trial_tab = readtable(Opts.admin_file, 'Sheet', Opts.trial_sheet);
n_trials = height(trial_tab);

if Opts.add_theia_version_to_trial_sheet
    trial_tab = addvars(trial_tab,repmat("",n_trials,1),'NewVariableNames','theia_version');
end

%% Initiate skeleton table

% Output variable definitions: name and type
if Opts.write_skeleton_info
    skelVarDef = [Opts.trialVarDef; Opts.skelVarDef];
    n_vars=size(skelVarDef,1);
    
    n_rows = sum(trial_tab{:,'n_skel'}); % n_trials*10;
    
    % Initialize table
    skel_tab = table('Size',[n_rows n_vars],...
        'VariableTypes',skelVarDef(:,2),'VariableNames',skelVarDef(:,1));
    skel_tab = removevars(skel_tab, rmTrialVars);
end

%% Loop per trial (row in admin)

% Initiate variables
row_counter = 0; % counter for total number of skeletons

for i_trial = 1:n_trials
    
    n_skel = trial_tab{i_trial,'n_skel'};
    if n_skel < 1
        continue;
    end
    
    trial_name = char(trial_tab{i_trial,'trial'});
    trial_output_name = char(trial_tab{i_trial,'trial_output_name'});
    pn_theia = char(trial_tab{i_trial,'theia_data_path'});
    pn_output = char(trial_tab{i_trial,'qtm_format_output_path'});
    
    if Opts.verbose
        fprintf('- Processing trial %d/%d: %s\n', i_trial, n_trials, pn_theia);
    end
    
    % Initiate QTM data structure (Matlab export format)
    qtm = struct(...
        'File',fullfile(trial_tab{i_trial,'qtm_data_path'},[trial_name, '.qtm']),... % Reference to original QTM file (reconstructed)
        'Timestamp',[],...
        'StartFrame',1,...
        'Frames',[],...
        'FrameRate',[],...
        'Skeletons',struct([]));
    
    for i_skel = 1:n_skel
        skel_name = sprintf('%s_%d', Opts.theia_pose_base, i_skel-1);
        
        if Opts.verbose
            fprintf('-- Skel: %s (%d/%d)\n', skel_name, i_skel, n_skel);
        end
        
        % Read skeleton file and extract info
        c3d = ezc3dRead(fullfile(pn_theia, [skel_name, '.c3d']));
        
        % Check requirements
        if c3d.parameters.ROTATION.USED.DATA < 1 % Number of segments
            if verbose
                fprintf('     No rotation data found in %s.\n',...
                    [skel_name, '.c3d']);
            end
            continue;
        end
        
        % n_frames = length(S.TIME{1});
        n_frames = c3d.header.points.lastFrame - c3d.header.points.firstFrame + 1;
        % Possibly needs to be corrected in case of combined mocap and video data with different frame rates using ratio c3d.parameters.ROTATION.RATIO.DATA

        % frame_rate = S.FRAME_RATE{1};
        frame_rate = c3d.parameters.ROTATION.RATE.DATA;
        
        theia_version = sprintf('Theia3D %d.%d.%d.%d',...
            c3d.parameters.THEIA3D.THEIA3D_VERSION.DATA);
        
        if i_skel == 1
            qtm.Frames = n_frames;
            qtm.FrameRate = frame_rate;
            
            if Opts.add_theia_version_to_trial_sheet
                trial_tab{i_trial,'theia_version'} = string(theia_version);
            end
        end
        
        % Parse segment label info
        segment_labels = strrep(c3d.parameters.ROTATION.LABELS.DATA,...
            rot_suffix,'');
        
        % Segment selection
        segm_idx = ~ismember(segment_labels,ignore_segments);
        n_segments = sum(segm_idx);
        segment_labels = segment_labels(segm_idx);
        
        % Convert to QTM position and rotation multidim matrix representation (rigid body)
        pos = reshape(c3d.data.rotations(1:3,4,segm_idx,:),...
            3,n_segments,n_frames);
        rot = reshape(c3d.data.rotations(1:3,1:3,segm_idx,:),...
            9,n_segments,n_frames);
        
        % Infer model used
        model = Opts.default_model;
        if prod(ismember(Opts.animation_model_segments, segment_labels))==1
            model = Opts.animation_model;
        end
        
        % QTM rigid body-like structure
        qtm_skel = struct(...
            'SkeletonName',skel_name,...
            'Solver',sprintf('%s-%s', theia_version, model),...
            'Scale',1,...
            'Reference','Global',...
            'NrOfSegments',n_segments,...
            'SegmentLabels',{segment_labels},...
            'PositionData',pos,...
            'RotationData',rot);
        
        % Parse into QTMTools skeleton class
        mc_skel = skeleton(qtm_skel);
        
        % Substitute rotation data (from rot matrix to quaternions)
        qrot = [mc_skel.Segments.Rotation];
        xyzw = [qrot.vector; shiftdim(qrot.real,-1)];
        qtm_skel.RotationData = permute(xyzw,[1 3 2]);
        
        % Add skeleton structure to qtm structure
        qtm.Skeletons = [qtm.Skeletons qtm_skel];
        
        if Opts.write_skeleton_info
            % Extract fill levels per segment
            segm_fill_perc = sum(~isnan(squeeze(pos(1,:,:))),2)./n_frames*100;
            
            % Add row to skel_tab
            row_counter = row_counter+1;
            
            skel_tab(row_counter,'theia_data_path') = trial_tab(i_trial,'theia_data_path');
            skel_tab(row_counter,'qtm_data_path') = trial_tab(i_trial,'qtm_data_path');
            skel_tab(row_counter,'qtm_format_output_path') = trial_tab(i_trial,'qtm_format_output_path');
            skel_tab(row_counter,'trial') = trial_tab(i_trial,'trial');
            skel_tab(row_counter,'trial_output_name') = trial_tab(i_trial,'trial_output_name');
            % skel_tab(row_counter,'n_skel') = 1;
            skel_tab(row_counter,'processing_date') = trial_tab(i_trial,'processing_date');
            skel_tab{row_counter,'theia_version'} = string(theia_version);
            skel_tab{row_counter,'skel_id'} = string(skel_name);
            skel_tab{row_counter,'model'} = string(model);
            skel_tab{row_counter,'n_frames'} = n_frames;
            skel_tab{row_counter,'frame_rate'} = frame_rate;
            skel_tab{row_counter,'n_segments'} = n_segments;
            skel_tab{row_counter,'fill_level_av'} = mean(segm_fill_perc);
            skel_tab{row_counter,'fill_level_sd'} = std(segm_fill_perc);
            skel_tab{row_counter,'fill_level_min'} = min(segm_fill_perc);
            skel_tab{row_counter,'fill_level_max'} = max(segm_fill_perc);
        end
    end
    
    % Save QTM mat file containing all skeletons
    if ~admin_only
        if ~exist(pn_output,'dir')
            mkdir(pn_output);
        end
        save(fullfile(pn_output, [trial_output_name, '.mat']), 'qtm');
    end
    
end


%% Write skeleton tab to Excel

% Rewrite trial_tab
if Opts.add_theia_version_to_trial_sheet
    writetable(trial_tab, Opts.admin_file,...
        'Sheet',Opts.trial_sheet, 'WriteMode','overwritesheet');
end

% Add/replace skeleton tab
if Opts.write_skeleton_info
    writetable(skel_tab(1:row_counter,:), Opts.admin_file,...
        'Sheet',Opts.skeleton_info_sheet, 'WriteMode','overwritesheet');
end
status = true;

if Opts.verbose
    disp('Theia pose conversion to QTM MAT format done!')
end

