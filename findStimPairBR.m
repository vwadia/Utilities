function [stim1BR, stim2BR, responseMatrix, screeningData] = findStimPairBR(windowBegin, windowEnd, windowLength, screeningData)
% windowBegin = stimON+50;
% windowLength = 400;
% windowEnd = windowBegin+windowLength;
screeningData.meanAndStdDev = zeros(length(strctCells), 2);
responseMatrix = zeros(length(screeningData.imageIDs), length(screeningData.visCell(:, 1)));

% calculating mean and std dev for each cell - to standardize
for cellIndex = l(strctCells)
    screeningData.meanAndStdDev(cellIndex, 1) = mean(mean(screeningData.psth{cellIndex, 2}(windowBegin:windowBegin+windowLength, :))); % mean across trials for response window
    screeningData.meanAndStdDev(cellIndex, 2) = std(mean(screeningData.psth{cellIndex, 2}(windowBegin:windowBegin+windowLength, :), 1)); % stddev of the FR
end

for imageNum = 1:length(screeningData.imageIDs)
    for cellIndex = l(strctCells)
        % note I am standardizing the responses here (subtract global mean
        % and divide by std dev of cell)
        screeningData.popVec{imageNum}(cellIndex, 1) = (mean(screeningData.psth{cellIndex, 2}(windowBegin:windowEnd, imageNum)) - screeningData.meanAndStdDev(cellIndex, 1))/screeningData.meanAndStdDev(cellIndex, 2);
    end
    screeningData.popVec{imageNum} = screeningData.popVec{imageNum}(screeningData.visCell(:, 1));
    responseMatrix(imageNum, :) = screeningData.popVec{imageNum};
end

meanImageResponse = mean(responseMatrix, 2); % mean across cells
[maxFR stim1BR] = max(meanImageResponse);
[minFR stim2BR] = min(meanImageResponse);
[responseList, stimList] = sort(meanImageResponse, 'desc');

% % loop through images find max and min
% % comparing images to find the ones with largest difference in the response
% % vectors - pairwise
diffMatrix = zeros(length(screeningData.imageIDs));

for row = 1:length(diffMatrix(:, 1))
    for col = 1:length(diffMatrix(1, :))

        diffMatrix(row, col) = sum(abs(screeningData.popVec{row} - screeningData.popVec{col}));

    end
end

% look at the indices of desiredStim - those are the two images you want.
desiredStim = find(diffMatrix(:) == max(diffMatrix(:)));
stim1BR = mod(desiredStim(1), length(screeningData.imageIDs));
stim2BR = mod(desiredStim(2), length(screeningData.imageIDs));
