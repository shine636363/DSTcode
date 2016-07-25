function [tracker, objs] = global_dynamic(tracker, objs, idf)
% Input :  
%     - tracker : real target status
%     - objs    : distractors status
%     - idf     : id of frame
% Output :  
%     - objs    : detected objects(target & objss)
%
%  Jingjing Xiao (shine636363@sina.com), 2016
%

%===== Global Dynamic constraint =====
if objs{idf-1}.num == 1 
    % no distractor in k-1 frame
    objs{idf}.dynamic.weig = get_dist(tracker{idf-1}.rect,  objs{idf}.rect); 
else
    % have distractor in k-1 frame
    objs{idf}.target_like_weig = get_dist(tracker{idf-1}.valid_rect,  objs{idf}.rect);
    objs{idf}.distractor_like_weig = get_dist(objs{idf-1}.rect, objs{idf}.rect);
    objs{idf}.distractor_like_weig(tracker{idf-1}.id, :) = []; % delete k-1 tracker from distractor
    if size(objs{idf}.distractor_like_weig,1)~=1
        objs{idf}.distractor_like_weig =  mean(objs{idf}.distractor_like_weig);
    end
        
    if objs{idf}.num == 1
        % no distractor in k frame
            objs{idf}.dynamic.weig = 0;
    else
        if (objs{idf}.num == objs{idf-1}.num) && (objs{idf}.num == objs{idf-2}.num) % more than two frames without topolpgy changes
            % generate historic informaiton
            valid_frame = idf-1;
            T_history = [];
            while objs{valid_frame}.num == objs{idf}.num
                T_history = [tracker{valid_frame}.pos_relative; T_history];
                valid_frame = valid_frame - 1;
                if valid_frame == 0
                    break;
                end
            end
            % training model
            time_len = size(T_history, 1);
            [a1,~] = polyfit(1: time_len, T_history(:,1)', 1);  
            [a2,~] = polyfit(1: time_len, T_history(:,2)', 1); 
            % EQ.8: predict target relative motion
            preT_relative = [a1(1)*(time_len+1) + a1(2), a2(1)*(time_len+1) + a2(2)]; 
            % EQ.9: get weight
            obsT_relative = objs{idf}.rect(:, 1:2) - repmat(mean(objs{idf}.rect(:, 1:2)), objs{idf}.num, 1);
            objs{idf}.dynamic.weig = get_dist(preT_relative, obsT_relative);
        else
            % Sec.3.2.B: handing dynamic number
            objs{idf}.dynamic.weig = exp(objs{idf}.target_like_weig-objs{idf}.distractor_like_weig);
        end
        % normalize the weight
        objs{idf}.dynamic.weig = objs{idf}.dynamic.weig/sum(objs{idf}.dynamic.weig);
    end
    objs{idf}.occ_flag = objs{idf}.occ_flag | (objs{idf}.target_like_weig < objs{idf}.distractor_like_weig);
end
    
%==== occlusion handling ===
id_occ = find(objs{idf}.occ_flag == 0);
if ~isempty(id_occ)
    % not occluded
    [~,idx_max] = max(objs{idf}.dynamic.weig(id_occ));
    objs{1,idf}.istracker(id_occ(idx_max)) = 1;
    tracker{idf}.id = id_occ(idx_max);
    tracker{idf}.rect = objs{1,idf}.rect(id_occ(idx_max),:);                 
else
    % occlusion
    tracker{idf}.id   = [];
    tracker{idf}.rect = [NaN NaN NaN NaN];     
end
