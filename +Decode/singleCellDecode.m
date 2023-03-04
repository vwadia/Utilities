% Single cell decoding of image category based in the learning trials

function [MDL,confusionMat, window] = singleCellDecode(startStop,neuralData,...
                                                       whichCell,window,...
                                                       decoder, criteria, baselineWindow)

if nargin<6
    decoder = 'poisson-nb';
end



%% Extract all the features to use

% Eye tracking behavioral information
startoflook   = startStop(:,1);
trials        = startStop(:,4);
labels        = startStop(:,5); % category labels
cellFeatures = [];


    
% Use Feature 2: two (or more) fixed windows to get spike counts
for i=1:size(window,1)

    periodsOfInterest  = [startoflook+window(i,1),...
                          startoflook+window(i,2)] ;
    lookONtimestamps   = getAllSpikeData(neuralData,periodsOfInterest,0);
    lookONRaster       = ReorgTimeStamps(lookONtimestamps);

    temp               = cell2mat(cellfun(@(x) numel(x),...
                         lookONRaster{whichCell},'UniformOutput',false))';

    cellFeatures = cat(2,cellFeatures,temp);

end

[MDL,confusionMat] = decodeCategory(cellFeatures,labels,criteria,...
                                    decoder,trials,baselineWindow);

    
   


