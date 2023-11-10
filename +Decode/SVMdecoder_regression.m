
function [predictions,groundtruth, Mdl,negLoss,pscore] = SVMdecoder_regression(X,Y)


CVMdl = fitrsvm(X,Y,'Standardize',false,'KFold',5,...
         'KernelFunction','linear'); 
predictions = kfoldPredict(CVMdl);
groundtruth = Y;
Mdl         = CVMdl;
negLoss     = [];
pscore      = [];



end
