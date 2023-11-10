function transcriptTS = readinTransJson(filePath, removeNonImportantWords)
% Read in text transcripts that come out of p2fa-vislab in json format
% Returns a nx3 cell array with the words and their on-off times
% vwadia Nov2022

if nargin == 1, removeNonImportantWords = 0; end
transcriptTS = {};

if ~removeNonImportantWords
    nonImportantWords = {};
else
    % this is for when you want to look at response to specific nouns -
    % remove the filler words
    nonImportantWords = { '{LG}', 'sp', 'A', 'OF', 'OH', 'AM', 'THIS', 'WITH', 'AT', 'FROM', 'INTO', 'DURING', 'INCLUDING', 'UNTIL', 'AGAINST', 'AMONG', 'THROUGHOUT',...
        'DESPITE', 'TOWARDS', 'UPON', 'CONCERNING',	'TO', 'IN',	'FOR', 'ON', 'BY', 'ABOUT',	'LIKE', 'THROUGH', 'OVER',...
        'BEFORE', 'BETWEEN', 'AFTER', 'SINCE',	'WITHOUT', 'UNDER',	'WITHIN',	'ALONG', 'FOLLOWING', 'ACROSS',...
        'BEHIND',	'BEYOND',	'PLUS', 'EXCEPT', 'BUT', 'UP', 'OUT', 'AROUND',	'DOWN', 'OFF', 'ABOVE', 'NEAR'};
end

index = 1;
file = jsondecode(fileread(filePath));
for ctr = 1:length(file.words)
    if ~ismember(file.words{ctr}.alignedWord, nonImportantWords)
        transcriptTS{index, 1} = file.words{ctr}.alignedWord;
        transcriptTS{index, 2} = file.words{ctr}.start*1e3; % convert to MS
        transcriptTS{index, 3} = file.words{ctr}.end*1e3; % convert to MS
        index = index + 1;
    end
end
