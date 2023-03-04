filepath = 'X:\LabUsers\duboisjx\stimuli\JuliensTasks\BangYoureDead\movie\full_frames\orig';

movepath = 'E:\Dropbox\Caltech\Thesis\Human_work\Cedars\SUAnalysis\Julien_Movie_Task\movieframes\full';

files = dir(fullfile(filepath, '*.png'));

for i = 1:length(files)
    currentframe = [filepath filesep files(i).name];
    copyfile(currentframe, movepath);
end


% test = [filepath filesep files(1).name]