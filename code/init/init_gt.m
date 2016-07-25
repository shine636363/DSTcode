function subS = init_gt(Seq)

% Initialise the test sequence
%
% Input:
%     - Seq           : general info. of sequences
% Output:
%     - subS.name     : sequence name
%     - subS.init_rect: [x, y, w, h]       
%     - subS.s_frames : path of sequences
%
%   Jingjing Xiao, 2016
%

subS.name      = Seq.name;

gt             = dlmread(sprintf('%s%s', Seq.path, Seq.gt));
subS.init_rect = round(gt(Seq.startFrame, :));

subS.len      = Seq.endFrame - Seq.startFrame + 1;
nz	          = strcat('%0',num2str(Seq.nz),'d'); % number of zeros in the name of image
subS.s_frames = cell(subS.len,1);
for idf = 1: subS.len
    image_no = Seq.startFrame + (idf-1);
    id       = sprintf(nz,image_no);
    subS.s_frames{idf} = strcat(Seq.path, id, '.' ,Seq.ext);
end