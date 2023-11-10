function resp = deepnetworkresponse(net,imgall,layer);

    tic
 if size(net.meta.normalization.averageImage,1) == net.meta.normalization.imageSize(1);
        imagebk = net.meta.normalization.averageImage;
 else
        imagebk = zeros(1,1,3);
        imagebk(1,1,:) = net.meta.normalization.averageImage;
        imagebk = repmat(imagebk,[net.meta.normalization.imageSize(1),net.meta.normalization.imageSize(2),1]);
 end
 
for i = 1:size(imgall,3);
    if mod(i,400) == 0;
        toc
    end
    im = imgall(:,:,i);
    im_ = im;
    im_ = imresize(single(im), net.meta.normalization.imageSize(1:2));
    im_gray = single(zeros(size(im_,1),size(im_,2),3));
    
    for j = 1:3
        im_gray(:,:,j) = im_;
    end
   
        
    
    im_gray = im_gray-imagebk;
    res= vl_simplenn(net, im_gray);
    for j = 1:length(layer)
    layer_number = layer(j);
    resp{j}(:,i) = squeeze(res(layer_number).x(:));
    end
        
end