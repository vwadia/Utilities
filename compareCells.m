function [cellPairs, compMat] = compareCells(cellMat, cellIDs, restrictToChannels, waveforms)
% This function returns a list of paired cells indicating that they are the same.
% It takes in a matrix of cell stimulus preferences, where each row is a the rank ordered stimulus IDs per cell
% or an nx1 cell array of psths
% The first set of rows are all the morning cells, the second set of rows are all the afternoon cells.
% It will compute a distance matrix and only examine the top right rectangle (entries that compare morning and afternoon)
% It will check each row for the lowest distance/highest similarity value
% with similar FR, waveform, and burstIndex
% It is currently set up to only compare cells on the same channel - unless
% a channel has no cells in either session, in which case the cell is
% simply compared to all cells in the other session
%
% INPUTS:
%     1. Cell Matrix - cells x stimuli OR cell array of rasters
%     2. Cell IDs - double array of cell names, session ID (morning = 1 and afternoon = 2), resplat, baselineFR, burst index
%
%
% OUTPUTS:
%     1. Array of morning-afternoon cell pairs that are similar
%     2. the raw distance matrix (for manual inspection)
%
% vwadia/March2022
% vwadia/April2022 -  included restrictToChannel parameter


if nargin == 3, waveforms = []; end

cellPairs = [];

numRows = size(cellMat, 1);

% extract morning and afternoon cells
morn_cells = cellIDs(cellIDs(:, 2) == 1, :);
aft_cells = cellIDs(cellIDs(:, 2) == 2, :);

% 'relevant' copies - will become clear later
rel_morn_cells = morn_cells;
rel_aft_cells = aft_cells;

morn_cell_num = sum(cellIDs(:, 2) == 1);
aft_cell_num = numRows - morn_cell_num;

% initialize comparison matrix
compMat = zeros(numRows, numRows);

if strcmp(class(cellMat), 'cell') % SSIM computation
    SSIM = 1;
    for cl = 1:numRows % is this correct???
        for ref = 1:numRows
            compMat(cl, ref) = ssim(cellMat{cl, 1}, cellMat{ref, 1});
        end
    end
    
else
    SSIM = 0;
    % compute distance - this returns (1 - cosine)
    compMat = squareform(pdist(cellMat, 'cosine'));
end

if ~isempty(waveforms)
    waveMat = squareform(pdist(waveforms, 'euclidean'));
    waveMat = waveMat(1:morn_cell_num, morn_cell_num+1:end);
end

% top right quadrant/section
relevant_compMat = compMat(1:morn_cell_num, morn_cell_num+1:end);




%% comparing morning cell to all aft cells
coords = [];
norms = [];
ctr = 1;
for row = 1:morn_cell_num

    % comparing morning cell to all aft cells
    if restrictToChannels
        chan = morn_cells(row, 7);
        
        sameChanCells = aft_cells(:, 7) == chan;
        
        % if there are no cells in that channel in other session
        % compare to all
        if sum(sameChanCells) == 0
            rel_aft_cells = aft_cells;
            if ~isempty(waveforms)
                rel_waveMat = waveMat;
            end
            rel_compMat = relevant_compMat;
        else
            rel_aft_cells = aft_cells(sameChanCells, :);
            if ~isempty(waveforms)
                rel_waveMat = waveMat(:, sameChanCells);
            end
            rel_compMat = relevant_compMat(:, sameChanCells);
        end
    else % can't compare cells on the left and right side
        sameHemCells = aft_cells(:, 6) == morn_cells(row, 6);
        rel_aft_cells = aft_cells(sameHemCells,:);
        
        if ~isempty(waveforms)
            rel_waveMat = waveMat(:, sameHemCells);
        end
        rel_compMat = relevant_compMat(:, sameHemCells);
    end
    
    % check pvalue of ramp - restrict search of sig cells to ther sig cells and vice versa
    pvalRamp = morn_cells(row, 8);
    if pvalRamp <= 0.01
        sameRampValCells = rel_aft_cells(:, 8) <= 0.01;
    elseif pvalRamp > 0.01
        sameRampValCells = rel_aft_cells(:, 8) > 0.01;
    end
    
    % if there is no other cell in the same tuned/nottuned category
    % then the given cell has no pair in the other session
    if sum(sameRampValCells) > 0
        rel_aft_cells = rel_aft_cells(sameRampValCells, :);
        if ~isempty(waveforms)
            rel_waveMat = rel_waveMat(:, sameRampValCells);
        end
        rel_compMat = rel_compMat(:, sameRampValCells);
        
        % compute differences in other fields
        FRDiff = abs(rel_aft_cells(:, 4) - morn_cells(row, 4));
        [minFRDiff, minFRDiff_idx] = sort(FRDiff');
        
        BI_Diff = abs(rel_aft_cells(:, 5) - morn_cells(row, 5));
        [minBIDiff, minBI_idx] = sort(BI_Diff');
        
        if ~isempty(waveforms)
            [minWD, minWD_idx] = sort(rel_waveMat(row, :));
        end
        
        if SSIM
            [minVals, minIdx] = sort(rel_compMat(row, :), 'descend'); % want the max SSIM
        else
            [minVals, minIdx] = sort(rel_compMat(row, :)); % want the min distance
        end
        
        
        
        coords = [];
        norms = [];
        % now devise coordinates
        for r = 1:size(rel_aft_cells, 1)
            if ~isempty(waveforms)
                coords(r, :) = [find(minIdx == r) find(minFRDiff_idx == r) find(minBIDiff == r) find(minWD_idx == r)];
            else
                coords(r, :) = [find(minIdx == r) find(minFRDiff_idx == r) find(minBIDiff == r)];
            end
            norms(r) = norm(coords(r, :));
        end
        
        % find the cells closest to the target in the FR, cosine dist space
        [~, nn] = min(norms);
        
        cellPairs{1, 1}(row, 1) = morn_cells(row, 1);
        cellPairs{1, 1}(row, 2) = rel_aft_cells(nn, 1);
    else
        cellPairs{1, 1}(row, 1) = morn_cells(row, 1);
%         cellPairs{1, 1}(row, 2) = [];
    end
    
end

%% comparing afternoon cells to all morning cells
relevant_compMat = relevant_compMat';
if exist('waveMat', 'var')
    waveMat = waveMat';
end

ctr = 1;
for row = 1:aft_cell_num
    
    if restrictToChannels
        chan = aft_cells(row, 7);
        
        sameChanCells = morn_cells(:, 7) == chan;
        
        % if there are no cells in that channel in other session
        % compare to all
        if sum(sameChanCells) == 0
            rel_morn_cells = aft_cells;
            if ~isempty(waveforms)
                rel_waveMat = waveMat;
            end
            rel_compMat = relevant_compMat;
        else
            rel_morn_cells = morn_cells(sameChanCells, :);
            if ~isempty(waveforms)
                rel_waveMat = waveMat(:, sameChanCells);
            end
            rel_compMat = relevant_compMat(:, sameChanCells);
        end
    else % can't compare left and right side to each other
        sameHemCells = morn_cells(:, 6) == aft_cells(row, 6);
        rel_morn_cells = morn_cells(sameHemCells,:);
        
        if ~isempty(waveforms)
            rel_waveMat = waveMat(:, sameHemCells);
        end
        rel_compMat = relevant_compMat(:, sameHemCells);
        
    end
    
    % check pvalue of ramp - restrict search of sig cells to ther sig cells and vice versa
    pvalRamp = aft_cells(row, 8);
    if pvalRamp <= 0.01
        sameRampValCells = rel_morn_cells(:, 8) <= 0.01;
    elseif pvalRamp > 0.01
        sameRampValCells = rel_morn_cells(:, 8) > 0.01;
    end
    % if there is no other cell in the same tuned/nottuned category
    % then the given cell has no pair in the other session
    if sum(sameRampValCells) > 0
        rel_morn_cells = rel_morn_cells(sameRampValCells, :);
        if ~isempty(waveforms)
            rel_waveMat = rel_waveMat(:, sameRampValCells);
        end
        rel_compMat = rel_compMat(:, sameRampValCells);
        
        FRDiff = abs(rel_morn_cells(:, 4) - aft_cells(row, 4));
        [minFRDiff, minFRDiff_idx] = sort(FRDiff');
        
        BI_Diff = abs(rel_morn_cells(:, 5) - aft_cells(row, 5));
        [minBIDiff, minBI_idx] = sort(BI_Diff');
        
        if ~isempty(waveforms)
            [minWD, minWD_idx] = sort(rel_waveMat(row, :));
        end
        
        if SSIM
            [minVals, minIdx] = sort(rel_compMat(row, :), 'descend'); % want the max SSIM
        else
            [minVals, minIdx] = sort(rel_compMat(row, :)); % want the min distance
        end
        
        coords = [];
        norms = [];
        % now devise coordinates
        for r = 1:size(rel_morn_cells, 1)
            
            if ~isempty(waveforms)
                coords(r, :) = [find(minIdx == r) find(minFRDiff_idx == r) find(minBIDiff == r) find(minWD_idx == r)];
            else
                coords(r, :) = [find(minIdx == r) find(minFRDiff_idx == r) find(minBIDiff == r)];
            end
            norms(r) = norm(coords(r, :));
        end
        
        % find the cells closest to the target in the FR, cosine dist space
        [~, nn] = min(norms);
        
        cellPairs{1, 2}(row, 1) = aft_cells(row, 1);
        cellPairs{1, 2}(row, 2) = rel_morn_cells(nn, 1); % why is this still aft cells?
    else
        cellPairs{1, 2}(row, 1) = aft_cells(row, 1);
%         cellPairs{1, 2}(row, 2) = []; % why is this still aft cells?
    end
    
    
end

%% Enforcing bi-directional agreement
itr = 1;
% if morn_cell_num == aft_cell_num
% enforcing the 2 way agreement
for i = 1:morn_cell_num
    
    cell_to_find = cellPairs{1, 1}(i, 2);
    idx_to_check = find(cellPairs{1, 2}(:, 1) == cell_to_find);
    
    if cellPairs{1, 1}(i, :) == fliplr(cellPairs{1, 2}(idx_to_check, :))
        cellPairs{1, 3}(itr, :) = cellPairs{1, 1}(i, :);
        itr = itr + 1;
    end
    
end
% end

% logical flow
% check for other cells on given channel - if no fill cellpairs and move on
% if yes check for pval ramp sig - if no fill cellPairs and move on 
%     devise coordinates

end