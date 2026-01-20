function trialsLFP_New = correctBadCh(trialsLFP, window, badCh)

tIdx = linspace(window(1), window(2), size(trialsLFP{1}, 2));
[~, baseIdx] = findWithinInterval(tIdx', [window(1), 0]);
trialsLFP = cellfun(@(x) x./SE(x(:, baseIdx), 2), trialsLFP, "UniformOutput", false);
temp = changeCellRowNum(trialsLFP);

badCh  = sort(badCh);
idx    = [1, find(diff(badCh) > 1)+1]';
idx    = [idx, [idx(2:end)-1; length(badCh)]];
if ~isempty(badCh)
    badCHs = rowFcn(@(x) badCh(x(1): x(2)), idx, "UniformOutput", false); 
    for badIdx = 1 :length(badCHs)
        A = temp{badCHs{badIdx}(1)-1, 1};
        B = temp{badCHs{badIdx}(end)+1, 1};
        k = (badCHs{badIdx}(end)+1) - (badCHs{badIdx}(1)-1) + 1;
        t = linspace(0,1,k);                    % 插值系数 [0, 1]
        matrices = A .* reshape(1-t,1,1,[]) + B .* reshape(t,1,1,[]);
        for mIndex = 1 : size(matrices, 3)
            temp{badCHs{badIdx}(1)-2+mIndex, 1} = matrices(:, :, mIndex);
        end
    end
end
trialsLFP_New = changeCellRowNum(temp);













