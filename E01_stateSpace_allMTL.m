% trialNum: N x S x D
% firingRates: N x S x D x T x maxTrialNum
% firingRatesAverage: N x S x D x T
%
% N is the number of neurons
% S is the number of stimuli conditions (F1 frequencies in Romo's task)
% D is the number of decisions (D=2)
% T is the number of time-points (note that all the trials should have the
% same length in time!)
%
% trialNum -- number of trials for each neuron in each S,D condition (is
% usually different for different conditions and different sessions)
%
% firingRates -- all single-trial data together, massive array. Here
% maxTrialNum is the maximum value in trialNum. E.g. if the number of
% trials per condition varied between 1 and 20, then maxTrialNum = 20. For
% the neurons and conditions with less trials, fill remaining entries in
% firingRates with zeros or nans.
%
% firingRatesAverage -- average of firingRates over trials (5th dimension).
% If the firingRates is filled up with nans, then it's simply
%    firingRatesAverage = nanmean(firingRates,5)
% If it's filled up with zeros (as is convenient if it's stored on hard 
% drive as a sparse matrix), then 
%    firingRatesAverage = bsxfun(@times, mean(firingRates,5), size(firingRates,5)./trialNum)
clear all

% load cells
% BCellList = dir('/Users/jie/Dropbox/Jie/Manuscript/MemSeg/Figures/Fig3/Fig3a_BCellExample/BCell_BAligned/units/*.mat');
BCellList = dir('G:\SUAnalysis\JieEventSeg_Data\BCell_BAligned\*.mat');
ECellList = dir('/Users/jie/Dropbox/Jie/Manuscript/MemSeg/Figures/Fig3/Fig3b_ECellExample/ECell_BAligned/units/*.mat');
otherCellList = dir('/Users/jie/Dropbox/Jie/Manuscript/MemSeg/Figures/Fig5/Fig5abc_SS3d/otherCells/*.mat');
n_BCells = length(BCellList);
n_ECells = length(ECellList);
n_otherCells = length(otherCellList);
n_cells = n_BCells;% + n_ECells + n_otherCells;
n_times = 151;     % number of time points
n_BTypes = 3;      % number of boundary types: NB, SB, HB
n_maxTrial = 75;   % maximal number of trial repetitions

% trialNum: n_cells x n_BTypes (1: NB; 2:SB; 3:HB)
% firingRates: n_cells x n_BTypes x n_times x n_maxTrial
% firingRatesAverage: nanmean(firintRates, 4), n_cells x n_BTypes x n_times
trialNum = nan(n_cells, n_BTypes);
firingRates = nan(n_cells, n_BTypes, n_times, n_maxTrial);
for cell_n = 1:n_BCells
    load([BCellList(cell_n).folder, '/',BCellList(cell_n).name], 'spks_per_trial');   
    % Normalize the data
    spks_per_trial = smoothdata(spks_per_trial, 2,'gaussian',20); % smoothing data in each row of spks_per_trial with a size 20 gaussian window
    spk_mean = mean(spks_per_trial,2); 
    spk_std = std(spks_per_trial,[], 2);
    spk_std(spk_std == 0) = 1;
    spks_per_trial_norm = (spks_per_trial - repmat(spk_mean, 1, 150))./(repmat(spk_std, 1,150));
    firingRates(cell_n,3,:,1:30) = spks_per_trial_norm(1:30,:)'; % HB
    firingRates(cell_n,2,:,1:75) = spks_per_trial_norm(31:105,:)'; % SB
    firingRates(cell_n,1,:,1:30) = spks_per_trial_norm(106:135,:)'; % NB
    trialNum(cell_n, 3) = 30;
    trialNum(cell_n, 2) = 75;
    trialNum(cell_n, 1) = 30;
end

for cell_n = 1:n_ECells
    load([ECellList(cell_n).folder, '/',ECellList(cell_n).name], 'spks_per_trial');   
    % Normalize the data
    spks_per_trial = smoothdata(spks_per_trial, 2,'gaussian',20);
    spk_mean = mean(spks_per_trial,2); 
    spk_std = std(spks_per_trial,[], 2);
    spk_std(spk_std == 0) = 1;
    spks_per_trial_norm = (spks_per_trial - repmat(spk_mean, 1, 151))./(repmat(spk_std, 1,151));
    firingRates(cell_n+n_BCells,3,:,1:30) = spks_per_trial_norm(1:30,:)'; % HB
    firingRates(cell_n+n_BCells,2,:,1:75) = spks_per_trial_norm(31:105,:)'; % SB
    firingRates(cell_n+n_BCells,1,:,1:30) = spks_per_trial_norm(106:135,:)'; % NB
    trialNum(cell_n+n_BCells, 3) = 30;
    trialNum(cell_n+n_BCells, 2) = 75;
    trialNum(cell_n+n_BCells, 1) = 30;
end

for cell_n = 1:n_otherCells
    load([otherCellList(cell_n).folder, '/',otherCellList(cell_n).name], 'spks_per_trial');   
    % Normalize the data
    spks_per_trial(135, :) = spks_per_trial(134,:);
    spks_per_trial(:, 151) = spks_per_trial(:, 150);
    spks_per_trial = smoothdata(spks_per_trial, 2,'gaussian',20);
    spk_mean = mean(spks_per_trial,2); 
    spk_std = std(spks_per_trial,[], 2);
    spk_std(spk_std == 0) = 1;
    spks_per_trial_norm = (spks_per_trial - repmat(spk_mean, 1, 151))./(repmat(spk_std, 1,151));
    firingRates(cell_n+n_BCells+n_ECells,3,:,1:30) = spks_per_trial_norm(1:30,:)'; % HB
    firingRates(cell_n+n_BCells+n_ECells,2,:,1:75) = spks_per_trial_norm(31:105,:)'; % SB
    firingRates(cell_n+n_BCells+n_ECells,1,:,1:30) = spks_per_trial_norm(106:135,:)'; % NB
    trialNum(cell_n+n_BCells+n_ECells, 3) = 30;
    trialNum(cell_n+n_BCells+n_ECells, 2) = 75;
    trialNum(cell_n+n_BCells+n_ECells, 1) = 30;
end

% computing PSTHs
firingRatesAverage = nanmean(firingRates, 4);

%% Define parameter grouping

% For two parameters (e.g. stimulus and time, but no decision), we would have
% firingRates array of [N S T E] size (one dimension less, and only the following
% possible marginalizations:
%    1 - stimulus
%    2 - time
%    [1 2] - stimulus/time interaction
% They could be grouped as follows: 
%    combinedParams = {{1, [1 2]}, {2}};

% Time events of interest (e.g. stimulus onset/offset, cues etc.)
% They are marked on the plots with vertical lines

combinedParams = {{1, [1 2]}, {2}};
margNames = {'BType', 'Time'};
margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

time = -0.5:(1.5/150):1; % the length of a trial
timeEvents = time(round(length(time)/2)); % the time a boundary happens in her case 

% check consistency between trialNum and firingRates
for n = 1:size(firingRates,1)
    for s = 1:size(firingRates,2)
            assert(isempty(find(isnan(firingRates(n,s,:,1:trialNum(n,s))), 1)), 'Something is wrong!')
    end
end

%% PCA of the dataset

X = firingRatesAverage(:,:);
X = bsxfun(@minus, X, mean(X,2));

[W,S,V] = svd(X, 'econ');

% computing explained variance
% you input the same W as both the encoder and decoder?
% Note: corrected by varun 11/2/21
explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
    'combinedParams', combinedParams); 
% old incorrect code
% explVar = dpca_explainedVariance(firingRatesAverage, W, W, ...
%     'combinedParams', combinedParams); 


% loadings in each PC
X = firingRatesAverage(:,:)';
Xcen = bsxfun(@minus, X, mean(X));
Z = Xcen * W;
componentsToPlot = find(explVar.cumulativePCA < 100);
dataDim = size(firingRatesAverage);
Zfull = reshape(Z(:,componentsToPlot)', [length(componentsToPlot) dataDim(2:end)]); % n_PCs x n_BTypes x n_times
NB_PC = squeeze(Zfull(:,3,:));
SB_PC = squeeze(Zfull(:,2,:));
HB_PC = squeeze(Zfull(:,1,:));

%% plot the top three PC components
HB_color = [255,99,71]./255;
SB_color = [100,149,237]./255;
NB_color = [102 204 0]./255;
figure('rend','painters','pos',[10 10 450 400]) % NB
plot3(NB_PC(1,:),NB_PC(2,:),NB_PC(3,:),  'LineWidth', 4, 'color', NB_color);
axis([-10 10 -10 10 -4 4]);
view(20, 30)
set(gca, 'LineWidth', 1.5, 'FontSize', 20, 'FontWeight', 'bold');
box on
grid on
saveas(gcf, 'MTL_pca_BAligned_NB.png');

figure('rend','painters','pos',[10 10 450 400]) % SB
plot3(SB_PC(1,:),SB_PC(2,:),SB_PC(3,:),  'LineWidth', 4, 'color', SB_color);
axis([-10 10 -10 10 -4 4]);
view(20, 30)
set(gca, 'LineWidth', 1.5, 'FontSize', 20, 'FontWeight', 'bold');
box on
grid on
saveas(gcf, 'MTL_pca_BAligned_SB.png');

figure('rend','painters','pos',[10 10 450 400]) % HB
plot3(HB_PC(1,:),HB_PC(2,:),HB_PC(3,:),  'LineWidth', 4, 'color', HB_color);
axis([-10 10 -10 10 -4 4]);
view(20, 30)
set(gca, 'LineWidth', 1.5, 'FontSize', 20, 'FontWeight', 'bold');
box on
grid on
saveas(gcf, 'MTL_pca_BAligned_HB.png');

%% plot the MDD

MDD_NB = sqrt(sum((NB_PC(1:3, :) - repmat(NB_PC(1:3,50),1,n_times)).^2));
MDD_SB = sqrt(sum((SB_PC(1:3, :) - repmat(SB_PC(1:3,50),1,n_times)).^2));
MDD_HB = sqrt(sum((HB_PC(1:3, :) - repmat(HB_PC(1:3,50),1,n_times)).^2));

figure('rend','painters','pos',[10 10 450 200])
plot(MDD_NB, 'LineWidth', 4, 'color', NB_color); hold on
plot(MDD_SB, 'LineWidth', 4, 'color', SB_color);
plot(MDD_HB, 'LineWidth', 4, 'color', HB_color);
plot([51 51], [0 10], 'k-.', 'LineWidth', 2);
ylim([0 10])
set(gca, 'XTick', [1 51 151], 'XTickLabel', [-0.5 0 1], 'LineWidth', 1.5, 'FontSize', 20, 'FontWeight', 'bold');
xlabel('Time from boundary (s)')
ylabel('MDD');
saveas(gcf,'MTL_MDD_BAligned.png');






















