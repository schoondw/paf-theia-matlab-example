% Script for conversion of Theia skeleton data to QTM MAT/TSV
% Input:
% - Visual3D matlab exported of Theia pose data in TheiaFormatData folder
%
% Output (in session folder):
% - QTM Matlab format file (<trial>_theia poses.mat) containing Theia poses as Skeleton data (one file per trial)
% - QTM TSV skeleton format file(s) (<trial>_s_pose_filt_*.tsv, one per pose)
% - Excel file skeleton_export_info.xlsx containing information about the
%   trials and skeletons

%% Script parameters
template_path = '<?=$template_directory;?>';
working_path='<?=$working_directory;?>';
theia_data_path = 'TheiaFormatData';
skel_base = 'pose_filt';

admin_file = 'skeleton_export_info.xlsx';
trial_sheet = 'trials';
skel_sheet = 'skeletons';
max_rows = 500; % Maximum number of trials in a session (needed to initialize tables)
max_skel = 10; % Maximum number of skeletons per trial

theia_version_default = 'Theia3D unknown version';

% qtm_format_folder = 'qtm_format';
qtm_format_export_path = working_path;
qtm_mat_suffix = '_theia poses';

verbose = true;

%% Check/set Matlab path
if ~exist('QTMTools','file')
    disp('QTMTools should be installed and added to the Matlab path.')
    return
end
addpath(genpath(fullfile(template_path,'Assets','ezc3d')),'-end')
addpath(genpath(fullfile(template_path,'Scripts','src','Matlab')),'-end')

%% Project admin
Create_project_admin

%% Convert Theia pose C3D files to QTM skeleton representation (QTM .mat export format)
C3D_to_QTM_mat;

%% Convert QTM mat to QTM TSV skeletons (QTM .tsv skeleton format)
QTM_mat_to_tsv;
