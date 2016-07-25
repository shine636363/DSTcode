function [OutRect, OutShape, weig_map] = get_shape(im, target_rect, target_shape, weig_map)
% INPUT:
%     img             -- image
%     target_rect     -- rectangle of the target
%     target_shape    -- shape reference model
% OUTPUT:
%     OutRect         -- correlation filter based results
%     OutShape        -- observed features
%     weig_map        -- the map of weights
%
%    Jingjing Xiao (shine636363@sina.com), 2016
%        

    %% parameters
    padding             = 1.5;  %extra area surrounding the target
	lambda              = 1e-4; %regularization
	output_sigma_factor = 0.1;  %spatial bandwidth (proportional to target)
    cell_size           = 4;
    kernel.sigma        = 0.5;
    features.gray       = false;
    features.hog        = true;
    features.hog_orientations = 9;
    
    %% re-scale the size
    % if the target is large, lower the resolution, we don't need that much
	% detail
    
    % set initial position and size
	target_sz = [target_rect(1,4), target_rect(1,3)];
	pos = [target_rect(1,2), target_rect(1,1)] + floor(target_sz/2);
    
	resize_image = (sqrt(prod(target_sz)) >= 100);  %diagonal size >= threshold
    if size(im,3) > 1, im = rgb2gray(uint8(im)); end
	if resize_image,
		pos = floor(pos / 2);
		target_sz = floor(target_sz / 2);
        im = imresize(im, 0.5);
    end
    if isempty(weig_map)
        weig_map = zeros(size(im, 1), size(im, 2));
    end

    %window size, taking padding into account
	window_sz = floor(target_sz * (1 + padding));
    
    %create regression labels, gaussian shaped, with a bandwidth
	%proportional to target size
	output_sigma = sqrt(prod(target_sz)) * output_sigma_factor / cell_size;
	yf = fft2(gaussian_shaped_labels(output_sigma, floor(window_sz / cell_size)));

	%store pre-computed cosine window
	cos_window = hann(size(yf,1)) * hann(size(yf,2))';	
    
    %% feature matching
    %obtain a subwindow for detection at the position from last
    %frame, and convert to Fourier domain (its size is unchanged)
    patch = get_subwindow(im, pos, window_sz);
    zf = fft2(get_features(patch, features, cell_size, cos_window));
    
    %calculate response of the classifier at all shifts
    kzf = gaussian_correlation(zf, target_shape.model_xf, kernel.sigma);    
    response = real(ifft2(target_shape.model_alphaf .* kzf));  %equation for fast detection
    
    % save all response
    weig_map = save_response(weig_map, response, pos, cell_size, size(zf));
    
    %target location is at the maximum response. we must take into
    %account the fact that, if the target doesn't move, the peak
    %will appear at the top-left corner, not at the center (this is
    %discussed in the paper). the responses wrap around cyclically.
    [vert_delta, horiz_delta] = find(response == max(response(:)), 1);
    if vert_delta > size(zf,1) / 2,  %wrap around to negative half-space of vertical axis
        vert_delta = vert_delta - size(zf,1);
    end
    if horiz_delta > size(zf,2) / 2,  %same for horizontal axis
        horiz_delta = horiz_delta - size(zf,2);
    end
    pos = pos + cell_size * [vert_delta - 1, horiz_delta - 1];
    
    %obtain a subwindow for training at newly estimated target position
    patch  = get_subwindow(im, pos, window_sz);
    xf     = fft2(get_features(patch, features, cell_size, cos_window));
    kf     = gaussian_correlation(xf, xf, kernel.sigma);
    alphaf = yf ./ (kf + lambda);   %equation for fast training
    
    %% scale back
    if resize_image,
		pos = pos * 2;
        target_sz = [target_rect(1,4), target_rect(1,3)];
    end
    
    %% output
	OutShape.model_xf     = xf;
    OutShape.model_alphaf = alphaf;
    OutShape.weig         = max(response(:));
    OutRect               = [pos(:, [2, 1]) - target_sz([2, 1])/2, target_sz([2, 1])];
            
end