function rect = check_rect(img, rect)
% Check boundary of the bounding box
% Input :  
%     - img  : images
%     - rect : rectangle
% Output :  
%     - rect : adapted rectangle
%
%  Jingjing Xiao (shine636363@sina.com), 2016
%

w = size(img, 2);
h = size(img, 1);

if rect(1) < 1
    rect(1) = 1;
end

if rect(2) < 1
    rect(2) = 1;
end

if rect(1) + rect(3) > w
    rect(1) = w - rect(3);
end

if rect(2) + rect(4) > h
    rect(2) = h - rect(4);
end