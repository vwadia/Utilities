function handlesToFig = PlotPerCellAllStim_Im(enc_psth, CR_psth, EncodingOrder, CROrder, offsetEnc, offsetTones, stimuli, FR_psth, FROrder, offsetFR)
% This is a functionized version of recall_plotPerCellAllStim
% Just for ease of plotting and use with other functions
% - or to plot reactivated cell across sessions without the need for 'RecallData' struct
% INPUTS:
%     1. enc_psth - 1x3 cell array of encoding raster, psth and times
%     2. CR_psth - 1x3 cell array of CR raster, psth and times
%     3. EncOrder - Order of images
%     4. CROrder - Order of images were imagined in
%     5. offsetEnc - offset used to make enc_psth
%     6. offsetTones - offset used to make CR_psth
%     7. stimuli - names of stimuli used (for legend)
%     8. FR_psth - 1x3 cell array of free recall raster, psth, and times
%     9. FROrder - normally RecallData.order_perCellAllStimFR
%     10. offsetFR - offset used to make FR_psth
%
% OUTPUTS:
%     1. Handles to figure
%
% vwadiaMay2023

% setting up viewing parameters
MarkerSize = 4;
Fontsize = 16;
LineWidth = 3;



if nargin == 7
    FR_psth = []; FROrder = []; offsetFR = []; noFR = true;
else
    noFR = false;
end

if noFR
    subPlotNum = 2; % change to 2 for only Enc and CR
else
    subPlotNum = 3; % change to 2 for only Enc and CR
end

colors = Utilities.distinguishable_colors(length(stimuli));

% 6 subplots - 1 pair for encoding, 1 for CR and 1 for FR
handlesToFig = figure('Visible', 'off'); clf;
% handlesToFig = figure; clf;
set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen


if noFR
    gyl = Utilities.Plotting.findingGlobalYLim(CR_psth{1, 2}(:, 1:6000), ...
        unique(CROrder), CROrder, 'AIC');
else
    gyl = Utilities.Plotting.findingGlobalYLim([CR_psth{1, 2}(:, 1:6000); FR_psth{1, 2}(:, 1:6000)], ...
        unique([CROrder; 10*FROrder]), [CROrder; 10*FROrder], 'AIC');
    
end

gyl2 = Utilities.Plotting.findingGlobalYLim(enc_psth{1, 2}, unique(EncodingOrder), EncodingOrder, 'AIC');
% set globaly yl
if gyl2 >= gyl
    globalyl = gyl2;
else
    globalyl = gyl;
end
% set globaly yl
if globalyl == 0
    globalyl = 1;
end

for spN = 1:subPlotNum
    if spN == 1 % Encoding
        orderToUse = EncodingOrder;
        psth = enc_psth;
        timelimits = offsetEnc;
        ttle = {'Encoding'};
    elseif spN == 2 % CR
        orderToUse = CROrder;
        psth = CR_psth;
        timelimits = offsetTones;
        ttle = {'Cued Recall'};
        %             keyboard
    elseif spN == 3 % FR
        orderToUse = FROrder;
        psth = FR_psth;
        timelimits = offsetFR;
%         ttle = {'Free Recall'};
        ttle = {'Trial ON'};
    end
    % smoothed FR
    h_1(spN) = subplot(2, subPlotNum, spN);
    hold on
    
    imagesTOplot = unique(orderToUse);
    for p1 = l(imagesTOplot)
        Utilities.stdshade5(psth{1, 2}(find(orderToUse == imagesTOplot(p1)), :), 0.1,...
            colors(mod(p1, length(imagesTOplot))+1, :), psth{1, 3}, 2);
    end
    
    set(gca,'FontSize',Fontsize, 'FontWeight', 'bold')
    ylabel('Firing Rate (Hz)','FontSize',Fontsize, 'FontWeight', 'bold');
    tt = title(ttle);
    tt.FontSize = 18;
    xlim([psth{1, 3}(1)+100 round(psth{1, 3}(end)*0.95)]);
    yl = ylim;
    ylim([0 globalyl]);
    plot([0 0], [0 globalyl], '--k', 'LineWidth', LineWidth, 'HandleVisibility', 'off');
    if spN == 2 % CR
        plot([5000 5000], [0 globalyl], '--k', 'LineWidth', LineWidth, 'HandleVisibility', 'off');
    end
    if spN == subPlotNum
        lgnd = legend(stimuli);
        lgnd.Position = [0.912673612414962,0.629427349279353,0.070312498696148,0.253723925133093];
        lgnd.FontSize = 12;
    end
    % raster
    h_2(spN) = subplot(2, subPlotNum, spN+subPlotNum);
    hold on
    iterSize = 0;
    for p2 = l(imagesTOplot)
        iter = find(orderToUse == imagesTOplot(p2));
        if p2 > 1
            iterSize = iterSize + length(find(orderToUse == imagesTOplot(p2-1)));
        else
            iterSize = 0;
        end
        for k = 1:size(iter, 1)
            try
                % timelimits here is in ms
                plot((find(psth{1, 1}(iter(k), :)==1)+(-timelimits(1))),...
                    iterSize+k,'Marker','square', 'LineStyle','none','MarkerFaceColor',colors(mod(p2, length(imagesTOplot))+1, :),...
                    'MarkerEdgeColor','none','MarkerSize',MarkerSize)
                
                hold on
                
            end
        end
    end
    set(gca,'FontSize',Fontsize, 'FontWeight', 'bold')
    ylabel('Trials (re-ordered)','FontSize',Fontsize, 'FontWeight', 'bold');
    xlim([psth{1, 3}(1)+100 round(psth{1, 3}(end)*0.95)]);
    ylim([0 size(psth{1, 1}, 1)]);
    plot([0 0], [0 size(psth{1, 1}, 1)+1], '--k', 'LineWidth', LineWidth, 'HandleVisibility', 'off');
    
    linkaxes(h_1, 'y');
    %         linkaxes(h_2, 'y');
    linkaxes([h_1(spN) h_2(spN)], 'x');
end




end