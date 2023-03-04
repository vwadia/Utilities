function [handleToFig] = plotRastersText(raster, times, order, offsets, transcription, textParams, specificColour, isPDF)
% This function is to plot rasters and avg firing rate 
% aligned to a transcript of any kind (movie, story, recall)
% 
% Inputs:
%     1. raster
%     2. times as a vector
%     3. order
%     4. the plot offsets as a 2 element vector
%     5. the transcript to align to
%     6. text parameters including axes labels and titles
%     7. color
%     8. What format to save the figure (PDF vs. PNG)
%
% Output:
%     1. Handle to a figure
% 
% vwadia Feb2020 modified Jan2021
if nargin == 6, isPDF = 0; specificColour = []; end
if nargin == 7, isPDF = 0; end

binsize = 500; 
% make firing rate
if isequal(class(raster), 'logical')
    psth = double(raster);
else
    psth = raster;
    raster = logical(raster);
end
for row = 1:size(raster, 1)
    psth(row, :) = (fastsmooth(raster(row,:),binsize, 1, 0)*binsize)*(1000/binsize);
end
orderPsth = order;

% if size(raster, 1) < 3
%     pad = false(1, size(raster, 2));
%     raster = [raster; pad; pad];
% elseif size(raster, 1) == length(unique(order)) % plotting all cells separately - need to pad
%     
%     raster2 = zeros(2*size(raster, 1), size(raster, 2)); % double it
%     for row = 1:size(raster, 1)
%         raster2(row*2, :) = raster(row, :);
%     end
%     raster = logical(raster2);
%     order = repelem(order, 2);
% end

if size(raster, 1) < 3 || size(raster, 1) == length(unique(order))
    lineType = 2;
else
    lineType = 1;
end

if ~isempty(order)
    regions = unique(order);
    numSubRasters = length(regions);
    if numSubRasters == 1
        if ~isempty(specificColour)
        colors = specificColour;
        else
            disp('Need to input a colour for a single region case');
            keyboard
        end
        rasterLengths = size(raster, 1);
        vertSpikePos = 0; 
        rasters{1} = raster;
        avgFRs{1} = psth;
    else
        rasterLengths = zeros(numSubRasters, 1);
        vertSpikePos = zeros(numSubRasters+1, 1);
        rasters = cell(numSubRasters, 1);
        avgFRs = cell(numSubRasters, 1);
        colors = distinguishable_colors(numSubRasters);
        % calculate all raster lengths
        % separate them and put into structure
        for ras = 1:numSubRasters
            % this is because the regions present may skip numbers
            rasterLengths(ras) = length(find(order == regions(ras)));
            rasters{ras} = raster(find(order == regions(ras)), :);
            avgFRs{ras} = psth(find(orderPsth == regions(ras)), :);
        end
        vertSpikePos(2:end) = cumsum(rasterLengths);
        vertSpikePos = vertSpikePos(1:end-1);
    end
end

RastersTimeBeforeMS = offsets(1);
handleToFig = figure; clf;

h1 = subplot(2, 1, 1);
hold on
xlabel(textParams.xlabel, 'FontSize', 14);
ylabel(textParams.ylabelplot1, 'FontSize', 14);
LineFormat.LineWidth = 1.5;

for i = 1:numSubRasters
    LineFormat.Color = colors(i, :);

if lineType == 1
    plotSpikeRaster(rasters{i}, 'PlotType', 'vertline','RasterWindowOffset', -RastersTimeBeforeMS*1e-3, 'LineFormat', LineFormat, 'VertSpikePosition', vertSpikePos(i));
elseif lineType == 2
    plotSpikeRaster(rasters{i}, 'PlotType', 'vertline2', 'LineFormat', LineFormat, 'VertSpikePosition', vertSpikePos(i));
end
end

if isfield(textParams, 'legend') && ~isempty(textParams.legend)
    lgnd = legend(textParams.legend);
    title(lgnd, textParams.legendTitle);
    set(lgnd, 'Position', [0.9153,0.8273,0.0562,0.0893]);
end

yl = ylim;
if length(order) > yl(2)
    yl(2) = length(order)+1;
end
xl = xlim;
if size(raster, 1) == 2 % singl free recall raster
    set(gca,'YLim',[0 3]) % setting y axes equal?
else
    set(gca,'YLim',[0 yl(2)]) % setting y axes equal?
end
set(gca, 'XTick', -RastersTimeBeforeMS:1e3:length(raster)-RastersTimeBeforeMS, 'XTickLabelRotation', 30, 'fontweight', 'bold', 'fontsize', 8);
% set(gca, 'XTickLabels', -RastersTimeBeforeMS:1e3:length(raster)-RastersTimeBeforeMS, 'XTickLabelRotation', 30, 'fontweight', 'bold', 'fontsize', 8);

% plot([0 0], [0 yl(2)], '--k', 'LineWidth', 2, 'HandleVisibility', 'Off');
plot([offsets(1) offsets(1)], [0 yl(2)], '--k', 'LineWidth', 2, 'HandleVisibility', 'Off');


for word = 1:length(transcription)
    spokenWord = transcription{word, 1};
    patches_x = [transcription{word, 2}, transcription{word, 2},...
        transcription{word, 3}, transcription{word, 3}];
    patches_y = [0, yl(2), yl(2), 0];
    if mod(word, 2) && ~strcmp(spokenWord, 'sp')
        a = fill(patches_x, patches_y, [0 0 1], 'LineStyle', 'none', 'HandleVisibility', 'Off');
        a.FaceAlpha = 0.1;
        %             elseif ~mod(word, 2)
        %                 a = fill(patches_x, patches_y, [1 0 0], 'LineStyle', 'none');
        %                 a.FaceAlpha = 0.1;
    elseif strcmp(spokenWord, 'sp')
        a = fill(patches_x, patches_y, [1 0 0], 'LineStyle', 'none', 'HandleVisibility', 'Off');
        a.FaceAlpha = 0.1;
    elseif strcmp(spokenWord, '{LG}')
        a = fill(patches_x, patches_y, [1 0.65 0], 'LineStyle', 'none', 'HandleVisibility', 'Off');
        a.FaceAlpha = 0.2;
    end
end

h2 = subplot(2, 1, 2);
hold on
ylabel(textParams.ylabelplot2, 'FontSize', 14);
xlabel(textParams.xlabel, 'FontSize', 14);

for j = 1:numSubRasters
    if size(avgFRs{j}, 1) > 1
        stdshade5(avgFRs{j}, 0.1, colors(j, :), times, 2);
    else
        plot(times, avgFRs{j}, 'color', colors(j, :), 'LineWidth', 1.5);
    end
end
% plot the average firing rate of all cells too 
if isfield(textParams, 'plotAverageFR') && textParams.plotAverageFR == 1
    plot(times, mean(psth, 1), 'color', 'k', 'LineWidth', 2.5);
end
% if numSubRasters == 1
%     if ~isempty(times)
%         plot(times, avgFR, 'color', color, 'LineWidth', 1.5);
%     else
%         plot((-RastersTimeBeforeMS):length(raster)-RastersTimeBeforeMS-1, avgFR, 'color', color, 'LineWidth', 1.5);
%     end
% elseif numSubRasters > 1
%     stimTOplot = unique(order);
%     keyboard % need smoothed version of raster for this way of plotting - also if more than one raster then no point feeding in avgFR
%     for p1 = l(stimTOplot)
%         stdshade5(avgFRs{p1}, 0.1, colors(p1, :), times, 2);
%     end
% end


% plot the mean FR As a horizontal line
if numSubRasters == 1 || (isfield(textParams, 'split') && textParams.split == 1)
    plot([-RastersTimeBeforeMS length(raster)-RastersTimeBeforeMS-1], [mean(mean(psth)) mean(mean(psth))], '--k', 'LineWidth', 1.5);
    plot([-RastersTimeBeforeMS length(raster)-RastersTimeBeforeMS-1],...
        [mean(mean(psth))+(2*std(mean(psth))) mean(mean(psth))+(2*std(mean(psth)))],  'Color', [0.5, 0.5, 0.5], 'LineStyle', '--', 'LineWidth', 1.5);
end
yl2 = ylim;
set(gca, 'XLim', [-RastersTimeBeforeMS length(raster)-RastersTimeBeforeMS-1]);
%         set(gca, 'XLim', [-RastersTimeBeforeMS (minLength-RastersTimeBeforeMS)])
set(gca, 'XTick', -RastersTimeBeforeMS:1e3:length(raster)-RastersTimeBeforeMS, 'XTickLabelRotation', 30, 'fontweight', 'bold', 'fontsize', 8);

plot([0 0], [0 yl2(2)], '--k', 'LineWidth', 2, 'HandleVisibility', 'Off');
fontSize = 10;
for word = 1:length(transcription)
    spokenWord = transcription{word, 1};
    patches_x = [transcription{word, 2}, transcription{word, 2},...
        transcription{word, 3}, transcription{word, 3}];
    patches_y = [0, yl2(2), yl2(2), 0];
    if ~strcmp(spokenWord, 'sp') && ~strcmp(spokenWord, '{LG}')
        if mod(word, 2) == 1
            a = fill(patches_x, patches_y, [0 0 1], 'LineStyle', 'none', 'HandleVisibility', 'Off');
            a.FaceAlpha = 0.1;
            t = text(mean([patches_x(1), patches_x(3)]), 0.9*patches_y(2), char(transcription(word, 1)), 'FontSize', fontSize, 'FontWeight', 'Bold');
            set(t, 'Rotation', 90);
        elseif mod(word, 3) == 0
            t = text(mean([patches_x(1), patches_x(3)]), 0.85*patches_y(2), char(transcription(word, 1)), 'FontSize', fontSize, 'FontWeight', 'Bold');
            set(t, 'Rotation', 90);
        else
            t = text(mean([patches_x(1), patches_x(3)]), 0.80*patches_y(2), char(transcription(word, 1)), 'FontSize', fontSize, 'FontWeight', 'Bold');
            set(t, 'Rotation', 90);
        end
    elseif strcmp(spokenWord, 'sp')
        a = fill(patches_x, patches_y, [1 0 0], 'LineStyle', 'none', 'HandleVisibility', 'Off');
        a.FaceAlpha = 0.1;
    elseif strcmp(spokenWord, '{LG}')
        a = fill(patches_x, patches_y, [1 0.65 0], 'LineStyle', 'none', 'HandleVisibility', 'Off');
        a.FaceAlpha = 0.2;
    end
end
if lineType == 1
    linkaxes([h1, h2], 'x');
end
% PDF
if isPDF
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 25 20]);
    set(gcf, 'PaperOrientation', 'landscape');
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