
function [strctLFPs] = extractLFPs(channelFiles, pathCells, brainAreas)
% extract lfps from the sort/final folder and return struct
% 
% Varun June 2019
strctLFPs = struct();

for channelIndex = 1:length(channelFiles)
    strctChannel = load([pathCells filesep channelFiles(channelIndex).name]);
    ChannelNumberParts = strsplit(channelFiles(channelIndex).name,'_');
    ChannelNumber = ChannelNumberParts{1};
    strctLFPs(channelIndex).ChannelNumber = ChannelNumber;
    strctLFPs(channelIndex).brainAreaIndex = brainAreas.brainArea(find(and(brainAreas.brainArea(:,1)==str2num(strrep(strctLFPs(channelIndex).ChannelNumber,'A','')),brainAreas.brainArea(:,3)==0)),4);
    strctLFPs(channelIndex).brainArea = translateArea(strctLFPs(channelIndex).brainAreaIndex);
    strctLFPs(channelIndex).lfpTimeStamps = strctChannel.lfp(:,1);
    strctLFPs(channelIndex).lfpSamples = strctChannel.lfp(:,2);
end

end