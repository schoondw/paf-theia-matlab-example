% Convert skeletons in QTM .mat files to TSV skeleton export

%% Loop through trials

for i_trial = 1:n_trials
    
    n_skel = trial_tab{i_trial,'n_skel'};
    if n_skel < 1
        continue;
    end
    
    trial_name = char(trial_tab{i_trial,'trial'});
    
    if verbose
        fprintf('- Processing trial %d/%d: %s\n', i_trial, n_trials, trial_name);
    end
    
    qtm = qtmread(fullfile(qtm_format_export_path, [trial_name, qtm_mat_suffix, '.mat']));
    
    n_frames = qtm.Frames;
    frame_rate = qtm.FrameRate;
    
    for i_skel = 1:n_skel
        skel_name = qtm.Skeletons(i_skel).SkeletonName;
        n_segments = qtm.Skeletons(i_skel).NrOfSegments;
        segment_labels = qtm.Skeletons(i_skel).SegmentLabels;
        
        if verbose
            fprintf('-- Skel: %s (%d/%d)\n', skel_name, i_skel, n_skel);
        end
        
        % Write TSV
        tsv_file = fullfile(qtm_format_export_path,[trial_name, '_s_', skel_name, '.tsv']);
        fid_tsv = fopen(tsv_file,'w');
        
        % Write info header
        fprintf(fid_tsv,'NO_OF_FRAMES\t%d\n',n_frames);
        fprintf(fid_tsv,'NO_OF_CAMERAS\t12\n');
        fprintf(fid_tsv,'FREQUENCY\t%d\n',frame_rate);
        fprintf(fid_tsv,'TIME_STAMP\t\n'); %	2019-11-28, 13:43:42.715	1476252.89504471
        fprintf(fid_tsv,'REFERENCE\tGLOBAL\n');
        fprintf(fid_tsv,'SCALE\t%.5f\n',1.00000);
        fprintf(fid_tsv,'SOLVER\t%s\n',qtm.Skeletons(i_skel).Solver);
        
        % Write column header
        format_str = 'Frame\tTime';
        for i_segm=1:n_segments
            format_str = [format_str, '\t%s\tX\tY\tZ\tQX\tQY\tQZ\tQW'];
        end
        format_str = [format_str, '\n'];
        
        fprintf(fid_tsv,format_str,segment_labels{:});
        
        fclose(fid_tsv);
        
        % Append data
        n_cols = 8*n_segments + 2;
        tsv_block = ones(n_frames,n_cols)*-99999; % Write -99999 to distinguish empty columns
        % tsv_block = nan(n_frames,n_cols); % Write NaN for empty columns (not possible to distinguish from NaN values in data columns
        
        tsv_block(:,1) = (1:n_frames)';
        tsv_block(:,2) = (0:n_frames-1)'./frame_rate;
        
        for i_segm=1:n_segments
            col_idx = 3 + (i_segm-1)*8; % Start column for current segment (start column is supposed to remain empty/-99999)
            tsv_block(:, col_idx + (1:3)) = permute(qtm.Skeletons(i_skel).PositionData(:,i_segm,:),[3 1 2]);
            tsv_block(:, col_idx + (4:7)) = permute(qtm.Skeletons(i_skel).RotationData(:,i_segm,:),[3 1 2]);
        end
        
        writematrix(tsv_block,tsv_file,...
            'FileType','text','WriteMode','append','Delimiter','\t');
    end
    
end

if verbose
    disp('Done!')
end
