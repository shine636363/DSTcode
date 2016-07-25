% Initialise parameters for tracking
%
% Contact:
%   Jingjing Xiao (shine636363@sina.com); Linbo Qiao (qiao.linbo@nudt.edu.cn)
% 

%===== disp & fps =====
en_disp     = 0; % display images
en_fps      = 1; % compute fps

%==== read image ====
img = imread(subS.s_frames{1});
if size(img, 3) == 1,  img = cat(3,img,img,img);  end

%==== Sparse sampling ====
SS.num_s = 19;   % the number of sparsely distributed samples : DS.num_s^2
init_len = 15;   % the length of initial search region
len      = max(round(init_len*size(img,1)*size(img,2)/720/1280),2);  % adapt the length of search region according to the image size
SS.s     = [repmat(len*[-9:1:9],1,SS.num_s)' reshape(((len*[-9:1:9]')*ones(1,SS.num_s))',SS.num_s^2,1)]; % matrix of samples
para.SS  = SS;   

%==== GDC: global dynamic constrain ===
GDC.num_frames2train = 5; % Number of frames used to train the model; -1 for don't train the model, just return the first rect
GDC.lambda           = 3; 
para.GDC             = GDC;

%==== tracker ====
tracker                 = [];
tracker{1}.rect         = subS.init_rect;                           % load the initialization of bounding box
tracker{1}.valid_rect   = tracker{1}.rect;                          % valid results (no occlusion)
tracker{1}.color.model  = get_color(double(img), tracker{1}.rect'); % initialize the color feature
tracker{1}.color.weig   = 1;                                        % tracker's color weight
tracker{1}.shape        = init_shape(img, tracker{1}.rect);         % initialize the shape feature/weight
tracker{1}.pos_relative = [0 0];                                    % initialize the relative position
tracker{1}.id           = 1;                                        % corresponding id of the target among objects 

%==== objects: target & distractors =====
objs                 = [];
objs{1}.rect         = tracker{1}.rect;
objs{1}.color        = tracker{1}.color;
objs{1}.shape        = tracker{1}.shape;
objs{1}.dynamic.weig = 1;
objs{1}.istracker    = 1;
objs{1}.num          = 1;

%==== save results ====
rest       = zeros(subS.len, 4);
rest(1, :) = tracker{1}.rect';