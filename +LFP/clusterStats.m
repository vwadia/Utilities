function [stats] = clusterStats(ppc_cond1, ppc_cond2, freqs)
% Code gifted to be (again) by Jonathan
% Makes use of fieldtrips freqstatistics functionality  to do
% cluster based permutation satistics and pick out significant frequency 
% clusters that are different between 2 conditions


% INPUTS:
%     1. ppc_cond1: ppc values across all neuron-channel combinations and frequencies in condition 1 (n_combinations x n_freq)
%     2. ppc_cond2: same for condition 2
%     3. freqs: all the frequencies ppc was computed for

% OUTPUTS:
%     1. stats 
        % From Jonathan
        % -----------------------------------------------------------------
        % in stats.poscluster.prob (or negclusters) you'll find the p-value for
        % each cluster (sorted by strongest cluster)
        % stats.posclusterslabelmat tells you which frequency belongs to which
        % cluster number
        % stats.mask contains logicals for all significant frequency indices of any
        % cluster

% vwadia modified from JDaume Feb2023

cond1 = [];
cond2 = [];

cond1.freq = freqs; % this should contain all your frequencies that you computed PPC for (vector 1 x n_freq)

cond1.dimord = 'subj_chan_freq'; % this is just FT stuff. FT needs to have a certain structure here to know which dimension to compute the statistics for. since we compute this over channel combinations, these are our "subjects"
cond1.time = 1;
cond1.label = {'null'};
cond2 = cond1;

cond1.sfcstat(:,1,:) = ppc_cond1; %
cond2.sfcstat(:,1,:) = ppc_cond2;

cfg                  = [];
cfg.channel          = 'all';% we only have "1", but without it this doesnt work...
cfg.latency          = 'all';% same here (you could run this function across time bins too (like for power or FR))
cfg.frequency        = 'all'; % here you could specify to only include certain frequencies. But it's better to use just all
cfg.method           = 'montecarlo'; %analytic montecarlo
cfg.statistic        = 'depsamplesT';
cfg.computeprob      = 'yes';
cfg.correctm         = 'cluster'; %cluster fdr no
cfg.clusteralpha     = 0.05; % this determines which freqs should be included into the cluster (if pvalue of the uncorrected t-test is lower than that value)
cfg.clusterstatistic = 'maxsum';
cfg.clustertail      = 0; %1 = right
cfg.tail             = 0; %1 = right
cfg.alpha            = 0.025; % alpha level for each cluster; since FT computes this separatly for right and left-sided clusters, this should be corrected for that
cfg.numrandomization = 10000; %
%     cfg.avgovertime      = 'yes';
cfg.avgoverfreq      = 'no';
cfg.avgoverchan      = 'yes';
cfg.parameter        = 'sfcstat';
cfg.spmversion       = 'spm12';

n_combinations = size(ppc_cond1,1);
design = zeros(2,2*n_combinations);
design(1,:) = repmat(1:n_combinations,1,2);
design(2,:) = mod(floor([0:(2*n_combinations-1)]/(n_combinations/1)),2)+1;

cfg.design   = design;
cfg.uvar     = 1;
cfg.ivar     = 2;

 [stats] = ft_freqstatistics(cfg, cond1,cond2);

end