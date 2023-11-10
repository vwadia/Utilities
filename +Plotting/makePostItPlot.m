
function handles = makePostItPlot(psth, order, timelimits, respLat, rows, cols, basePath, pathStimuli, cellInfo, screeningData, options)
% This function makes a population summary of a cells response to a large
% number of images, along with the images themselves.
% Inputs:
%     1. Psth (1x3 cell - raster, smoothed psth, times)
%     2. order (of the whole psth)
%     3. Timelimits (for plotting purposes)
%     4. The response latency of the cell (not centered)
%     5. number of rows desired
%     6. number of columns desired
%     7. basePath (essentially folder you want to save images to)
%     8. the path to the images 
%     9. cellInfo (cell number, channel, area etc. essentially a row of strctCells)
%     10. dataStruct (optional - most commonly screeningData)
% Outputs:
%     1. Handles to a figure
% vwadia/april2021
if nargin == 9, screeningData = []; options = []; end
if nargin == 10, options = []; end
MarkerSize = 4;

% collect images
imDir = dir(fullfile(pathStimuli));
imDir = imDir(~ismember({imDir.name}, {'.', '..', '.DS_Store', 'Thumbs.db'}));

% sort order by magnitude
imageIDs = unique(order);
labels = Utilities.sortByRespMagnitude(order, imageIDs, psth{1, 1}, respLat, screeningData.stimDur);

% colors
color = [0 0.2 0];
img_ctr = 1;
numImgsPerFig = rows*cols/2;

% plot only the top and bottom stim
if ~isempty(options)
    if ~isempty(options.topStimNum)
        labels = labels([1:options.topStimNum  end-(options.topStimNum-1):end]);
        numFigsPerCell = 1;
        newIdxes = [1:options.topStimNum  length(imageIDs)-(options.topStimNum-1):length(imageIDs)];
        assert(isequal(length(labels), length(newIdxes)));
    else
        disp("Need to specify how many stim you want");
        keyboard;
    end
end

numFigsPerCell = ceil(length(labels)/numImgsPerFig);
runOff = mod(length(labels), numImgsPerFig);


for figNum = 1:numFigsPerCell
    
    handles = figure('Visible', 'off');
    set(gcf,'Position',get(0,'Screensize')) % display fullsize on other screen
    
    beginPathOut = [basePath filesep 'rasters' filesep 'PostitPlots'];
    
    if figNum == numFigsPerCell && runOff ~= 0
        numPerRow = cols/2; 
        rows = ceil(runOff/numPerRow);
        colsInLastRow = mod(runOff, numPerRow)*2;
    end
    
    if isfield(screeningData, 'sigCell') && ~isempty(screeningData.sigCell) && ismember(cellInfo.Name, cell2mat(screeningData.sigCell(:, 2)))
        sigCtr = find(cell2mat(screeningData.sigCell(:, 2)) == cellInfo.Name);
        if iscell(cellInfo.brainArea)
            sgtitle({[num2str(cellInfo.Name) ' ' char(cellInfo.brainArea) '\_' num2str(figNum)],...
                ['Anova Type: ' screeningData.anovaType ', Pval: ' num2str(screeningData.sigCell{sigCtr, 3})]});
        else
            sgtitle({[num2str(cellInfo.Name) ' ' cellInfo.brainArea '\_' num2str(figNum)],...
                ['Anova Type: ' screeningData.anovaType ', Pval: ' num2str(screeningData.sigCell{sigCtr, 3})]});            end
        pathOut = [beginPathOut filesep 'significant_cells'];
        if ~exist(pathOut)
            mkdir([pathOut]);
        end
    else
        if iscell(cellInfo.brainArea)
            sgtitle({[num2str(cellInfo.Name) ' ' char(cellInfo.brainArea) '\_' num2str(figNum)]}); % backslash allows you to print the underscore
        else
            sgtitle({[num2str(cellInfo.Name) ' ' cellInfo.brainArea '\_' num2str(figNum)]}); % backslash allows you to print the underscore
        end
        pathOut = beginPathOut;
        if ~exist(pathOut)
            mkdir([pathOut]);
        end
    end
    
    for row = 1:rows
        if figNum == numFigsPerCell && row == rows && runOff ~= 0
            ogCols = cols;
            cols = colsInLastRow;
        end
        for col = 1:cols
            if figNum == numFigsPerCell && row == rows && runOff ~= 0
                ctr = (row-1)*ogCols + col;                
                h(ctr) = subplot(rows, ogCols, ctr);
            else
                ctr = (row-1)*cols + col;                
                h(ctr) = subplot(rows, cols, ctr);
            end
            hold on
            if mod(col, 2) == 1
                % imshow that stimulus
                imshow([imDir(labels(img_ctr)).folder filesep imDir(labels(img_ctr)).name]);
                if ~isempty(options)
                    title([newIdxes(img_ctr)]);
                else
                    title([img_ctr]);
                end
            elseif mod(col, 2) == 0
                % plot raster using mag order
                iter = find(order == labels(img_ctr));
                for k = 1:size(iter, 1)
                    try
                        % if sorted raster used replace original with presentations
                        plot((find(psth{1, 1}(iter(k), :)==1).*(1/1000)+timelimits(1)),...
                            k,'Marker','|', 'LineStyle','none', 'LineWidth', 1.5, 'MarkerFaceColor',color,...
                            'MarkerEdgeColor',color,'MarkerSize',MarkerSize)
                        
                        hold on
                    end
                end
                ylim([0 size(iter, 1)])
                xlim([timelimits(1) timelimits(2)])
                plot([0 0], [0 size(iter, 1)], '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
                img_ctr = img_ctr + 1;
                
            end
        end
    end
    if isempty(options)
        filename = [pathOut filesep cellInfo.brainArea '_' num2str(cellInfo.ChannelNumber)...
            '_' num2str(cellInfo.Name) '_PostIt_' num2str(figNum)];
    else
        filename = [pathOut filesep cellInfo.brainArea '_' num2str(cellInfo.ChannelNumber)...
            '_' num2str(cellInfo.Name) '_PostIt_TopandBottom'];
    end
    
    print(handles ,filename ,'-dpng','-r0')
    close all
    
end

end
