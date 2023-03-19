function [group, val] = findMaxGroup(fullmatrix, labels, neg)
% This function takes in a psth with labels, finds the max value and returns which 
% group in the psth (i.e. which stimulus raster) has said highest value.
% Currenly this function returns a single max value and a single group - so
% in case of a tie the last max value group will be returned, which is fine
% for finding response latency
%
% INPUTS:
%     1. The raster
%     2. labels 
%     3. neg - if you want to find the min group
%     
% OUTPUTS:
%     1. max group - which label group had the max value
%     2. max value 
%
% vwadia Nov2021
% edited March2023 to include negative option
if nargin == 2, neg = false; end

groups = unique(labels);
max_val = 0;
max_group = [];

min_val = Inf;
min_group = [];


for gr = 1:length(groups)
    
    stimMatrix = fullmatrix(find(labels == gr), :);
    %     mean = max(nanmean(stimMatrix))
    if ~neg
        if max_val <= max(nanmean(stimMatrix))
            max_val = max(nanmean(stimMatrix));
            max_group = groups(gr);
        end
        group = max_group;
        val = max_val;
        
    else
        if min_val >= min(nanmean(stimMatrix))
            min_val = min(nanmean(stimMatrix));
            min_group = groups(gr);
        end
        group = min_group;
        val = min_val;
        
    end
end

    