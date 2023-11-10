function [audioFileMS] = readInAudio(audioChannel, fileFormat, channel, block_size)
% reading in the audio file as an LFP 
%
% Varun June 2019
if nargin < 2
    fileFormat  = 6;
    channel     = audioChannel.name;
    block_size = 512;
end

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
end