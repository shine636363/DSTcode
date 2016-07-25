function objs  = dense_sampling(im, tracker, Darea, Bsample)
% Input :  
%     - img     : images
%     - tracker : real target status
%     - Darea   : region for dense sampling
% Output :  
%     - objs    : detected objects(target & distractors)
%
% Contact:
%   Jingjing Xiao (shine636363@sina.com); Linbo Qiao (qiao.linbo@nudt.edu.cn)
%

%====== divid the region : x_num*y_num=====
padding = 1.5;
x_num = ceil(Darea(3)/((1+padding)*tracker.valid_rect(3)));
y_num = ceil(Darea(4)/((1+padding)*tracker.valid_rect(4)));

%====== dense smaple properties: select best sample from each sub-region =====
weig_map = [];
di       = 0;
for i = 0:1:x_num-1
    for j = 0:1:y_num-1
        if j == 0, dj = 0; end
        % dense sampling
        Pos= round([Bsample(1, 1)+ di*(1+padding)*Bsample(1, 3), Bsample(1, 2)+ dj*(1+padding)*Bsample(1, 4), Bsample(1, 3:4)]);
        [~, ~, weig_map] = get_shape(im, Pos, tracker.shape, weig_map);
        % check y-axis boundary
        if Bsample(2)+Bsample(4)/2+(j+1)*(1+padding)*Bsample(4)/2 >Darea(2)+Darea(4)
            dj = j + 1 - y_num;
        else
            dj = j + 1;
        end
        
    end
    % check x-axis boundary
    if Bsample(1)+Bsample(3)/2 +(i+1)*(1+padding)*Bsample(3)/2 >Darea(1)+Darea(3)
        di = i + 1 - x_num;
    else
        di = i + 1;
    end
end

%====== sub-dividing ======
[objs.rect, objs.shape] = sub_dividing(im, weig_map, tracker.valid_rect, Darea);

%====== save detected objects ======
if ~isnan(objs.rect(1, 1))    
    objs.num         = size(objs.rect, 1);  
    objs.color.model = get_color(double(im), objs.rect'); 
    objs.color.weig  = sum(sqrt(objs.color.model.*repmat(tracker.color.model, size(objs.rect, 1), 1)));
else
    objs.num         = 0;    
    objs.color       = [];
end




