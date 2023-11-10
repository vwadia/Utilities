function stimOrd_ax = returnOrderAlongAx(fr_raw, params, options, axis)
% This is a function to


para = params(options.ind_train,:);
amp_dim = sqrt(sum(para.^2)); % finding the norm of each dimension 1xndim
if strcmp(options.screenType, 'Object')
    para = param_normalize_per_dim(para, amp_dim, length(options.ind_train));
elseif strcmp(options.screenType, 'Face')
    para = param_normalize(para, amp_dim, ndim1);
end

ndim = size(para, 2);

fr = fr_raw - mean(fr_raw);
sta=fr'*para;

value_sta_prj = (sta/norm(sta))*para';


para_sub_sta = zeros(size(para));
for k=1:size(para,1);
    param_sta_prj = sta*(para(k,:)*sta')/(sta*sta'); % vector of params pojected onto STA
    para_sub_sta(k,:) = para(k,:) - param_sta_prj; % subtract STA component from param
end

% Note: standardizing makes no difference here
if strcmp(options.task, 'Object_Screening')
    touse_fr = fr; % already mean subtracted
elseif strcmp(options.task, 'Recall_Task')
    touse_fr = options.CRResp;
    touse_fr = touse_fr - mean(touse_fr); % don't want to subtract the mean from viewing...different conditions
    %     touse_fr = touse_fr./std(touse_fr);
end
% PCA
COEFF = pca(para_sub_sta);

pc1 = para_sub_sta * COEFF(:,1); % projections on to principal orthogonal axis


if strcmp(options.task, 'Object_Screening')
    if strcmp(axis, 'sta')
        [~, stimOrd_ax] = sort(value_sta_prj');%, touse_fr);e
    elseif strcmp(axis, 'ortho')
        [~, stimOrd_ax] = sort(pc1, touse_fr);
    end
elseif strcmp(options.task, 'Recall_Task')
    if strcmp(axis, 'sta')
        [~, stimOrd_ax] = sort(value_sta_prj(options.recalledStim)');
    elseif strcmp(axis, 'ortho')
        [~, stimOrd_ax] = sort(pc1(options.recalledStim)); % note this is mean subtracted but not standardized
    end
end
end

%% helpers

function param = param_normalize(param, amp_dim, ndim1)
%% normalize shape/appearance separately while keeping the relative amplitude within shape or appearance dimensions
%% stevens way - in the cell paper
ndim = size(param, 2);
% para = para./repmat(amp_dim, [NIMAGE 1]);

param(:,1:ndim1)=param(:,1:ndim1) / sqrt(sum(amp_dim(1:ndim1).^2)) / sqrt(2);
param(:, ndim1+1:ndim)=param(:, ndim1+1:ndim) / sqrt(sum(amp_dim(ndim1+1:ndim).^2)) / sqrt(2);
end

function param = param_normalize_per_dim(param, amp_dim, NIMAGE)
%% normalize each dimension separately 
%% Liang does this only - May2021
param = param./repmat(amp_dim, [NIMAGE 1]);
end
