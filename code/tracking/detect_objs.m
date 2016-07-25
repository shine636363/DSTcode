function objs = detect_objs(img, tracker, objs, para, idf)
% Input :  
%     - img     : images
%     - tracker : real target status
%     - objs    : target & distractors status
%     - para    : paramenters used for tracking
%     - idf     : id of frame
% Output :  
%     - objs    : detected objects(target & distractors)
%
% Contact:
%   Jingjing Xiao (shine636363@sina.com); Linbo Qiao (qiao.linbo@nudt.edu.cn)
%

%==== allocate sparse samples ====
samples = repmat(tracker{idf-1}.valid_rect(1:2),para.SS.num_s^2,1) + para.SS.s; 
samples = [samples repmat(tracker{idf-1}.valid_rect(3:4),para.SS.num_s^2,1)];

%==== 1st feature: color ====
Cfeat = get_color(double(img), samples');                                             % get the color feature 
CBha  = sum(sqrt(Cfeat.*repmat(tracker{idf-1}.color.model, para.SS.num_s^2, 1))')';   % use Bhattacharyya coefficients for color weight 
CWeig = exp((CBha)'*10/(0.01+std(CBha)));                                             % Gaussian tuning
CWeig = CWeig/sum(CWeig);                                                             % normalize the weight
if isnan(sum(CWeig)), CWeig = CBha';end

%==== 1st clustering: GMM =====
GMMdata  = [samples(:, 1:2)'; CWeig];  % Clustering data: pos & color weight
label    = emgm(GMMdata, 2);           % GMM clustering

CWeigLabel(1) = mean(CWeig(label == 1));
CWeigLabel(2) = mean(CWeig(label == 2));
[~,id]        = max(CWeigLabel);       % choose the foreground label
Fsample       = find(label == id);

%===== 2nd clustering: spatial =====
Slabel = distribution_cluster(samples(Fsample, :), tracker{idf-1}.valid_rect(3)/2, tracker{idf-1}.valid_rect(4)/2); 

%=== 3rd clustering ===
EstPos                       = [];
objs{idf}.rect               = [];
objs{idf}.shape.model_alphaf = []; 
objs{idf}.shape.model_xf     = []; 
objs{idf}.shape.weig         = [];
objs{idf}.color.model        = [];
objs{idf}.color.weig         = [];

if idf == 155
end


for i = 1: 1: max(Slabel)
    id_Slabel  = find(Slabel == i); 
    
    %=== 3rd clustering: Dense HOG & sub_dividing ===
    LCsample = samples(Fsample(id_Slabel),:);
    LCWeig   = CWeig(Fsample(id_Slabel));
    Darea = get_area(img, LCsample);% area for dense sampling
    Bsample = LCsample(find(LCWeig==max(LCWeig(:))), :);
    est_objs = dense_sampling(img, tracker{idf-1}, Darea, Bsample);

    % save estimation
    for num_i = 1: est_objs.num
        objs{idf}.rect(end+1, :)            = est_objs.rect(num_i, :);  
        objs{idf}.shape.model_alphaf{end+1} = est_objs.shape.model_alphaf{num_i};         
        objs{idf}.shape.model_xf{end+1}     = est_objs.shape.model_xf{num_i};              
        objs{idf}.shape.weig(end+1)         = est_objs.shape.weig(num_i);
        objs{idf}.color.model(end+1, :)     = est_objs.color.model(num_i, :);
        objs{idf}.color.weig(end+1)         = est_objs.color.weig(num_i);
    end
end
objs{idf}.num = size(objs{idf}.rect, 1);

%===== 0cclusion reasoning from appearacne ======
for i = 1: size(objs{idf}.rect,1)
    objs{idf}.occ_flag(i) = 0;
    % TO DO: add reasoning from pure appearance
end

%% visualization for debugging
if 0
    figure(1)
    refresh;
    imshow(uint8(img))
    % particles' region
    for i = 1: para.SS.num_s^2
        if label(i) == id  
            % foreground particles
             rectangle('Position',samples(i, :), 'LineWidth',2,'EdgeColor','y')
        else % background particles
             rectangle('Position',samples(i, :), 'LineWidth',1,'EdgeColor','b')
        end
        hold on
    end
    
    %     % color estimation
    %     for i = 1: size(EstPos, 1)
    %         rectangle('Position',EstPos(i, :), 'LineWidth',2,'EdgeColor','g')
    %     end
    
    % shape & color estimation
    for i = 1: size(objs{idf}.rect,1)
        rectangle('Position',objs{idf}.rect(i, :), 'LineWidth',4,'EdgeColor','r')
    end
    
    %  rectangle('Position',mean_pos, 'LineWidth',3,'EdgeColor','g')
    hold on
% pause
% text(25,60, ['Score:',num2str(res_dep)],'fontsize',30,'fontweight','bold','color',[0 1 0])
end
