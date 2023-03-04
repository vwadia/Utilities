function [lfDat, spikDat] = SFCConfig(params, cond)
% Call separately for each condition
% This should define things like:

% For lfp
%     Needs events
%     channel numbers of lfpArea
%     offsets

% For spike
%     offsets
%     extract from correct area

% OUTPUT:
%     lfDat structure with events/offsets/channelnumbers etc. defined
%     spikDat structure with offsets etc. defined
%
%     Feed both of these into extractDataSFC


% this needs to be here - scope of initial path declaration doesn't extend
% here
setDiskPaths
taskCodePath = [boxPath filesep 'recallTaskVarun']; % more events described here
addpath(taskCodePath); setTTLCodes;
addpath(['Code' filesep 'SFCpackage' filesep 'helpers']);
addpath(genpath('osortTextUI'));


rawPath = 'raw';
basePath = params.sessDir;

% load all events and create trials
events = getRawTTLs([basePath filesep rawPath filesep 'Events.nev'], 1);
expON = find(events(:, 2) == EXPERIMENT_ON);
expOFF = find(events(:, 2) == EXPERIMENT_OFF);

if strcmp(cond, 'Screening')

    % spike data
    spikDat.timelimits = [-0.17 0.53];
    spikDat.offset = 100;

    % lfp data
    switch [diskPath filesep params.sessDir]
        case [diskPath filesep 'Recall_Task' filesep 'P76CS' filesep 'ReScreenRecall_Session_1_20210917']
            events = events(expON(1):expOFF(1), :); % 1892 trials instead of 2000 makes data
        case [diskPath filesep 'Recall_Task' filesep 'P76CS' filesep 'RecallScreening_Session_2_20210925'] % pain in the ass session
            events = events(expON(1):expOFF(1), :); % screening
        case [diskPath filesep 'Recall_Task' filesep 'P76CS' filesep 'ReScreenRecall_Session_3_20210927']
            events = events(expON(end):expOFF(end), :); % screening
        case [diskPath filesep 'Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_1_20220330']
            events = events(expON(end):expOFF(end), :); % screening
        case [diskPath filesep 'Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_2_20220403']
            events = events(expON(end):expOFF(end), :); % screening
        case [diskPath filesep 'Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_3_20220405']
            events = events(expON(end):expOFF(end), :); % screening
        case [diskPath filesep 'Recall_Task' filesep 'P80CS' filesep 'ReScreenRecall_Session_1_20220728']
            events = events(expON(end):expOFF(end), :); % screening
        case [diskPath filesep 'Recall_Task' filesep 'P80CS' filesep 'ReScreenRecall_Session_2_20220731']
            events = events(expON(end):expOFF(end), :); % screening
    end

    lfDat.eventsMS = events*1e3;

    % define time periods
    % screening - (stim on - 100ms) so you don't miss 1st trial
    % note that resolution is in microseconds so 100ms = 1e5 us
    periods = [events(events(:, 2) == IMAGE_ON, 1) - 1e5 events(events(:, 2) == IMAGE_ON, 1)];

    lfDat.timeFrom = periods(:, 1);
    lfDat.timeTo = periods(:, 2);

    lfDat.bin_size = mean(lfDat.timeTo-lfDat.timeFrom)*1e-4; % because timeFrom and To are in us
    lfDat.Ord = 1:length(lfDat.timeFrom);
    lfDat.use_both_offsets = 1;

    lfDat.offset = [170 530]; % in ms - should this be us??

elseif strcmp(cond, 'Encoding')
    
    % spike data
    spikDat.timelimits = [-0.5 2.5];
    spikDat.offset = 500; % how much of baseline period to grab 

    switch [diskPath filesep params.sessDir]
        case [diskPath filesep 'Recall_Task' filesep 'P76CS' filesep 'ReScreenRecall_Session_1_20210917']
            events = events(find(events(:, 2) == TRAINING_RECALL_END):expOFF(end), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P76CS' filesep 'Recall_Session_2_20210925'] % pain in the ass session
            events = events(find(events(:, 2) == TRAINING_RECALL_END):expOFF(end), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P76CS' filesep 'ReScreenRecall_Session_3_20210927']
            events = events(find(events(:, 2) == TRAINING_RECALL_END):expOFF(1), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_1_20220330']
            trainEnd = find(events(:, 2) == TRAINING_RECALL_END);
            events = events(trainEnd(end):expOFF(1), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_2_20220403']
            events = events(find(events(:, 2) == TRAINING_RECALL_END):expOFF(1), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_3_20220405']
            trainEnd = find(events(:, 2) == TRAINING_RECALL_END);
            events = events(trainEnd(end):expOFF(2), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P80CS' filesep 'ReScreenRecall_Session_1_20220728']
            events = events(find(events(:, 2) == TRAINING_RECALL_END):expOFF(1), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P80CS' filesep 'ReScreenRecall_Session_2_20220731']
            events = events(find(events(:, 2) == TRAINING_RECALL_END):expOFF(1), :); % recall task
    end
    

    lfDat.eventsMS = events*1e3;
    % encoding 
    periods = [events(events(:, 2) == IMAGE_ON, 1) events(events(:, 2) == IMAGE_OFF, 1)];

    lfDat.timeFrom = periods(:, 1);
    lfDat.timeTo = periods(:, 2);
    lfDat.bin_size = 200;
    lfDat.Ord = 1:length(lfDat.timeFrom);
    lfDat.use_both_offsets = 1;

    lfDat.offset = [1000 1500]; % is this correct?

elseif strcmp(cond, 'Imagination')


    % spike data
    spikDat.timelimits = [-1 6.5];
    spikDat.offset = 5000;

    switch [diskPath filesep params.sessDir]
        case [diskPath filesep 'Recall_Task' filesep 'P76CS' filesep 'ReScreenRecall_Session_1_20210917']
            events = events(find(events(:, 2) == TRAINING_RECALL_END):expOFF(end), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P76CS' filesep 'Recall_Session_2_20210925'] % pain in the ass session
            events = events(find(events(:, 2) == TRAINING_RECALL_END):expOFF(end), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P76CS' filesep 'ReScreenRecall_Session_3_20210927']
            events = events(find(events(:, 2) == TRAINING_RECALL_END):expOFF(1), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_1_20220330']
            trainEnd = find(events(:, 2) == TRAINING_RECALL_END);
            events = events(trainEnd(end):expOFF(1), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_2_20220403']
            events = events(find(events(:, 2) == TRAINING_RECALL_END):expOFF(1), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_3_20220405']
            trainEnd = find(events(:, 2) == TRAINING_RECALL_END);
            events = events(trainEnd(end):expOFF(2), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P80CS' filesep 'ReScreenRecall_Session_1_20220728']
            events = events(find(events(:, 2) == TRAINING_RECALL_END):expOFF(1), :); % recall task
        case [diskPath filesep 'Recall_Task' filesep 'P80CS' filesep 'ReScreenRecall_Session_2_20220731']
            events = events(find(events(:, 2) == TRAINING_RECALL_END):expOFF(1), :); % recall task
    end

    lfDat.eventsMS = events*1e3;
    % recall
    periods = [events(events(:, 2) == TONE_1, 1) events(events(:, 2) == TONE_2, 1);...
        events(find(events(:, 2) == TONE_2), 1) events(find(events(:, 2) == TONE_2)+1, 1)];

    lfDat.timeFrom = periods(:, 1);
    lfDat.timeTo = periods(:, 2);
    lfDat.bin_size = 200;
    lfDat.Ord = 1:length(lfDat.timeFrom);
    lfDat.use_both_offsets = 1;

    lfDat.offset = [0 0];

end

end