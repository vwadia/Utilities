function sigBins = slidingWindowRanksum(raster, order, binsize, stepsize, alpha, offsets, comparisonType)
% this function takes in a matrix and an order
% carves out the stimuli based on the order and computes a sliding windo
% rankum - saving all the bins where the difference is significant
% INPUTS:
% matrix: in trialsxtime
% order: order of stimuli
% binsize: what size window to test?
% comparisonType:
% 1 - compare just 1 bin pre and post stimOn
% 2 - compare bins starting after stimOn vs baseline
% 3 - compare bins starting from the beginning of matrix vs the mean of the whole period
% offsets: if comparisonType == 1 you need to know stimOn point
% OUTPUT:
% A cell array of significant time bins per stimulus.
% It is important to note that in comparisonType 2 & 3 p values are
% screened by false discovery rate
% vwadia Dec2020
if nargin == 5, offsets = []; comparisonType = 3; end
if nargin == 6, comparisonType = 2; end

stim = unique(order);
if binsize > size(raster, 2)
    disp('Error: need smaller binsize');
    return
end
sigBins = cell(length(stim), 1);
FDRrate = 0.01;
% set up start and end points correctly
if comparisonType == 2 || comparisonType == 3
    if comparisonType == 2
        windowBegin = offsets(1);
    elseif comparisonType == 3
        windowBegin = 1;
    end
    windowEnd = size(raster, 2)-binsize;
    timeBinArray = [windowBegin:stepsize:windowEnd]';
    pVals = zeros(length(windowBegin:stepsize:windowEnd), 1);
    FDR = zeros(length(pVals), 1);
    
    if ~isequal(length(timeBinArray), length(FDR))
        disp('Error: check lengths of timeBinArray');
        keyboard
    end
end


for ii = l(stim)
    binCtr = 1;

    % carve out stimuli
    stimTOUse = find(order == stim(ii));
    amatrix = raster(stimTOUse, :);
    
    sigCtr = 1;
    if comparisonType == 1
        window = offsets(1) + stepsize;
        baselineBin = mean(amatrix(:, (offsets(1)-binsize):offsets(1)), 2);
        testBin = mean(amatrix(:, window:window+binsize), 2);
        [p, ~] = ranksum(baselineBin, testBin, 'Alpha', alpha);
        if p < alpha
            sigBins{ii}(sigCtr, 1) = window;
            sigBins{ii}(sigCtr, 2) = p;
            sigCtr = sigCtr+1;
        end
    elseif comparisonType == 2 || comparisonType == 3 % other comparison types
%         baselineBin = mean(amatrix(:, (offsets(1)-binsize):offsets(1)), 2);
        baselineBin = mean(amatrix(:, 1:offsets(1)-1), 2); % mean across entire baseline period
        for window = windowBegin:stepsize:windowEnd
            testBin = mean(amatrix(:, window:window+binsize), 2);
            [p, ~] = ranksum(baselineBin, testBin, 'Alpha', alpha);
            pVals(binCtr, 1) = p; % for each stim
            binCtr = binCtr + 1;
        end
        if ~isempty(find(pVals < alpha))
%             % checking false discovery rate
            FDR = mafdr(pVals);
            for q = 1:length(FDR)
                if pVals(q) < alpha %&& FDR(q) < FDRrate 
                    sigBins{ii, 1}(sigCtr, 1) = timeBinArray(q)-offsets(1);
                    sigBins{ii, 1}(sigCtr, 2) = pVals(q);
                    sigCtr = sigCtr+1;
                end
            end
        end
    end
end

