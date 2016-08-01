function rest = run_DST(Seq)

%% DST: Distractor Supported Tracker
% Input:
%     - Seq.name     : sequence name
%     - Seq.init_rect: [x, y, w, h]
%     - Seq.s_frames : path of sequences
% Output:
%     - rest: tracking results
%
%   It is provided for educational/research purpose only.
%   If you find the software useful, please consider cite our paper. 
%
%   @inproceedings{Tracking2016Xiao,
%     title={Distractor-supported single target tracking in extremely cluttered scenes},
%     Author = {Xiao, Jingjing and Qiao, Linbo and Stolkin, Rustam and Leonardis, Ale\v{s}},
%     booktitle = {ECCV},
%     Year = {2016}
%   }
%
% Contact:
%   Jingjing Xiao (shine636363@sina.com); Linbo Qiao (qiao.linbo@nudt.edu.cn)
%

warning off
addpath(genpath('./'));
if nargin < 1, Seq = init_seq; en_save = 1; else en_save = 0; end

for ids = 1: 1: length(Seq)
    if nargin < 1, subS = init_gt(Seq{ids}); else subS = Seq; end
    init_para;

    if en_fps, time_start  = tic; time_elapse = 0; end
    for idf = 2:subS.len
        fprintf('%d_%s frame : %d/%d\n', ids, subS.name, idf, subS.len );
        img =  imread(subS.s_frames{idf});
        if size(img, 3) == 1, img = cat(3,img,img,img); end
        
        %========= tracking =========
        objs            = detect_objs(img, tracker, objs, para, idf);
        [tracker, objs] = global_dynamic(tracker, objs, idf);
        tracker         = update_model(img, tracker, objs, idf);
        % save resluts
        if isnan(tracker{idf}.rect), rest(idf, :) = rest(idf-1, :); else rest(idf, :) = tracker{idf}.rect';   end

        %======== fps & disp =========
        if en_fps, time_elapse = toc(time_start);  end
        % show results
        if en_disp
            imshow(uint8(img))
            hold on
            if ~isnan(tracker{idf}.rect)
                rectangle('Position',rest(idf, :), 'LineWidth',3,'EdgeColor','r')
            else
                text(25,25, ['Occlusion'],'fontsize' ,25,'fontweight' ,'bold' ,'color' ,'r' )
            end
            pause(0.01)
        end
    end
    fprintf('time elapse: %.2f sec, speed: %.2f frames/sec \n',time_elapse, (subS.len - 1)/time_elapse);
    if en_save,  dlmwrite(sprintf('../DSTresults/DST%s.txt', subS.name), rest,'newline', 'pc','precision','%.1f'); end
end
