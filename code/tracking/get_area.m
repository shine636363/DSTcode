function BB = get_area(img, samples)
% Input :  
%     - img     : images
%     - samples : all samples [X, Y, W, H]
% Output :  
%     - BB      : rectangle boundardy of all samples
%
%  Jingjing Xiao (shine636363@sina.com), 2016
%

BB = round([min(samples(:,1)), min(samples(:,2)), max(samples(:,1))+ samples(1,3)-min(samples(:,1)), max(samples(:,2))+ samples(1,4)-min(samples(:,2))]);
BB = check_rect(img, BB);