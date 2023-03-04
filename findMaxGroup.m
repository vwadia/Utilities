function [max_group, max_val] = findMaxGroup(fullmatrix, labels)
% This function takes in a psth with labels, finds the max value and returns which 
% group in the psth (i.e. which stimulus raster) has said highest value.
% Currenly this function returns a single max value and a single group - so
% in case of a tie the last max value group will be returned, which is fine
% for finding response latency
%
% INPUTS:
%     1. The raster
%     2. labels 
%     
% OUTPUTS:
%     1. max group - which label group had the max value
%     2. max value 
%
% vwadia Nov2021

groups = unique(labels);
max_val = 0;
max_group = [];

for gr = 1:length(groups)
    
    stimMatrix = fullmatrix(find(labels == gr), :);
%     mean = max(nanmean(stimMatrix))
    if max_val <= max(nanmean(stimMatrix))
        max_val = max(nanmean(stimMatrix));
        max_group = groups(gr);
    end
    
end
    