function [handlesToFig] = plotRastersMultStim(totalRasters, FRs, offsets, colors, textParams, isPDF, isOnset, legendEntries)
% This function plots the response of a single cell to multiple stim (arbitrary)
%
% Inputs:
%     1. Rasters to the multiple stim (cell array of logicals)
%     2. FRs to the same stim (cell array of FRs)
%     3. offsets as a 2 element vector
%     4. colors
%     5. textParams (xlabel, ylabel, title)
%     6. What format to save the figure (PDF vs PNG)
%     7. Whether we are plotting the onset of stories (stim responsive neurons)
%     8. Legend entries
%
% Outputs:
%     1. Handles to a figure
%
% vwadia Feb2020

RastersTimeBeforeMS = offsets(1);
RastersTimeAfterMS = offsets(2);

longestFR = max(cellfun('size', FRs, 2));
FRtotalRaster = 1e3*smoothdata(mean(totalRasters, 1), 'movmean', 500);        

numRasters = length(totalRasters);
% pad the arrays so it doesn't scream
for fr = l(FRs)
    if length(FRs{fr}) < longestFR
        FRs{fr} = padarray(FRs{fr}, [0 (longestFR - length(FRs{fr}))], 0, 'post');
    end
end
handlesToFig = figure; clf;

% plotting rasters
h1 = subplot(2, 1, 1);
hold on
title(textParams.title); 
xlabel(textParams.xlabel);
ylabel(textParams.ylabel);
for rasterNum = 1:numRasters
    vertSum = 0;
    for rNum = 1:rasterNum-1
        vertSum = vertSum+size(totalRasters{rNum}, 1);
    end
    if vertSum == 0
        vertDisplacement = vertSum;
    else
        vertDisplacement = vertSum+1;
    end
    LineFormat.Color = colors(rasterNum, :);
    LineFormat.LineWidth = 1.5;
    plotSpikeRaster(totalRasters(rasterNum), 'PlotType', 'vertline','RasterWindowOffset',-RastersTimeBeforeMS*1e-3,'LineFormat',LineFormat, 'VertSpikePosition', vertDisplacement);
    
end
yl = ylim;
numtrials = yl(2);

if numtrials
    set(gca,'YLim',[0 numtrials+1]) % setting y axes equal?
end

if isOnset
    set(gca, 'XLim', [-2000 5000]); % for boundary plot
else
    set(gca, 'XLim', [-RastersTimeBeforeMS RastersTimeAfterMS]);
end
set(gca, 'XTick', -RastersTimeBeforeMS:1e3:RastersTimeAfterMS, 'XTickLabelRotation', 30, 'fontsize', 6);
plot([0 0], [0 numtrials+1], '--k', 'LineWidth', 2);

% plotting firing rate
h2 = subplot(2, 1, 2);
hold on
ylabel('Firing Rate (Hz)');
if isOnset
    plot((-2000):5000, FRtotalRaster, 'color', [0.4 0 0.4]);
    set(gca, 'XLim', [-2000 5000]); % for boundary plot
else
    for frNum = 1:numRasters
        plot((-RastersTimeBeforeMS):RastersTimeAfterMS, FRs{frNum}, 'color', colors(frNum, :));    
    end
end
yl2 = ylim;
set(gca, 'XTick', -RastersTimeBeforeMS:1e3:RastersTimeAfterMS, 'XTickLabelRotation', 30, 'fontsize', 6);

plot([0 0], [0 yl2(2)+1], '--k', 'LineWidth', 2);

if nargin > 7
    legend(legendEntries);
end
linkaxes([h1, h2], 'x');

if isPDF
    % PDF
    orient(f2, 'landscape');
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 28 18]);
else
    % PNG
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 65 35]);
end

h = gcf;
numSubplots = numel(h.Children);
if numSubplots > 1
    suptitle(textParams.title);
else
    title(textParams.title);
end

end

