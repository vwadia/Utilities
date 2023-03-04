function [screeningData] = selectivityCheck_ANOVA(labels, anovaType, strctCells, screeningData)

% screeningData.anovaType = anovaType;
screeningData.sigCell = [];
% screeningData.standardizedFR = cell(length(strctCells), 1);
ctr = 0;
stimOnLength = ceil(screeningData.stimDur);

% don't initialize stats_vis or stats_sel - causes errors
p_sel=[];

for cellIndex = l(strctCells)
    % how long has this been wrong????
%     if exist('screeningData.responses{cellIndex, 2}') && ~isempty(screeningData.responses{cellIndex, 2}) 

%     if isfield(screeningData, 'responses') && exist('screeningData.responses{cellIndex, 2}') && ~isempty(screeningData.responses{cellIndex, 2})
    if isfield(screeningData, 'responses') && ~isempty(screeningData.responses{cellIndex, 2})
        stimON = screeningData.responses{cellIndex, 2}-screeningData.timelimits(1)*1e3;         
    else
        stimON = -screeningData.timelimits(1)*1e3;
    end
    
    if stimON+stimOnLength > size(screeningData.psth{cellIndex, 1}, 2)
        stimONAll = screeningData.psth{cellIndex, 1}(:, stimON:end); % raster
    else
        stimONAll = screeningData.psth{cellIndex, 1}(:, stimON:stimON+stimOnLength); % raster
    end
    % run Anova
    [p_sel(cellIndex), ~, stats_sel(cellIndex)] = anova1(sum(stimONAll, 2), labels, 'off');

    if (p_sel(cellIndex) < 0.05) % threshold is the same as 
        ctr = ctr+1;
        screeningData.sigCell{ctr, 1} = cellIndex;
        screeningData.sigCell{ctr, 2} = strctCells(cellIndex).Name;
        screeningData.sigCell{ctr, 3} = p_sel(cellIndex);
        screeningData.sigCell{ctr, 4} = strctCells(cellIndex).brainArea;
    end
end
end