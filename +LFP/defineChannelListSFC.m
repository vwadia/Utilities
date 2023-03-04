function [dirID] = defineChannelListSFC(patIDs, condition, channelType)
% function to define the channel list for all patients 
% then choose either the cell channels or just the non-noise channels
% INPUTS:
%     0. Patient IDs (so you can do only 1? future implementation)
%     1. Condition (screening vs Im or Encoding vs Im)
%     2. Type of channels desired (cell channels or non-noise channels)

% OUTPUTS:
%     1. A directory list for the inputted condition
%         n x 4 cell array (n = number of sessions)
%         Col 1 - session path
%         Col 2 - Valid channels for that session
%         Col 3 - session ID (as in strctCells)
%         Col 4 - the channel list for each patient 
%         
% vwadia Feb2023


% set up channel list per patient
P76Chans = [1:64 193:216]';
P76Chans = mat2cell(P76Chans, ones(length(P76Chans), 1));
P76Chans(:, 2) = [repelem({"LAC"}, 8)'; repelem({"LSMA"}, 8)'; repelem({"LA"}, 8)'; repelem({"LH"}, 8)';...
    repelem({"RAC"}, 8)'; repelem({"RSMA"}, 8)'; repelem({"RA"}, 8)'; repelem({"RH"}, 8)'; repelem({"LOF"}, 8)';...
    repelem({"LINS"}, 8)'; repelem({"RFFA"}, 8)'];

P79Chans = [1:64 193:224]';
P79Chans = mat2cell(P79Chans, ones(length(P79Chans), 1));
P79Chans(:, 2) = [repelem({"LAC"}, 8)'; repelem({"LSMA"}, 8)'; repelem({"LA"}, 8)'; repelem({"LH"}, 8)';...
    repelem({"RAC"}, 8)'; repelem({"RSMA"}, 8)'; repelem({"RA"}, 8)'; repelem({"RH"}, 8)'; repelem({"LOF"}, 8)';...
    repelem({"ROF"}, 8)'; repelem({"LFFA"}, 8)'; repelem({"RFFA"}, 8)'];

P80Chans = P79Chans;


if strcmp(condition, 'ScreeningImagination')
    
    % set up directory list for both conditions (the only reason this is
    % reapeated is because of screening and recall being separate in P76
    % Session 2
    dirID = {['Recall_Task' filesep 'P76CS' filesep 'ReScreenRecall_Session_1_20210917'];...
        ['Recall_Task' filesep 'P76CS' filesep 'ReScreenRecall_Session_3_20210927'];...
        ['Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_1_20220330'];...
        ['Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_2_20220403'];...
        ['Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_3_20220405'];...
        ['Recall_Task' filesep 'P80CS' filesep 'ReScreenRecall_Session_1_20220728'];...
        ['Recall_Task' filesep 'P80CS' filesep 'ReScreenRecall_Session_2_20220731']};
    
    P76 = [1 1 0 0 0 0 0];
    P79 = [0 0 1 1 1 0 0];
    P80 = [0 0 0 0 0 1 1];
    
    if strcmp(channelType, 'Cell')
        % channels with cells on them or no 60hz (all standard regions + IT)
        dirID(:, 2) = {[1 5 7 8 14 17:24 25 26 28 34:36 38 40 44:46 50 52 54:56 57 60:64 193:195 197:200 211 213 ],... %P76 RsR 1
            [6:8 14 21 22 28 34 45 50 53 56 59 64 197 200 211 213],... P76 RsR 3
            [1:3 5:10 12:16 18:22 24:28 30:33 36 38 46 49:56 59:62 64 193:200 202 208],... P79 RsR 1, all IT channels seem to have noise (ugh)
            [1:3 5:10 13:22 24 27 28 29 30 35 38 46 49:52 54:56 59 60 193 194 196:199 209:212 214 215 217:219 222],... P79 RsR 2
            [1 3 5:10 14:17 19:22 24 27 28 30 32 35 46 49:52 54 55 59 60 62 193:199 202 205 209:212 214 215 217:222],... P79 RsR 3
            [1 3 9 16:25 31 32 35 37:41 43 45:56 59 206 209:211 214 217 222:224],... P80 RsR 1
            [1:5 7 9:11 16:26 30:32 35 37:39 41:56 58 59 206 209 211 219 222:224]}; % P80 RsR 2
        
    elseif strcmp(channelType, 'NoNoise')
       % note these are manually chosen
        noiseChans = {[39], [33:47], [209:224], [220], [], [], []};
        bigSet = {P76Chans; P76Chans; P79Chans; P79Chans; P79Chans; P80Chans; P80Chans};
        for ch = 1:size(dirID, 1)
            dirID{ch,2} = setdiff(cell2mat(bigSet{ch}(:, 1)), noiseChans{ch});
        end
        
    end
    % C1_dirID(:, 3) = {'P76CS'; 'P76CS'; 'P79CS'; 'P79CS'; 'P79CS'; 'P80CS'; 'P80CS'};
    dirID(:, 3) = {'P76CSRec_ReScreen';  'P76CSRec_ReScreen_3'; 'P79CS_ReScreen_1'; 'P79CS_ReScreen_3'; 'P79CS_ReScreen_4'; 'P80CS_ReScreenRecall'; 'P80CS_ReScreecRecall_2'};
    
    dirID(:, 4) = {P76Chans; P76Chans; P79Chans; P79Chans; P79Chans; P80Chans; P80Chans};
    
elseif strcmp(condition, 'EncodingImagination')
    
    % ------------------------------------------------------------------------------------------------------------------------------------------
    dirID = {['Recall_Task' filesep 'P76CS' filesep 'ReScreenRecall_Session_1_20210917'];...
        ['Recall_Task' filesep 'P76CS' filesep 'Recall_Session_2_20210925'];... % use screening session
        ['Recall_Task' filesep 'P76CS' filesep 'ReScreenRecall_Session_3_20210927'];...
        ['Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_1_20220330'];...
        ['Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_2_20220403'];...
        ['Recall_Task' filesep 'P79CS' filesep 'ReScreenRecall_Session_3_20220405'];...
        ['Recall_Task' filesep 'P80CS' filesep 'ReScreenRecall_Session_1_20220728'];...
        ['Recall_Task' filesep 'P80CS' filesep 'ReScreenRecall_Session_2_20220731']};

    P76 = [1 1 1 0 0 0 0 0];
    P79 = [0 0 0 1 1 1 0 0];
    P80 = [0 0 0 0 0 0 1 1];
    
    if strcmp(channelType, 'Cell')
        
        dirID(:, 2) = {[1 5 7 8 14 17:24 25 26 28 34:36 38 40 44:46 50 52 54:56 57 60:64 193:195 197:200 211 213 ],... %P76 RsR 1
            [4 6:8 14 21 22 24 28 34 38 40 41 44 45 50 53 193 195 200 205 211 213],... P76 Recall 2
            [6:8 14 21 22 28 34 45 50 53 56 59 64 197 200 211 213],... P76 RsR 3
            [1:3 5:10 12:16 18:22 24:28 30:33 36 38 46 49:56 59:62 64 193:200 202 208],... P79 RsR 1, all IT channels seem to have noise (ugh)
            [1:3 5:10 13:22 24 27 28 29 30 35 38 46 49:52 54:56 59 60 193 194 196:199 209:212 214 215 217:219 222],... P79 RsR 2
            [1 3 5:10 14:17 19:22 24 27 28 30 32 35 46 49:52 54 55 59 60 62 193:199 202 205 209:212 214 215 217:222],... P79 RsR 3
            [1 3 9 16:25 31 32 35 37:41 43 45:56 59 206 209:211 214 217 222:224],... P80 RsR 1
            [1:5 7 9:11 16:26 30:32 35 37:39 41:56 58 59 206 209 211 219 222:224]}; % P80 RsR 2
        
    elseif strcmp(channelType, 'NoNoise')
        % note these are manually chosen
        noiseChans = {[39], [], [33:47], [209:224], [220], [], [], []};
        bigSet = {P76Chans; P76Chans; P76Chans; P79Chans; P79Chans; P79Chans; P80Chans; P80Chans};
        for ch = 1:size(dirID, 1)
            dirID{ch,2} = setdiff(cell2mat(bigSet{ch}(:, 1)), noiseChans{ch});
        end
    end
    % C2_dirID(:, 3) = {'P76CS'; 'P76CS'; 'P76CS'; 'P79CS'; 'P79CS'; 'P79CS'; 'P80CS'; 'P80CS'};
    dirID(:, 3) = {'P76CSRec_ReScreen';  'P76CS_RecScreen3'; 'P76CSRec_ReScreen_3'; 'P79CS_ReScreen_1'; 'P79CS_ReScreen_3'; 'P79CS_ReScreen_4'; 'P80CS_ReScreenRecall'; 'P80CS_ReScreecRecall_2'};
    
    dirID(:, 4) = {P76Chans; P76Chans; P76Chans; P79Chans; P79Chans; P79Chans; P80Chans; P80Chans};
    
end

validSess = zeros(1, size(dirID, 1));

for p = 1:length(patIDs)
    if strcmp('P76CS', patIDs{p})
        validSess = validSess + P76;
    elseif strcmp('P79CS', patIDs{p})
        validSess = validSess + P79;       
    elseif strcmp('P80CS', patIDs{p})
        validSess = validSess + P80;
    end
end

if (max(validSess) > 1) 
    error('Fix inputted patient list');
else
    dirID = dirID(logical(validSess), :);
end

end