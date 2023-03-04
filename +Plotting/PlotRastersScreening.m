function PlotRastersScreening(basePath, imagesPerSubplot, subPlotNum, numFigsPerCell, strctCells, screeningData, sortByMag)

% setting up viewing parameters
if isfield(screeningData, 'catOrder') && ~isempty(screeningData.catOrder)
    MarkerSize = 4;
    Fontsize = 20;
    TitleFontSize = Fontsize;
    LineWidth = 3;
else
    MarkerSize = 4;
    Fontsize = 10;
    TitleFontSize = 16;
    LineWidth = 1.5;
end

colors = Utilities.distinguishable_colors(imagesPerSubplot);
sigCtr = 0;

% f = figure;
% set(0, 'CurrentFigure', f);

for cellIndex = 1:length(strctCells)%42:length(strctCells)%screeningData.visCell(:,1)'%l(strctCells)
    
    
    if isfield(screeningData, 'catOrder') && ~isempty(screeningData.catOrder)
        if sortByMag
            labels = Utilities.sortByRespMagnitude(screeningData.catOrder, screeningData.catIDs, screeningData.psth{cellIndex, 2}, -screeningData.timelimits(1)*1e3);
        else
            labels = screeningData.catIDs;
        end
        orderToUse = screeningData.catOrder;
    else
        if sortByMag
            labels = Utilities.sortByRespMagnitude(screeningData.sortedOrder, screeningData.imageIDs, screeningData.psth{cellIndex, 2}, -screeningData.timelimits(1)*1e3);
%             MarkerSize = 3;
        else
            labels = screeningData.imageIDs;
        end
        orderToUse = screeningData.sortedOrder;
    end
    screeningData.magnitudeOrder{cellIndex} = labels;
    
    
    % find global ylim
    totalTrials = numFigsPerCell*imagesPerSubplot*subPlotNum;
    if isfield(screeningData, 'catIDs') && ~isempty(screeningData.catIDs)
        globalyl = Utilities.Plotting.findingGlobalYLim(screeningData.psth{cellIndex, 2}, labels, orderToUse, 'Screening', totalTrials);
    else
        globalyl = Utilities.Plotting.findingGlobalYLim(screeningData.psth{cellIndex, 2}, labels, orderToUse, 'Screening', totalTrials);
    end
    for figNum = 1:numFigsPerCell
        f(figNum) = figure('Visible', 'off');
        set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen
        %         clf reset
%         if isfield(screeningData, 'catIDs') && ~isempty(screeningData.catIDs)
            beginPathOut = [basePath filesep 'rasters' filesep screeningData.anovaType];
%         end
        if sortByMag
            beginPathOut = [beginPathOut filesep 'sortedByMag'];
        end
        if isfield(screeningData, 'sigCell') && ~isempty(screeningData.sigCell) && ismember(cellIndex, cell2mat(screeningData.sigCell(:, 1)))
            if figNum == 1
                sigCtr = sigCtr + 1;
            end
            if iscell(strctCells(cellIndex).brainArea)
%                 suptitle({[num2str(strctCells(cellIndex).Name) ' ' char(strctCells(cellIndex).brainArea) '\_' num2str(figNum)],...
%                     ['Anova Type: ' screeningData.anovaType ', Pval: ' num2str(screeningData.sigCell{sigCtr, 3})]});
                if isempty(screeningData.responses{cellIndex, 2})
                    sgt = sgtitle({[num2str(strctCells(cellIndex).Name) ' ' char(strctCells(cellIndex).brainArea) '\_' num2str(figNum)],...
                        ['Anova Type: ' screeningData.anovaType ', Pval: ' num2str(screeningData.sigCell{sigCtr, 3})]});
                    sgt.FontSize = TitleFontSize;
                    sgt.FontWeight = 'Bold';
                else
                    sgt = sgtitle({[num2str(strctCells(cellIndex).Name) ' ' char(strctCells(cellIndex).brainArea) '\_' num2str(figNum)],...
                        ['Anova Type: ' screeningData.anovaType ', Pval: ' num2str(screeningData.sigCell{sigCtr, 3})],...
                        ['Response Latency ' num2str(screeningData.responses{cellIndex, 2})]});
                    sgt.FontSize = TitleFontSize;
                    sgt.FontWeight = 'Bold';
                end
            else
                if isempty(screeningData.responses{cellIndex, 2})
                    
                    %                 suptitle({[num2str(strctCells(cellIndex).Name) ' ' strctCells(cellIndex).brainArea '\_' num2str(figNum)],...
                    %                     ['Anova Type: ' screeningData.anovaType ', Pval: ' num2str(screeningData.sigCell{sigCtr, 3})]});
                    sgt = sgtitle({[num2str(strctCells(cellIndex).Name) ' ' strctCells(cellIndex).brainArea '\_' num2str(figNum)],...
                        ['Anova Type: ' screeningData.anovaType ', Pval: ' num2str(screeningData.sigCell{sigCtr, 3})]});
                    sgt.FontSize = TitleFontSize;
                    sgt.FontWeight = 'Bold';
                else
                    sgt = sgtitle({[num2str(strctCells(cellIndex).Name) ' ' strctCells(cellIndex).brainArea '\_' num2str(figNum)],...
                        ['Anova Type: ' screeningData.anovaType ', Pval: ' num2str(screeningData.sigCell{sigCtr, 3})],...
                        ['Response Latency ' num2str(screeningData.responses{cellIndex, 2})]});
                    sgt.FontSize = TitleFontSize;
                    sgt.FontWeight = 'Bold';
                end
            end
            pathOut = [beginPathOut filesep 'significant_cells'];
            if ~exist(pathOut)
                mkdir([pathOut]);
            end
        else
            if iscell(strctCells(cellIndex).brainArea)
                if isempty(screeningData.responses{cellIndex, 2})
                    %                 suptitle({[num2str(strctCells(cellIndex).Name) ' ' char(strctCells(cellIndex).brainArea) '\_' num2str(figNum)]}); % backslash allows you to print the underscore
                    sgt = sgtitle({[num2str(strctCells(cellIndex).Name) ' ' char(strctCells(cellIndex).brainArea) '\_' num2str(figNum)]}); % backslash allows you to print the underscore
                    sgt.FontSize = TitleFontSize;
                    sgt.FontWeight = 'Bold';
                else
                    sgt = sgtitle({[num2str(strctCells(cellIndex).Name) ' ' char(strctCells(cellIndex).brainArea) '\_' num2str(figNum)],...
                        ['Response Latency ' num2str(screeningData.responses{cellIndex, 2})]}); % backslash allows you to print the underscore
                    sgt.FontSize = TitleFontSize;
                    sgt.FontWeight = 'Bold';
                end
            else
                if isempty(screeningData.responses{cellIndex, 2})
                    %                 suptitle({[num2str(strctCells(cellIndex).Name) ' ' strctCells(cellIndex).brainArea '\_' num2str(figNum)]}); % backslash allows you to print the underscore
                    sgt = sgtitle({[num2str(strctCells(cellIndex).Name) ' ' strctCells(cellIndex).brainArea '\_' num2str(figNum)]}); % backslash allows you to print the underscore
                    sgt.FontSize = TitleFontSize;
                    sgt.FontWeight = 'Bold';
                else
                    sgt = sgtitle({[num2str(strctCells(cellIndex).Name) ' ' strctCells(cellIndex).brainArea '\_' num2str(figNum)],...
                        ['Response Latency ' num2str(screeningData.responses{cellIndex, 2})]}); % backslash allows you to print the underscore
                    sgt.FontSize = TitleFontSize;
                    sgt.FontWeight = 'Bold';
                end
            end
            pathOut = beginPathOut;
            if ~exist(pathOut)
                mkdir([pathOut]);
            end           
        end
        % currently this is redrawing the same few images on each figure, change it
        for ctr = 1:subPlotNum % make sure this is divisible - chunks of images
            
            % adjusted for which figure it is eg. if I'm ploting 100 images
            % per figure then fig 2 should start plotting from 101-200
            figurePlotOffset = ((figNum-1)*imagesPerSubplot*subPlotNum);
            
%             if isfield(screeningData, 'catIDs') && ~isempty(screeningData.catIDs)
%                 imagesTOplot=screeningData.catIDs(((imagesPerSubplot*(ctr-1))+figurePlotOffset+1):...
%                     screeningData.catIDs((imagesPerSubplot*(ctr-1))+figurePlotOffset+imagesPerSubplot));
%                 screeningData.imageIDstoDEL=setdiff(screeningData.catIDs,[imagesTOplot]);
%             else
%                 imagesTOplot=screeningData.imageIDs(((imagesPerSubplot*(ctr-1))+figurePlotOffset+1):...
%                     screeningData.imageIDs((imagesPerSubplot*(ctr-1))+figurePlotOffset+imagesPerSubplot));
%                 screeningData.imageIDstoDEL=setdiff(screeningData.imageIDs,[imagesTOplot]);
%             end
            imagesTOplot=labels(((imagesPerSubplot*(ctr-1))+figurePlotOffset+1):...
                    ((imagesPerSubplot*(ctr-1))+figurePlotOffset+imagesPerSubplot));
                screeningData.imageIDstoDEL=setdiff(labels,[imagesTOplot]);
            % FR
            h_1(ctr) = subplot(2, subPlotNum, ctr);
            hold on
            
            
            for p1 = 1:length(imagesTOplot)
                Utilities.stdshade5(screeningData.psth{cellIndex, 2}(find(orderToUse == imagesTOplot(p1)), :), 0.1,...
                    colors(mod(p1, length(imagesTOplot))+1, :), screeningData.psth{cellIndex, 3}, 2);
            end
            set(gca,'FontSize',Fontsize, 'FontWeight', 'bold')
            ylabel('Firing Rate (Hz)','FontSize',Fontsize, 'FontWeight', 'bold');

            if subPlotNum == 1
                crunchFactor = screeningData.Binsize*1e-3;
                %                 xlim([screeningData.timelimits(1)*0.9 screeningData.timelimits(2)*0.9]);
                xlim([screeningData.timelimits(1)+crunchFactor screeningData.timelimits(2)-crunchFactor]);
                if isfield(screeningData, 'lgnd') && ~isempty(screeningData.lgnd)
%                     lgnd = legend(screeningData.lgnd(labels)); % sorting my magnitude if required
                    lgnd = legend(screeningData.lgnd(labels), 'FontWeight', 'bold'); % sorting my magnitude if required
%                     lgnd = legend('\color{red} Faces', '\color{green} Text', '\color{black} Plants/Fruits', '\color{magenta} Animals', '\color{blue} Objects');
%                    set(lgnd, 'Position', [0.9153,0.8273,0.0562,0.0893]);
                    if strcmp(screeningData.subID, 'P73CS_FWFast')
                        set(lgnd, 'Position', [0.8907,0.6756,0.1077,0.2850]);
                    else
                        set(lgnd, 'Position', [0.8543 0.8330 0.1385 0.0958]);
                    end
                end
            else
                xlim([screeningData.timelimits(1) screeningData.timelimits(2)]);
            end
            % needs to be improved
            ylim([0 globalyl+2]);
%             plot([0 0], [0 globalyl+2], '--k', 'LineWidth', 1, 'HandleVisibility');
            plot([0 0], [0 globalyl+2], '--k', 'LineWidth', LineWidth, 'HandleVisibility', 'off');
            plot([screeningData.stimDur/1000 screeningData.stimDur/1000], [0 globalyl+2], '--k', 'LineWidth', LineWidth, 'HandleVisibility', 'off');
            
            % raster
            h_2(ctr) = subplot(2, subPlotNum, ctr+subPlotNum);
            hold on
            if isfield(screeningData, 'catIDs') && ~isempty(screeningData.catIDs)
                iterSize = 0;
                for p2 = 1:length(imagesTOplot)
                    iter = find(orderToUse == imagesTOplot(p2));
                    if p2 > 1
                        iterSize = iterSize + length(find(orderToUse == imagesTOplot(p2-1)));
                    else
                        iterSize = 0;
                    end
                    for k = 1:size(iter, 1)
                        try
                            % if sorted raster used replace original with presentations
                            plot((find(screeningData.psth{cellIndex, 1}(iter(k), :)==1).*(1/1000)+screeningData.timelimits(1)),...
                                iterSize+k,'Marker','square', 'LineStyle','none','MarkerFaceColor',colors(mod(p2, length(imagesTOplot))+1, :),...
                                'MarkerEdgeColor','none','MarkerSize',MarkerSize)
                            
                            hold on
                            
                        end
                    end
                end
            else
                runningSum = 0;
                plotDisp = length(orderToUse(ismember(orderToUse, imagesTOplot)))*(ctr-1);
                for p2 = 1:length(imagesTOplot)
                    iter = find(orderToUse == imagesTOplot(p2)); % iter is now a vector of indices size 6
                    if p2 > 1
                        runningSum = runningSum + length(find(orderToUse == imagesTOplot(p2-1)));
                    end
                    for k = 1:length(iter)%screeningData.numRepetitions
                        try
                            % if sorted raster used replace original with presentations
                            plot((find(screeningData.psth{cellIndex, 1}(iter(k), :)==1).*(1/1000)+screeningData.timelimits(1)),...
                                runningSum+k+plotDisp,'Marker','square', 'LineStyle','none','MarkerFaceColor',colors(mod(p2, length(imagesTOplot))+1, :),...
                                'MarkerEdgeColor','none','MarkerSize',MarkerSize)
                            
                            hold on
                            
                        end
                    end
                end
            end
            
            set(gca,'XGrid','on')
            set(gca, 'YGrid','on')
            grid on
            
%             tick=round(length(screeningData.correctOrder)*0.20);
            
            set(gca,'FontSize',Fontsize, 'FontWeight', 'bold')
            
            xlim([screeningData.timelimits(1) screeningData.timelimits(2)]);

            ylabel('trial nr (re-ordered)','FontSize',Fontsize, 'FontWeight', 'bold');
            if subPlotNum == 1
                ylim([0 length(orderToUse)+1]);
                xlim([screeningData.timelimits(1)+crunchFactor screeningData.timelimits(2)-crunchFactor]);                
            else
                ylim([plotDisp+1 plotDisp+length(orderToUse(ismember(orderToUse, imagesTOplot)))]);
            end
            yl = ylim;
            plot([0 0], [yl(1) yl(2)], '--k', 'LineWidth', LineWidth, 'HandleVisibility', 'off');
            plot([screeningData.stimDur/1000 screeningData.stimDur/1000], [yl(1) yl(2)], '--k', 'LineWidth', LineWidth, 'HandleVisibility', 'off');
            xlabel('time (sec)','FontSize',Fontsize, 'FontWeight', 'bold');
            
            set(gca,'FontSize',Fontsize)
            %             keyboard;          
        end
        if subPlotNum == 1
            linkaxes([h_1, h_2], 'x');
        else
            linkaxes(h_1, 'y');
        end
        % saving
        %         filename = [pathOut filesep strctCells(cellIndex).brainArea '_' num2str(strctCells(cellIndex).ChannelNumber) '_' num2str(strctCells(cellIndex).Name) '_' num2str(figNum)];
        %         if ~strcmp(class(filename), 'cell')
        %             print(f,filename ,'-dpng','-r0')
        %         else
        %             filename = [pathOut filesep strctCells(cellIndex).brainArea{1} '_' num2str(strctCells(cellIndex).ChannelNumber) '_' num2str(strctCells(cellIndex).Name) '_' num2str(figNum)];
        %             print(f,filename ,'-dpng','-r0')
        %         end
        %         keyboard;
    end
    
    % saving all together after modification
    for i = 1:numFigsPerCell
        filename = [pathOut filesep strctCells(cellIndex).brainArea '_' num2str(strctCells(cellIndex).ChannelNumber) '_' num2str(strctCells(cellIndex).Name) '_' num2str(i)];
        if ~strcmp(class(filename), 'cell')
            print(f(i),filename ,'-dpng','-r0')
        else
            filename = [pathOut filesep strctCells(cellIndex).brainArea{1} '_' num2str(strctCells(cellIndex).ChannelNumber) '_' num2str(strctCells(cellIndex).Name) '_' num2str(i)];
            print(f(i),filename ,'-dpng','-r0')
        end
        
    end
    %     keyboard;
    close all;
end

end