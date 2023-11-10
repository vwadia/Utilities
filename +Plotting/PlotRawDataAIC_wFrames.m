function PlotRawDataAIC_wFrames(pathOut, wholeVidPsth, chunkSize, offsets, order, textParams, plotOptions, images, strctCells, isPDF)
% This function takes in neural data of a full movie (psth1, psth, times)
% and a desired chunk size (eg, 10s) and makes separate plots of each chunk
% it includes an option to plot the frames of the movie below each second marker
% Note:  the chunks don't need to perfectly divide the videolength, it will intelligently figure it out
% Inputs:
%     1. pathOut(destination folder)
%     2. psth (1x3 cell with psth1, psth, times)
%     3. chunkSize
%     4. offsets
%     5. order
%     6. textParams
%     7. plotOptions
%     8. vidFrames (cell array)
% Outputs:
%     1. figures printed to pathOut
% vwadia Jan 2021
if nargin == 7, images = []; frames = 0; strctCells = []; isPDF = 0; end
if nargin == 8, strctCells = []; isPDF = 0; end

if ~isempty(images)
    frames = 1;
end

if ~isempty(strctCells) 
    population = 1;
else
    population = 0;
end


if frames
    numFramesPerPage = chunkSize*1e-3;
end
numChars = 2; % inputted manually
resolution = 1000; % ms
% set up blocks
if population
    blocksPerSubplot = length(strctCells)*numChars;
    plotOptions.MarkerSize = 3;
else
%     blocksPerSubplot = plotOptions.blocksPerSubplot; %length(unique(order))/2;
    blocksPerSubplot = length(unique(order))/2;
end
colors = distinguishable_colors(blocksPerSubplot, [1 1 1]);

% if I want specific colour settings eg. to match the encoding data
if isfield(textParams, 'useTheseColors') && ~isempty(textParams.useTheseColors)
    colors = textParams.useTheseColors;
end


numBins = ceil(size(wholeVidPsth{1, 1}, 2)/chunkSize); % number of bins needed

globalyl = findingGlobalYLim(wholeVidPsth{1, 2}, unique(order), order, 'AIC');

% figure out which pages to put dashed lines
onsetPageNum = ceil(offsets(1)/chunkSize);
offsetPageNum = ceil((size(wholeVidPsth{1, 1}, 2) - offsets(2))/chunkSize);

framesPerChunk = chunkSize/resolution; % we want to print a frame per how many seconds?


for bin = 1:numBins % figure per bin
    if bin == numBins
        psth{1, 1} = wholeVidPsth{1, 1}(:, ((bin-1)*chunkSize)+1:end);
        psth{1, 2} = wholeVidPsth{1, 2}(:, ((bin-1)*chunkSize)+1:end);
        psth{1, 3} = wholeVidPsth{1, 3}(:, ((bin-1)*chunkSize)+1:end);
    else
        psth{1, 1} = wholeVidPsth{1, 1}(:, ((bin-1)*chunkSize)+1:((bin-1)*chunkSize)+chunkSize);
        psth{1, 2} = wholeVidPsth{1, 2}(:, ((bin-1)*chunkSize)+1:((bin-1)*chunkSize)+chunkSize);
        psth{1, 3} = wholeVidPsth{1, 3}(:, ((bin-1)*chunkSize)+1:((bin-1)*chunkSize)+chunkSize);
    end
    timelimits = [-offsets(1) size(psth{1, 1}, 2)-offsets(1)];
    
    handlesToFig = figure; clf;
    set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen
%     if population
    textParams.supertitle = [textParams.suptitle '\_Section\_' num2str(bin)];
%     else
%         textParams.supertitle = [textParams.suptitle{1, 1} '\_Section\_' num2str(bin)];
%     end
    suptitle(textParams.supertitle);
    
    stimTOplot=unique(order);%stim(((blocksPerSubplot*(ctr-1))+1):...
    %(blocksPerSubplot*(ctr-1))+blocksPerSubplot);
    
    
    % FR ------------------------------------------------------------------
    if ~frames
        h_1 = subplot(2, 1, 1);
    elseif frames
        h_1 = subplot('Position', [0.13,0.656405163853029,0.775,0.268594836146971]);%subplot(3, numFramesPerPage, [1:numFramesPerPage]);
    end
    hold on
    
    % data
    for p1 = l(stimTOplot)
        stdshade5(psth{1, 2}(find(order == stimTOplot(p1)), :), 0.1, colors(p1, :), psth{1, 3}, 2);
    end
    
    
    % set legend
    if isempty(strctCells) && isfield(textParams, 'legend')
        lgnd = legend(textParams.legend);
        title(lgnd, textParams.legendTitle);
    elseif isfield(textParams, 'legend')
        legText1 = text(size(psth{1, 1}, 2)+200, 350, 'TOP - Al Gore');
        legText2 = text(size(psth{1, 1}, 2)+200, 300, 'BOTTOM - Bill Clinton');
        legText1.FontWeight = 'bold';
        legText2.FontWeight = 'bold';
    end
    
    % adjust axes
    xlim([psth{1, 3}(1) psth{1, 3}(end)]);
    
    if bin == onsetPageNum
        plot([0 0], [0 globalyl+(globalyl/10)], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
    elseif bin == offsetPageNum
        plot([psth{1, 3}(1) + timelimits(2) psth{1, 3}(1) + timelimits(2)], [0 globalyl+(globalyl/10)], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
    end
    ylabel(textParams.ylabelplot1,'FontSize',plotOptions.FontSize);
    
    ylim([0 globalyl+(globalyl/10)]);
    
    xt = xticks;
    % label axes
    xlabel(textParams.xlabel,'FontSize',plotOptions.FontSize);
    
    if isfield(plotOptions, 'statsArray') && ~isempty(plotOptions.statsArray)
        xvalStar = cell2mat(plotOptions.statsArray(:, 2))';
        xvalStar = xvalStar+250;
        yvalStar = repmat(globalyl, 1, length(xvalStar));
        scatter(xvalStar, yvalStar, 25, '*', 'k');
    end
    
    %  plot raster --------------------------------------------------------
    if ~frames
        h_2 = subplot(2, 1, 2);
    elseif frames
        h_2 = subplot('Position', [0.13,0.11,0.775,0.268594836146971]);%subplot(3, numFramesPerPage, [2*numFramesPerPage+1:3*numFramesPerPage]);
    end
    hold on
    if size(stimTOplot, 1) > size(stimTOplot, 2)
        stimTOplot = stimTOplot';
    end
    % data
    
    if length(find(order == stimTOplot)) < 30
        for p2 = l(stimTOplot)
            raster = logical(psth{1, 1}(find(order == stimTOplot(p2)), :));
            LineFormat.Color = colors(length(stimTOPlot)-p2+1, :);
            vertSpikePos = (p2-1)*6;
            plotSpikeRaster(raster, 'PlotType', 'vertline','RasterWindowOffset', -offsets(1)*1e-3, 'LineFormat', LineFormat, 'VertSpikePosition', vertSpikePos);
        end
        ylim([0 (6*length(stimTOplot))+1]);        
    else
        for p2 = l(stimTOplot)
            iter = find(order == stimTOplot(p2)); % iter is now a vector of indices size 6
            for k = 1:length(iter) %psth.numRepetitions % this needs to be fixed...
                try
                    % note that the time here is already in ms so no
                    % need to divide by 1000
                    %                     plot((find(psth{1, 1}(iter(k), :)==1)+timelimits(1)),...
                    %                         length(iter)*(stimTOplot(p2)-1)+k,'Marker','square', 'LineStyle','none','MarkerFaceColor',colors(p2, :),...
                    %                         'MarkerEdgeColor','none','MarkerSize',plotOptions.MarkerSize)
                    plot((find(psth{1, 1}(iter(k), :)==1)+timelimits(1)),...
                        length(iter)*(p2-1)+k,'Marker','square', 'LineStyle','none','MarkerFaceColor',colors(length(stimTOplot)-p2+1, :),...
                        'MarkerEdgeColor','none','MarkerSize',plotOptions.MarkerSize)
                    hold on
                end
            end
        end
    end
    
    % titles
    if isfield(textParams, 'title1') && ~isempty(textParams.title1)
        if mod(ctr, 2) == 1
            title(textParams.title1);
        else
            title(textParams.title2);
        end
    end
 
    
    ylim([0 length(order)+1]);
    yl = ylim;
    if bin == 1
        plot([0 0], [yl(1) yl(2)], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
    elseif bin == numBins
        plot([timelimits(1)+timelimits(2) timelimits(1)+timelimits(2)], [yl(1) yl(2)], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
    end
    
    set(gca,'XGrid','on')
    set(gca, 'YGrid','on')
    grid on
    
    % adjust axes
    set(gca,'FontSize',plotOptions.FontSize)
    xlim([timelimits(1) timelimits(2)]);
    xticklabels(xt);
    xlim([timelimits(1) timelimits(2)]);
    
%     for ii = 1:2 % change this, don't need to plot rasters together
%         if ii == 1
%             h = h_1;
%         else
%             h = h_2;
%         end
        if population
            h = h_2;
            % ylabels for population plot
            patientBrainAreas = struct2cell(strctCells');
            patientBrainAreas = patientBrainAreas(3:4, :)';
            ptba(:, 1) = repelem(patientBrainAreas(:, 1), length(order)/length(strctCells));
            ptba(:, 2) = repelem(patientBrainAreas(:, 2), length(order)/length(strctCells));
            patientBrainAreas = {};
            %         patientBrainAreas(:, 2) = [];
            patientBrainAreas(:, 1) = ptba(:, 1);
            patientBrainAreas(:, 2) = ptba(:, 2);
            regions = unique([patientBrainAreas{:, 1}], 'stable');
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
            
            yticks(h, ytik);
            %         set(gca,'YDir','reverse');
            set(h, 'YTickLabel', []);
            
            xl = xlim;
            for yticknum = 1:length(ytik)
                if yticknum ==1
                    ytikpos = ytik(yticknum)/2;
                else
                    ytikpos = ytik(yticknum-1)+(ytik(yticknum)-ytik(yticknum-1))/2;
                end
                ty = text(h, xl(1)-300, ytikpos, ytiklabs{yticknum});
                %             ty.FontWeight = 'bold';
            end
            
        else
            ylabel(textParams.ylabelplot2,'FontSize',plotOptions.FontSize);
        end
%     end
    % label axes
    xlabel(textParams.xlabel,'FontSize',plotOptions.FontSize);
    set(gca,'FontSize',plotOptions.FontSize)
    
    if frames
        % first page - after baseline
        if bin == onsetPageNum
            frameTicks = find(xt >= 0);
            for framePos = 1:length(frameTicks)
                frameOffset = length(frameTicks);
                h_3 = subplot(3, numFramesPerPage, frameTicks(framePos)+numFramesPerPage);
                pos = get(h_3, 'Position');
                pos(1) = pos(1)-(pos(3))/1.5; % shift left by half the width of the frame
                pos(4) = 0.65*pos(4);
                pos(3) = 1.25*pos(3);
                movFrame = images{numFramesPerPage*(bin-1)+framePos};
                image(movFrame);
                set(gca, 'visible', 'off');
                set(h_3, 'Position', pos);
            end
            % last page - before stimOFF
        elseif bin == offsetPageNum
            frameTicks = find(xt <= psth{1, 3}(1) + timelimits(2));
            for framePos = frameTicks
                h_3 = subplot(3, numFramesPerPage, framePos+numFramesPerPage);
                pos = get(h_3, 'Position');
                pos(1) = pos(1)-(pos(3))/1.5; % shift left by half the width of the frame
                pos(4) = 0.65*pos(4);
                pos(3) = 1.25*pos(3);
                movFrame = images{numFramesPerPage*(bin-1)+framePos-frameOffset};
                image(movFrame);
                set(gca, 'visible', 'off');
                set(h_3, 'Position', pos);
            end
        else
            for framePos = 1:numFramesPerPage
                h_3 = subplot(3, numFramesPerPage, framePos+numFramesPerPage);
                pos = get(h_3, 'Position');
                pos(1) = pos(1)-(pos(3))/1.5; % shift left by half the width of the frame
                pos(4) = 0.65*pos(4);
                pos(3) = 1.25*pos(3);
                movFrame = images{numFramesPerPage*(bin-1)+framePos-frameOffset};
                image(movFrame);
                set(gca, 'visible', 'off');
                set(h_3, 'Position', pos);
            end
        end
    end
    
    
    % plot legend position
    if isempty(strctCells)
        if plotOptions.moveLegend == 1 % scenes and cuts
            set(lgnd, 'Position', [0.47,0.78,0.0625,0.1146]);
            %         set(lgnd, 'Position', [0.47,0.58,0.079,0.32]);
        elseif plotOptions.moveLegend == 2 % videos
            if blocksPerSubplot > 5
%                 set(lgnd, 'Position', [0.912,0.478,0.0823,0.5480]); 0.915,0.4909,0.062,0.4326
                set(lgnd, 'Position', [0.915,0.4909,0.062,0.4326]); 
            else
                set(lgnd, 'Position', [0.9153,0.8273,0.0562,0.0893]);
            end
        end
    end
%         keyboard
    filenum = sprintf('%03d', bin);
    filename = [pathOut filesep plotOptions.fold_name '_' filenum];% '.pdf'];
    
     % PDF
    if isPDF
        set(handlesToFig, 'PaperUnits', 'centimeters');
        set(handlesToFig, 'PaperPosition', [-1 0 28 20]);
        set(handlesToFig, 'PaperOrientation', 'landscape');
        keyboard
        tic
        saveas(handlesToFig, filename, 'pdf');
        toc
    else
        % PNG
        print(handlesToFig, filename, '-dpng', '-r0');
    end
   
    close all
    
end




end