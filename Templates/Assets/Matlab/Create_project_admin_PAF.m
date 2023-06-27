function status = Create_project_admin_PAF(trial_list,varargin)
% Create_project_admin

% - Detect Theia data folders (.\Data\<subject>\<session>\<TheiaFormatData>\<trial>)
% - Loop through subjects\sessions\data_folders\trials
% - Create trial admin file
% 
% Admin (trials):
% - Columns: subject_folder, session_folder, data_folder, trial, n_skel
% - Save to admin.xlsx, sheet: trials

%% Parameters
status = false;

% - Admin info
admin_file_default = 'admin.xlsx';
trial_sheet_default = 'trials';
theia_output_folder_default = 'TheiaFormatData'; % subfolder of qtm trial path
qtm_data_path_default = '.'; % PAF working directory
qtm_format_output_suffix_default = '_theia_pose';
theia_pose_base_default = 'pose_filt';
max_trials_default = 1000;
verbose_default = true;

trialVarDef_default = {...
    'theia_data_path','string';...
    'qtm_data_path','string';...
    'qtm_format_output_path','string';...
    'trial','string';...
    'trial_output_name','string';...
    'n_skel','double';...
    'processing_date','string'};
    
%% Parse input arguments
p = inputParser;
p.KeepUnmatched = true;

validScalarPosInt = @(x) isnumeric(x) && isscalar(x) && (x > 0) && x==floor(x);
istext = @(x) isstring(x) || ischar(x);

addRequired(p,'trial_list',@iscell);

addParameter(p,'admin_file', admin_file_default, istext);
addParameter(p,'trial_sheet', trial_sheet_default, istext);
addParameter(p,'theia_output_folder', theia_output_folder_default, istext);
addParameter(p,'qtm_data_path', qtm_data_path_default, istext);
addParameter(p,'qtm_format_output_suffix', qtm_format_output_suffix_default, istext);
addParameter(p,'theia_pose_base', theia_pose_base_default, istext);
addParameter(p,'max_trials', max_trials_default, validScalarPosInt);
addParameter(p,'verbose', verbose_default, @islogical);
addParameter(p,'trialVarDef', trialVarDef_default, @iscell);

parse(p,trial_list,varargin{:});

Opts = p.Results;

%% Identify Theia output folders (subfolders of current dir)
if ~exist(Opts.theia_output_folder,'dir')
    disp('No Theia output data found.')
    return
end

%% Initiate trial table

n_vars=size(Opts.trialVarDef,1);

% Initialize table
trial_tab = table('Size',[Opts.max_trials n_vars],...
    'VariableTypes',Opts.trialVarDef(:,2),'VariableNames',Opts.trialVarDef(:,1));

%% Loop through folder structure

row_counter = 0; % Counter for total number of trials
theia_datafolder = Opts.theia_output_folder;

n_trials = length(Opts.trial_list);

for i_tr = 1:n_trials
    current_trial = Opts.trial_list{i_tr};
    
    % Count number of exported skeletons
    D = dir(fullfile(theia_datafolder, current_trial,...
        [Opts.theia_pose_base, '_*.c3d']));
    n_skel = length(D);
    
    if n_skel > 0
        % Write row
        row_counter = row_counter+1;
        
        trial_tab{row_counter,'theia_data_path'} = ...
            string(fullfile(theia_datafolder, current_trial));
        trial_tab{row_counter,'qtm_data_path'} = string(Opts.qtm_data_path);
        trial_tab{row_counter,'qtm_format_output_path'} = string(Opts.qtm_data_path);
        trial_tab{row_counter,'trial'} = string(current_trial);
        trial_tab{row_counter,'trial_output_name'} = string([current_trial, Opts.qtm_format_output_suffix]);
        trial_tab{row_counter,'n_skel'} = n_skel;
        
        trial_tab{row_counter,'processing_date'} = string(D(1).date);
    end
end
    
%% Write output to Excel

writetable(trial_tab(1:row_counter,:),Opts.admin_file,...
    'Sheet',Opts.trial_sheet,'WriteMode','overwritesheet');

status = true;

if Opts.verbose
    disp('Project admin ready!')
end