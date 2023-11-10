function [cor] = returnCorrelationValues(fr_raw, params, options)

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
%     touse_fr = fr./std(fr); % already mean subtracted
    touse_fr = fr; % already mean subtracted
elseif strcmp(options.task, 'Recall_Task')
    touse_fr = options.CRResp;
%     im_fr = options.ScrnResp;    
%     if ~isequal(fr_raw(options.recalledStim), im_fr)
%         disp(options.cellIndex);
%     end
    touse_fr = touse_fr - mean(touse_fr); % don't want to subtract the mean from viewing...different conditions
%     touse_fr = touse_fr./std(touse_fr);
end
% PCA
COEFF = pca(para_sub_sta);

pc1 = para_sub_sta * COEFF(:,1); % projections on to principal orthogonal axis


if strcmp(options.task, 'Object_Screening')
    cor(1) = corr(value_sta_prj', touse_fr);
    cor(2) = corr(pc1, touse_fr);
elseif strcmp(options.task, 'Recall_Task')
    cor(1) = corr(value_sta_prj(options.recalledStim)', touse_fr); % note this is mean subtracted but not standardized
    cor(2) = corr(pc1(options.recalledStim), touse_fr); % note this is mean subtracted but not standardized
end
end