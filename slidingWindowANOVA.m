function [multMatrix] = slidingWindowANOVA(raster, order, offsets, alpha, useBothOffsets, subRasterLengths, binsize, stepsize, comparisonType)
% this function takes in a matrix and an order
% carves out the stimuli based on the order and computes a sliding window
% anova - saving all the bins where the difference is significant
% INPUTS:
%     1. matrix: in trialsxtime
%     2. order: order of stimuli
%     3. binsize: what size window to test?
%     4. stepsize: how much to slide over each time?
%     5. alpha: significance level
%     6. offsets: So one can calculate stimOn time
%     7. comparisonType:
%         a - no sliding window (with option to handle different lengths)
%         b - sliding window compare bins starting after stimOn (avonva1 and compare significance)
%         c - same as 2 except computing omega squared at each window and findind the time of its peak 
% OUTPUT:
%     1. A cell array where each cell is an array of significant timebins for that
%       stim (stim = member of order)
% vwadia Jan2021
%  edited vwadia Oct2022 - added omegasquared functinoality
if nargin == 4, useBothOffsets = 0; subRasterLengths = []; comparisonType = 1; stepsize = []; binsize = []; end
if nargin == 5, comparisonType = 1; subRasterLengths = []; stepsize = []; binsize = []; end
if nargin == 6, comparisonType = 1; stepsize = []; binsize = []; end

if ~isempty(subRasterLengths)
    if comparisonType ~= 1
        disp('Error: this makes no sense. Sliding windows across unequal rasters is not possible');
        keyboard
    elseif length(unique(subRasterLengths)) ~= length(unique(order))
        disp('Error: Categories are incorrect');
        keyboard
    end
end

if ~isempty(binsize)
    if binsize > size(raster, 2)
        disp('Error: need smaller binsize');
        keyboard
    end   
    numBins = length(offsets(1)+stepsize:stepsize:size(raster, 2)-binsize);
    p_sel = zeros(numBins, 1);      
end

labels = order;
labelTypes = unique(labels);
multMatrix = {};
metaData = [];
sigCtr = 1;
binCtr = 1;
% type 1 - no sliding window 
if comparisonType == 1
    % carve out simtONAll appropriately
    if isempty(subRasterLengths)
        if ~useBothOffsets
            stimONAll = mean(raster(:, offsets(1):end), 2);
        else
            stimONAll = mean(raster(:, offsets(1):end-offsets(2)), 2);        
        end
    else
        stimONAll = [];
        for st = 1:length(labelTypes)
            subRas = raster(find(labels == labelTypes(st)), :);
            subVec = mean(subRas(:, offsets(1):offsets(1)+subRasterLengths(st)), 2);
            stimONAll = [stimONAll; subVec];
        end
        [labels, ~] = sort(labels); % critical step, the above procedure arranges the values in sorted order
    end
    
    [p_sel, ~, stats_sel] = anova1(stimONAll, labels, 'off');
    if p_sel < alpha
        c = multcompare(stats_sel, 'Display', 'off');
        % save the significant rows
        for row = 1:size(c, 1)
            if c(row, end) < alpha
                metaData = [metaData; c(row, :)];
            end
        end
        multMatrix{sigCtr, 1} = p_sel(binCtr);
        multMatrix{sigCtr, 2} = 'full';
        multMatrix{sigCtr, 3} = metaData;
    end
    
elseif comparisonType == 2
    % type 2 -  compare post stimON only
    windowBegin = abs(offsets(1));
    if ~useBothOffsets
        windowEnd = size(raster, 2)-binsize;
    else
        windowEnd = size(raster, 2)-binsize-offsets(2);
    end
    for window = windowBegin:stepsize:windowEnd
        stimONAll = raster(:, window:window+binsize);
        % run Anova
        [p_sel(binCtr), ~, stats_sel(binCtr)] = anova1(mean(stimONAll, 2), labels, 'off');
        % check for selectivity
        if p_sel(binCtr) < alpha
            c = multcompare(stats_sel(binCtr), 'Display', 'off');
            % save the significant rows
            for row = 1:size(c, 1)
                if c(row, end) < alpha
                    metaData = [metaData; c(row, :)];
                end
            end
            multMatrix{sigCtr, 1} = p_sel(binCtr);
            multMatrix{sigCtr, 2} = window;
            multMatrix{sigCtr, 3} = metaData;
            sigCtr = sigCtr +1;
        end
        binCtr = binCtr+1;
    end
    
    % type 3 - compute imegasquared in each bin and find peak time
elseif comparisonType == 3
    windowBegin = abs(offsets(1));
    if ~useBothOffsets
        windowEnd = size(raster, 2)-binsize;
    else
        windowEnd = size(raster, 2)-binsize-offsets(2);
    end
    for window = windowBegin:stepsize:windowEnd
        stimONAll = raster(:, window:window+binsize);
        % run Anova
        [p_sel(binCtr), ~, stats_sel(binCtr)] = anova1(mean(stimONAll, 2), labels, 'off');
        % check for selectivity
        if p_sel(binCtr) < alpha
           
            multMatrix{sigCtr, 1} = p_sel(binCtr);
            multMatrix{sigCtr, 2} = window;
            multMatrix{sigCtr, 3} = Utilities.Effectsize.calcOmiga2Fast(mean(stimONAll, 2), labels);
            sigCtr = sigCtr +1;
        end
        binCtr = binCtr+1;
    end
end



