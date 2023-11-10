function [params] = runAnova1(labels, stimDur, timelimits, strctCells, params)
% This is a more generalized version of 'selectivityCheck_ANOVA' that is 
% used in screeningScript.
% 
% INPUTS:
%     1. labels (for categories)
%     2. stimON time (can insert this on a per cell basis in strctCells)
%     3. timelimits (same as above ^ can be done per cell)
%     4. strctCells
%     5. params struct - needs responses, timelimits, psths, and stimDur
% 
% OUTPUT:
%     1. params with a sigCell field
% 
% vwadia Dec2021
params.sigCell = [];
ctr = 0;
stimOnLength = ceil(stimDur);

% don't initialize stats_vis or stats_sel - causes errors
p_sel=[];

if isempty(timelimits)
    assert(exist('strctCells.timelimits'), 'Need a timelimit to bound the calculation');
end
if isempty(stimDur)
    assert(exist('strctCells.stimDur'), 'Need stimON time');
end

for cellIndex = 1:length(strctCells)
    
    
    if isfield(params, 'responses') && ~isempty(params.responses{cellIndex, 2}) 
        stimON = params.responses{cellIndex, 2}-timelimits(1)*1e3; 
    else
        stimON = -timelimits(1)*1e3;
    end
    
    if stimON+stimOnLength > size(params.psth{cellIndex, 1}, 2)
        stimONAll = params.psth{cellIndex, 1}(:, stimON:end); % raster
    else
        stimONAll = params.psth{cellIndex, 1}(:, stimON:stimON+stimOnLength); % raster
    end
    % run Anova
    [p_sel(cellIndex), ~, stats_sel(cellIndex)] = anova1(sum(stimONAll, 2), labels, 'off');

    if (p_sel(cellIndex) < 0.05)
        ctr = ctr+1;
        params.sigCell{ctr, 1} = cellIndex;
        params.sigCell{ctr, 2} = strctCells(cellIndex).Name;
        params.sigCell{ctr, 3} = p_sel(cellIndex);
        params.sigCell{ctr, 4} = strctCells(cellIndex).brainArea;
    end
end
end