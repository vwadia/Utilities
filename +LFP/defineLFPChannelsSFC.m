function [lfpChans] = defineLFPChannelsSFC(sessDir, lfpArea)
% takes in cell aray for a session
% 1- dir ID, 2-channels with cells, 3-patientID, 4-channel numebrs and labels

% vwadia Feb2023

labels = sessDir{1, 4};
lfpChans = labels(:, 1);

cellChans = sessDir{1, 2};

area = cellfun(@(x) strcmp(x, lfpArea), labels(:, 2), 'UniformOutput', false);

lfpChans = cell2mat(lfpChans(cell2mat(area)));

lfpChans = lfpChans(ismember(lfpChans, cellChans));

end