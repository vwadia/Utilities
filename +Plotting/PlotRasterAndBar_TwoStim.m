function handlesToFig = PlotRasterAndBar_TwoStim(stimRaster, spikeCount, imPath, plotOptions)
% Same function as the _SingleStim one but plots two stim
% INPUTS:
%     1. Psth (cell with 2 rasters --> two stimuli or encoding + recall)
%     2. Path to relevant image(s)
%     3. spikeCount{1}s (for bar plot)
%     4. plotOptions struct with timelimits and global ylim
%
% OUTPUT:
%     1. Handles to figure
% vwadia Sept 2021


% plot
Fontsize = 14;
handlesToFig = figure;
set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen

color = [0 0.2 0];

%  h1 = subplot(1, 14, [1 2]);
h1 = subplot(2, 36, [1:8 37:44]);
hold on
for k = 1:size(stimRaster{1}, 1)
    try
        % if sorted raster used replace original with presentations
        plot((find(stimRaster{1}(k, :)==1)+plotOptions.EncTimelimits(1)*1e3),...
            k,'Marker','|', 'LineStyle','none', 'LineWidth', 1.5, 'MarkerFaceColor',color,...
            'MarkerEdgeColor',color,'MarkerSize',24)
        hold on
    end
end
ylabel('trials (reordered)', 'FontSize', Fontsize, 'FontWeight', 'bold');
xlabel('time (ms)', 'FontSize', Fontsize, 'FontWeight', 'bold');
ylim([0 size(stimRaster{1}, 1)+1])
xlim([plotOptions.EncTimelimits(1)*1e3 plotOptions.EncTimelimits(2)*1e3])
plot([0 0], [0 size(stimRaster{1}, 1)+1], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
set(gca,'FontSize',Fontsize, 'FontWeight', 'bold')

%  h2 = subplot(1, 14, [4]);
h2 = subplot(2, 36, [11 12 47 48]);
hold on
% barplot of countsize
if plotOptions.globalyl == 0
    yl = 1;
else
    yl = ceil(plotOptions.globalyl)*1.1;
end
bar(spikeCount{1});
ylim([0 yl]);
% ylabel('spikes/s', 'FontSize', 10, 'FontWeight', 'bold');

set(gca,'FontSize',Fontsize, 'FontWeight', 'bold')
% h3 = subplot(1, 14, [6]);
h3 = subplot(2, 36, [13:16 49:52]);
hold on
imshow(imPath);

% h4 = subplot(1, 14, [8:12]);
h4 = subplot(2, 36, [19:26 55:62]);
hold on
for k = 1:size(stimRaster{2}, 1)
    try
        % if sorted raster used replace original with presentations
        plot((find(stimRaster{2}(k, :)==1)+plotOptions.CRTimelimits(1)*1e3),...
            k,'Marker','|', 'LineStyle','none', 'LineWidth', 1.5, 'MarkerFaceColor',color,...
            'MarkerEdgeColor',color,'MarkerSize',24)
        hold on
    end
end
% ylabel('trials (reordered)', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('time (ms)', 'FontSize', Fontsize, 'FontWeight', 'bold');
ylim([0 size(stimRaster{2}, 1)+1])
xlim([plotOptions.CRTimelimits(1)*1e3 plotOptions.CRTimelimits(2)*1e3])
plot([0 0], [0 size(stimRaster{2}, 1)+1], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
set(gca,'FontSize',Fontsize, 'FontWeight', 'bold')

% h5 = subplot(1, 14, [14]);
h5 = subplot(2, 36, [29:36 65:72]);
hold on
% barplot of countsize
if plotOptions.globalyl == 0
    yl = 1;
else
    yl = ceil(plotOptions.globalyl)*1.1;
end
bar(spikeCount{2}, 'FaceColor', [0.6350 0.0780 0.1840]);

ylim([0 yl]);
% yyaxis right
% set(gca,'YTickLabel',[]);
ylabel('spikes/s', 'FontSize', Fontsize, 'FontWeight', 'bold', 'Color', 'k');

set(gca,'FontSize',Fontsize, 'FontWeight', 'bold')


end