% Script for collecting video and Theia processing meta data for
% markerless mocap trials 
%
% Requirements:
% - ffmpeg binaries on system path (for extraction of video meta data)
% 
% Input:
% - skeleton_export_info.xlsx file (from markerless data conversion script)
% 
% Output:
% - Adds a sheet "trial_metadata" to the skeleton_export_info-xlsx file

%% Script parameters
template_path = '<?=$template_directory;?>';
working_path='<?=$working_directory;?>';
theia_data_path = 'TheiaFormatData';
skel_base = 'pose_filt';

admin_file = 'skeleton_export_info.xlsx';
trial_sheet = 'trials';
meta_sheet = 'trial_metadata';

verbose = true;

%% Set Matlab path
addpath(genpath(fullfile(template_path,'Scripts','src','Matlab')),'-end')

%% Prepare metadata tab
% Adds tab "trial_metadata" to admin file

Prepare_metadata;

%% Video meta data
% Extract video meta data from json file created with help of ffmpeg (see
% info in script)

Extract_video_info;

%% Processing stats
% Collect processing time information from time stamps of files
% exported by Theia processing:
% - Time stamp of cal.txt indicates start of Theia processing
% - Time stamps of pose_*.c3d files for respective trials indicate times
%   when trials were finished.

Extract_processing_stats;
