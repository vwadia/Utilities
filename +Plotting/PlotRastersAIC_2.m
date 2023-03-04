function handlesToFig = PlotRastersAIC_2(subPlotNum, numFigsPerCell, offsets, psth, order, textParams, plotOptions)
% In this current paradigm:
% images per subplot tells you what chunks to plot together
% That determines imagesToplot in each subplot as you cycle through them
% In my case, I want all the chunks for each character plotted together
% Inputs:
%     1. Plot arrangement (num of subplots, figs per cell etc.)
%     2. Offsets (1-side or 2-sided)
%     3. strctCells
%     4. Psth (cell array, cell 1 - raster, cell 2 - smoothed raster, cell 3 - times)
%     5. Order (because the psth isn't sorted)
%     6. textParams (title, axes labels etc.)
%     7. plotOptions: useBothOffsets, curb edges, MarkerSize, Fontsize 
% Outputs:
%     1. Plots will be printed to destination folder.
% vwadia Dec2020 modified Jan2021


blocksPerSubplot = plotOptions.blocksPerSubplot; %length(unique(mod(order, 10)));
colors = distinguishable_colors(blocksPerSubplot);



timelimits = [-offsets(1) size(psth{1, 1}, 2)-offsets(1)];
globalyl = findingGlobalYLim(psth{1, 2}, unique(order), order, 'AIC');


for figNum = 1:numFigsPerCell
    
    handlesToFig = figure; clf;
    set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen
    
    % handle this in textparams
    suptitle(textParams.suptitle);
   
    
    % currently this is redrawing the same few images on each figure, change it
    for ctr = 1:subPlotNum 
        if isfield(plotOptions, 'cellEventOrder') && ~isempty(plotOptions.cellEventOrder)
            stim = plotOptions.cellEventOrder;
        else
            stim = unique(order);
        end
        stimTOplot=stim(((blocksPerSubplot*(ctr-1))+1):...
            (blocksPerSubplot*(ctr-1))+blocksPerSubplot);
        %             stimtoDEL=setdiff(order,[stimTOplot]);
        % FR
        h_1(ctr) = subplot(2, subPlotNum, ctr);
        hold on
        
        
        for p1 = l(stimTOplot)
            stdshade5(psth{1, 2}(find(order == stimTOplot(p1)), :), 0.1, colors(p1, :), psth{1, 3}, 2);
        end
        if ctr == 1
            lgnd = legend(textParams.legend); %legend('Al Gore', 'Bill Clinton');%, 'Sc3 - Market');
            title(lgnd, textParams.legendTitle);            
        end
        
%         % needs to be improved
%         if isfield(textParams, 'title1') && ~isempty(textParams.title1)
%             if mod(ctr, 2) == 1
%                 title(textParams.title1);
%             else
%                 title(textParams.title2);
%             end
%         end
        xlim([psth{1, 3}(1) psth{1, 3}(end)]);

%         wtf is this?
        if ~isfield(plotOptions, 'split')

            if plotOptions.curbEdges
                xlim([timelimits(1)-(0.1*timelimits(1)) timelimits(2)-(0.05*timelimits(2))]);
            else
                xlim([timelimits(1) timelimits(2)]);
            end

        end
        
        if isfield(plotOptions, 'plotNum') 
            if plotOptions.plotNum == 1
                plot([0 0], [0 globalyl+(globalyl/10)], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
            elseif plotOptions. plotNum == 13
                plot([psth{1, 3}(555) psth{1, 3}(555)], [0 globalyl+(globalyl/10)], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
            end
        end
        
        if isfield(plotOptions, 'split') && plotOptions.split == 1
            xt = xticks;
        end

        ylim([0 globalyl+(globalyl/10)]);

        ylabel(textParams.ylabelplot1,'FontSize',plotOptions.FontSize);
        xlabel(textParams.xlabel,'FontSize',plotOptions.FontSize);
        
        if isfield(plotOptions, 'statsArray') && ~isempty(plotOptions.statsArray)
            xvalStar = cell2mat(plotOptions.statsArray(:, 2))';
            xvalStar = xvalStar+250;
            yvalStar = repmat(globalyl, 1, length(xvalStar));
            scatter(xvalStar, yvalStar, 25, '*', 'k');
        end
        
        if plotOptions.useBothOffsets
            plot([timelimits(2)-offsets(2) timelimits(2)-offsets(2)], [0 globalyl+2], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
        end
        
        %  plot raster
        h_2(ctr) = subplot(2, subPlotNum, ctr+subPlotNum);
        hold on
        if size(stimTOplot, 1) > size(stimTOplot, 2)
            stimTOplot = stimTOplot';
        end
        if length(find(order == stimTOplot)) < 30
            for p2 = l(stimTOplot)
                raster = logical(psth{1, 1}(find(order == stimTOplot(p2)), :));
                LineFormat.Color = colors(p2, :);
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
                            length(iter)*(p2-1)+k,'Marker','square', 'LineStyle','none','MarkerFaceColor',colors(p2, :),...
                            'MarkerEdgeColor','none','MarkerSize',plotOptions.MarkerSize)
                        hold on
                        
                    end
                end
            end
        end
        % needs to be improved
        if isfield(textParams, 'title1') && ~isempty(textParams.title1)
            if mod(ctr, 2) == 1
                title(textParams.title1);
            else
                title(textParams.title2);
            end
        end
        
        
        set(gca,'XGrid','on')
        set(gca, 'YGrid','on')
        grid on
        
        set(gca,'FontSize',plotOptions.FontSize)
        yl = ylim;
        xlim([timelimits(1) timelimits(2)]);
        if plotOptions.plotNum == plotOptions.numBins
            xticks([-555 555 1555 2555 3555 4555]);
        end
        xticklabels(xt);

        if ~isfield(plotOptions, 'split') || plotOptions.split == 0
            
            if plotOptions.curbEdges
                xlim([timelimits(1)-(0.1*timelimits(1)) timelimits(2)-(0.05*timelimits(2))]);
            else
                xlim([timelimits(1) timelimits(2)]);
            end            
        end
        if isfield(plotOptions, 'plotNum') 
            if plotOptions.plotNum == 1 || plotOptions.plotNum == plotOptions.numBins
                plot([0 0], [yl(1) yl(2)], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
            end
        end
        ylabel(textParams.ylabelplot2,'FontSize',plotOptions.FontSize);
        
        %             stimPlotNums = mod(stimTOplot, 10); % specific to AIC, because of how order was created
        
%         ylim([length(iter)*(stimTOplot(1)-1) length(iter)*(stimTOplot(end))+1]);
        
        if plotOptions.useBothOffsets
            plot([timelimits(2)-offsets(2) timelimits(2)-offsets(2)], [yl(1) yl(2)], '--k', 'LineWidth', 1);
        end
        xlabel(textParams.xlabel,'FontSize',plotOptions.FontSize);
        set(gca,'FontSize',plotOptions.FontSize)
        
        
        
    end
    linkaxes(h_1, 'y');
%     linkaxes([h_1, h_2], 'x');

    if plotOptions.moveLegend == 1 % scenes and cuts
        set(lgnd, 'Position', [0.47,0.78,0.0625,0.1146]);
%         set(lgnd, 'Position', [0.47,0.58,0.079,0.32]);

    elseif plotOptions.moveLegend == 2 % videos
        if blocksPerSubplot > 5
            set(lgnd, 'Position', [0.912,0.478,0.0823,0.5480]);
        else
            set(lgnd, 'Position', [0.9153,0.8273,0.0562,0.0893]);    
        end
    end


end