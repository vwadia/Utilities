% Naive Bayes Classifier

function [params,confusionMat] = decodeCategory(features,labels,criteria,...
                                             method)

                                         

X            = features(all(criteria,2),:); % firing rate
Y            = labels(all(criteria,2)); % class labels
params       = struct('prediction',[],'gt',[],'mdl',[]);

switch method
    
    % 1.  Naive Bayes method for decoding
    case 'naiveBayes'
        [prediction, groundTruth] =  Decode.naive_bayes(X, Y);
        confusionMat = confusionmat(groundTruth,prediction);
        
    % 2.  Poisson Naive Bayes
    case 'poisson-nb'
        [prediction, groundTruth] =  Decode.PNBdecoder(X, Y);
        %prediction   = generatePrediction(MDL,'poisson-nb', unique(labels));
        confusionMat = confusionmat(groundTruth,prediction);
        
    % 3. Discriminant Analysis
    case 'dis-analysis'
        [prediction,groundTruth] = Decode.DISdecoder(X,Y);
        confusionMat = confusionmat(groundTruth,prediction);
        
    % 4. Logistic regression using time since last spike as a feature
    case 'multinomial'
          [prediction,groundTruth] = Decode.mnrDecoder(X,Y);
          confusionMat = confusionmat(groundTruth,prediction);
 
    % 5. Support-vector machines
    case 'svm'
       [prediction, groundTruth,mdl,~,pScore] =  Decode.SVMdecoder(X, Y);
        confusionMat = confusionmat(groundTruth,prediction);
        % 5. Support-vector machines
    case 'svm_regression'
       [prediction, groundTruth,mdl,~,pScore] =  Decode.SVMdecoder_regression(X, Y);
        confusionMat = confusionmat(groundTruth,prediction);     
    case 'svm_mdl'
       mdl =  Decode.SVMdecoder_mdl(X, Y);
       prediction = []; groundTruth = []; confusionMat = [];
        
    case 'glm'
        [prediction, groundTruth] =  Decode.glm(X, Y);
        confusionMat = confusionmat(groundTruth,prediction);
        
    case 'decision_tree' % decision trees
        [prediction, groundTruth] =  Decode.dtree(X, Y);
        confusionMat = confusionmat(groundTruth,prediction);
        
    case 'linear_svm' % Linear svm 
       [prediction, groundTruth,mdl] =  Decode.linear_svm(X, Y);
       confusionMat = confusionmat(groundTruth,prediction);
       
    case 'linear_svm_reg' % Linear svm with regularization
        [prediction, groundTruth,mdl] =  Decode.linear_svm_reg(X, Y);
       confusionMat = confusionmat(groundTruth,prediction);

    % use C++ svm implementation in libsvm     
    case 'libsvm' % Linear svm with regularization
        [prediction, groundTruth,mdl] =  Decode.libsvm(X, Y);
       confusionMat = prediction;
    
    
end 


params.prediction = prediction;
params.gt         = groundTruth;
if exist('mdl','var')
   params.mdl = mdl; 
end

if exist('pScore','var')
   params.pScore = pScore; 
end



end % Main




