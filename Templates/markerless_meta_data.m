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

load(fullfile(working_path,'script_options.mat')); % Load Opts structure

%% Set Matlab path
addpath(fullfile(template_path,'Assets','Matlab'),'-end')
addpath(genpath(fullfile(template_path,'Assets','Matlab','convertxml')),'-end')

if exist('QTMTools','file') ~= 2
    addpath(genpath(fullfile(template_path,'Assets','Matlab','qtmtools_local')),'-end')
end

if exist('MarkerlessTools','file') ~= 2
    addpath(genpath(fullfile(template_path,'Assets','Matlab','theia_pose_conversion_local')),'-end')
    addpath(genpath(fullfile(template_path,'Assets','Matlab','ezc3d')),'-end')
end

%% Prepare metadata tab
% Adds tab "trial_metadata" to admin file
Prepare_metadata(Opts);

%% Video meta data
% Extract video meta data from json file created with help of ffmpeg (see
% info in script)
system('extractmiqusvideoinfo_json.bat');
Extract_video_info(Opts);

%% Processing stats
% Collect processing time information from time stamps of files
% exported by Theia processing:
% - Time stamp of cal.txt indicates start of Theia processing
% - Time stamps of pose_*.c3d files for respective trials indicate times
%   when trials were finished.

Extract_processing_stats(Opts);

%% Close Matlab
disp('Quitting Matlab')

pause(2);
quit
