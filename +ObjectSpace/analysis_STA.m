function [ sta, ev] = analysis_STA(resp, param, method, alpha)
% [ sta, ev ] = analysis_STA(resp, param, method, alpha)
% STA analysis for single cell
% 
% INPUT:
%     method,: 'sta' or 'linear_regression'
% 
% OUTPUT: 
%     sta:
%     ev: explained variance
% Note that params need to be normalized for sta method - vwadia May 21

if nargin<3
    method = 'sta';
end
ndim = 50;

% added by varun August2022
amp_dim = sqrt(sum(param.^2));
amp_dim(amp_dim == 0) = 1;
param = param_normalize_per_dim(param, amp_dim, length(resp));

% ignore NaN
ind_nan = isnan(resp);
resp = resp(~ind_nan);
param = param(~ind_nan,:);

switch method
    case 'linear_regression'
        X = [param ones(size(param,1),1)]; 
        [b,~,~,~,stats] = regress(resp, X);
        sta = b(1:end-1)';
        ev = stats(1);
        
    case 'ridge_regression'
        resp = resp - mean(resp);
        cov_stim = param'*param;
        sta = (resp'*param)/(cov_stim+eye(ndim)*mean(diag(cov_stim))*alpha);
        ev = nan; 
        
    case 'sta' 
        resp = resp - mean(resp);
        sta = resp'*param;
        ev = nan;
%         ev = explained_variance_by_STA( sta, resp, param);

end

end


%% helper function
function param = param_normalize_per_dim(param, amp_dim, NIMAGE)
%% normalize each dimension separately 
%% Liang does this only - May2021
param = param./repmat(amp_dim, [NIMAGE 1]);
end
