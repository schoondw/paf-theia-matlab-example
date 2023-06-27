function status = Prepare_metadata(varargin)
% Prepare metadata

%% Parameters
status = false;

% - Admin info
admin_file_default = 'admin.xlsx';
trial_sheet_default = 'trials';
meta_sheet_default = 'trial_metadata';

metaVarDef_default = {... 
    'n_videocams','doublenan';...
    'n_videoframes','doublenan';...
    'videoframe_rate','doublenan';...
    'video_width','doublenan';...
    'video_height','doublenan';...
    'n_megapix','doublenan';...
    'flag_unequal_no_frames','logical';...
    'flag_unequal_frame_rates','logical';...
    'flag_unequal_video_resolutions','logical';...
    'start_theia_processing','string';...
    'end_theia_processing','string';...
    'theia_processing_time','doublenan';...
    'theia_processing_fps','doublenan'...
    };

verbose_default = true;

%% Parse input arguments
p = inputParser;
p.KeepUnmatched = true;

istext = @(x) isstring(x) || ischar(x);

addParameter(p,'admin_file', admin_file_default, istext);
addParameter(p,'trial_sheet', trial_sheet_default, istext);
addParameter(p,'meta_sheet', meta_sheet_default, istext);
addParameter(p,'verbose', verbose_default, @islogical);
addParameter(p,'metaVarDef', metaVarDef_default, @iscell);

parse(p,varargin{:});

Opts = p.Results;


%% Read admin
trial_tab = readtable(Opts.admin_file,'Sheet',Opts.trial_sheet);
n_trials = height(trial_tab);

% project_path = pwd;

%% Initiate output table
n_vars=size(Opts.metaVarDef,1);

% Initialize table
meta_tab = table('Size',[n_trials n_vars],...
    'VariableTypes',Opts.metaVarDef(:,2),'VariableNames',Opts.metaVarDef(:,1));


%% Write output table to Excel sheet

writetable([trial_tab meta_tab],Opts.admin_file,...
    'Sheet',Opts.meta_sheet,'WriteMode','overwritesheet');

status = true;

if Opts.verbose
    disp('Meta data sheet added to admin file.')
end

