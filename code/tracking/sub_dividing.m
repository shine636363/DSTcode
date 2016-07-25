function [rect, feat] = sub_dividing(im, weig_map, target_rect, Darea)
% INPUT:
%     - im       : images
%     - weig_map : map of weigth
%     - target_rect: previous target position
% OUTPUT:
%     - rect : positions of objects
%     - feat : features of objects
%
% Contact:
%   Jingjing Xiao (shine636363@sina.com); Linbo Qiao (qiao.linbo@nudt.edu.cn)
%

% keep consistent coordinates with KCF
cell_size                 = 4;
lambda                    = 1e-4; %regularization
padding                   = 1.5;  %extra area surrounding the target
output_sigma_factor       = 0.1;  %spatial bandwidth (proportional to target)
features.gray             = false;
features.hog              = true;
features.hog_orientations = 9;
kernel.sigma              = 0.5;

obj_pos                   = [nan nan];
feat                      = [];

target_sz = [target_rect(1,4), target_rect(1,3)];
resize_image = (sqrt(prod(target_sz)) >= 100);  % diagonal size >= threshold
Rarea =  target_rect;
if size(im,3) > 1, im = rgb2gray(uint8(im)); end
if resize_image,
    target_sz = floor(target_sz / 2);
    Darea = floor(Darea / 2);
    Rarea = floor(target_rect/2);
    im = imresize(im, 0.5);  
end

% count impact from previous feature
weig_map(1:min(Darea(2), end),:) = 0;
weig_map(:,1:min(Darea(1),end)) = 0;
weig_map(:,Darea(1)+Darea(3): end) = 0;
weig_map(Darea(2)+Darea(4): end,:) = 0;
weig_map(weig_map(:)<0) = 0;

%window size, taking padding into account
window_sz = floor(target_sz * (1 + padding));
%create regression labels, gaussian shaped, with a bandwidth
%proportional to target size
output_sigma = sqrt(prod(target_sz)) * output_sigma_factor / cell_size;
yf = fft2(gaussian_shaped_labels(output_sigma, floor(window_sz / cell_size)));
%store pre-computed cosine window
cos_window = hann(size(yf,1)) * hann(size(yf,2))';	

%================ iteratively cluster sub-diving ==============
i = 0;
while 1    
    i = i+1;
    if sum(weig_map(:))==0 % no matched area
        break
    end    
    mean_pos(1)          = floor(sum([1: size(weig_map, 1)]*weig_map/sum(weig_map(:))));
    mean_pos(2)          = floor(sum(weig_map*[1: size(weig_map, 2)]')/sum(weig_map(:)));
    [mode_pos(1), mode_pos(2)] = find(weig_map==max(weig_map(:)), 1);  
    
    %obtain a subwindow for training at newly estimated target position
    obj_pos(i,:) = mode_pos;
    patch  = get_subwindow(im, mode_pos, window_sz);
    xf     = fft2(get_features(patch, features, cell_size, cos_window));
    kf     = gaussian_correlation(xf, xf, kernel.sigma);
    alphaf = yf ./ (kf + lambda);   %equation for fast training
    
    feat.model_xf{i}     = xf;
    feat.model_alphaf{i} = alphaf; 
    feat.weig(i)         = max(weig_map(:));

    if abs(mode_pos(1)-mean_pos(1))<=target_sz(1)/2&& abs(mode_pos(2)-mean_pos(2))<=target_sz(2)/2
        break;
    end
    
    % using the region in another plane
    new_map = zeros(size(weig_map, 1), size(weig_map, 2));
    if mode_pos(1)>mean_pos(1)
        new_map(1: mode_pos(1)-target_sz(1)/2, :) = weig_map(1: mode_pos(1)-target_sz(1)/2, :);
    else
        new_map(mode_pos(1)+target_sz(1)/2: end, :) = weig_map(mode_pos(1)+target_sz(1)/2: end, :);
    end
    
    if mode_pos(2)>mean_pos(2)
        new_map(:, 1: mode_pos(2)-target_sz(2)/2) = weig_map(:, 1: mode_pos(2)-target_sz(2)/2);
    else
        new_map(:, mode_pos(2)+target_sz(2)/2: end) = weig_map(:, mode_pos(2)+target_sz(2)/2:end);
    end
    weig_map = new_map;
end

%======== convert back to real coordinates ===== 
if resize_image,
    obj_pos = obj_pos*2;
end
rect = [obj_pos(:, [2, 1]) - repmat(target_rect(3:4)/2, i, 1), repmat(target_rect(3:4), i, 1)];
