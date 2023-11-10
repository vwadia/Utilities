function [pred_feat, obs_feat] = computePredictedNNFeatures(feat, fir, all_inds, method)
% Method to use image responses to predict model features for images
% Almost identical to comptePredictedResponses - the role of responses and
% features is reversed.
% INPUTS:
%     1. feat a 1 x ndim vector of features to a given image
%     2. fir - the responses matrix (nimg x ncells)
%     3. Indices of images
%     4. method to compute sta axis
% 
% OUTPUTS:
%     1. predicted features (via linear model)
%     2. observed features (same as feat inputted)
% vwadia Jan2022

% Note that feat needs to be zscored

pred_feat = zeros(size(all_inds, 1), 1);

para = fir(all_inds,:);
para = para./repmat(sqrt(sum(para.^2)), [length(all_inds) 1]); % normalizing

feat = zscore(feat);

% performing Leave-One-Out
for i = 1:length(all_inds)
    
    ind_train = setdiff(all_inds, i);
    ind_test = i;
    
    obs_feat(i, 1) = feat(i);
    

    feat_train = feat(ind_train); % if already zscored you don't have to change anything here
    
    
    % calculate STA axis using n-1 images    
    if strcmp(method, 'sta')
        sta=feat_train'*para(ind_train, :);  % 1x50
    elseif strcmp(method, 'linear_regression') 
        X = [para(ind_train, :) ones(size(para(ind_train, :),1),1)]; % fr matrix 
        [b,~,~,~,~] = regress(feat_train, X);
        sta = b(1:end-1)';
    end
    
    % calculate x_train
%     x_train = para_train*sta'; % liang just uses the full para matrix here
    X = para*sta'; % liang's way 
    
     % fit linear model
%     p = polyfit(x_train, resp_train, 1); % then he inputs x_train(ind_train) here
    p = polyfit(X(ind_train, :), feat_train, 1); % then he inputs x_train(ind_train) here

    % Use axis to predict response    
    pred_feat(i, 1) = polyval(p, X(ind_test, :)); %=p(1)*(para_test*sta') + p(2);
end




