%% script to compute spike quality metrics

% using Jie's code
% load in session list, compute spike metrics
% note can't just load in big cell structs because I don't keep the
% waveform etc. so need A**_sorted_new files

setDiskPaths

% task = 'Object_Screening';
% [sessID, ~, ~] = Utilities.sessionListAllTasks(task);

% all_tasks = {'Object_Screening', 'Recall_Task', 'ReScreen_Recall'};
all_tasks = {'Object_Screening', 'ReScreen_Recall'};

addpath(genpath(['Code' filesep 'osortTextUI']))

%% define sorted files - loop through sessions

IT_Only = true;
toPrint = false;
plotVisible = true;

cell_total_n = 0;
pair_total_n = 0;

for tsk = 1:length(all_tasks)

    task = all_tasks{tsk};
    [sessID, ~, ~] = Utilities.sessionListAllTasks(task);
    
for ss = 1:length(sessID)

    tic
%     fileList = dir([sessID{ss} filesep 'sort' filesep 'final' filesep '*_sorted_new.mat']);
    slashPos = strfind(sessID{ss}, filesep);
    patID = sessID{ss}(slashPos(1)+1:slashPos(2)-1);
    assert(strcmpi(patID(1), 'P') && strcmpi(patID(end-1:end), 'CS'))
    if IT_Only
        chans = Utilities.defineChannelListAllTasks(patID, {'LFFA', 'RFFA'});
    else
        chans = Utilities.defineChannelListAllTasks(patID);
    end
    chans = sortrows(chans);
    cnt = 0;
    for ch = 1:length(chans)
        if isfile([sessID{ss} filesep 'sort' filesep 'final' filesep 'A' num2str(chans(ch)) '_sorted_new.mat'])
            if cnt == 0
                fileList = dir([sessID{ss} filesep 'sort' filesep 'final' filesep 'A' num2str(chans(ch)) '_sorted_new.mat']);
                cnt = 1;
            elseif cnt ~= 0
                fileList(end+1, :) = dir([sessID{ss} filesep 'sort' filesep 'final' filesep 'A' num2str(chans(ch)) '_sorted_new.mat']);
            end
        end
    end
    n_files = length(fileList);

for file_n = 1:n_files
    %% load sorted spike information
    file = load([fileList(file_n).folder, filesep,fileList(file_n).name]);
    n_cells = length(file.useNegative);

    for cell_n = 1:n_cells
        
        cell_total_n = cell_total_n + 1;
        cluster_n = file.useNegative(cell_n);
        spk_indx = (file.assignedNegative == cluster_n);
        spk_timestamp = file.newTimestampsNegative(spk_indx); % in micro seconds
        spk_waveform = file.newSpikesNegative(spk_indx,:); 
    
        %% Propotion of ISI < 3ms
        spk_ISI = diff(spk_timestamp); % in micro seconds
        ISI3ms = sum((spk_ISI <= 3000))/length(spk_ISI);
        spk_quality(cell_total_n).ISI3ms = ISI3ms;
%         spk_quality(cell_n).ISI3ms = ISI3ms;

        %% Average firing rate
        record_duration = (max(spk_timestamp) - min(spk_timestamp))*10^-6; % in seconds
        fr = length(spk_timestamp)/record_duration; % in Hz
        spk_quality(cell_total_n).fr = fr;

        %% waveform peak SNR
        mWaveform = mean (spk_waveform);
        % SNR is root mean square divided by std of noise, adapted from Jan's and Ueli's codes
        SNR = calcSNR( mWaveform, file.stdEstimateOrig); % in osort
        SNRPeak = abs(max(mWaveform))./file.stdEstimateOrig;
        spk_quality(cell_total_n).SNR = SNR;
        spk_quality(cell_total_n).SNRPeak = SNRPeak;

        %% Coefficient-of-variation (CV2)
        spk_ISI_inSec = spk_ISI/10^6; % in secs
        CV = Utilities.calcCV(spk_ISI_inSec); % in the helpers folder   
        ignoreMode = 1;   
        CV2 = Utilities.calcCV2(spk_ISI_inSec, ignoreMode); % in the helpers folder
        spk_quality(cell_total_n).CV = CV;
        spk_quality(cell_total_n).CV2 = CV2;
    end
        
    %% projection test
    if n_cells > 1
      pairs = nchoosek(file.useNegative, 2);
      for pair_n = 1:size(pairs,1)
          pair_total_n = pair_total_n + 1;
          clNr1 = pairs(pair_n, 1);
          clNr2 = pairs(pair_n, 2);
          [d,~,~,~, ~] = figureClusterOverlap(file.allSpikesCorrFree, file.newSpikesNegative, file.assignedNegative, clNr1, clNr2, '', 3, '');  % in osort         
          ptest(pair_n) = d; 
          projtestTotal(pair_total_n) = d;
      end 
    end
end
toc
% fprintf('Finished for session: %d \n', ss);

end

fprintf('Finished for task: %s \n', task);

end
%% plot 
task = 'Object_Screening';
spk_quality_cell = permute(struct2cell(spk_quality), [3 1 2]);
flds = fields(spk_quality);

for ii = 1:length(fields(spk_quality))
        
    t1 = cell2mat(spk_quality_cell(:, ii));
    
    if plotVisible
        f = figure;
    else
        f = figure('Visible', 'off');
    end
    h = histogram(t1);
    h.FaceColor = [0 0 0];
    title(flds(ii))
    ylabel('Number of neurons')
    set(findobj(f,'type','axes'),'FontName','Arial','FontSize',16,'FontWeight','Bold', 'LineWidth', 1.2);
    if IT_Only
        filename = [diskPath filesep task filesep flds{ii} '_ITCells'];    
    else
        filename = [diskPath filesep task filesep flds{ii} '_allCells'];
    end
    
    if toPrint
        print(f, filename, '-dsvg', '-r300');
        close all
    end
    
end


% plot isoloation distance
if plotVisible
    f = figure;
else
    f = figure('Visible', 'off');
end
h = histogram(projtestTotal, 0:1:36);
h.FaceColor = [0 0 0];
set(findobj(f,'type','axes'),'FontName','Arial','FontSize',16,'FontWeight','Bold', 'LineWidth', 1.2);
title('isolation distance'); ylabel('Neuron pairs'); xlabel('Distance in s.d.')
if IT_Only
    filename = [diskPath filesep task filesep 'isolationDistance_ITCells'];
else
    filename = [diskPath filesep task filesep 'isolationDistance_allCells'];  
end
if toPrint
    print(f, filename, '-dsvg', '-r300')
    close all
end
