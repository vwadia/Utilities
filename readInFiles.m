function files = readInFiles(pathFiles, fileExt)
% Essentially a wrapper around dir(fullfile(pathFiles)) to avoid the 
% annoying copies and garbage files that are usually present in folders
% 
% INPUTS:
%     1. Path to files
%     2. Specific extension
%     
% OUTPUTS:
%     1. files
%     
% vwadia Jan2023

if nargin == 1, fileExt = '*'; end

assert(ischar(fileExt), 'Please enter valid file extension');
fileDir = dir(fullfile(pathFiles, ['*.' fileExt]));

fileDir = fileDir(~ismember({fileDir.name}, {'.', '..', '.DS_Store', 'Thumbs.db'}));

% gets rid of weird copies
fileNames = struct2cell(fileDir);
fileNames = fileNames(1, :)';
goodStim = ~startsWith(fileNames, '._', 'IgnoreCase', true);
files = fileDir(goodStim);
