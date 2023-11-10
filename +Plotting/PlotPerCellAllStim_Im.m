function handlesToFig = PlotPerCellAllStim_Im(plotOptions, enc_psth, CR_psth, EncodingOrder, CROrder, offsetEnc, offsetTones, stimuli, stimONCR, FR_psth, FROrder, offsetFR)
% This is a functionized version of recall_plotPerCellAllStim
% Just for ease of plotting and use with other functions
% - or to plot reactivated cell across sessions without the need for 'RecallData' struct
% INPUTS:
%     1. plotOptions - struct with misc plotting options
%     2. enc_psth - 1x3 cell array of encoding raster, psth and times
%     3. CR_psth - 1x3 cell array of CR raster, psth and times
%     4. EncOrder - Order of images
%     5. CROrder - Order of images were imagined in
%     6. offsetEnc - offset used to make enc_psth
%     7. offsetTones - offset used to make CR_psth
%     8. stimuli - names of stimuli used (for legend)
%     9. StimOnCR - How long was Im period?
%     10. FR_psth - 1x3 cell array of free recall raster, psth, and times
%     11. FROrder - normally RecallData.order_perCellAllStimFR
%     12. offsetFR - offset used to make FR_psth
%
% OUTPUTS:
%     1. Handles to figure
%
% vwadiaMay2023

% setting up viewing parameters
MarkerSize = plotOptions.MarkerSize;
Fontsize = plotOptions.Fontsize;
LineWidth = plotOptions.LineWidth;

nonLink = false;
if nargin == 8
    stimONCR = 5000; FR_psth = []; FROrder = []; offsetFR = []; noFR = true;
elseif nargin == 9
    FR_psth = []; FROrder = []; offsetFR = []; noFR = true;
else
    noFR = false;
end

if noFR
    subPlotNum = 2; % change to 2 for only Enc and CR
else
    subPlotNum = 3; % change to 2 for only Enc and CR
end

if ~isfield(plotOptions, 'cols') %|| (size(plotOptions.cols, 1) ~= length(stimuli))
    colors = Utilities.distinguishable_colors(length(stimuli));
%     colors = linspecer(length(stimuli), 'qualitative'); % better
%     colors = linspecer(length(stimuli), 'sequential'); % colors too close
%     colors = colormap(brewermap(8, "Dark2"));

else
    colors = plotOptions.cols;
end

% 6 subplots - 1 pair for encoding, 1 for CR and 1 for FR
if plotOptions.visible
    handlesToFig = figure; clf;
else
    handlesToFig = figure('Visible', 'off'); clf;
end

if plotOptions.fullscreen
    set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen
end

if noFR
    gyl = Utilities.Plotting.findingGlobalYLim(CR_psth{1, 2}(:, 1:find(CR_psth{1, 3} == stimONCR)), ...
        unique(CROrder), CROrder, 'AIC');
else
    gyl = Utilities.Plotting.findingGlobalYLim([CR_psth{1, 2}(:, 1:find(CR_psth{1, 3} == stimONCR)); FR_psth{1, 2}(:, 1:find(CR_psth{1, 3} == stimONCR))], ...
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

if plotOptions.NormPsthFR
    globalyl = 3;
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
        toPlotPsth = psth{1, 2}(find(orderToUse == imagesTOplot(p1)), :);
        if plotOptions.NormPsthFR
            toPlotPsth = zscore(toPlotPsth, 0, 2);
        end
        Utilities.stdshade5(toPlotPsth, 0.1,...
            colors(mod(p1, length(imagesTOplot))+1, :), psth{1, 3}, 2);
    end
    
    if plotOptions.binSpikes
        % cutting # of ticklabels in half and scaling
        ytiklabs = get(gca, 'yticklabels');
        ytiklabs = cellfun(@(x) str2num(x)/plotOptions.binSize, ytiklabs, 'UniformOutput', false);
        ytiklabs = cellfun(@(x) num2str(x), ytiklabs, 'UniformOutput', false);
%         ytiklabs = ytiklabs(1:2:end);
%         ytiks = yticks; ytiks = ytiks(1:2:end);
%         yticks([ytiks])
        set(gca,'yticklabels', ytiklabs) 
    end
    
    set(gca,'FontSize',Fontsize, 'FontWeight', 'bold')
    
    ylabel('Firing Rate (Hz)','FontSize',Fontsize, 'FontWeight', 'bold');
    
   
%     ylabel('Norm Firing Rate','FontSize',Fontsize, 'FontWeight', 'bold');
    tt = title(ttle);
    tt.FontSize = 18;
    xlim([psth{1, 3}(1)+300 round(psth{1, 3}(end)*0.85)]);
    yl = ylim;
    
    if nonLink
        if spN == 2
            globalyl = gyl;
        elseif spN == 1
            globalyl = gyl2;
        end
    end
    
   ylim([0 globalyl])
    plot([0 0], [0 globalyl], '--k', 'LineWidth', LineWidth, 'HandleVisibility', 'off');
    if spN == 2 % CR
        plot([5000 5000], [0 globalyl], '--k', 'LineWidth', LineWidth, 'HandleVisibility', 'off');
    end
    if spN == subPlotNum
        if plotOptions.legend
            if length(stimuli) <= 20
                lgnd = legend(stimuli);
                lgnd.Position = [0.912673612414962,0.629427349279353,0.070312498696148,0.253723925133093];
%                 0.91006944593456,0.781363800486154,0.076562498509883,0.137537235418166
                lgnd.FontSize = 8;
            elseif length(stimuli) <= 40
                lgnd = legend(stimuli);
                lgnd.Position = [0.92370265195753,0.378301432367334,0.056249999115244,0.521847055590496];
                lgnd.FontSize = 8;
            elseif length(stimuli) > 40
                disp("No legend - too many entries!")
            end
        end
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
                
%                  plot((find(psth{1, 1}(iter(k), :)==1)+(-timelimits(1))),...
%                     iterSize+k,'Marker','|', 'LineStyle','none', 'LineWidth', 2, 'MarkerFaceColor',colors(mod(p2, length(imagesTOplot))+1, :),...
%                     'MarkerEdgeColor',colors(mod(p2, length(imagesTOplot))+1, :),'MarkerSize',MarkerSize*3)

                       
                               
                hold on
 
            end
        end
    end
 
    set(gca,'FontSize',Fontsize, 'FontWeight', 'bold')
    ylabel('Trials (re-ordered)','FontSize',Fontsize, 'FontWeight', 'bold');
    xlabel('time (ms)','FontSize',Fontsize, 'FontWeight', 'bold');
    xlim([psth{1, 3}(1)+300 round(psth{1, 3}(end)*0.85)]);
    ylim([0 size(psth{1, 1}, 1)]);
    plot([0 0], [0 size(psth{1, 1}, 1)+1], '--k', 'LineWidth', LineWidth, 'HandleVisibility', 'off');
   if spN == 2 % CR
        plot([5000 5000], [0 size(psth{1, 1}, 1)+1], '--k', 'LineWidth', LineWidth, 'HandleVisibility', 'off');
        
        
        if spN == 2 && plotOptions.showReacTrials % CR            
            rTrialVec = plotOptions.reacTrials; % nx1 vector
            rTrials = find(rTrialVec == 1);
            xl = xlim;
            for rT = 1:length(rTrials) 
                rectangle('Position', [xl(1) rTrials(rT)-0.5 50 1], 'FaceColor', [0 0 0]);
            end
        end
        
        
    end
%     linkaxes(h_1, 'y');
    if ~nonLink
       linkaxes(h_1, 'y');
    end
    if ~plotOptions.binSpikes
        linkaxes([h_1(spN) h_2(spN)], 'x');
    end
end




end