
function [screeningData] = responsivityCheck(windowBegin, windowEnd, windowLength, offset, strctCells, screeningData, alpha)
testWindowBegin = windowBegin;
testWindowEnd = windowEnd;
baselineWindowend = testWindowBegin - offset;
baselineWindowBegin = baselineWindowend - windowLength;

if baselineWindowBegin < 1
    baselineWindowBegin = 1;
end

screeningData.ranksum = {};
sigCtrRanksum = 1;
sigCtrttest = 1;

for cellIndex = l(strctCells)
    data = screeningData.psth{cellIndex, 1}; % raster
    
    for i = 1:length(screeningData.imageIDs)
        stimRaster = data(find(screeningData.sortedOrder == screeningData.imageIDs(i)), :);
        baselinebin = mean(stimRaster(:, baselineWindowBegin:baselineWindowend), 2);
        testbin = mean(stimRaster(:, testWindowBegin:testWindowEnd), 2);
        [pr, hr] = ranksum(baselinebin, testbin, 'Alpha', alpha);
        [ht, pt] = ttest(testbin, baselinebin, 'Alpha', alpha);
        if pr < alpha
            screeningData.ranksum{sigCtrRanksum, 1} = pr;
            screeningData.ranksum{sigCtrRanksum, 2} = strctCells(cellIndex).brainArea;
            screeningData.ranksum{sigCtrRanksum, 3} = strctCells(cellIndex).Name;
            screeningData.ranksum{sigCtrRanksum, 4} = screeningData.imageIDs(i);
            screeningData.ranksum{sigCtrRanksum, 5} = i;
            sigCtrRanksum = sigCtrRanksum +1;
        elseif pt < alpha
            screeningData.ttest{sigCtrttest, 1} = pt;
            screeningData.ttest{sigCtrttest, 2} = strctCells(cellIndex).brainArea;
            screeningData.ttest{sigCtrttest, 3} = strctCells(cellIndex).Name;
            screeningData.ttest{sigCtrttest, 4} = screeningData.imageIDs(i);
            screeningData.ttest{sigCtrttest, 5} = i;
            sigCtrttest = sigCtrttest + 1;
        end
    end
end
end