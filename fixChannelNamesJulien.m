
function fixChannelNamesJulien(pathChannels)
% This function takes off the leading zeros in Julien's filenames
% note that pathChannels needs to be a full path in quotes
%
% written by Varun Wadia Dec2019

% cd([pathChannels]);
% cd Z:\dataRawEpilepsy\P63CS\082519_varunScreen\raw
files = dir(fullfile(pathChannels, '*.mat'));
for fileIndex = 1:length(files)
    filename = files(fileIndex).name;
    dashpos =strfind(filename,'_');
    if dashpos
        restofName = filename(dashpos(1):end);
        partToChange = filename(2:dashpos(1)-1); % we don't want the leading A
        partToChangeNum = str2num(partToChange);
        partChanged = num2str(partToChangeNum);
        if~strcmp(partChanged, partToChange)
            newfilename = ['A' partChanged restofName];
            movefile([pathChannels filesep filename],[pathChannels filesep newfilename]);
        end
    end
end
end
