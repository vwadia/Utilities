function fixChannelNamesNlx(pathChannels)
% This function takes off the irritating extra numbers nlx sometimes puts
% on raw ncs files
%
% note that pathChannels needs to be a full path in quotes
% 
% written by Janis Hesse Aug2019

cd([pathChannels]);
% cd Z:\dataRawEpilepsy\P63CS\082519_varunScreen\raw
files = dir(fullfile(pathChannels, '*.ncs'));

for fileIndex = 1:length(files)
    filename = files(fileIndex).name;
    filepos =strfind(filename,'_');
    if filepos
        newfilename = [filename(1:filepos-1) '.ncs'];
        movefile(filename,newfilename);
    end
end


