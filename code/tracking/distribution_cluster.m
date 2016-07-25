function Slabel = distribution_cluster(pos, thresh_x, thresh_y)
% Input :  
%     - pos      : distribution of samples
%     - thresh_x : spatial threshold for x-axis
%     - thresh_y : spatial threshold for y-axis
% Output :  
%     - Slabel   : Clutering label w.r.t. spatial distribution
%
%  Jingjing Xiao (shine636363@sina.com), 2016
%

%=== initialisation ===
num        = size(pos, 1);
label      = zeros(num, 1);
Slabel     = zeros(num, 1);
label_x    = zeros(num, num);
label_y    = zeros(num, num);
dist_x     = abs(repmat(pos(:, 1), 1, num) - repmat(pos(:, 1)', num, 1));
dist_y     = abs(repmat(pos(:, 2), 1, num) - repmat(pos(:, 2)', num, 1));

label_x(dist_x < thresh_x) = 1;
label_y(dist_y < thresh_y) = 1;
label_xy = (label_x + label_y)/2;
label_xy(label_xy < 1) = 0;

%=== spatial graph ===
label_count = 1;
for i = 1: 1: num-1
    if sum(label_xy(i, i+1:end)) == 0 % no link
        if label(i) == 0 % no label -- add label
            label(i) = label_count;
            label_count = label_count + 1;
        end
    else % has link
        id = find(label_xy(i, i:end) == 1); 
        if sum(label(id+i-1)) == 0 % no label
            label(id+i-1) = repmat(label_count, 1, length(id));
            label_count = label_count + 1;
        else % with label
            swap_label = label(id+i-1);
            swap_label(swap_label==0) = max(label(id+i-1));
            label(id+i-1) = swap_label;
            uni_label = unique(label(id+i-1));
            id_num = length(uni_label);% merge all labels
            for j = 1:1:id_num
                label(label == uni_label(j)) = max(label(id+i-1));
            end
        end
    end
end

%=== squential number ===
label_id = unique(label); 
for i = 1:1:length(label_id)
    Slabel(label == label_id(i)) = i;
end
