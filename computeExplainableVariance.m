function expableVar = computeExplainableVariance(psth, order, respLat, stimDur, offset)
% Takes in a raster and order, sum the responses per trial (trials*images x 1) 
% Then split this in have per image so you get two equal sized vectors of (trials*images)/2 x 1 and 
% then compute the correlation between those two to get r
%
% computes the explainable variance via formula
% r' = 2*r/(1+r)
% Inputs:
%     1. psth
%     2. order
%     3. pre-computed response latency (for response calc) 
% Outputs
%     1. explainable variance
%
% vwadia April2021

fullRaster = psth{1, 1};
stimuli = unique(order);
windowLength = ceil(stimDur);

vec1 = [];
vec2 = [];


for i = 1:length(stimuli)

    stimRas = fullRaster(find(order == stimuli(i)), :);
    if offset+respLat+windowLength > size(stimRas, 2)
        stimResp = sum(stimRas(:, offset+respLat:end), 2);
    else
        stimResp = sum(stimRas(:, offset+respLat:offset+respLat+windowLength), 2);
    end
    % if the size is odd, even it out
    if mod(size(stimResp, 1), 2) ~= 0
        x = median(stimResp);
        stimResp = [stimResp; x];
    end
    
    inds = 1:length(stimResp);
    halfInds = inds(randperm(length(stimResp),floor(length(stimResp)/2)));
    otherHalfInds = setdiff(inds, halfInds);
    % split
    halfTrials = stimResp(halfInds);
    otherHalfTrials = stimResp(otherHalfInds);
    
    % compute average - Liang input Jan 2022
    hT = mean(halfTrials);
    ohT = mean(otherHalfTrials);
    
    % make vectors 
    vec1 = [vec1; hT];
    vec2 = [vec2; ohT];
    
end

r = corr(vec1, vec2);
expableVar = (2*r/(1+r))^2;


end