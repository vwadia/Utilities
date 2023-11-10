function respScreeningImages = getLayerActivations(net, grayImages)
% Deep network stuff
% get responses via pinglei's function
% caffNet = load('imagenet-caffe-alex.mat'); % this has the correct format
% caffNet = load('imagenet-matconvnet-alex.mat'); 

% load resp_Alexnet.mat % will produce resp{1, 7} with the unit activations of the different layers
% dnresp = resp;
% % response of fc6 for 19606 images
% respAllImages = dnresp{3};% 3 is for fc6 before relu, 4 is fc6 after relu, 5 is fc7 before relu, 6 is fc7 after relu, 8 is softmax 
% respAllImages = respAllImages';
% r_p = (respAllImages - repmat(mu,[size(respAllImages,1),1]))*coeff;
% rp = r_p(:,1:50);



% % responses of fc6 to my screening images
respScreeningImages = deepnetworkresponse(net, grayImages, [17:22]); % 17 is fc6 before relu as returned by vl_simplenn
%%
% % n, n+1 before and after normalization. 
% % 1, 2 fc6, relu
% % 3, 4 fc7, relu
% % 5, 6 fc8, softmax
% respScreeningImagesLayer = respScreeningImages{3}'; 
%     
% % dp PCA and keep the first 50 PCs
% [coeff,score,latent,tsquared,explained,mu] = pca(respScreeningImagesLayer);
% score = score(:, 1:50); % you can do this in STA figure or here
end