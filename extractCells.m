
function [strctCells, dupCells] = extractCells(pathCells, pathBrainAreas, channels, patientID, sessionID) 
% extracting cells from sorted channels 
% 
% varun June 2019
% edited so you can choose specific brain regions April2021
% edited to include patient and sessionID Nov 2021
if nargin == 2 
    patientID = []; sessionID = []; channels = [];   
    channelFiles = dir([pathCells filesep '*cells.mat']);
elseif nargin == 3 
    patientID = []; sessionID = [];    
    fullChannelFiles = dir([pathCells filesep '*cells.mat']);
    ctr = 1;
    for chanIdx = 1:length(fullChannelFiles)
        for cid = channels
            if startsWith(fullChannelFiles(chanIdx).name, ['A' num2str(cid)])
                channelFiles(ctr, 1) = fullChannelFiles(chanIdx);
                ctr = ctr+1;
            end
        end
    end
elseif isempty(channels)
    channelFiles = dir([pathCells filesep '*cells.mat']);
elseif ~isempty(channels)
    fullChannelFiles = dir([pathCells filesep '*cells.mat']);
    ctr = 1;
    for chanIdx = 1:length(fullChannelFiles)
        for cid = channels
            if startsWith(fullChannelFiles(chanIdx).name, ['A' num2str(cid)])
                channelFiles(ctr, 1) = fullChannelFiles(chanIdx);
                ctr = ctr+1;
            end
        end
    end
end

% gets rid of all the weird copies switching OS makes
stimuli = channelFiles(~ismember({channelFiles.name}, {'.', '..', '.DS_Store'}));
stimNames = struct2cell(stimuli);
stimNames = stimNames(1,:)';
goodStim = ~startsWith(stimNames, '._', 'IgnoreCase', true);
channelFiles = stimuli(goodStim);


brainAreas = load([pathBrainAreas filesep 'brainArea.mat']);
numCells = 0;
strctCells = struct;
for channelIndex = 1:length(channelFiles)
       
    strctChannel = load([pathCells filesep channelFiles(channelIndex).name]);
    ChannelNumberParts = strsplit(channelFiles(channelIndex).name,{'A','_'}, 'CollapseDelimiters', true);
    ChannelNumber = str2double(ChannelNumberParts{2});
    cellList = unique(strctChannel.spikes(:,2)); % cluster number
    for cellIndex = 1:length(cellList)
        numCells = numCells+1;
        strctCells(numCells).Name = cellList(cellIndex);
        strctCells(numCells).ChannelNumber = ChannelNumber;
        strctCells(numCells).brainAreaIndex = brainAreas.brainArea...
            (find(and(brainAreas.brainArea(:,3)==strctCells(numCells).Name, brainAreas.brainArea(:,1)==strctCells(numCells).ChannelNumber)),4);
        strctCells(numCells).brainArea = translateArea(strctCells(numCells).brainAreaIndex);
        strctCells(numCells).spikeTimeStamps = strctChannel.spikes(strctChannel.spikes(:,2) == strctCells(numCells).Name,3);
        strctCells(numCells).spikeTimeStampsMS = strctCells(numCells).spikeTimeStamps*1e-3;
        if ~isempty(patientID)
            strctCells(numCells).PatientID = patientID;
        end
        if ~isempty(sessionID)
            strctCells(numCells).SessionID = sessionID;
        end
    end
end

% if a cluster with the same name shows up in 2 areaas then brainAreaIndex
% is a [x, y] pair in both entries. We want to make sure the right area has the right index number instead of both having both 
dupCells = [];
for cellIndex = 1:length(strctCells)
    if length(strctCells(cellIndex).brainAreaIndex) > 1
        if ismember(strctCells(cellIndex).Name, dupCells)
            strctCells(cellIndex).brainAreaIndex = strctCells(cellIndex).brainAreaIndex(2);
            strctCells(cellIndex).brainArea = strctCells(cellIndex).brainArea(2);
            
        else
            strctCells(cellIndex).brainAreaIndex = strctCells(cellIndex).brainAreaIndex(1);
            strctCells(cellIndex).brainArea = strctCells(cellIndex).brainArea(1);
            dupCells(end+1) = strctCells(cellIndex).Name;
        end
    end
end

end