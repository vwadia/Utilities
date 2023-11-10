function ChangeImgNames(path)
% This function takes in images in a folder and renames them
% Used for AIC images to rearrange stim order
% vwadia Aug21

% path = 'D:\Users\wadiav\Dropbox\Caltech\Thesis\Human_work\Cedars\screeningTaskVarun\newAIC_wReal\Gr3';

imDir = dir(fullfile(path));
imDir = imDir(~ismember({imDir.name}, {'.', '..'}));
imgs = imDir;
% for fold = 1:length(imDir)
%     imgs = dir(fullfile([imDir(fold).folder filesep imDir(fold).name]));
%     imgs = dir(fullfile([imDir(fold).folder filesep imDir(fold).name]));
%     imgs = imgs(~ismember({imgs.name}, {'.', '..'}));

    for fidx = 1:length(imgs)
            ctr = (fidx-1)*3 + 78;
%         ctr = 75;
        suffix = '.png';
        fname = [imgs(fidx).folder filesep imgs(fidx).name]
        filepos =strfind(fname,'.png');
        %      filenum = sprintf('%03d', ctr);
        if filepos
            newfilename = [imDir(fidx).folder filesep sprintf('%03d', ctr) suffix]%fname(filepos:end)]
            movefile(fname,newfilename);
        end
    end
end
% end