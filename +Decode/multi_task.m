function [prediction, groundTruth,MDL] =  multi_task(X, Y)


% Add the bias term
for t = 1: length(X)
    X{t} = [X{t} ones(size(X{t}, 1), 1)]; % add bias.
end

% Split data into training and testing
training_percent         = 0.75;
[X_tr, Y_tr, X_te, Y_te] = mtSplitPerc(X, Y, training_percent);


% Which fititng method to use
eval_func_str = 'eval_MTL_accuracy';
higher_better = true; % need to maximize accuracy
cv_fold       = 5;
opts.maxIter  = 100;
param_range   = [0.001 0.01 0.1 1 10 100 1000 10000];
best_param = CrossValidation1Param(X_tr, Y_tr, 'Logistic_Lasso',...
             opts, param_range, ...
             cv_fold, eval_func_str, higher_better);

[W,C]       = Logistic_Lasso(X, Y, best_param);
prediction = eval_MTL_accuracy(X_te, Y_te, W,C);

MDL.W = W;
MDL.C = C;



end