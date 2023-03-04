% extract movie frames 
% vwadia Jan2020

addpath(genpath('osortTextUI'));
addpath(genpath('E:\Dropbox\Caltech\Thesis\Human_work\Cedars\MATLAB\distinguishable_colors'));
addpath(genpath('E:\Dropbox\Caltech\Thesis\Human_work\Cedars\MATLAB\Add-Ons\Collections\rgb2hex and hex2rgb'));
basePath = 'E:\Dropbox\Caltech\Thesis\Human_work\Cedars\SUAnalysis';
cd(basePath);
taskPath = 'Julien_Movie_Task';
stimDir = 'movieframes';


moviePath = [basePath filesep taskPath filesep stimDir];
% outputFolder = [moviePath filesep 'short'];
% moviefile = fullfile(moviePath, 'short.avi');
outputFolder = [moviePath filesep 'full'];
moviefile = fullfile(moviePath, 'full.mov');
vidObject = vision.VideoFileReader(moviefile);

% numberOfFrames = vidObject.NumberOfFrames;
% vidHeight = vidObject.Height;
% vidWidth = vidObject.Width;
% 
% numberOfFramesWritten = 0;
%%
% outputBaseFileName
% outputFullFileName
i = 0;
ctr = 0;
while ~isDone(vidObject)
    i = i+1;
    outputBaseFileName = "";
    frame = vidObject();
    if i > 421
        ctr = ctr + 1;
%         outputBaseFileName = "";
%         frame = vidObject();
        % Construct an output image file name.
        outputBaseFileName = sprintf('Frame%d.png', ctr);
        outputFullFileName = fullfile(outputFolder, outputBaseFileName);
        imwrite(frame, outputFullFileName);
    end
    %     keyboard;
end