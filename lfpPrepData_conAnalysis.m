
function [data_raw, params] = lfpPrepData_conAnalysis(sessPath, FsDown, mapping)
% Function to prep data for cross region connectivity analysis via Juri's
% functions
% 
% Currently data is set up per channel:
% AChannelNum_lfp.mat --> datasamples (lfp)
%                         timestamps
%                         
% Need to convert to per session:
% data_raw --> label (cell array with area and channel num as a string eg. 'uRAC:98')
%             fsample 500
%             trial (matrix with lfp)
%             time (timestamps)
%             
% Workflow:
%     Take in input and use it to setpaths to appropriate folders 
%     create data_raw, params
%     Loop through channels with natsort, keeping metadata for each one (channelnum and brainRegion)
%     load the data 
%         --> store the lfp as a row in matrix 
%         --> add to label cell aray
%         --> if first store time stamps as time 
%     INPUTS:
%         1. sessionID (the path to the session to convert)
%         2. FsDown (the frequency the channels were resampled to)
%         3. Mapping of brain areas (see defineUsableClusters_fromXlsFile)
%         
%     OUTPUTS:
%         1. data_raw (struct containing lfp data, timestamps, channel labels)
%         2. params (params struct that contains the frequency we downsampled to)
%             
% vwadia July2022

basePath = [sessPath filesep 'sort' filesep 'final'];
pathOut = sessPath;
data_raw = struct;
params = struct;

% area mapping
areas = translateArea(mapping(:, 3))';
areas(:, 2:3) = num2cell(mapping(:, 1:2));
ctr = 1;
for chanIndex = min(min(mapping)):max(max(mapping))
   
    % if it is a legit channel
    if exist([basePath filesep 'A' num2str(chanIndex) '_lfp.mat'], 'file') == 2
    
        % load in the lfp data
        load([basePath filesep 'A' num2str(chanIndex) '_lfp.mat'])

        % trial variable
        trial(ctr, :) = lfp(:, 2)';

        % timestamps variable
        if chanIndex == 1
            time = lfp(:, 1)';
        end
        
        lowerChan = find(cell2mat(areas(:, 2)) <= chanIndex);
        upperChan = find(cell2mat(areas(:, 3)) >= chanIndex);
        cIdx = intersect(lowerChan, upperChan);
        % label variable
        label{ctr, 1} = ['u' areas{cIdx, 1} ':' num2str(chanIndex)];
        ctr = ctr + 1;
    end
    
end

% assign data_raw struct
data_raw.label = label;
data_raw.fsample = FsDown;
data_raw.trial = trial;
data_raw.time = time;


% assign params struct
% only adding FsDown here - everything else will be added in the
% connectivity functions via the get_opt functions Juri wrote
params.FsDown = FsDown;






