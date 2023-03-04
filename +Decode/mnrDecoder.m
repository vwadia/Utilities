function [predictions,groundtruth] = mnrDecoder(features,labels)


% Remap labels values to discrete categorical levels
predictions   = NaN(size(features,1),1);
groundtruth   = NaN(size(features,1),1);
nr_partitions = 20;
c             = cvpartition(length(labels),'KFold',nr_partitions);
unique_levels = unique(labels);
new_labels    = get_new_labels(labels);


% Try leave-one-trial-out classification
for i=1:nr_partitions

    trainingset          = c.training(i);
    testset              = c.test(i);
    
    trainingset          = balanceTrainingSet(trainingset,new_labels);
  
    
    [B,~,stats]          = mnrfit(features(trainingset,:),...
                           new_labels(trainingset,:));
    [phat,~,~]           = mnrval(B,features(testset,:),stats);
    [~,idx]              = max(phat,[],2);
    
    predictions(testset) = unique_levels(idx);
    groundtruth(testset) = labels(testset);

end


end

% HELPERS
function trainingset = balanceTrainingSet(trainingset,labels)

trainingidfeatures   = find(trainingset);
trainingLabels       = labels(trainingset);

uniqueCategories     = unique(labels);
counts               = hist(trainingLabels,numel(uniqueCategories));
[minSamples,idfeatures]  = min(counts); % Smallest categorlabels

remove = [];

for i=1:numel(uniqueCategories)
    
    % Onllabels remove training samples from the categories that have too manlabels
    if ~ismember(i,idfeatures)
        
        temp           = find(trainingLabels==uniqueCategories(i));
        labelstoremove = randperm(length(temp),length(temp)-minSamples);
        
        
        
        remove     = cat(1,remove, trainingidfeatures(temp(labelstoremove)));
        
    end

end

trainingset(remove) = false;

end


function new_labels   = get_new_labels(labels)

levels     = unique(labels);
new_labels = NaN(size(labels));

for i=1:length(levels)
    new_labels(ismember(labels,levels(i))) = i;  
end



end