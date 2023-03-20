function [accTrain,accTest] = classification_simple(Data,Labels, params)

[params,NbrRep] = Utilities.get_opt(params, 'NbrRep', 1 );
[params,k] = Utilities.get_opt(params, 'k', length(unique(Labels)));
[params,classifierType] = Utilities.get_opt(params, 'classifierType','diaglinear');
[params,flagErrorMatrix] = Utilities.get_opt(params, 'flagErrorMatrix',false);
[params,PCA_analysis] = Utilities.get_opt(params, 'PCA_analysis',true);
[params,flagLeaveOneOut] = Utilities.get_opt(params, 'flagLeaveOneOut',false);
[params,PCA_var_p] = Utilities.get_opt(params, 'PCA_var_p',85);
[params,random_perm] = Utilities.get_opt(params, 'random_perm',false);

%[params,flagAverageBeforePCA] = Utilities.argkeyval('flagAverageBeforePCA',params, true);
% Utilities.argempty(params);

NbrLabels = length(unique(Labels));

% Data in trials x features
% Labels in trials x 1 
    
%% decode cue - not working well at all, and very variable even if I average over 8 trials 

%figure(); gscatter(score(:,1), score(:,2), LabelsDecodeCue)
%PCA

if size(Data,1) ~= size(Labels,1)
    error('Wrong label size')
end

errTrain = zeros(NbrRep,k);
errTest = zeros(NbrRep,k);

for rep = 1:NbrRep
    
    if flagLeaveOneOut
        cv = cvpartition(size(Data,1),'LeaveOut');
    else
        cv = cvpartition(size(Data,1), 'KFold', k);
    end 
    
    %randomize trial labels
    if random_perm
        Labels = Labels(randperm(length(Labels)));
    end 

    for cvRun = 1:cv.NumTestSets %

        trIdx = find(cv.training(cvRun));
        teIdx = find(cv.test(cvRun));
        %TrainingSet
        DataTrain = Data(trIdx,:);
        
        %LabelsTrain(:,rep) = Labels(trIdx); 
        LabelsTrain = Labels(trIdx); 

        DataTest = Data(teIdx,:); 
        LabelsTestAll{:,cvRun,rep} = Labels(teIdx);
        LabelsTest = Labels(teIdx);


        if PCA_analysis
            [coeff, ~, ~,~, explained] = pca(DataTrain); 
            
            variance = cumsum(explained); 
            
            idx_90 = find(variance > PCA_var_p,1); 
            %idx_90
            PCA_DataTrain = DataTrain*coeff;
            PCA_DataTest = DataTest*coeff;
            DataTrain = PCA_DataTrain(:,1:idx_90);
            DataTest = PCA_DataTest(:,1:idx_90);
            %disp(['Performing PCA analysis: ' num2str(idx_90)])
            %figure(); gscatter(PCA_DataTrain(:,1), PCA_DataTrain(:,2), LabelsTrain)
            %figure(); gscatter(PCA_DataTrain(:,1), PCA_DataTrain(:,2), LabelsTrain)
        end 
        
        model = fitcdiscr(DataTrain, LabelsTrain, 'DiscrimType', params.classifierType);
        %model = fitcnb(DataTrain, LabelsTrain);

       % model = fitcdiscr(DataTrain, LabelsTrain, 'DiscrimType', 'diaglinear');

        PredictedTrainAll{:,cvRun,rep} = predict(model, DataTrain);
        PredictedTestAll{:,cvRun,rep} = predict(model, DataTest);
        PredictedTrain = predict(model, DataTrain);
        PredictedTest = predict(model, DataTest);
        
        errTrain(rep,cvRun) = 1-(nnz(LabelsTrain == PredictedTrain)/numel(LabelsTrain));
        errTest(rep,cvRun) = 1-(nnz(LabelsTest == PredictedTest)/numel(LabelsTest));
        
    end

end 

accTrain = 1-mean(squeeze(errTrain));
accTest = 1-mean(squeeze(errTest));



if params.flagErrorMatrix
    
    LabelsTest = cell2mat(LabelsTestAll);
    LabelsTest = LabelsTest(:);
    
    PredictedTestAll = cell2mat(PredictedTestAll);
    PredictedTestAll = PredictedTestAll(:);
    figure()
    C = confusionmat(LabelsTest, PredictedTestAll);
    confusionchart(C)
    %disp(['Classification ITI correct: ' num2str(C(1)/sum(C(1,:))*100)])
    %disp(['Classification Speech correct: ' num2str(C(2,2)/sum(C(1,:))*100)])

    %ErrorMatrix = classification.misclassification(LabelsTest, PredictedTestAll);
    %Names = num2str(unique(LabelsTest));
    %Names = utile.label_number_to_grasp_name(unique(LabelsTest));
    %utile.plot_error_matrix(ErrorMatrix, Names , '');
end


end

