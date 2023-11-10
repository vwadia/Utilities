function [params] = defineInputParamsReactivation(sessDir, BlineType, method, perStim, IT_Only)
% Choosing input parameters for Reactivation
% How to compute - BlineType, Threshold vs Ranksum, Per Stim comparison
% IT Cells only
% CutOffFR for cells
%
%     INPUTS:
%         1. sessDir - session in question
%         2. BlineType - encoding baseline (1), PreCR baseline (2), PreTrial baseline (3)
%         3. method - Threshold, Anova, Ranksum
%         4. perstim - for Threshold per stim baseline, for ranksum per stim comparison
%         5. IT Cells only (or all)
%     OUTPUTS:
%         1. params - struct to pass to other functions
% vwadia June2023

params = struct;

dbstop if error
[~, host] = system('hostname');
if strcmp(host(1:end-1), 'DWA644201')
    diskPath = 'G:\SUAnalysis';
elseif strcmp(host(1:end-1), 'DESKTOP-LJHLIED')
    diskPath = 'G:\SUAnalysis';
elseif strcmp(host(1:end-1), 'VarunWadia') % Ubuntu 18.04
    diskPath = '/media/vwadia/T7/SUAnalysis';
else % mac
    diskPath = '/Volumes/T7/SUAnalysis';
end


% directory params
[params, diskPath]          = Utilities.get_opt(params, 'diskPath', diskPath);
[params, sessDir]         = Utilities.get_opt(params, 'sessDir', sessDir);

% basic params Threshold, Anova, Ranksum
[params, perStim]         = Utilities.get_opt(params, 'perStim', perStim);
[params, BlineType]       = Utilities.get_opt(params, 'BlineType', BlineType);

% exclude ceclls with FR below this
[params,cutOffFR]       = Utilities.get_opt(params,'cutOffSpikeVal', 0.5); % change to 0 if not needed 

% correlation params - to cpmute corr w/ screening or just with enc
[params,scrnCorr]       = Utilities.get_opt(params,'cutOffSpikeVal', false); 

if strcmpi(method, 'threshold')
    [params, useThreshold]        = Utilities.get_opt(params, 'useThreshold', true);
    [params, useRanksum]        = Utilities.get_opt(params, 'useRanksum', false);
    [params, useAnova]            = Utilities.get_opt(params, 'useAnova', false);
    
elseif strcmpi(method, 'ranksum')
    [params, useThreshold]        = Utilities.get_opt(params, 'useThreshold', false);
    [params, useRanksum]        = Utilities.get_opt(params, 'useRanksum', true);
    [params, useAnova]            = Utilities.get_opt(params, 'useAnova', false);
    
elseif strcmpi(method, 'anova')
    [params, useThreshold]        = Utilities.get_opt(params, 'useThreshold', false);
    [params, useRanksum]        = Utilities.get_opt(params, 'useRanksum', false);
    [params, useAnova]            = Utilities.get_opt(params, 'useAnova', true);
    
end
end
