function tracker = update_model(img, tracker, objs, idf)

% Input :  
%     - tracker : real target status
%     - objs    : distractors status
%     - para    : paramenters used for tracking
%     - idf     : id of frame
% Output :  
%     - objs    : detected objects(target & objss)
%
%  Jingjing Xiao (shine636363@sina.com), 2016
%

if (tracker{idf}.rect(4) ~= 0) && (~isnan(tracker{idf}.rect(1)))
    % get dection
    tracker{idf}.rect       = check_rect(img, tracker{idf}.rect);
    tracker{idf}.valid_rect = tracker{idf}.rect;
    
    % target relative motion
    if size(objs{idf}.rect, 1) == 1
        tracker{idf}.pos_relative = [0 0];
    else
        tracker{idf}.pos_relative = tracker{idf}.rect(1:2) - mean(objs{idf}.rect(:, 1:2));
    end
    
    % model adaptation
    if 1                
        if ~isempty(tracker{idf}.id)
            % update color
            obs_color  = get_color(double(img), tracker{idf}.valid_rect');
            obs_weig   = sum(sqrt(tracker{idf-1}.color.model.*obs_color))*0.1;        
            tracker{idf}.color.model = (1-obs_weig)*tracker{idf-1}.color.model + obs_weig*obs_color; 
            % update shape
            obs_alphaf         = objs{idf}.shape.model_alphaf{tracker{idf}.id};
            obs_xf             = objs{idf}.shape.model_xf{tracker{idf}.id};
            obs_weig           = 0.02;%objs{idf}.shape.weig(tracker{idf}.id)*0.05;
            tracker{idf}.shape.model_alphaf = (1-obs_weig)*tracker{idf-1}.shape.model_alphaf + obs_weig*obs_alphaf;
            tracker{idf}.shape.model_xf     = (1-obs_weig)*tracker{idf-1}.shape.model_xf + obs_weig*obs_xf;
        else
            tracker{idf}.shape = tracker{idf-1}.shape;
        end
    else
        tracker{idf}.shape     = tracker{idf-1}.shape;
        tracker{idf}.color     = tracker{idf-1}.color; 
    end
else
    % no dection
    tracker{idf}.valid_rect   = tracker{idf-1}.valid_rect;
    tracker{idf}.shape        = tracker{idf-1}.shape;
    tracker{idf}.color        = tracker{idf-1}.color; 
    tracker{idf}.pos_relative = [0 0];
end
