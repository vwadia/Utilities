function [handlesToFig] = plotRastersTextinChunks_2(paths, raster, times, order, offsets, transcription, textParams, specificColour, isPDF, strctCells)
% This function is to plot rasters and avg firing rate
% aligned to a transcript of any kind (movie, story, recall)
% Adapted for matlab 2020b
% Inputs:
%     1. Path struct
%     2. raster (this needs to be padded if each row is unique/only 1 row)
%     3. times as a vector
%     4. order
%     5. the plot offsets as a 2 element vector
%     6. the transcript to align to
%     7. text parameters including axes labels and titles
%     8. color
%     9. What format to save the figure (PDF vs. PNG)
%
% Output:
%     1. Handle to a figure
%
% vwadia Dec2020 modified Jan2021
% modified Feb2021 to keep a consistent plotting technique(plot markers
% manually)
if nargin == 7, isPDF = 0; specificColour = []; strctCells = []; end
if nargin == 8, isPDF = 0; strctCells = []; end
if nargin == 9, strctCells = []; end

if ~isempty(strctCells)
    allCells = 1;
else
    allCells = 0;
end

binsize = 500;
% make firing rate
if isequal(class(raster), 'logical')
    psth = double(raster);
else
    psth = raster;
    raster = logical(raster);
end
for row = 1:size(raster, 1)
    psth(row, :) = (Utilities.Smoothing.fastsmooth(raster(row,:),binsize, 1, 0)*binsize)*(1000/binsize);
end
orderPsth = order;

if size(raster, 1) < 3 || size(raster, 1) == length(unique(order))
    lineType = 2;
else
    lineType = 1;
end
% if split across pages
chunkSize = 30000; % ms
numBins = ceil(size(raster, 2)/chunkSize);
% else
% chunkSize = size(raster, 2);

if ~isempty(order)
    regions = unique(order, 'stable');
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
        colors = Utilities.distinguishable_colors(numSubRasters);
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

% if I want specific colour settings eg. to match the encoding data
if isfield(textParams, 'useTheseColors') && ~isempty(textParams.useTheseColors)
    colors = textParams.useTheseColors;
end


RastersTimeBeforeMS = offsets(1);
% figure out which pages to put dashed lines
onsetPageNum = ceil(offsets(1)/chunkSize);
offsetPageNum = ceil((size(raster, 2) - offsets(2))/chunkSize);


binRaster = cell(numSubRasters, 1);
binPsth = cell(numSubRasters, 1);
binTrans = {};
binTimes = zeros(1, chunkSize);
for bin = 1:numBins
    % carve out raster/psth first
    if bin == numBins
        binTimes = times(chunkSize*(bin-1)+1:end);
        
        for ras = 1:numSubRasters
            binRaster{ras} = rasters{ras}(:, chunkSize*(bin-1)+1:end);
            binPsth{ras} = avgFRs{ras}(:, chunkSize*(bin-1)+1:end);
        end
        
    else
        binTimes = times(chunkSize*(bin-1)+1:chunkSize*(bin-1)+chunkSize);
        for ras = 1:numSubRasters
            binRaster{ras} = rasters{ras}(:, chunkSize*(bin-1)+1:chunkSize*(bin-1)+chunkSize);
            binPsth{ras} = avgFRs{ras}(:, chunkSize*(bin-1)+1:chunkSize*(bin-1)+chunkSize);
        end
    end
    
    % carve out transcription
    if bin < onsetPageNum || bin > offsetPageNum
        binTrans = {};
    elseif bin == onsetPageNum
        timeWindow = and(cell2mat(transcription(:, 2)) > 0, cell2mat(transcription(:, 2)) < chunkSize-offsets(1));
        binTrans = transcription(timeWindow, :);
    elseif bin == offsetPageNum
        timeWindow = cell2mat(transcription(:, 2)) > ((bin-1)*chunkSize)-offsets(1);
        binTrans = transcription(timeWindow, :);
    else
        timeWindow = and(cell2mat(transcription(:, 2)) > ((bin-1)*chunkSize)-offsets(1), ...
            cell2mat(transcription(:, 2)) < ((bin-1)*chunkSize)+(chunkSize-offsets(1)));
        binTrans = transcription(timeWindow, :);
    end
    
    handlesToFig = figure; clf;
    set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen
    
    % FR----------------------------------------------------------------------
    h_1 = subplot(2, 1, 1);
    hold on
    xlabel(textParams.xlabel, 'FontSize', 14);
    ylabel(textParams.ylabelplot1, 'FontSize', 14);
    LineFormat.LineWidth = 1.5;
    
    % change this to generalize!!!
%     keyboard
    globalYl = Utilities.Plotting.findingGlobalYLim(psth, unique(order), order, 'AIC');

    for j = 1:numSubRasters
        if size(binPsth{j}, 1) > 1 % && length(unique(binPsth{j}(2, :))) > 1 % why did I include this??
            Utilities.stdshade5(binPsth{j}, 0.1, colors(j, :), binTimes, 2);
        else
            plot(binTimes, binPsth{j}, 'color', colors(j, :), 'LineWidth', 1.5);
        end
    end
    
    if isfield(textParams, 'legend') && ~isempty(textParams.legend)
        lgnd = legend(textParams.legend);
        title(lgnd, textParams.legendTitle);
        if exist('numSubRasters', 'var') && numSubRasters > 20
            set(lgnd, 'Position', [0.934,0.4175,0.0562,0.4657]);
        else
            set(lgnd, 'Position', [0.934,0.684,0.0562,0.187]);
        end
    end
    % plot the average firing rate of all cells too
    if isfield(textParams, 'plotAverageFR') && textParams.plotAverageFR == 1
        plot(binTimes, mean(psth, 1), 'color', 'k', 'LineWidth', 2.5);
    end
    
    % plot the mean FR As a horizontal line
    if numSubRasters == 1
        plot([binTimes(1) binTimes(end)], [mean(mean(psth)) mean(mean(psth))], '--k', 'LineWidth', 1.5, 'HandleVisibility', 'Off');
        plot([binTimes(1) binTimes(end)],...
            [mean(mean(psth))+(2*std(mean(psth))) mean(mean(psth))+(2*std(mean(psth)))],  'Color', [0.5, 0.5, 0.5], 'LineStyle', '--', 'LineWidth', 1.5, 'HandleVisibility', 'Off');
    end
    yl2 = ylim;
    set(gca, 'XLim', [binTimes(1) binTimes(end)]);
    set(gca, 'YLim', [0 globalYl]);

    %     set(gca, 'XTick', -binTimes(1):1e3:binTimes(end), 'XTickLabelRotation', 30, 'fontweight', 'bold', 'fontsize', 8);
    xt = xticks;
    
    if bin == onsetPageNum
        plot([0 0], [0 globalYl], '--k', 'LineWidth', 2, 'HandleVisibility', 'Off');
    elseif bin == offsetPageNum
        plot([binTimes(1)+(size(binRaster{1}, 2)-offsets(2)) binTimes(1)+(size(binRaster{1}, 2)-offsets(2))], [0 globalYl], '--k', 'LineWidth', 2, 'HandleVisibility', 'Off');
    end
    fontSize = 8;
    for word = 1:size(binTrans, 1)
%         if bin == offsetPageNum
%             keyboard
%         end
        spokenWord = binTrans{word, 1};
        patches_x = [binTrans{word, 2}, binTrans{word, 2},...
            binTrans{word, 3}, binTrans{word, 3}];
        patches_y = [0, 0.85*globalYl, 0.85*globalYl, 0];
        if ~strcmp(spokenWord, 'sp') && ~strcmp(spokenWord, '{LG}')
            if mod(word, 2) == 1
                a = fill(patches_x, patches_y, [0 0 1], 'LineStyle', 'none', 'HandleVisibility', 'Off');
                a.FaceAlpha = 0.1;
                t = text(mean([patches_x(1), patches_x(3)]), 0.9*patches_y(2), char(binTrans(word, 1)), 'FontSize', fontSize, 'FontWeight', 'Bold');
                set(t, 'Rotation', 90);
            elseif mod(word, 3) == 0
                t = text(mean([patches_x(1), patches_x(3)]), 0.85*patches_y(2), char(binTrans(word, 1)), 'FontSize', fontSize, 'FontWeight', 'Bold');
                set(t, 'Rotation', 90);
            else
                t = text(mean([patches_x(1), patches_x(3)]), 0.80*patches_y(2), char(binTrans(word, 1)), 'FontSize', fontSize, 'FontWeight', 'Bold');
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
    
    % Raster --------------------------------------------------------------
    h_2 = subplot(2, 1, 2);
    hold on
    if isempty(strctCells)
        ylabel(textParams.ylabelplot2, 'FontSize', 14);
    end
    xlabel(textParams.xlabel, 'FontSize', 14);
    
    yl = ylim;
    if length(order) >= yl(2)
        yl(2) = length(order)+1;
    end
    if size(binRaster, 1) == 2 % single free recall raster
        yl(2) = 2;
        set(gca,'YLim',[0 yl(2)]) % setting y axes equal?
    else
        set(gca,'YLim',[0 yl(2)]) % setting y axes equal?
    end
    
    if bin == onsetPageNum
        % This screws the plot up if done at the end, so draw it first
        plot([0 0], [0 yl(2)], '--k', 'LineWidth', 2, 'HandleVisibility', 'Off');
    elseif bin == offsetPageNum
        plot([(binTimes(1)+(size(binRaster{1}, 2)-offsets(2)))*1e-3 (binTimes(1)+(size(binRaster{1}, 2)-offsets(2)))*1e-3],...
            [0 yl2(2)], '--k', 'LineWidth', 2, 'HandleVisibility', 'Off');
    end
    
    
    for word = 1:size(binTrans, 1)
        spokenWord = binTrans{word, 1};
        
        % CONVERT TIMESTAMPS TO SECONDS
%         patches_x = [binTrans{word, 2}*1e-3, binTrans{word, 2}*1e-3,...
%             binTrans{word, 3}*1e-3, binTrans{word, 3}*1e-3];
        
        patches_x = [binTrans{word, 2}, binTrans{word, 2},...
            binTrans{word, 3}, binTrans{word, 3}];
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

    for i = 1:numSubRasters
        LineFormat.Color = colors(i, :);
        LineFormat.LineWidth = 2;
        RawterWindowOffsetSeconds = ((bin-1)*chunkSize - offsets(1))*1e-3;
        plotSpikeRaster(binRaster{i}, 'PlotType', 'vertline','RasterWindowOffset', RawterWindowOffsetSeconds, 'LineFormat', LineFormat, 'VertSpikePosition', vertSpikePos(i));
%         try
%             plot((find(binRaster{i}(1, :)==1)+((bin-1)*chunkSize - offsets(1))),...
%                 i,'Marker','|', 'LineStyle','none','MarkerFaceColor',colors(i, :),...
%                 'MarkerEdgeColor',colors(i, :),'MarkerSize',8, 'linewidth', 1.5)
%             hold on
%         end
    end
    
  
    
    set(gca, 'XLim', [binTimes(1) binTimes(end)]);
    set(gca, 'YLim', yl);
    xticklabels(xt);

    if allCells
        % ylabels for population plot
        patientBrainAreas = struct2cell(strctCells');
        patientBrainAreas = patientBrainAreas(3:4, :)';
        regions = unique([patientBrainAreas{:, 1}], 'stable');
        regions = fliplr(regions); % to match the encoding order
        %     regions = unique([patientBrainAreas{:, 1}]);
        ytik = zeros(length(regions), 1);
        ytiklabs = cell(1, length(regions));
        
        idx = 0;
        for regionIndex = regions
            idx = idx+1;
            if idx == 1
                ytik(idx) = length(find([patientBrainAreas{:, 1}] == regionIndex));
            else
                ytik(idx) = ytik(idx-1) + length(find([patientBrainAreas{:, 1}] == regionIndex));
            end
            ytiklabs{idx} = patientBrainAreas{[patientBrainAreas{:, 1}] == regionIndex, 2};
            
        end
        
        yticks(ytik);
        set(h_2, 'YTickLabel', []);
        
        xl = xlim;
        for yticknum = 1:length(ytik)
            if yticknum ==1
                ytikpos = ytik(yticknum)/2;
            else
                ytikpos = ytik(yticknum-1)+(ytik(yticknum)-ytik(yticknum-1))/2;
            end
            ty = text(xl(1)-300, ytikpos, ytiklabs{yticknum});
%             ty.FontWeight = 'bold';
        end
        
    end
    
    
    
    numSubplots = numel(handlesToFig.Children);
    textParams.supertitle = textParams.suptitle;
    
    if numSubplots > 1
        sgtitle(textParams.supertitle);
        %         suptitle(textParams.title);
    else
        title(textParams.supertitle);
    end
    if strcmp(paths.sessPath, 'AIC_Session_1_20201107')
        filenum = sprintf('%03d', 13+bin);
    elseif strcmp(paths.sessPath, 'AIC_Session_2_20201112')
        filenum = sprintf('%03d', 6+bin);
    else
        filenum = sprintf('%03d', bin);
    end
    filename = [paths.destPathRecall filesep textParams.supertitle '_' filenum];
   
%     keyboard
    % PDF
    if isPDF
        set(handlesToFig, 'PaperUnits', 'centimeters');
        set(handlesToFig, 'PaperPosition', [-1 0 28 20]);
        set(handlesToFig, 'PaperOrientation', 'landscape');
%         keyboard
        tic
        saveas(handlesToFig, filename, 'pdf');
        toc
    else
        % PNG
%         set(handlesToFig, 'PaperUnits', 'centimeters');
%         set(handlesToFig, 'PaperPosition', [0 0 65 35]);
        print(handlesToFig, filename, '-dpng', '-r0');
    end
    
   
%     keyboard
    close all
    
end

end