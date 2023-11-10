function [audioFileMS] = makeAudioFile(pathAudio, channelNum, fileFormat, block_size)
% reading in the audio file as an LFP
% this is later saved as a wav and transcribed
% vwadia/2019
% modified vwadia Dec2020

if nargin < 3
    % standard nlx parameters
    fileFormat = 6;
    block_size = 512;
end

channelName = ['CSC' num2str(channelNum) '.ncs'];
% note Nlx file format is 6
audioChannel = dir([pathAudio filesep channelName]); % its normally CSC127 but change it to whatever
channel     = audioChannel.name;
dataSamples = cell(1,length(channel));


file_loc = [audioChannel.folder filesep audioChannel.name];
[~, scaleFact, fileExists]      = getRawHeader( [audioChannel.folder filesep audioChannel.name] );

if fileExists
    [~,~,nrSamples,sampleFreq,~,~] = getRawTimestamps(file_loc, fileFormat);
    [timestamps,dataSamples]       = getRawData(file_loc,1,nrSamples,...
        fileFormat,sampleFreq);
    timestamps          = cell2mat(cellfun(@(x) ...
        x+(1:block_size)*1e6/sampleFreq,...
        num2cell(timestamps),'UniformOutput',false));
end

dataSamples                  = dataSamples*scaleFact*1e6;
    
% this is what we want 
audioFileMS = zeros(length(dataSamples), 2);
audioFileMS(:, 2) = dataSamples;
audioFileMS(:, 1) = timestamps'*1e-3; % convert to milliseconds