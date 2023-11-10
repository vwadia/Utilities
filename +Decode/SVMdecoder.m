
function [predictions,groundtruth, CVMdl,negLoss,pscore] = SVMdecoder(X,Y)
% function [predictions,groundtruth, CVMdl,pscore] = SVMdecoder(X,Y)

Mdl = [];
negLoss = [];

% Using fitclinear - better when you have two groups
% CVMdl   = fitclinear(X, Y, 'ObservationsIn', 'rows', 'KFold', 10, 'Learner', 'svm'); %,'Prior','uniform','Learners',t);
% [predictions,pscore] = kfoldPredict(CVMdl);

% Using classwise pairwise decoding - when you have multiple groups this is better 
%  ------------------------------------------------------------
t    = templateSVM('Standardize',false,'KernelFunction','linear');
Mdl   = fitcecoc(X,Y,'Prior','uniform','Learners',t);
% tic
CVMdl = crossval(Mdl,'Kfold',length(unique(Y)));
% CVMdl = crossval(Mdl,'Leaveout', 'on');
% toc
[predictions,negLoss,pscore] = kfoldPredict(CVMdl); % gets produced by fitecoc
groundtruth = Y;

end
