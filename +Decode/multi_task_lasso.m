function [prediction, W] =  multi_task_lasso(X, Y)
% Split data into training and testing

nr_folds = 10;
nr_tasks = length(X);
cv = cell(1,nr_tasks);

for i=1:nr_tasks
    cv{i} = cvpartition(size(X{i},1),'kFold',nr_folds);
end

perf_1_1 = [];
perf_1_2 = [];
perf_2_1 = [];
perf_2_2 = [];

for i=1:nr_folds
    
    X_tr = cell(1,nr_tasks);
    Y_tr = cell(1,nr_tasks);
    X_te = cell(1,nr_tasks);
    Y_te = cell(1,nr_tasks);
    
    for j=1:nr_tasks
        idx_test  = cv{j}.test(i);
        idx_train = cv{j}.training(i);
        
        X_tr{j}   = X{j}(idx_train,:);
        Y_tr{j}   = Y{j}(idx_train,:);
        X_te{j}   = X{j}(idx_test,:);
        Y_te{j}   = Y{j}(idx_test,:);
        
    end
    
    [W,C]        = Logistic_Lasso(X_tr, Y_tr, 0.001);
    [~,temp_1_1] = eval_MTL_accuracy(Y_te(1), X_te(1), W(:,1),C(:,1));
    [~,temp_1_2] = eval_MTL_accuracy(Y_te(2), X_te(2), W(:,1),C(:,1));
    [~,temp_2_1] = eval_MTL_accuracy(Y_te(1), X_te(1), W(:,2),C(:,2));
    [~,temp_2_2] = eval_MTL_accuracy(Y_te(2), X_te(2), W(:,2),C(:,2));
    
    
    perf_1_1(cv{1}.test(i)) = temp_1_1{1};
    perf_1_2(cv{2}.test(i)) = temp_1_2{1};
    perf_2_1(cv{1}.test(i)) = temp_2_1{1};
    perf_2_2(cv{2}.test(i)) = temp_2_2{1};
end



prediction.perf_1_1 = perf_1_1;
prediction.perf_1_2 = perf_1_2;
prediction.perf_2_1 = perf_2_1;
prediction.perf_2_2 = perf_2_2;




end


