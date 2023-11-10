function PlotRastersAIC(pathOut, subPlotNum, numFigsPerCell, offsets, useBothOffsets, strctCells, psth, order, statsMatrix, alpha)
% In this current paradigm:
% images per subplot tells you what chunks to plot together
% That determines imagesToplot in each subplot as you cycle through them
% In my case, I want all the chunks for each character plotted together
% Inputs: 
%     1. Desired destination folder
%     2. Plot arrangement (num of subplots, figs per cell etc.)
%     3. Offsets (1-side or 2-sided)
%     4. strctCells
%     5. Psth
%     6. Order (because the psth isn't sorted)
%     7. statsMatrix; 
%     8. alpha
% Outputs:
%     1. Plots will be printed to destination folder.
% vwadia Dec2020
if nargin == 8, statsMatrix = []; alpha = []; end
if nargin == 7, alpha = []; end

anova = 0; 
% setting up viewing parameters
MarkerSize = 4;
Fontsize = 9;
% stimTOplot = zeros(1, length(unique(order))/subPlotNum);
blocksPerSubplot = length(unique(mod(order, 10)));
colors = distinguishable_colors(blocksPerSubplot);


for cellIndex = l(strctCells)
    
    timelimits = [-offsets(1) size(psth{cellIndex, 1}, 2)-offsets(1)];
    globalyl = findingGlobalYLim(psth{cellIndex, 2}, unique(order), order, 'AIC');
    doStats = 0;
    if ~isempty(statsMatrix)
        if anova
            for numP = 1:3:size(statsMatrix, 2)
                if statsMatrix{cellIndex, numP} < alpha
                    doStats = 1;
                    break;
                end
            end
        else
            doStats = 1;
        end
    end

    for figNum = 1:numFigsPerCell
        f = figure; clf;
        set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen
        
        if iscell(strctCells(cellIndex).brainArea)
            suptitle({[num2str(strctCells(cellIndex).brainArea) '\_' char(strctCells(cellIndex).ChannelNumber) '\_' num2str(strctCells(cellIndex).Name)]}); % backslash allows you to print the underscore
        else
            suptitle({[strctCells(cellIndex).brainArea '\_' num2str(strctCells(cellIndex).ChannelNumber) '\_' num2str(strctCells(cellIndex).Name)]}); % backslash allows you to print the underscore
        end
        
        if ~exist(pathOut)
            mkdir([pathOut]);
        end
        
        % currently this is redrawing the same few images on each figure, change it
        for ctr = 1:subPlotNum % make sure this is divisible - chunks of images
            
            stim = unique(order);
            stimTOplot=stim(((blocksPerSubplot*(ctr-1))+1):...
                (blocksPerSubplot*(ctr-1))+blocksPerSubplot);
            %             stimtoDEL=setdiff(order,[stimTOplot]);
            % FR
            h_1(ctr) = subplot(2, subPlotNum, ctr);
            hold on
            
            
            for p1 = l(stimTOplot)
                stdshade5(psth{cellIndex, 2}(find(order == stimTOplot(p1)), :), 0.1, colors(p1, :), psth{cellIndex, 3}, 2);
            end
            if doStats
                if anova
                    title(['1xScenes Anova Pval: ', num2str(statsMatrix{cellIndex, ((ctr-1)*blocksPerSubplot)+1})]);
                else 
                    if ~isempty(cell2mat(statsMatrix(cellIndex, ((ctr-1)*3)+1:((ctr-1)*3)+3))) 
                        rankNum1 = statsMatrix{cellIndex, ((ctr-1)*3)+1};
                        if ~isempty(rankNum1)
                            rankNum1 = rankNum1(2);
                        end
                        rankNum2 = statsMatrix{cellIndex, ((ctr-1)*3)+2};
                         if ~isempty(rankNum2)
                            rankNum2 = rankNum2(2);
                        end
                        rankNum3 = statsMatrix{cellIndex, ((ctr-1)*3)+3};
                         if ~isempty(rankNum3)
                            rankNum3 = rankNum3(2);
                        end
                        title(['Ranksum 1 Pval: ', num2str(rankNum1), ' Ranksum 2 Pval: ', num2str(rankNum2),...
                            ' Ranksum 3 Pval: ', num2str(rankNum3) ]);
                    end
                end
            end
            
            % needs to be improved
%             xlim([timelimits(1)-(0.1*timelimits(1)) timelimits(2)-(0.1*timelimits(2))]);
            xlim([timelimits(1) timelimits(2)]);
            ylim([0 globalyl+(globalyl/10)]);
            plot([0 0], [0 globalyl+(globalyl/10)], '--k', 'LineWidth', 1);
            ylabel('Firing rate (hz)','FontSize',Fontsize);
            xlabel('time (ms)','FontSize',Fontsize);
           
            
            
            if useBothOffsets
                plot([timelimits(2)-offsets(2) timelimits(2)-offsets(2)], [0 globalyl+2], '--k', 'LineWidth', 1);
            end
            if ctr == 1
                lgnd = legend('Sc1 - House', 'Sc2 - City', 'Sc3 - Market');
                title(lgnd, 'Scenes');
%                 lgnd = legend('Al Gore', 'Bill Clinton');%, 'Sc3 - Market');
%                 title(lgnd, 'Characters');

            end
       
            %  plot raster
            h_2(ctr) = subplot(2, subPlotNum, ctr+subPlotNum);
            hold on
            for p2 = l(stimTOplot)
                iter = find(order == stimTOplot(p2)); % iter is now a vector of indices size 6
                for k = 1:length(iter) %psth.numRepetitions % this needs to be fixed...
                    try
                        % note that the time here is already in ms so no
                        % need to divide by 1000
                        plot((find(psth{cellIndex, 1}(iter(k), :)==1)+timelimits(1)),...
                            length(iter)*(stimTOplot(p2)-1)+k,'Marker','square', 'LineStyle','none','MarkerFaceColor',colors(p2, :),...
                            'MarkerEdgeColor','none','MarkerSize',MarkerSize)
                        
                        hold on
                        
                    end
                end
               
            end
            
            
            set(gca,'XGrid','on')
            set(gca, 'YGrid','on')
            grid on
            
            set(gca,'FontSize',Fontsize)
            
%             xlim([timelimits(1)-(0.1*timelimits(1)) timelimits(2)-(0.1*timelimits(2))]);
            xlim([timelimits(1) timelimits(2)]);

            ylabel('trial nr (re-ordered)','FontSize',Fontsize);
            
            %             stimPlotNums = mod(stimTOplot, 10); % specific to AIC, because of how order was created
            
            ylim([length(iter)*(stimTOplot(1)-1) length(iter)*(stimTOplot(end))+1]);
            
            yl = ylim;
            plot([0 0], [yl(1) yl(2)], '--k', 'LineWidth', 1);
            if useBothOffsets
                plot([timelimits(2)-offsets(2) timelimits(2)-offsets(2)], [yl(1) yl(2)], '--k', 'LineWidth', 1);
            end
            %             plot([psth.stimDur/1000 psth.stimDur/1000], [yl(1) yl(2)], '--k', 'LineWidth', 1);
            xlabel('time (ms)','FontSize',Fontsize);
            
            set(gca,'FontSize',Fontsize)
            %             keyboard;
            
           

        end
        linkaxes(h_1, 'y');
        %----------Check this
%         set(lgnd, 'Position', [0.47,0.78,0.0625,0.1146]);
        %----------------
        % saving
        filename = [pathOut filesep strctCells(cellIndex).brainArea '_' num2str(strctCells(cellIndex).ChannelNumber) '_' num2str(strctCells(cellIndex).Name) '_VideoRaster'];
        if ~strcmp(class(filename), 'cell')
            print(f,filename ,'-dpng','-r0')
        else
            filename = [pathOut filesep strctCells(cellIndex).brainArea{1} '_' num2str(strctCells(cellIndex).ChannelNumber) '_' num2str(strctCells(cellIndex).Name) '_' num2str(figNum)];
            print(f,filename ,'-dpng','-r0')
        end

    end
    
    
%         keyboard;
        close all;
end

end