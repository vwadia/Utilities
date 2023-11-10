function [data_lfp, data_spike, params] = ExtractDataSFC(lfDat, spikDat, params, sessDir, condition)
% This function takes in spike and lfp configuration structs that outline
% the periods, timebins, etc. for lfp trial snippets and spikes
% Then actually run the parfor loop across channels to get trial snippets etc.


%% spike data

% load in cells (if sigramp only)
if strcmp(params.cellArea(2:end), 'FFA')
    if strcmp(params.cells, 'allCells')
        load([params.diskPath filesep 'Recall_Task' filesep 'AllITCells_500stim_Im.mat']);
    elseif strcmp(params.cells, 'respCells')
        load([params.diskPath filesep 'Recall_Task' filesep 'AllRespITCells_500stim_Im.mat']);
    elseif strcmp(params.cells, 'sigRamp')
        load([params.diskPath filesep 'Recall_Task' filesep 'ReactiveITCells_alpha0.05_500Stim_Im_SigRamp.mat']);
%         load([params.diskPath filesep 'Recall_Task' filesep 'AllITCells_500Stim_Im_SigRamp.mat']);
%         load([params.diskPath filesep 'Recall_Task' filesep 'old_cellStructs' filesep 'AllITCells_500Stim_Im_SigRamp.mat']);
    end
else
    
    load([params.diskPath filesep params.sessDir filesep 'PsthandResponses'])
    load([params.diskPath filesep params.sessDir filesep 'strctCells'])
    psths = screeningPsth;
end

strctCELL = struct2cell(strctCells');
strctCELL = strctCELL';

% temporary - removing shitty neurons
badCells = [1085, 1759, 713, 5477, 2099, 750, 773, 819]';
allCells = cell2mat(strctCELL(:, 1));
goodCells = ~ismember(allCells, badCells);

strctCells = strctCells(goodCells);
strctCELL = strctCELL(goodCells, :);
psths = psths(goodCells, :);
responses = responses(goodCells, :);

relevantCells = cellfun(@(x,y) strcmp(x, params.cellArea) && strcmp(y, sessDir{3}), strctCELL(:, 4), strctCELL(:, 8), 'UniformOutput', false);
relevantCells = cell2mat(relevantCells);
sess_strctCells = strctCells(relevantCells);
sess_psths = psths(relevantCells, :);
sess_responses = responses(relevantCells, :);

sData = cell(length(sess_strctCells), 1);

if strcmp(condition, 'Screening')
    % grab relevant spike data for screening
    for cellIndex = l(sess_strctCells)
        % grab part of baseline period - short OFF period means responses bleed into early baseline period 
        sData{cellIndex, 1} = sess_psths{cellIndex, 1}(:, -spikDat.timelimits(1)*1e3-spikDat.offset:-spikDat.timelimits(1)*1e3)'; 
    end

else
    basePath = params.sessDir;
    % grab CRTimecourse etc. of only ramp tuned ones
    ImStrct = load([basePath filesep 'RecallData_NoFReeRec']);
    ImStrct.strctCELL = struct2cell(ImStrct.strctCells');
    ImStrct.strctCELL = ImStrct.strctCELL';
    relevantCells = cellfun(@(x) strcmp(x, params.cellArea), ImStrct.strctCELL(:, 4)); % cells in the correct area
    
    ImStrct.strctCells = ImStrct.strctCells(relevantCells);
    ImStrct.RecallData.CRTimeCourse = ImStrct.RecallData.CRTimeCourse(relevantCells, :);
    ImStrct.RecallData.EncodingTimeCourse = ImStrct.RecallData.EncodingTimeCourse(relevantCells, :);
    % correctly pick out encoding trial data for responsive/ramp tuned neurons
    for cellIndex = l(sess_strctCells)
        cntrl = 1;
        for c_idx = l(ImStrct.strctCells)
            if isequal(sess_strctCells(cellIndex).Name, ImStrct.strctCells(c_idx).Name) &&...
                    isequal(sess_strctCells(cellIndex).spikeTimeStamps, ImStrct.strctCells(c_idx).spikeTimeStamps)
                
                assert(cntrl == 1, 'Cell Pairing is wrong!');
                if strcmp(condition, 'Encoding')
                    % sData needs to be cellIndex and EncTimeCourse needs to be c_idx
                    sData{cellIndex, 1} = ImStrct.RecallData.EncodingTimeCourse{c_idx, 1}(:, 1:-spikDat.timelimits(1)*1e3)'; % grab whole baseline period
                elseif strcmp(condition, 'Imagination')
                    sData{cellIndex, 1} = ImStrct.RecallData.CRTimeCourse{c_idx, 1}(:, -spikDat.timelimits(1)*1e3:-spikDat.timelimits(1)*1e3+spikDat.offset)';
                end
                cntrl = cntrl + 1;
            end
        end
    end
    
end

% OPTIONAL: choose only cells with at least n spikes in that condition
if ~isfield(params, 'valid_cell')
%     if ~strcmp(condition, 'Encoding')
        if params.cutOffSpikeVal > 0
            valid_cell = zeros(length(sess_strctCells), 1);
            
            assert(isequal(length(valid_cell), size(sData, 1)));
            for cellIndex = 1:(size(sData, 1))
                
                if sum(sum(sData{cellIndex, 1})) > params.cutOffSpikeVal
                    
                    valid_cell(cellIndex, 1) = 1;
                end
            end
            sData = sData(logical(valid_cell), :);
            params.valid_cell = valid_cell;
        end
%     end
else
    % use from previous condition
    sData = sData(logical(params.valid_cell), :);
end
% rearrange spike data into correct shape for Jonathan's function
% put data into correct format for Jonathan's function
data_spike = [];
for cellIndex = 1:size(sData, 1)
    
    sD = sData{cellIndex, 1};
    sD = reshape(sD, [size(sD, 1) 1 size(sD, 2)]);
    if ~isempty(data_spike)
        if size(data_spike, 1) > size(sD, 1)
            sD = padarray(sD, size(data_spike, 1) - size(sD, 1), 'post');
        elseif size(data_spike, 1) < size(sD, 1)
            sD = sD(1:size(data_spike, 1), :, :);
        end
    end
    
    % should be samples x neurons x trials
    data_spike = cat(2, data_spike, sD);
end
%% lfp data

% bigass parfor loop
replaceMethod=1; %1=spline, 2=cubic, 3=linear, 4=mean spike subtraction
cancelSpikePhaseShift=0;
FsDownReq=1000; % requested sampling rate.
data_lfp = [];

% grab lfp data
chans = params.lfpChans;

dataRawReshaped = [];
dfLP = cell(1, length(chans));
basepathLFP = [params.sessDir filesep 'raw'];

parfor chan_ind = 1:length(chans)
% for chan_ind = 1:length(chans)
    channel = chans(chan_ind);
    
    if strcmp(params.local, 'true')
        % replaceSpikeTimes = 1;
        [dataRaw, dataRawDownsampled, isContinuous,periodsExtracted, validTrials, FsDown,Fs, maxRange] = getLFPofTrial(basepathLFP, channel, lfDat.timeFrom, lfDat.timeTo, params.notch, params.FsDown, 1 );        
    else
        % data is returned as a 1 x ntrials cell array
        [dataRaw, dataRawDownsampled, isContinuous,periodsExtracted, validTrials, FsDown,Fs, maxRange] = getLFPofTrial(basepathLFP, channel, lfDat.timeFrom, lfDat.timeTo, params.notch, params.FsDown );
    end
    
    %filter
    filterMode=9; %LFP
    [dataFilteredLowPass, filterSettings1] = filterLFPofTrial( dataRawDownsampled, filterMode, FsDown );
    
    
    maxLength = cellfun(@(x) length(x), dataFilteredLowPass);
    maxLength = max(maxLength);
    
    % make sure size matches spike data  
    if size(data_spike, 1) ~= maxLength
        maxLength = size(data_spike, 1);
    end
    
    for tr = 1:length(dataFilteredLowPass)
        if length(dataFilteredLowPass{tr}) > maxLength
            dataFilteredLowPass{tr} = dataFilteredLowPass{tr}(1:maxLength, :);
        elseif length(dataFilteredLowPass{tr}) < maxLength
            dataFilteredLowPass{tr} = padarray(dataFilteredLowPass{tr}, maxLength - length(dataFilteredLowPass{tr}), 'post');
        end
    end
    
    % put data into correct shape for jonathan's function
    dfLP{chan_ind} = cell2mat(dataFilteredLowPass);
    %             dataRawReshaped = reshape(dfLP, [1 size(dfLP, 1)*size(dfLP, 2)]);
    dataRawReshaped = [dataRawReshaped; reshape( dfLP{chan_ind}, [1 size( dfLP{chan_ind}, 1)*size(dfLP{chan_ind}, 2)])];
    
end

% Optional: Check thrwsholds to remove grounds
% chan_stddevs = std(dataRawReshaped');
% if mean(chan_stddevs)/min(chan_stddevs) > 2 % means one is reference channel
%     [~, ref] = min(chan_stddevs);
%     dfLP(ref) = [];
% end

% rearrange for ppc function
for idx = 1:length(dfLP)
    dfLP_ofChan = reshape(dfLP{idx}, [size(dfLP{idx}, 1) 1 size(dfLP{idx}, 2)]);
    data_lfp = cat(2, data_lfp, dfLP_ofChan);
end

% sort if screening
if strcmp(condition, 'Screening')
    taskStruct = load([params.diskPath filesep params.sessDir filesep sessDir{5}]);
    order = taskStruct.order(:);
    if strcmp(sessDir{1}, 'Recall_Task\P76CS\ReScreenRecall_Session_1_20210917')
        order = order(1:1892);
    end
    [sortedOrder, correctOrder] = sortrows(order);
    data_lfp = data_lfp(:, :, correctOrder);
    data_lfp = data_lfp(:, :, 1:size(data_spike, 3));
end

%% boom done
end

