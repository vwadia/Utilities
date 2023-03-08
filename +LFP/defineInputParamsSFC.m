function [params] = defineInputParamsSFC(cellArea, lfpArea, valid_lfpChans, sessDir, scale, cellGroup, diskPath)
% Choosing input parameters for SFC
% conditions, regions, sessions
%
%     INPUTS:
%         1. cellArea - region to grab spikes (string)
%         2. lfpArea - region to grab channels (string)
%         3. lfpChans - channel set (pre-selected)
%         4. Dir - path to session
%         5. scale - 'log' or 'linear' for Jonathans ppc function
%     OUTPUTS:
%         1. params - struct to pass to other functions
% vwadia Jan2023

%  if nargin == 8, valid_chans = ones(1, length(lfpChans)); end % keep all channels
params = struct;
% basic params 
[params, high_pass]     = Utilities.get_opt(params,'high_pass',true); % struct, field, value
[params, notch]         = Utilities.get_opt(params,'notch',true); % 60hz notch filter
[params, FsDown]        = Utilities.get_opt(params, 'FsDown', 1000);
[params, low_freq]        = Utilities.get_opt(params, 'low_freq', 3);
[params, high_freq]        = Utilities.get_opt(params, 'high_freq', 100);
[params, scale]        = Utilities.get_opt(params, 'scale', scale);
[params, cellGroup]        = Utilities.get_opt(params, 'cells', cellGroup);
[params, diskPath]        = Utilities.get_opt(params, 'diskPath', diskPath);

% directory params
[params, sessDir]       = Utilities.get_opt(params, 'sessDir', sessDir);

% brain area params
[params, cellArea]       = Utilities.get_opt(params, 'cellArea', cellArea);
[params, lfpArea]       = Utilities.get_opt(params, 'lfpArea', lfpArea); % for example
[params, valid_lfpChans]      = Utilities.get_opt(params, 'lfpChans', valid_lfpChans);
[params,run_boot]       = Utilities.get_opt(params,'run_boot','true'); % surrogate distribution for sfc
[params,cutOffSpikeVal]       = Utilities.get_opt(params,'cutOffSpikeVal', 50); % change to 0 if not needed 
[params, balance_spikes] = Utilities.get_opt(params,'balance_spikes','true'); % surrogate distribution for sfc

% maybe something like this is good?
if strcmp(cellArea, lfpArea)
    params.local = 'true';
else
    params.local = 'false';
end

end

