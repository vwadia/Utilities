function [handlesToFig] = PlotReactivationVis_AlongAxis(enc_psth, CR_psth, EncodingOrder, CROrder, offsetEnc, offsetTones, stim_ims, orderAlongAx, plotOptions)
% This function takes in a cells viewing and recall data 
% and plots a visualisation with the spike counts to show reactivation.
% The plot will take in stimulus images, display them in the order given
% under that it will plot a paried barplot of the spike coiunts in both
% conditions
% 
% INPUTS:
%     1. enc_psth
%     2. CR_psth
%     3. EncOrder
%     4. CROrder
%     5. offsetEnc
%     6. offsetTones
%     7. stim ims (in an nx1 cell array - in order)
%     8. plotOptions (marker size etc.)
% 
% OUTPUTS:
%     1. Handles to a figure
%         
% vwadia June2023

% setting up viewing parameters
MarkerSize = plotOptions.MarkerSize; %4;
Fontsize = plotOptions.Fontsize; %20;
LineWidth = plotOptions.LineWidth; %3;

% number of subplots per row
subPlotNum = length(stim_ims);
rasterNum = 2; % encoding and Im

im_colors = Utilities.distinguishable_colors(length(stim_ims));

bar_colors = [0 0.4470 0.7410; 0.6350 0.0780 0.1840];
% sort stimuli by order Along Axis
stim_ims = stim_ims(orderAlongAx);
im_colors = circshift(im_colors, -1); % to keep colors consistent
im_colors = im_colors(orderAlongAx, :);

handlesToFig = figure('Visible', 'off'); clf;
% handlesToFig = figure; clf;
set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen

spikCounts = nan(length(stim_ims), rasterNum);
% compute spike counts
for spN = 1:rasterNum
    
    if spN == 1 % Encoding
        orderToUse = EncodingOrder;
        psth = enc_psth;
        timelimits = offsetEnc;
        endTime = 1500;
        ttle = {'Encoding'};
    elseif spN == 2 % CR
        orderToUse = CROrder;
        psth = CR_psth;
        timelimits = offsetTones;
        endTime = 5000;
        ttle = {'Cued Recall'};       
    end
    
    for stim = 1:length(stim_ims)
        spikCounts(stim, spN) = mean(mean(psth{1}(orderToUse == stim, timelimits(1):timelimits(1)+endTime)))*1e3;
    end

    
end

% sort by axis order!
spikCounts = spikCounts(orderAlongAx, :);


% plot images first
for im = 1:length(stim_ims)
     
    h_1(im) = subplot(2, subPlotNum, im);
    bColor = im_colors(im, :); % silly thing I've been doing with the colors
    framedIm = Utilities.Plotting.AddColouredFrame(stim_ims{im}, bColor);
    imshow(framedIm);  
    
end

h_2 = subplot(2, subPlotNum, [subPlotNum+1:2*subPlotNum]);
hold on
hp = bar(spikCounts);
hp(1).FaceColor = bar_colors(1, :);
hp(2).FaceColor = bar_colors(2, :);
ylabel('Spikes/s')

set(gca, 'Fontsize', 14, 'FontWeight', 'bold')

  
    
end


