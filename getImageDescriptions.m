function stimImages = getImageDescriptions(pathStimuli, imSize, threeD, gray)
% This function takes in paths to image stimuli, a desired size and whether
% you want the images to be 3 channels (RGB) or 1 and returns an array of size
% H x W x N_Channels x N-Images for use with deep networks
% -------------------------------------------------------------------------
% Requirements: Natsortfiles extension: can be found among matlab extensions
% or even by just googling 'Natural-Order Filename Sort'
% -------------------------------------------------------------------------
%     INPUTS:
%         1. Full path to stimuli
%         2. Desired image size
%         3. threeD - do you want 3 channels or not
%         4. gray - option to make image grayscale
%     
%     OUTPUTS:
%         1. Array of images
% vwadia July2021
% the 
%% making images correct type

if nargin == 2,  threeD = true; gray = true; end
if nargin == 3, gray = true; end   


tic
imDir = dir(fullfile(pathStimuli));
imDir = imDir(~ismember({imDir.name}, {'.', '..', '.DS_Store', 'Thumbs.db'}));

% gets rid of weird copies
stimNames = struct2cell(imDir);
stimNames = stimNames(1, :)';
goodStim = ~startsWith(stimNames, '._', 'IgnoreCase', true);
imDir = imDir(goodStim);


[~, natIdx] = natsortfiles({imDir.name});
images = cell(length(imDir), 1);

stimImages = [];
for im_num = 1:length(imDir)
    
    fullFilename = [imDir(natIdx(im_num)).folder filesep imDir(natIdx(im_num)).name];
    info = imfinfo(fullFilename);
    im = imread(fullFilename);
      
    % resize and convert to correct format
    img = imresize(im, [imSize imSize]); 

    % if the image has 3 channels already
    if length(size(img)) > 2 
        
        if gray
            % handle conversion properly
            if(strcmp('truecolor',info.ColorType))
                img = uint8(rgb2gray(img));
            elseif(strcmp('grayscale',info.ColorType))
                img = uint8(imread(fullFilename));
            elseif(strcmp('indexed',info.ColorType))
                img = uint8(ind2gray(img,map));
            end
            
            if threeD
                img = repmat(img, [1 1 3]);
            end
            
        end
        
    else % if it has 1 channel 
        if threeD
            img = repmat(img, [1 1 3]);
        end
    end
    
    stimImages(:, :, :, im_num) = img;
 
end
stimImages = single(squeeze(stimImages));

toc


