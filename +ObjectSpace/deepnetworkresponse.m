%
% function to get deep network response to a set of images
%
% this function does not work if you use matconvnet-alexnet instead caffe-alexnet
% written by Pinglei Bao
% edited by Varun Wadia May2019
function resp = deepnetworkresponse(net,imgall,layer)

    tic
 if size(net.meta.normalization.averageImage,1) == net.meta.normalization.imageSize(1);
        imagebk = net.meta.normalization.averageImage;
 else
        imagebk = zeros(1,1,3);
        imagebk(1,1,:) = net.meta.normalization.averageImage;
        imagebk = repmat(imagebk,[net.meta.normalization.imageSize(1),net.meta.normalization.imageSize(2),1]);
 end
%  load('G:\SUAnalysis\ObjectSpace\ImageReconstructionCode_Python\caffenet\ilsvrc_2012_mean.mat')
%  imagebk = image_mean(15:15+226, 15:15+226, :); 
 
for i = 1:size(imgall,3);
    if mod(i,400) == 0;
        toc
    end
    im = imgall(:,:,i);
    im_ = im;
    im_ = imresize(single(im), net.meta.normalization.imageSize(1:2));
    im_gray = single(zeros(size(im_,1),size(im_,2),3));
    
    % making im_gray a 3D image
    for j = 1:3
        im_gray(:,:,j) = im_;
    end
   
        
    
    im_gray = im_gray-imagebk;
    % fc6 is the 17th element of res
    res= vl_simplenn(net, im_gray); 
    for j = 1:length(layer)
    layer_number = layer(j);
    resp{j}(:,i) = squeeze(res(layer_number).x(:));
    end
        
end
end