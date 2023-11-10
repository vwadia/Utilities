function param = param_normalize_per_dim(param, amp_dim, NIMAGE)
%% normalize each dimension separately 
%% Liang does this only - May2021
param = param./repmat(amp_dim, [NIMAGE 1]);