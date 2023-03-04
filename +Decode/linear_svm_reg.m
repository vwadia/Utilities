
function [predictions,groundtruth, Mdl] = linear_svm_reg(X,Y)
Lambda = logspace(-6,-0.5,10);
Mdl_cv    = fitclinear(X,Y,'ObservationsIn','rows','Learner','svm',...
         'KFold',10, 'Prior','uniform','Solver','sparsa',...
         'Regularization','lasso','Lambda',Lambda);
     
ce                    = kfoldLoss(Mdl_cv);
all_predictions       = kfoldPredict(Mdl_cv);
[~,idx_mdl]           = min(ce);
predictions           = all_predictions(:,idx_mdl);

Mdl_no_cv = fitclinear(X,Y,'ObservationsIn','rows','Learner','svm',...
         'Prior','uniform','Solver','sparsa',...
         'Regularization','lasso','Lambda',Lambda);
Mdl       = selectModels(Mdl_no_cv,idx_mdl);
groundtruth = Y;

end
