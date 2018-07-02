function pairList = pairs(list)
%RANDOMIZE - randomly create condition table
%   Detailed explanation goes here
    pairList = [];
    for i = 1:size(list,1)
        if i<size(list,1)
            if list(i,3) == 0 && list(i+1, 3) == 0
                pairList = [pairList 1];
            else
                pairList = [pairList 0];
            end
        end
    end 
end