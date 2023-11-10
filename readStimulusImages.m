function [trialImages] = readStimulusImages(imPath, recallOn)
% reading in stimulus images per trial and saving them
% 
% varun june 2019
imDir = dir(imPath);
imDir = imDir(~ismember({imDir.name}, {'.', '..', '.DS_Store'})); 
[~, idx] = natsortfiles({imDir.name});


num_imgs = 4;
images = cell(length(recallOn), num_imgs);
trialImages = cell(length(recallOn), 1);
for trial = 1:length(recallOn)+1
    
    current_dir = imDir(idx(trial));
    trial_stimuli = dir([current_dir.folder filesep current_dir.name]);
    trial_stimuli = trial_stimuli(~ismember({trial_stimuli.name}, {'.', '..', '.DS_Store'}));
%     trial_stimuli = trial_stimuli';
    for im = 1:num_imgs
%         images{trial}{im} = imread(trial_stimuli(im).name);
        images{trial, im} = imread([trial_stimuli(im).folder filesep trial_stimuli(im).name]);
        images{trial, im} = imresize(images{trial, im}, [224 224]); % resize to make them equal
        
    end
    trialImages{trial} = horzcat(images{trial, 1}, images{trial, 2}, images{trial, 3}, images{trial, 4});

end
end