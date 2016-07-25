function [shape] = init_shape(im, ground_truth)
    % HOG (shape) feature from the correlation filter
    % 
    % High-Speed Tracking with Kernelized Correlation Filters
    % J. F. Henriques, R. Caseiro, P. Martins, J. Batista, TPAMI 2015
    % 
    % edited by Jingjing Xiao, 2016
    
    % parameters
    padding             = 1.5;  %extra area surrounding the target
	lambda              = 1e-4; %regularization
	output_sigma_factor = 0.1;  %spatial bandwidth (proportional to target)
    cell_size           = 4;
    kernel.sigma        = 0.5;
    features.gray       = false;
    features.hog        = true;
    features.hog_orientations = 9;

    % set initial position and size
	target_sz = [ground_truth(1,4), ground_truth(1,3)];
	pos = [ground_truth(1,2), ground_truth(1,1)] + floor(target_sz/2);

    %% scale the size
    % if the target is large, lower the resolution, we don't need that much
	% detail
	resize_image = (sqrt(prod(target_sz)) >= 100);  %diagonal size >= threshold
    if size(im,3) > 1, im = rgb2gray(uint8(im)); end
    
	if resize_image,
		pos = floor(pos / 2);
		target_sz = floor(target_sz / 2);
        im = imresize(im, 0.5);
    end

    %% get feature    
	% window size, taking padding into account
	window_sz = floor(target_sz * (1 + padding));
    
	%create regression labels, gaussian shaped, with a bandwidth
	%proportional to target size
	output_sigma = sqrt(prod(target_sz)) * output_sigma_factor / cell_size;
	yf = fft2(gaussian_shaped_labels(output_sigma, floor(window_sz / cell_size)));

	%store pre-computed cosine window
	cos_window = hann(size(yf,1)) * hann(size(yf,2))';	
    
    %obtain a subwindow for training at newly estimated target position
    patch = get_subwindow(im, pos, window_sz);
    xf = fft2(get_features(patch, features, cell_size, cos_window));
    
    %Kernel Ridge Regression, calculate alphas (in Fourier domain)
    kf = gaussian_correlation(xf, xf, kernel.sigma); % 
    alphaf = yf ./ (kf + lambda);   %equation for fast training
    
    % first frame, train with a single image
    shape.model_alphaf = alphaf;
    shape.model_xf     = xf;
    shape.weig         = 1;
    
end
