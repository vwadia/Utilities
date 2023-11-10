function handlesToFig = PlotRasterAndBar_SingleStim(stimRaster, spikeCount, imPath, plotOptions)
% This function takes in a psth for a single stimulus and the stimulus, 
% computes the spikes/s and then plots a figure with raster, barplot and image
% Primarily used for encoding vs recall comparisons
% INPUTS:
%     1. Psth (single stimulus)
%     2. Path to relevant image
%     3. Spikecounts (for bar plot)
%     4. plotOptions struct with timelimits and global ylim
%
% OUTPUT:
%     1. Handles to figure
% vwadia Sept 2021

% plot
Fontsize = 12;
handlesToFig = figure;
% set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen

color = [0 0.2 0];

%              h1 = subplot(1, 7, [1:4]);
h1 = subplot(2, 17, [1:8 18:25]);
hold on
for k = 1:size(stimRaster, 1)
    try
        % if sorted raster used replace original with presentations
        plot((find(stimRaster(k, :)==1)+plotOptions.timelimits(1)*1e3),...
            k,'Marker','|', 'LineStyle','none', 'LineWidth', 1.5, 'MarkerFaceColor',color,...
            'MarkerEdgeColor',color,'MarkerSize',24)
        hold on
    end
end
ylabel('trials (reordered)', 'FontSize', Fontsize, 'FontWeight', 'bold');
xlabel('time (ms)', 'FontSize', Fontsize, 'FontWeight', 'bold');
ylim([0 size(stimRaster, 1)+1])
xlim([plotOptions.timelimits(1)*1e3 plotOptions.timelimits(2)*1e3])
plot([0 0], [0 size(stimRaster, 1)+1], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
% plot([150 150], [0 size(stimRaster, 1)+1], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
% 
% plot([400 400], [0 size(stimRaster, 1)+1], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');

set(gca,'FontSize',Fontsize, 'FontWeight', 'bold')

%              h2 = subplot(1, 7, [6 7]);
h2 = subplot(2, 17, [11 12 28 29]);
hold on
% barplot of countsize
if plotOptions.globalyl == 0
    yl = 1;
else
    yl = ceil(plotOptions.globalyl)*1.1;
end
bar(spikeCount, 'FaceColor', plotOptions.color);
ylim([0 yl]);
ylabel('spikes/s', 'FontSize', Fontsize, 'FontWeight', 'bold');

set(gca,'FontSize',Fontsize, 'FontWeight', 'bold')
%              h3 = subplot(1, 7, [7]);
h3 = subplot(2, 17, [13:16 31:34]);
hold on
imshow(imPath);

end