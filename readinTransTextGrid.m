function transcriptTS = readinTransTextGrid(filePath)
% Takes in textgrid format .txt file, returns a cell array with the words and their on/off times 
% INPUT: name of story to transcribe (char)
% OUTPUT: nx3 cell array of the words with on and off times
% vwadia Jan2021
% edited Nov2022


transPath = filePath;

% read the file
file = fopen(transPath, 'rt');
data = textscan(file, '%s', 'Delimiter', ' '); % this works
fclose(file);

% find the word alignment index, and carve out that data
% (textgrid format has phoneme alignments and word alignments)
ind = find(strcmp(data{1,1}, '"word"')); % index of this value

realData = data{1, 1}(ind+1:end);

realData = realData(4:end, 1); % chosen manually for each file

% make timestamp array
transcriptTS = cell(length(realData)/3, 3);

ctr = 1;
for i = 1:length(realData)
    % start time
    if mod(i, 3) == 1
        transcriptTS{ctr, 2} = str2double(realData{i})*1e3;
        % end time
    elseif mod(i, 3) == 2
        transcriptTS{ctr, 3} = str2double(realData{i})*1e3;
        % word
    elseif mod(i, 3) == 0
        word = strsplit(realData{i}, '"');
        transcriptTS{ctr, 1} = word{2};
        ctr = ctr +1; % move to next row after this one is filled
    end
    
end
end