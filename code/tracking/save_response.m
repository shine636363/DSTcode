function  weig_map = save_response(weig_map, response, pos, cell_size, sz)
% Input :  
%     - weig_map  : the overall map of response
%     - response  : local map of response
%     - cell_size : the size of cell
%     - sz        : size of local map
% Output :  
%     - weig_map  : updated overall map of response
%
%  Jingjing Xiao (shine636363@sina.com), 2016
%

for i = 1: 1: sz(1)
    for j = 1: 1: sz(2)   
        
        resp = response(i, j);
        
        % wrap around to negative half-space of axis
        if i > sz(1) / 2, 
            pi = i - sz(1);
        else
            pi = i;
        end
        if j > sz(2) / 2, 
            pj = j - sz(2);
        else
            pj = j;
        end
        new_pos = pos + cell_size * [pi - 1, pj - 1];
        
        % check boundary & transmit the response
        if new_pos(1)>=1 && new_pos(2)>=1 && new_pos(1)<=size(weig_map, 1) && new_pos(2)<=size(weig_map, 2)
            weig_map(new_pos(1), new_pos(2)) = resp;
        end
    end
end

