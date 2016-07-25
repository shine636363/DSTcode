function weig = get_dist(a_rect,  b_rect)
% Input :  
%     - a_rect : target a position
%     - b_rect : target b position
% Output :  
%     - weig    : weigths w.r.t. distance
%
%  Jingjing Xiao (shine636363@sina.com), 2016
%

a_num = size(a_rect, 1);
b_num = size(b_rect, 1);

%=== x-axis ===
a_x = a_rect(:, 1);
b_x = b_rect(:, 1);
a_x_array = repmat(a_x, 1, b_num);
b_x_array = repmat(b_x', a_num, 1);

%=== y-axis ===
a_y = a_rect(:, 2);
b_y = b_rect(:, 2);
a_y_array = repmat(a_y, 1, b_num);
b_y_array = repmat(b_y', a_num, 1);

%=== final dist ===
dist = abs(a_x_array - b_x_array) + abs(a_y_array - b_y_array);
weig = exp(-dist/100);

