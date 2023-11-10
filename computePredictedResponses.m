function [pred_resp, obs_resp] = computePredictedResponses(resp, params, all_inds, screenType, method)
% To compute predicted responses:
% 1. Take in n-1 resp, and n-1 x ndim parameter matrix
% 2. compute axis by multiplying them
% 3. compute predicted response by multiplying axis and left out 1xndim parameter
% vector
% 4. Store it and repeat this process until I have all the predicted
% responses
% vwadia May 2021

ndim1 = 25; % number of appearance dimension
% NIMAGE = ceil(length(all_inds)/2);
pred_resp = zeros(size(all_inds, 1), 1);

para = params(all_inds,:);
amp_dim = sqrt(sum(para.^2));

if strcmp(method, 'sta')
    if strcmp(screenType, 'Face')
        %     normalize shape-appearance separately preserving relative amplitude differences
        para = param_normalize(para, amp_dim, ndim1);
    elseif strcmp(screenType, 'Object')
        %     normalize each dimension separately
        para = param_normalize_per_dim(para, amp_dim, length(all_inds));
    end
end
% performing Leave-One-Out
for i = 1:length(all_inds)
    
    ind_train = setdiff(all_inds, i);
    ind_test = i;
    
    obs_resp(i, 1) = resp(i);
    

    fr_raw = resp(ind_train);
    resp_train_mean_sub = fr_raw - mean(fr_raw);
    resp_train = resp(ind_train);
    
    %% calculate STA axis using n-1 images
    if strcmp(method, 'sta')
        sta=resp_train_mean_sub'*para(ind_train, :);  % 1x50
    elseif strcmp(method, 'linear_regression') % is this right?? vwadia Jan2022
        X = [para(ind_train, :) ones(size(para(ind_train, :),1),1)];
        [b,~,~,~,~] = regress(resp_train_mean_sub, X);
        sta = b(1:end-1)';
    end
    %% calculate x_train
%     x_train = para_train*sta'; % liang just uses the full para matrix here
    X = para*sta'; % liang's way 
    
    

    %% fit linear model
%     p = polyfit(x_train, resp_train, 1); % then he inputs x_train(ind_train) here
    p = polyfit(X(ind_train, :), resp_train, 1); % then he inputs x_train(ind_train) here

    %% Use axis to predict response    
    pred_resp(i, 1) = polyval(p, X(ind_test, :)); %=p(1)*(para_test*sta') + p(2);
end

% splitting data in half 
% ind_train = all_inds(randperm(length(all_inds),1000));
% ind_test = setdiff(all_inds,ind_train);
% 
% obs_resp = resp(ind_test);
% 
% para_train = para(ind_train, :);
% para_test = para(ind_test, :);
% 
% fr_raw = resp(ind_train);
% resp_train = fr_raw - mean(fr_raw);

% %% calculate STA axis using subset of images
% sta = resp_train'*para_train;
% 
% %% calculate x_train
% x_train = para_train*sta';
% 
% %% fit linear model
% p = polyfit(x_train, resp_train, 1); %p(1) = a, p(2) = b 
% % mdl = fitlm(x_train, resp_train);
% % a = mdl.Coefficients{2, 1};
% % b = mdl.Coefficients{1, 1};
% %% Use axis to predict response
% pred_resp = p(1)*(para_test*sta') + p(2);
    


%% Helpers
function param = param_normalize(param, amp_dim, ndim1)
%%

ndim = size(param, 2);
% para = para./repmat(amp_dim, [NIMAGE 1]);

param(:,1:ndim1)=param(:,1:ndim1) / sqrt(sum(amp_dim(1:ndim1).^2)) / sqrt(2);
param(:, ndim1+1:ndim)=param(:, ndim1+1:ndim) / sqrt(sum(amp_dim(ndim1+1:ndim).^2)) / sqrt(2);



function param = param_normalize_per_dim(param, amp_dim, NIMAGE)
%% normalize each dimension separately 
%% Liang does this only - May2021
param = param./repmat(amp_dim, [NIMAGE 1]);
