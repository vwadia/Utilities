function [psth1] = BinRasterSpikes(raster, binsize, stepsize)
% Utility function to bin spikes so that psth's look nicer (not as jagged).
% INPUTS:
%     1. Raster (in ms) 
%     2. Desired bin size
%     3. Stepsize: how much to slide over? Empty = non-overlapping
%     
% OUTPUTS; 
%     1. Binned raster
%     2. Smoothed psth?
%     3. New 'times' vector?
%     
% vwadia Nov 2023

if nargin == 1, binsize = 10; stepsize = binsize; end
if nargin == 2, stepsize = binsize; end

numrows = size(raster, 1);
numcols = size(raster, 2);
numBins = ceil(numcols/binsize);

% windowEnd = (numBins*binsize) - binsize;
windowEnd = numcols;
windowBegin = 1; 

for row = 1:numrows
    binCtr = 1;
    for window = windowBegin:stepsize:windowEnd
        
        if window+binsize > numcols
            psth1(row, binCtr) = sum(raster(row, window:end));
        else
            % need the -1 or you'll double count the edges
            psth1(row, binCtr) = sum(raster(row, window:window+binsize-1)); 
        end
        binCtr = binCtr+1;
    end
end

end