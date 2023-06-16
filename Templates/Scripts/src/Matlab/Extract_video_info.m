% Extract video meta data

%% Execute batch file for extraction of video data
system('extractmiqusvideoinfo_json.bat');

%% Parameters

json_tempfile = 'miqusvideoinfo_json.txt';
json_file = 'miqusvideoinfo.json';

pat = [44 13 10 123 125 93 125 13 10]; % char codes
% ,
% {}]}
% 
repl = [93 125 13 10]; % char codes
% ]}
% 

%% Prepare json file from batch file output
% Need to replace final empty element (alternatively, skip last element
% after parsing JSON in next step, but this leaves a nicer json file. Best
% would be if the batch file could take care of a better ending of the json
% file.)
if exist(json_tempfile,'file')
    fid_temp = fopen(json_tempfile,'r');
    f_temp = fread(fid_temp);
    fclose(fid_temp);
    
    f_json = strrep(f_temp, pat, repl);
    
    fid_json = fopen(json_file,'w');
    fprintf(fid_json,'%s',f_json);
    fclose(fid_json);
    
    delete(json_tempfile);
end

%% Parse json file
fid_json = fopen(json_file, 'r');
str = fread(fid_json, '*char').';
fclose(fid_json);
J = jsondecode(str);

% Extract required information
N_mv = length(J.miqusvideo);
mv_files = cell(1,N_mv);
mv_width = nan(1,N_mv);
mv_height = nan(1,N_mv);
mv_frames = nan(1,N_mv);
mv_frame_rate = cell(1,N_mv);
for i1=1:N_mv
    mv_files{i1} = J.miqusvideo(i1).format.filename;
    mv_width(i1) = J.miqusvideo(i1).streams.width;
    mv_height(i1) = J.miqusvideo(i1).streams.height;
    mv_frames(i1) = J.miqusvideo(i1).streams.duration_ts;
    mv_frame_rate{i1} = J.miqusvideo(i1).streams.avg_frame_rate;
end

%% Loop per trial

n_rows = height(meta_tab);

for i_trial = 1:n_rows
    trial_id = char(meta_tab{i_trial,'trial'});
    
    if verbose
        fprintf('- Processing trial %d/%d: %s\n', i_trial, n_rows, trial_id);
    end
    
    % Find videos corresponding to current trial
    vid_idx = contains(mv_files,[trial_id, '_Miqus']);
    
    % Process video info
    flag_nf = false; % Initiate flags
    flag_fps = false;
    flag_res = false;
    
    n_cams = sum(vid_idx);
    if n_cams < 1
        continue;
    end
    
    vid_nf_array = mv_frames(vid_idx); % Number of frames
    vid_nf = mode(vid_nf_array);
    if length(unique(vid_nf_array))>1
        flag_nf = true;
    end
    
    str_format = ['[%s', repmat(',%s',1,n_cams-1), '];'];
    vid_fps_array = eval(...
        sprintf(str_format,mv_frame_rate{vid_idx})); % Frame rate array (evaluated from text)
    vid_fps = mode(vid_fps_array);
    if length(unique(vid_fps_array))>1
        flag_fps = true;
    end
    
    vid_height_array = mv_height(vid_idx);
    vid_height = mode(vid_height_array);
    if length(unique(vid_height_array))>1
        flag_res = true;
    end
    
    vid_width_array = mv_width(vid_idx);
    vid_width = mode(vid_width_array);
    if length(unique(vid_width_array))>1
        flag_res = true;
    end    
    
    % Add info to meta_tab
    meta_tab{i_trial,'n_videocams'} = n_cams;
    meta_tab{i_trial,'n_videoframes'} = vid_nf;
    meta_tab{i_trial,'videoframe_rate'} = vid_fps;
    meta_tab{i_trial,'video_width'} = vid_width;
    meta_tab{i_trial,'video_height'} = vid_height;
    meta_tab{i_trial,'n_megapix'} = vid_width*vid_height/1e6;
    meta_tab{i_trial,'flag_unequal_no_frames'} = flag_nf;
    meta_tab{i_trial,'flag_unequal_frame_rates'} = flag_fps;
    meta_tab{i_trial,'flag_unequal_video_resolutions'} = flag_res;
    
end

%% Write output table to Excel sheet

writetable(meta_tab,admin_file,...
    'Sheet',meta_sheet,'WriteMode','overwritesheet');

if verbose
    disp('Done!')
end