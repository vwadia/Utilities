function params = getDNActivations(pathStimuli, imageIDs, ndim, layer)
% This function takes in a stimulus psth and imageIDs,
% creates image descirptions and then gets unit activations for those images.
% Makes a more compact representation by doing PCA, takes the first n dimensions 
% and returns them.
%     INPUTS:
%         1. Path stimuli
%         2. imageIDs (unique(order))
%         3. The number of dimensions to take
%         4. layer pf alexnet to use  eg.'fc6'
%     
%     OUPUTS:
%         1. Params
% vwadia July2021


% load the network
lexnet = alexnet; 

% get image descriptions
threeD = 1;
grayImages = Utilities.getImageDescriptions(pathStimuli, 227, imageIDs, threeD);

% get unit activations to those images
act = activations(lexnet, grayImages, layer, 'OutputAs', 'rows'); 

% do pca and create params 
respScreeningImagesLayer = act;
[coeff,score,latent,tsquared,explained,mu] = pca(respScreeningImagesLayer);
score = score(:, 1:ndim); 
params = score;


end