
function [predictions,groundtruth, Mdl,negLoss] = linear_svm(X,Y)

Mdl = fitclinear(X,Y,'ObservationsIn','rows','Learner','svm',...
      'KFold',20, 'Prior','uniform','Solver','sparsa',...
      'Regularization','lasso','Lambda','auto');
[predictions,negLoss] = kfoldPredict(Mdl);
groundtruth = Y;

end
