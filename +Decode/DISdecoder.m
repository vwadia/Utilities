%  Features is in the form [num_examples x num_features]
%  Labels is in the form [num_examples x 1]
function [predictions,groundtruth] = DISdecoder(features,labels)


% Remap labels values to discrete categorical levels
predictions   = NaN(size(features,1),1);
groundtruth   = NaN(size(features,1),1);
nr_partitions = 20;
c             = cvpartition(length(labels),'KFold',nr_partitions);



% Try leave-one-trial-out classification
for i=1:nr_partitions

    trainingset          = c.training(i);
    testset              = c.test(i);
    disModel             = fitcdiscr(features(trainingset,:),...
                           labels(trainingset),'discrimType','pseudoLinear');

    
    
    
    phat                 = predict(disModel,features(testset,:));
    predictions(testset) = phat;
    groundtruth(testset) = labels(testset);
    
    
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


