function [cellPairs, compMat] = compareCells_2(cellMat, cellIDs, restrictToChannels, waveforms, no_repeats)
% This function returns a list of paired cells indicating that they are the same.
% It takes in a matrix of cell stimulus preferences, where each row is a the rank ordered stimulus IDs per cell
% or an nx1 cell array of psths (if using SSIM)
% The first set of rows are all the morning cells, the second set of rows are all the afternoon cells.
% It will compute a distance matrix and only examine the top right rectangle (entries that compare morning and afternoon)
% It will check each row for the lowest distance/highest similarity value
% with similar FR, waveform, burstIndex, and the pvalue of the ramp
% It is currently set up to only compare cells on the same channel - unless
% a channel has no cells in one of the sessions, in which case the cell is
% simply compared to all cells in the other session
% Now that response latency is computed in a fine grained manner  
%
%
%
% INPUTS:
%     1. Cell Matrix - cells x stimuli OR cell array of rasters
%     2. Cell IDs - double array of cell names, session ID (morning = 1 and afternoon = 2), resplat, baselineFR, burst index
%     3. Whether or not to restrict to searching only on matching channels
%     4. Waveforms of the cells
%     5. Whether or not to allow a given cell to be matched to multiple others
%
% OUTPUTS:
%     1. Array of morning-afternoon cell pairs that are similar
%     2. the raw distance matrix (for manual inspection)
%
% vwadia/May2022 - included ramp pval check and cleanedup workflow 


if nargin == 3, waveforms = []; no_repeats = 1; end
if nargin == 4, no_repeats = 1; end

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
        
        sameCatCells = aft_cells(:, 7) == chan;
    else
        sameCatCells = aft_cells(:, 6) == morn_cells(row, 6);
    end
    
    
    % if there are no cells in that channel in other session
    % compare to all
    if sum(sameCatCells) == 0
        
        cellPairs{1, 1}(row, 1) = morn_cells(row, 1);
        continue;
        
    elseif sum(sameCatCells) ~= 0
            
            
        rel_aft_cells = aft_cells(sameCatCells, :);
        if ~isempty(waveforms)
            rel_waveMat = waveMat(:, sameCatCells);
        end
        rel_compMat = relevant_compMat(:, sameCatCells);
        
        % check pvalue of ramp - restrict search of sig cells to ther sig cells and vice versa
        pvalRamp = morn_cells(row, 8);
        if pvalRamp <= 0.01
            sameRampValCells = rel_aft_cells(:, 8) <= 0.01;
        elseif pvalRamp > 0.01
            sameRampValCells = rel_aft_cells(:, 8) > 0.01;
        end
        
        if sum(sameRampValCells) == 0
            cellPairs{1, 1}(row, 1) = morn_cells(row, 1);
            continue;
        elseif sum(sameRampValCells) > 0
            
            rel_aft_cells = rel_aft_cells(sameRampValCells, :);
            if ~isempty(waveforms)
                rel_waveMat = rel_waveMat(:, sameRampValCells);
            end
            rel_compMat = rel_compMat(:, sameRampValCells);
            
            % compute differences in other fields
            FRDiff = abs(rel_aft_cells(:, 4) - morn_cells(row, 4));
            [minFRDiff, minFRDiff_idx] = sort(FRDiff);
            
            BI_Diff = abs(rel_aft_cells(:, 5) - morn_cells(row, 5));
            [minBIDiff, minBI_idx] = sort(BI_Diff);
            
            RL_Diff = abs(rel_aft_cells(:, 3) - morn_cells(row, 3));
            [minRLDiff, minRL_idx] = sort(RL_Diff);
            
            if ~isempty(waveforms)
                [minWD, minWD_idx] = sort(rel_waveMat(row, :)');
            end
            
            if SSIM
                [minVals, minComp_Idx] = sort(rel_compMat(row, :)', 'descend'); % want the max SSIM
            else
                [minVals, minComp_Idx] = sort(rel_compMat(row, :)'); % want the min distance
            end
            
            
            % now devise coordinates - this is a matrix showing for each variable what the rank order of closeness to the morning cell was
            coords = [minComp_Idx minFRDiff_idx minBI_idx minWD_idx minRL_idx];
            score_val = size(rel_aft_cells, 1);
            cc_mat = zeros(1, size(rel_aft_cells, 1));
            
            for r = 1:score_val
                for id = 1:size(coords, 2)
                    cc_mat(coords(r, id)) = cc_mat(coords(r, id)) + (score_val - r + 1);
                end
            end
            [scr, m_n] = max(cc_mat);
            
%             coords = [];
%             norms = [];
%             % now devise coordinates - why am I doing this n times?? include respLat and weight the factors
%             for r = 1:size(rel_aft_cells, 1)
%                 if ~isempty(waveforms)
%                     coords(r, :) = [find(minComp_Idx == r) find(minFRDiff_idx == r) find(minBI_idx == r) find(minWD_idx == r)  find(minRL_idx == r)];
%                 else
%                     coords(r, :) = [find(minComp_Idx == r) find(minFRDiff_idx == r) find(minBI_idx == r) find(minRL_idx == r)];
%                 end
%                 norms(r) = norm(coords(r, :));
%             end
%             
%             % find the cells closest to the target in the FR, cosine dist space
%             [m_n, nn] = min(norms);
            
            cellPairs{1, 1}(row, 1) = morn_cells(row, 1);
            cellPairs{1, 1}(row, 2) = rel_aft_cells(m_n, 1);
            cellPairs{1, 1}(row, 3) = scr;
            cellPairs{1, 1}(row, 4) = ((score_val)*size(coords, 2));
            
        end
        
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
        
        sameCatCells = morn_cells(:, 7) == chan;
    else
        sameCatCells = morn_cells(:, 6) == aft_cells(row, 6);
        
    end
    % if there are no cells in that channel in other session
    % compare to all
    if sum(sameCatCells) == 0
        cellPairs{1, 2}(row, 1) = aft_cells(row, 1);
        continue
    elseif sum(sameCatCells ~= 0)
        rel_morn_cells = morn_cells(sameCatCells, :);
        if ~isempty(waveforms)
            rel_waveMat = waveMat(:, sameCatCells);
        end
        rel_compMat = relevant_compMat(:, sameCatCells);
        
        
        % check pvalue of ramp - restrict search of sig cells to ther sig cells and vice versa
        pvalRamp = aft_cells(row, 8);
        if pvalRamp <= 0.01
            sameRampValCells = rel_morn_cells(:, 8) <= 0.01;
        elseif pvalRamp > 0.01
            sameRampValCells = rel_morn_cells(:, 8) > 0.01;
        end
        
        if sum(sameRampValCells) == 0
            cellPairs{1, 2}(row, 1) = aft_cells(row, 1);
            continue;
        elseif sum(sameRampValCells) > 0
            
            rel_morn_cells = rel_morn_cells(sameRampValCells, :);
            if ~isempty(waveforms)
                rel_waveMat = rel_waveMat(:, sameRampValCells);
            end
            rel_compMat = rel_compMat(:, sameRampValCells);
            
            FRDiff = abs(rel_morn_cells(:, 4) - aft_cells(row, 4));
            [minFRDiff, minFRDiff_idx] = sort(FRDiff);
            
            BI_Diff = abs(rel_morn_cells(:, 5) - aft_cells(row, 5));
            [minBIDiff, minBI_idx] = sort(BI_Diff);
            
            RL_Diff = abs(rel_morn_cells(:, 3) - aft_cells(row, 3));
            [minRLDiff, minRL_idx] = sort(RL_Diff);
            
            if ~isempty(waveforms)
                [minWD, minWD_idx] = sort(rel_waveMat(row, :)');
            end
            
            if SSIM
                [minVals, minComp_Idx] = sort(rel_compMat(row, :)', 'descend'); % want the max SSIM
            else
                [minVals, minComp_Idx] = sort(rel_compMat(row, :)'); % want the min distance
            end
            
            % now devise coordinates - this is a matrix showing for each variable what the rank order of closeness to the morning cell was
            coords = [minComp_Idx minFRDiff_idx minBI_idx minWD_idx minRL_idx];
            score_val = size(rel_morn_cells, 1);
            cc_mat = zeros(1, size(rel_morn_cells, 1));
            
            for r = 1:score_val
                for id = 1:size(coords, 2)
                    cc_mat(coords(r, id)) = cc_mat(coords(r, id)) + (score_val - r + 1);
                end
            end
            [scr, m_n] = max(cc_mat);
            
%             coords = [];
%             norms = [];
%             % now devise coordinates
%             for r = 1:size(rel_morn_cells, 1)
%                 
%                 if ~isempty(waveforms)
%                     coords(r, :) = [find(minComp_Idx == r) find(minFRDiff_idx == r) find(minBI_idx == r) find(minWD_idx == r)];
%                 else
%                     coords(r, :) = [find(minComp_Idx == r) find(minFRDiff_idx == r) find(minBI_idx == r)];
%                 end
%                 norms(r) = norm(coords(r, :));
%             end
%             
%             % find the cells closest to the target in the FR, cosine dist space
%             [m_n, nn] = min(norms);
            
            cellPairs{1, 2}(row, 1) = aft_cells(row, 1);
            cellPairs{1, 2}(row, 2) = rel_morn_cells(m_n, 1);
            cellPairs{1, 2}(row, 3) = scr; 
            cellPairs{1, 2}(row, 4) = ((score_val)*size(coords, 2));
            
        end
    end

end


%% checking for repeats - am I doing this right?
if no_repeats == 1
    paired_cells_morn = unique(cellPairs{1, 1}(:, 2));
    for j = paired_cells_morn'
        
        if sum(cellPairs{1, 1}(:, 2) == j) > 1 && j ~= 0
            
            idx = find(cellPairs{1, 1}(:, 2) == j); % actual idx numbers
            norms = cellPairs{1, 1}(cellPairs{1, 1}(:, 2) == j, 3);
            [m_n, nn] = sort(norms, 'descend');
            idx = idx(nn);
            
            log_vec = cellPairs{1, 1}(idx, 3) == m_n(1);
            log_vec = ~log_vec; % invert
            cellPairs{1, 1}(idx(log_vec), 2) = 0;
            
        end
        
    end
    
    paired_cells_aft = unique(cellPairs{1, 2}(:, 2));
    for j = paired_cells_aft'
        
        if sum(cellPairs{1, 2}(:, 2) == j) > 1 && j ~= 0
            
            idx = find(cellPairs{1, 2}(:, 2) == j); % actual idx numbers
            norms = cellPairs{1, 2}(cellPairs{1, 2}(:, 2) == j, 3);
            [m_n, nn] = sort(norms, 'descend');
            idx = idx(nn);
            
            log_vec = cellPairs{1, 2}(idx, 3) == m_n(1);
            log_vec = ~log_vec; %invert
            cellPairs{1, 2}(idx(log_vec), 2) = 0;
            
        end
        
    end
end
%% Enforcing bi-directional agreement
itr = 1;
m_score = [];


if morn_cell_num <= aft_cell_num
    inds = morn_cell_num; 
elseif morn_cell_num > aft_cell_num
    inds = aft_cell_num;     
end
% if morn_cell_num == aft_cell_num
% enforcing the 2 way agreement
for i = 1:inds
    
    cell_to_find = cellPairs{1, 1}(i, 2);
    idx_to_check = find(cellPairs{1, 2}(:, 1) == cell_to_find);
    
    if cellPairs{1, 1}(i, 1:2) == fliplr(cellPairs{1, 2}(idx_to_check, 1:2))
        cellPairs{1, 3}(itr, :) = cellPairs{1, 1}(i, 1:2);
        m_score(itr, 1) = mean([cellPairs{1, 1}(i, 3)/cellPairs{1, 1}(i, 4), cellPairs{1, 2}(idx_to_check, 3)/cellPairs{1, 2}(idx_to_check, 4)]);
%         cellPairs{1, 3}(itr, end+1) = mean([cellPairs{1, 1}(i, end) cellPairs{1, 2}(i, end)]);
        itr = itr + 1;
    end
    
end

cellPairs{1, 3}(:, 3) = m_score;
    

% logical flow
% check for other cells on given channel - if no fill cellpairs and move on
% if yes check for pval ramp sig - if no fill cellPairs and move on 
%     devise coordinates
% if there are repetitions then choose the one with the closest distance.
% if they are equal - keep both

end