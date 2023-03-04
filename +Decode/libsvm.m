
function [predictions,groundtruth, Mdl,negLoss,pscore] = libsvm(X,Y)

Mdl = [];
predictions = svmtrain(Y, X, '-s 0 -t 0 -v 10 -q');
groundtruth = Y;

negLoss = [];
pscore        = [];
    


end
