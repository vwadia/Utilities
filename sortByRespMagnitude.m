function [magOrd] = sortByRespMagnitude(order, labels, psth, offset, stimDur, timelimits)
% Takes in the order, and the raster for a given cell
% cycles through the order and computes the spike counts for each stim in a vector
% Then sorts that vector by magnitude, sorts the inputted order by those indices and returns
% Inputs:
%     1. Order (Num images * trials)
%     2. labels (image IDs)
%     3. raster
%     4. offset (either stimON time or computed response latency of the cell)
%     5. stimulus duration in ms (so window can be chosen as repLat+stimDur)
% Outputs:
%     1. order (length(imageIDs)) sorted by response magnitude
% vwadia/March2021
if nargin == 5, timelimits = []; end

assert(~isempty(offset) || ~isempty(timelimits), 'Need either a response latency or a fixed window for spike collection');

if ~isempty(timelimits)
    fixedOffset = -timelimits(1)*1e3+50; % stimOn point + 50ms
end

magOrd = zeros(length(labels), 1);
respMag = zeros(length(labels), 1);
respMagTest = zeros(length(labels), 1);
stimDur = ceil(stimDur); % in case it is a decimal
for i = 1:length(labels)
        
    if ~isempty(offset) 
        if(offset+stimDur <= size(psth, 2))
            amatrix = psth(find(order == i), offset:offset+stimDur);
        else
            amatrix = psth(find(order == i), offset:end);         
        end
    else
        amatrix = psth(find(order == i), fixedOffset:fixedOffset+stimDur);
    end
    if size(amatrix, 1) > 1
        % changed from sum to mean by varun Sept 2021
        % some images don't have equal trials
        amax= mean(mean(amatrix)); 
%         amax = sum(sum(amatrix));
    else
        amax = mean(amatrix);
%         amax = sum(amatrix);
    end    
    respMag(i) = amax;
    
end

[~, idx] = sortrows(respMag, 'descend'); 
% [~, testidx] = sortrows(respMagTest, 'descend');
magOrd = labels(idx);
% magOrdtest = labels(i

end