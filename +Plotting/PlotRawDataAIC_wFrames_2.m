function PlotRawDataAIC_wFrames_2(pathOut, wholeVidPsth, chunkSize, offsets, order, textParams, plotOptions, images, strctCells, isPDF)
% This function takes in neural data of a full movie (psth1, psth, times)
% and a desired chunk size (eg, 10s) and makes separate plots of each chunk
% it includes an option to plot the frames of the movie below each second marker
% Note:  the chunks don't need to perfectly divide the videolength, it will intelligently figure it out
% Adapted for matlab 2020
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
    allCells = 1;
else
    allCells = 0;
end

% if length(unique(order)) > size(wholeVidPsth, 2)
% population s= 1;
% else
    population = 0;
% end


if frames
    numFramesPerPage = chunkSize*1e-3;
end
numChars = 2; % inputted manually
resolution = 1000; % ms
% set up blocks
if allCells
    blocksPerSubplot = length(strctCells)*numChars;
    plotOptions.MarkerSize = 3;
else
    %     blocksPerSubplot = plotOptions.blocksPerSubplot; %length(unique(order))/2;
    blocksPerSubplot = length(unique(order));
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
if isfield(plotOptions, 'stimTOplot')
    scNum = mod(plotOptions.stimTOplot(1), plotOptions.numScenes);
    if scNum == 1
        place = '_House_';
        endPoint = plotOptions.endPoint(scNum);
    elseif scNum == 2
        place = '_City_';
        endPoint = plotOptions.endPoint(scNum);
    elseif scNum == 0
        scNum = plotOptions.numScenes;
        place = '_Market_';
        endPoint = plotOptions.endPoint(scNum);
    end
else
    endPoint = (size(wholeVidPsth{1, 1}, 2) - sum(offsets));
end
framesPerChunk = chunkSize/resolution; % we want to print a frame per how many seconds?


for bin = 1:numBins % figure per bin
    if bin == numBins
        psth{1, 1} = wholeVidPsth{1, 1}(:, ((bin-1)*chunkSize)+1:end);
        psth{1, 2} = wholeVidPsth{1, 2}(:, ((bin-1)*chunkSize)+1:end);
        psth{1, 3} = wholeVidPsth{1, 3}(:, ((bin-1)*chunkSize)+1:end);
        
        prevSize = size(wholeVidPsth{1, 3}(:, ((bin-2)*chunkSize)+1:((bin-2)*chunkSize)+chunkSize), 2);
        padArray = zeros(size(psth{1, 1}, 1), prevSize - size(psth{1, 1}, 2));
        
        psth{1, 1} = [psth{1, 1} padArray];
        psth{1, 2} = [psth{1, 2} padArray];
        psth{1, 3} = [psth{1, 3} (psth{1, 3}(end)+1):(psth{1, 3}(end)+size(padArray, 2))];
    else
        psth{1, 1} = wholeVidPsth{1, 1}(:, ((bin-1)*chunkSize)+1:((bin-1)*chunkSize)+chunkSize);
        psth{1, 2} = wholeVidPsth{1, 2}(:, ((bin-1)*chunkSize)+1:((bin-1)*chunkSize)+chunkSize);
        psth{1, 3} = wholeVidPsth{1, 3}(:, ((bin-1)*chunkSize)+1:((bin-1)*chunkSize)+chunkSize);
    end
    timelimits = [-offsets(1) size(psth{1, 1}, 2)-offsets(1)];
    
    handlesToFig = figure; clf;
    set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen
    if allCells || population
        textParams.supertitle = [textParams.suptitle '\_Section\_' num2str(bin)];
    else
        textParams.supertitle = [textParams.suptitle{1, 1} '\_Section\_' num2str(bin)];
    end
    sgtitle(textParams.supertitle);
    
    if isfield(plotOptions, 'splitScenes')
        stimTOplot = plotOptions.stimTOplot;
    else
        stimTOplot=unique(order);
    end
    %     %stim(((blocksPerSubplot*(ctr-1))+1):...
    %(blocksPerSubplot*(ctr-1))+blocksPerSubplot);
    
    
    % FR ------------------------------------------------------------------
    if ~frames
        h_1 = subplot(2, 1, 1);
    elseif frames
        h_1 = subplot('Position', [0.13,0.656405163853029,0.775,0.268594836146971]);%subplot(3, numFramesPerPage, [1:numFramesPerPage]);
    end
    hold on
    
    if bin == offsetPageNum
        disp('here');
    end
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
        plot([endPoint endPoint], [0 globalyl+(globalyl/10)], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
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
    
    % datarunningSum = 0;
    for p2 = l(stimTOplot)
        iter = find(order == stimTOplot(p2)); % iter is now a vector of indices size 6
        if p2 > 1
            iterSize = iterSize + length(find(order == stimTOplot(p2-1)));
        else
            iterSize = 0;
        end
        for k = 1:length(iter) %psth.numRepetitions % this needs to be fixed...
            %             if length(find(order == stimTOplot)) < 40
            %                 try
            %                     plot((find(psth{1, 1}(iter(k), :)==1)+timelimits(1)),...
            %                         length(iter)*(p2-1)+k,'Marker','|', 'LineStyle','none','MarkerFaceColor',colors(length(stimTOplot)-p2+1, :),...
            %                         'MarkerEdgeColor',colors(length(stimTOplot)-p2+1, :),'MarkerSize',2*plotOptions.MarkerSize, 'linewidth', 1.5)
            %                     hold on
            %                 end
            %             else
            try
                plot((find(psth{1, 1}(iter(k), :)==1)+timelimits(1)),...
                    iterSize+k,'Marker','square', 'LineStyle','none','MarkerFaceColor',colors(p2, :),...
                    'MarkerEdgeColor','none','MarkerSize',plotOptions.MarkerSize)
                hold on
            end
            %             end
        end
    end
    %     end
    
    % titles
    if isfield(textParams, 'title1') && ~isempty(textParams.title1)
        if mod(ctr, 2) == 1
            title(textParams.title1);
        else
            title(textParams.title2);
        end
    end
    
    ylim([0 (length(stimTOplot)*6)+1]);
%     ylim([0 length(order)+1]);
    yl = ylim;
    % note that in raster plotting the xticks are always timelimits(1) ->
    % timelimits(2). So the vertical line plotting has to be handled
    % differently on the last page
    if bin == onsetPageNum
        plot([0 0], [yl(1) yl(2)], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
    elseif bin == offsetPageNum
        plot([find(psth{1, 3} == endPoint) + timelimits(1) find(psth{1, 3} == endPoint) + timelimits(1)],...
            [yl(1) yl(2)], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
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
    if allCells
        h = h_2;
        % ylabels for allCells plot
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
                movFrame = images{numFramesPerPage*(bin-1)+framePos, scNum};
                image(movFrame);
                set(gca, 'visible', 'off');
                set(h_3, 'Position', pos);
            end
            % last page - before stimOFF
        elseif bin == offsetPageNum
            frameTicks = find(xt <= endPoint);
            framesDone = xt(1)/1000; % frames already plotted
            for framePos = frameTicks
                h_3 = subplot(3, numFramesPerPage, framePos+numFramesPerPage);
                pos = get(h_3, 'Position');
                pos(1) = pos(1)-(pos(3))/1.5; % shift left by half the width of the frame
                pos(4) = 0.65*pos(4);
                pos(3) = 1.25*pos(3);
                movFrame = images{framesDone+framePos, scNum};
                image(movFrame);
                set(gca, 'visible', 'off');
                set(h_3, 'Position', pos);
            end
        elseif bin < offsetPageNum % weirdly have to specify here in case no frames on the last page
            framesDone = xt(1)/1000; % frames already plotted
            for framePos = 1:numFramesPerPage
                h_3 = subplot(3, numFramesPerPage, framePos+numFramesPerPage);
                pos = get(h_3, 'Position');
                pos(1) = pos(1)-(pos(3))/1.5; % shift left by half the width of the frame
                pos(4) = 0.65*pos(4);
                pos(3) = 1.25*pos(3);
                movFrame = images{framesDone+framePos, scNum};
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
            if blocksPerSubplot > 20
                set(lgnd, 'Position', [ 0.917,0.0764,0.0717,0.910]);% 0.915,0.4909,0.062,0.4326
                %                 set(lgnd, 'Position', [ 0.915,0.0783,0.0656,0.908]);
                %                 0.917,0.0764,0.0717,0.910
            elseif blocksPerSubplot > 5 && blocksPerSubplot <= 20
                set(lgnd, 'Position', [0.915,0.4909,0.062,0.4326]);
            else
                set(lgnd, 'Position', [0.9153,0.8273,0.0562,0.0893]);
            end
        end
    end
    %         keyboard
    filenum = sprintf('%03d', bin);
    if isfield(plotOptions, 'stimTOplot')       
        filename = [pathOut filesep plotOptions.fold_name place filenum];% '.pdf'];
    else
        filename = [pathOut filesep plotOptions.fold_name filenum];% '.pdf'];
    end
    
    % PDF
    if isPDF
        
        set(handlesToFig, 'PaperUnits', 'centimeters');
        set(handlesToFig, 'PaperPosition', [-1 0 28 20]);
        set(handlesToFig, 'PaperOrientation', 'landscape');
        
        %         set(handlesToFig, 'PaperUnits', 'inches');
        %         screenPos = get(handlesToFig, 'Position');%, [-2 0 29 26]);
        %         set(handlesToFig,...
        %             'PaperPosition', [0 0 screenPos(3:4)],...
        %             'PaperSize', [screenPos(3:4)]);
        %         keyboard
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