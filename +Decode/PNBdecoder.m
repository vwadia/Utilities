%  Features is in the form [num_examples x num_features]
%  Labels is in the form [num_examples x 1]
function [predictions,groundtruth] = PNBdecoder(features,labels)

% Remap labels values to discrete categorical levels
predictions   = NaN(size(features,1),1);
groundtruth   = NaN(size(features,1),1);
new_labels    = make_new_labels(labels);
c             = cvpartition(length(labels),'LeaveOut');


% Try leave-one-trial-out classification
for i=1:length(labels)

    trainingset          = c.training(i);
    testset              = c.test(i);

    % Make sure the training set is balanced, if not then sample from the 
    % larger groups until all classes have the same number of training
    % samples. 
    trainingset          = balanceTrainingSet(trainingset,new_labels);
    
     % Initialize devoder
    cl = poisson_naive_bayes_CL;
    cl = train(cl, features(trainingset,:)', new_labels(trainingset,:));
    
    % Test the decoder
    [predicted_labels,~] = test(cl, features(testset,:)');
    predictions(testset) = predicted_labels;
    groundtruth(testset) = new_labels(testset);
end

 
end % Main Function


% HELPERS
function trainingset = balanceTrainingSet(trainingset,labels)

trainingidx          = find(trainingset);
trainingLabels       = labels(trainingset);

uniqueCategories     = unique(labels);
counts               = hist(trainingLabels,numel(uniqueCategories));
[minSamples,idx]     = min(counts); % Smallest category

remove = [];

for i=1:numel(uniqueCategories)
    
    % Only remove training samples from the categories that have too many
    if ~ismember(i,idx)
        
        temp           = find(trainingLabels==uniqueCategories(i));
        labelstoremove = randperm(length(temp),length(temp)-minSamples);
        remove     = cat(1,remove, trainingidx(temp(labelstoremove)));
        
    end

end

trainingset(remove) = false;

end
function new_labels = make_new_labels(labels)

unique_levels = unique(labels);
new_labels    = NaN(length(labels),length(unique_levels));

for i=1:length(unique_levels)
    new_labels(:,i) = i*ismember(labels,unique_levels(i));
end

new_labels = sum(new_labels,2);

end


