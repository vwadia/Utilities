function [handlesToFig] = plotRastersMultStim_2(rasters, psths, times, order, textparams)
% This function plots the response of a single cell to multiple stim 
%
% Inputs:
%     1. Rasters to the multiple stim (cell  array of doubles)
%     2. FRs to the same stim (cell array of smoothed psths)
%     3. order (sorted already)
%     3. offsets as a 2 element vector
%     5. textParams (xlabel, ylabel, title, legend)
%
% Outputs:
%     1. Handles to a figure
%
% vwadia Feb2020



colors = distinguishable_colors(size(rasters));
timelimits = [-offsets(1) size(psth{1, 1}, 2)-offsets(1)];

handlesToFig = figure; clf;
set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen

% handle this in textparams
title(textParams.suptitle);



end

