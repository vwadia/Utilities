function projVals = grab_AxisProj_Values(resp, params, options)
% This function takes in params, responses to all images for axis computation
% Then it computes the values of STA nad ortho ax projections and returns that list - sorted by firing rate.
%
% Inputs:
%     1. Responses 
%     2. Params (image features)
%     3. Options struct (to specify type of screening and which dimension you want average)
%     
% Outputs:
%     1. A Nx3 matrix with the first column = STA projection values and the second = ortho proj values (sorted by FR)
%         and the 3rd = order of indices 
%
% vwadia Nov2022
ndim1 = 25; % number of appearance dimension

fr_raw = resp(options.ind_train);
fr = fr_raw - mean(fr_raw);

nstim = length(fr);

%% STA
para = params(options.ind_train,:);
amp_dim = sqrt(sum(para.^2)); % finding the norm of each dimension 1xndim
if strcmp(options.screenType, 'Object')
    para = param_normalize_per_dim(para, amp_dim, length(options.ind_train));
elseif strcmp(options.screenType, 'Face')
    para = param_normalize(para, amp_dim, ndim1);
end

ndim = size(para, 2);
 
sta=fr'*para; 

value_sta_prj = (sta/norm(sta))*para'; 

%% principal orthogonal axis 
para_sub_sta = zeros(size(para));
for k=1:size(para,1);
    param_sta_prj = sta*(para(k,:)*sta')/(sta*sta'); % vector of params pojected onto STA 
    para_sub_sta(k,:) = para(k,:) - param_sta_prj; % subtract STA component from param
end

% PCA
COEFF = pca(para_sub_sta);

pc1 = para_sub_sta * COEFF(:,1);


[sorted_fr, reorder_ind] = sort(fr);

if isfield(options, 'reorder') && options.reorder ~= 0
    x = value_sta_prj(reorder_ind); % sort by firing rate
    y = pc1(reorder_ind);
else
    x = value_sta_prj;
    y = pc1;
end

projVals = [x' y reorder_ind];


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







