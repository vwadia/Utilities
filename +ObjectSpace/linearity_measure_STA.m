function [p_pearson, pearsSpearRatio] = linearity_measure_STA(resp, params, options)
% This function a stripped away version of STA_figure_original.
% The point being to take in responses from a given time bin and just return the p value 
% of the linear correlation.
%
% Inputs:
%     1. Responses 
%     2. Params (image features)
%     3. Options struct 
%         a. to delineate type of screening and hence normalization)
%     
% Outputs:
%     1. significance of ramp
%     2. the ratio of the pearson (linear) and spearman (rank order monotonic) correlation 
% vwadia July2021



fr_raw = resp(options.ind_train);
fr = fr_raw - mean(fr_raw);

nstim = length(fr);

%% Compute STA
para = params(options.ind_train,:);
amp_dim = sqrt(sum(para.^2)); % finding the norm of each dimension 1xndim
if strcmp(options.screenType, 'Object')
    para = param_normalize_per_dim(para, amp_dim, length(options.ind_train));
elseif strcmp(options.screenType, 'Face')
    ndim1 = floor(size(para, 2)/2);
    para = param_normalize(para, amp_dim, ndim1);
end
ndim = size(para, 2);
 
sta=fr'*para;

value_sta_prj = (sta/norm(sta))*para'; 

%% shuffled control for sta
n_repeats = 500;
cc_rand = zeros(n_repeats,1);
sta_shuffle = zeros(n_repeats,ndim);

for i=1:n_repeats
    
    para_shuffle = para(randsample(nstim, nstim),:);
    sta_shuffle(i,:) = fr'*para_shuffle;
    
    value_sta_shuffle = sta_shuffle(i,:)*para_shuffle';
    cc_rand(i) = corr(value_sta_shuffle',fr);

end


% %% Repeat for pval distribution (if needed)
% if isfield(options, 'pvalDist') && isfield(options, 'imageIDs') && isfield(options, 'n_reps')
%     
%     for n = 1:options.n_reps
%         options.ind_train = sortrows(randsample(options.imageIDs, length(options.ind_train), false));
%         
%         para = params(options.ind_train,:);
%         amp_dim = sqrt(sum(para.^2)); % finding the norm of each dimension 1xndim
%         if strcmp(options.screenType, 'Object')
%             para = param_normalize_per_dim(para, amp_dim, length(options.ind_train));
%         elseif strcmp(options.screenType, 'Face')
%             ndim1 = floor(size(para, 2)/2);
%             para = param_normalize(para, amp_dim, ndim1);
%         end  
%         
%         sta=fr'*para;
%         
%         value_sta_prj = (sta/norm(sta))*para';
%         cc(n) = corr(value_sta_prj',fr); % pearson
%         p_pearson(n) = sum(cc_rand > cc(n))/length(cc_rand);
%         cc_spear(n) = corr(value_sta_prj',fr, 'type', 'Spearman'); % spearman
% 
%     end
%     
%     pearsSpearRatio = mean(cc)/mean(cc_spear);
%     
%    
% 
% else 

cc = corr(value_sta_prj',fr); % pearson
cc_spear = corr(value_sta_prj',fr, 'type', 'Spearman'); % spearman
p_pearson = sum(cc_rand > cc)/length(cc_rand);
pearsSpearRatio = cc/cc_spear;
 
% end

function param = param_normalize(param, amp_dim, ndim1)
%% normalize shape/appearance separately while keeping the relative amplitude within shape or appearance dimensions
%% stevens way - in the cell paper
ndim = size(param, 2);
% para = para./repmat(amp_dim, [NIMAGE 1]);

param(:,1:ndim1)=param(:,1:ndim1) / sqrt(sum(amp_dim(1:ndim1).^2)) / sqrt(2);
param(:, ndim1+1:ndim)=param(:, ndim1+1:ndim) / sqrt(sum(amp_dim(ndim1+1:ndim).^2)) / sqrt(2);


function param = param_normalize_per_dim(param, amp_dim, NIMAGE)
%% normalize each dimension separately 
%% Liang does this only - May2021
param = param./repmat(amp_dim, [NIMAGE 1]);
