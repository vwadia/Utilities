function grayImages = getImageDescriptions_OLD(pathStimuli, imSize, threeD)

%% making images correct type
tic

addpath(genpath('Z:\LabUsers\vwadia\SUAnalysis\natsortfiles'));


imDir = dir(fullfile(pathStimuli));


imDir = imDir(~ismember({imDir.name}, {'.', '..', '.DS_Store', 'Thumbs.db'}));

% gets rid of weird copies
stimNames = struct2cell(imDir);
stimNames = stimNames(1, :)';
goodStim = ~startsWith(stimNames, '._', 'IgnoreCase', true);
imDir = imDir(goodStim);


[~, natIdx] = natsortfiles({imDir.name});
images = cell(length(imDir), 1);
if threeD
    grayImages = single(zeros(imSize, imSize, 3, length(imDir)));    
else
    grayImages = single(zeros(imSize, imSize, length(imDir)));
end
for image = 1:length(imDir)
    
    images{image} = imread([imDir(natIdx(image)).folder filesep imDir(natIdx(image)).name]);
    
    if length(size(images{image}))> 2 % if the image has 3 channels already
        images{image} = images{image}(:, :, 1:3);
        images{image} = rgb2gray(images{image});
    end
    img = single(imresize(images{image}, [imSize imSize])); % resize and convert to correct format
    if threeD
        grayImages(:, :, :, image) = repmat(img, [1 1 3]);
    else
        grayImages(:, :, image) = img;        
    end
end

toc