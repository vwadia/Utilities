% Leave one trial out decoding

function accuracy = LFPdecodeSVM(features,labels,trials)

nrUniqueTrials = unique(trials);
correct        = [];

for i=1:length(nrUniqueTrials)

    testing           =  ismember(trials,nrUniqueTrials(i));
    training          = ~testing;
    Mdl1              =  fitcsvm(features(training,:),...
                         labels(training),'Standardize',true);
    [~,scores]        =  predict(Mdl1,features(testing,:));
    match             =  scores(:,1)<0 == labels(testing);
    
    correct           =  [correct; match];
    
    
end

accuracy = sum(correct)./length(correct);

end