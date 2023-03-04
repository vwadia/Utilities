% Compute mutual information from confusion matrix
% INPUT 'confusionMatrix' should be a cell, where each entry in the cell
% contains a different symmetric confusion matrix

function MI = computeMI(confusionMatrix)

nr = length(confusionMatrix);
MI = NaN(1,nr);


for i=1:nr
    
    % Normalize the confusion matrix
    Pxy = confusionMatrix{i}./sum(sum(confusionMatrix{i}));
    Px  = confusionMatrix{i}./repmat(sum(confusionMatrix{i},1),size(confusionMatrix{i},1),1);
    Py  = confusionMatrix{i}./repmat(sum(confusionMatrix{i},2),1,size(confusionMatrix{i},2));
    % Compute the mutual information from the joint pdf of 
    % predicted and ground truth
    
    Px(isnan(Px)) = 0; % remove nans
    Py(isnan(Py)) = 0; % remove nans
    temp = Pxy.*log2(Pxy./(Px.*Py)); % Shannon information
    temp(isnan(temp)) = 0; % remove nans
    
    
    MI(i) = -sum(temp(:)); % sum across all entries
end