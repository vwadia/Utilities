function varargout = makeRastersFromStrctCells(loadpath, offsets, useBothOffsets, order, binsize, stimOnTimes, stimOffTimes, split, numrowspersplit)
% takes in strctCells and relevant parameters 
% then extracts psth1 and psth per cell
% Note here that 'psth' is a smoothed one for FR ploting purposes
%     INPUTS:
%         1. loadpath = strctCells(cellIndex)
%         2. offsets - 2 element vector eg. [500 1000]
%         3. useBothOffsets - keep this = 1
%         4. order - stimuluse order
%         5. binsize - for smoothing
%         6. stimOnTimes
%         Can leave the rest blank
%     OUTPUTS:
%         1x3 cell array with raster, smoothed psth, times

% vwadia Dec/2020

if nargin==8
    numrowspersplit = [];
end
if nargin==7
    split = 0;
    numrowspersplit = [];
end
if nargin==6
    split = 0;
    numrowspersplit = [];
    stimOffTimes = [];
end

if isempty(stimOffTimes) && ~useBothOffsets
    disp('Error: need an end time OR an offset after stimON');
    keyboard;
end

max_length = 0;
offsetBegin = offsets(1);
offsetEnd = offsets(2);
spikeTimeCourseStimulus = cell(length(stimOnTimes), 1);
for trial = l(stimOnTimes)
    stimOnTime = stimOnTimes(trial);
    if ~isempty(stimOffTimes)
        if useBothOffsets
            stimOffTime = stimOffTimes(trial)+offsetEnd;  
        elseif ~useBothOffsets
            stimOffTime = stimOffTimes(trial);
        end
    else
        stimOffTime = stimOnTime+offsetEnd;        
    end
    
    aic_timeStampsInRange = and(loadpath.spikeTimeStampsMS <= stimOffTime,...
        loadpath.spikeTimeStampsMS >= stimOnTime-offsetBegin);
    
    timeStampsInRangeMS = loadpath.spikeTimeStampsMS(aic_timeStampsInRange);
    spikeTimeCourseStimulus{trial} = double(false(1, round((stimOffTime) - (stimOnTime-offsetBegin)))); % vector of 0s this length
%     vec_length = length(spikeTimeCourseStimulus);
    actualTimeStamps = round(timeStampsInRangeMS - (stimOnTime-offsetBegin)); % subtracting the (imageOn-baseline) time, so stimon time = 0
    spikeTimeCourseStimulus{trial}(actualTimeStamps+1) = 1; %true; % this can sometimes add another bin to the end
    
    if max(size(spikeTimeCourseStimulus{trial})) > max_length
        max_length =  max(size(spikeTimeCourseStimulus{trial}));
    end
end

% pad the arrays and save them in AICData struct
for trial = l(stimOnTimes)
    psth1(trial, :) = padarray(spikeTimeCourseStimulus{trial},...
        [0 max_length - max(size(spikeTimeCourseStimulus{trial}))], 0, 'post');
end

% makes times
times = -offsetBegin:max_length-offsetBegin;
if length(times) < max_length
    % find out by how much
    diff = max_length - length(times);
    extra = times(end)+1:(times(end)+diff);
    % tack on the extra
    times = [times extra];
else
    % otherwise trim
    times = times(1:max_length);
end

% make smoothed psths
psth = zeros(size(psth1, 1), max_length);
for row = 1:size(psth1, 1)
    % method 1
    spkeTimes = find(psth1(row, :) == 1);
    if ~isempty(spkeTimes)
        for spkNum = l(spkeTimes)
%             psth(row, :) = (smoothdata(psth1(row,:), 'gaussian', binsize)*binsize)*(1000/binsize); % smooth is way too slow
            psth(row, :) = (Utilities.Smoothing.fastsmooth(psth1(row,:),binsize, 1, 0)*binsize)*(1000/binsize); % smooth is way too slow
        end
    end    
end


% can only split if order is defined
if split
    if isempty(numrowspersplit)
        numSplits = length(unique(order));
        numrowspersplit = size(psth1, 1)/numSplits;
    else
        numSplits = size(psth1, 1)/numrowspersplit;
    end
    varargout = cell(1, numSplits);
    for ii = 1:numSplits
        varargout{ii} = psth1(numrowspersplit*(ii-1)+1:numrowspersplit*(ii-1)+numrowspersplit, :);
    end
else
    varargout{1} = psth1;
    varargout{2} = psth;
    varargout{3} = times;
end




end