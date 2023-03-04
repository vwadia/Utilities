function generate_objects_50d_obj_space(destPath, layer_resp, coeff_obj, mu_obj, im2all, ndim, method, feat_vec, name)
% Takes in a feature vector, deepnet response to a large image set
% uses the feature vector to find a picture that is closest to the target
% image (defined by the feature vector) and writes both the image and the
% feature vector to the output folder
%     INPUTS:
%         1. Output Folder
%         2. Deep network responses to large image set
%         3. PC loadings of stimulus set
%         4. Mean of stimulus features as returned by PCA
%         5. The large image set used to train the net
%         6. number of desired dimensions
%         7. Method that defines how inputted feature vector will be handled  
%         8. Feature vector
%         9. Output name of the file
%     OUTPUTS:
%         1. Write figures and feature vectors of chosen figures to output folder
% vwadia June 2021

if nargin == 7, name = []; end

resp_wholeimage = layer_resp;

%% Project 19606 images into space built by object set
r_p = (resp_wholeimage - repmat(mu_obj,[size(resp_wholeimage,1),1]))*coeff_obj;
rp = r_p(:,1:ndim);

%% image parameters

% to plot axes - not relevant
switch method
    case 'random'
        ax = rand(1,50); 
    case 'sta'
        ax = feat_vec;
    case 'sta_with_range'
        % sta with range
        ax = repmat(feat_vec, [8 1]);
        range = setdiff([-4:4], 0);
        ax = ax .* range';
    case 'recon'
        ax = feat_vec;
end

% ss = std(rp);
% ax = ax.*repmat(ss,size(ax,1),1);

%% find image with closest distance to inputted feature vector

for i = 1:size(ax,1);
    target = ax(i,:);
    
    dist1 = rp - repmat(target,size(rp,1),1);
    for j = 1:size(dist1,1);
        dd(j) = norm(dist1(j,:));
    end
    [d1(i) index1(i)] = min(dd);
end   

ims = im2all(:, :, index1); % select the image;
para = rp(index1,:); % parameters of the image;

for im = 1:length(index1)
    % to plot axes - not needed
    if strcmp(method, 'sta_with_range') 
        if range(im) < 0
            suff = ['_minus_' num2str(abs(range(im)))];
        elseif range(im) > 1
            suff = ['_plus_' num2str(abs(range(im)))];
        elseif range(im) == 1
            suff = ['_STA'];
        end
        filename = [destPath filesep [num2str(name) '_' num2str(im) suff]];
%         ctr = ctr + 1;
    elseif strcmp(method, 'sta')
        filename = [destPath filesep [num2str(name) '_STA']];
        
    elseif strcmp(method, 'random')
        filename = [destPath filesep num2str(im)];
    elseif strcmp(method, 'recon')
        name = im;
        filename = [destPath filesep [num2str(name) '_reconstructed']];
    end
   
    % decoding
    imwrite(ims(:, :, im),[filename,'.tiff']);
    
    %output the 50-d feature vectors
    fid2 = fopen([filename,'.txt'], 'w');
    for i=1:size(para, 2)
        fprintf(fid2,'%f ',para(im, i));
    end
    fclose(fid2);
    close all
    
end


    
end 
    
    
