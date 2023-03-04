function globalYlim = findingGlobalYLim(fullmatrix, stimIDs, order, task, total)
% take in the full, smoothed raster
% cycle through the psth for each image
% find the max and save it
% this is so that I can split subplots across fgures with the same Ylim
% the default is that matlab redraws tthe ylim on each figure
% vwadia Dec/2020
% all I really need from each vector is max(amean+astd)

% FOR SCREENING:
% stimIDs = screeningData.imageIDs;
% order = screeningData.sortedOrder;

% FOR AIC:
% stimIDs = unique values in order
% order = order (it;s used in PlotRastersVarun and in that order =
% AICData.someOrder
if nargin == 4, total = size(fullmatrix, 1); end

globalYlim = 0;
if isequal(task, 'Screening') % screening
    for imageNum = 1:length(stimIDs(1:total))
        
        % matrix for specific image
        amatrix = fullmatrix(find(order == imageNum), :);
        
        amean=(nanmean(amatrix));
        %astd=nanstd(amatrix); % to get std shading
        astd=nanstd(amatrix)/sqrt(size(amatrix,1)); % to get sem shading
        if globalYlim <= max(amean+astd)
            globalYlim = max(amean+astd);
        end
    end
elseif isequal(task, 'AIC') % AIC
    for imageNum = 1:length(stimIDs)
        
        % matrix for specific image
        amatrix = fullmatrix(find(order == stimIDs(imageNum)), :);
        
        if size(amatrix, 1) > 1
            amean=(nanmean(amatrix));
        else
            amean = max(amatrix);
        end
        %astd=nanstd(amatrix); % to get std shading
        astd=nanstd(amatrix)/sqrt(size(amatrix,1)); % to get sem shading
        if globalYlim <= max(amean+astd)
            globalYlim = max(amean+astd);
        end
    end
elseif isequal(task, 'RespLat')
    
end
end