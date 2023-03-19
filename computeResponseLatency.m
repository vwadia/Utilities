function [respLat, max_gr] = computeResponseLatency(psth, labels, timelimits, stimOffDur, stimDur, method, n_stdDevs)
% This function takes in psth (cell with raster, smoothed psth, times),
% category labels (to determine how to calculate resp latency) and timelimits and
% computes the response latency of the cell. If there is only 1 category
% then use an iterative ttest, if there are multiple categories 
% Current iteration has 3 methods of finding response latency 0 - threshold crossing
% 1 - threshold crossing to make a candidate then sliding window anova with first win
% 2 - threshold crossing to makea candidate then peak of omega squared
% Inputs:
%     1. psth (1x3 cell)
%     2. labels (category)
%     3. timelimits
%     4. Stimulus Duration (on and off)
%     5. What technique to use (baseline increase vs sliding anova for multiple categories)
%     6. How many std devs to use as threshold (if using basic method)
% Outputs:
%     1. the response latency
%     2. the group with the maximal response (if using the basic method)
% vwadia/March2021
% edited Nov2022
if nargin == 5, method = 1; n_stdDevs = 2; end
if nargin == 6, n_stdDevs = 2.5; end % default value
binSize = 25; %ms
endRas = size(psth{1, 1}, 2);
bins = (-timelimits(1)*1e3):binSize:endRas;
nSig = 3;

if stimDur < 10
    stimDur = stimDur*1e3;
end

alpha = 0.05;
cnter = zeros(length(-timelimits(1)*1e3:binSize:endRas), 1);
respLat = [];
max_gr = [];

if length(unique(labels)) == 1 % only 1 category - iterative ttest
    ctr = 1;
    ht = zeros(length(bins(1:end-1)), 1);
    pt = zeros(length(bins(1:end-1)), 1);
    if (-timelimits(1)*1e3) > stimOffDur
        baselineBin = round(((-timelimits(1)*1e3) - stimOffDur):(-timelimits(1)*1e3));
    else
        baselineBin = round(1:(-timelimits(1)*1e3));
    end
    baseline = mean(psth{1, 1}(:, baselineBin), 2);
    
    for win = bins(1:end-1)
        test = mean(psth{1, 1}(:, win:win+binSize), 2);
        [ht(ctr), pt(ctr)] = ttest(test, baseline, 'Alpha', alpha);
        
        if ctr >= nSig
            b = ht(ctr-(nSig-1):ctr);
            if length(unique(b)) == 1 && b(1) == 1
                respLat = bins(ctr);
                break
            end
        end
        ctr = ctr+1;
    end
else % multiple categories
    offset = 80;  % sometimes cells randomly have sig differences right after stim on, not in response to that particular image - gets rid of that
    
    %     % make sure that at least 1 group crosses baseline + n std devs before finding latency
    num_std_dvs = n_stdDevs;
    
    % 'baseline' psth - note that this is post stimON but before the response
    % this is because I have short stimOFF times and responses bleed into the interstimulus interval
    % ALO NOTE - using the smoothed psth because it's cleaner to measure threshold crossings
    baselinePsth = psth{1, 2}(:, abs(timelimits(1))*1e3:abs(timelimits(1))*1e3+offset);
    
    threshold = mean(mean(baselinePsth)) + num_std_dvs*std(mean(baselinePsth));
    
    % find max group (to asses category selectivity)
    [max_gr, max_val] = Utilities.findMaxGroup(psth{1, 2}(:, abs(timelimits(1))*1e3+offset:abs(timelimits(1))*1e3+offset+ceil(stimDur)), labels);
    
    % split psth into all groups
    for ng = 1:length(unique(labels))
        
        % ALSO NOTE - using the smoothed psth because it's cleaner to measure threshold crossings
        testPsth{ng, 1} = psth{1, 2}(find(labels == ng), abs(timelimits(1))*1e3+offset:abs(timelimits(1))*1e3+offset+ceil(stimDur)); % used to be 'end' March2023
        
    end
    
    % another way to find max group
    maxFR = cell2mat(cellfun(@(x) max(mean(x,1)), testPsth, 'UniformOutput', false));
    
    
    if method ~= 0
        
        stepsize = 5;
        
        if max(maxFR > threshold)
            
            if method == 1 % significance diff
                % comparison type = 2 --> comparison of groups post stimON
                % multiple comparisons correction if bins are overlapping?? Do I need to do this?
                % made no difference when tested - vwadia Oct2022
                multMatrix = Utilities.slidingWindowANOVA(psth{1, 1}, labels, abs(timelimits)*1e3+offset, alpha, 0, [], binSize, stepsize, 2);
                if ~isempty(multMatrix)
                    
                    % old way
%                     respLat = multMatrix{g, 2}; % the first timewindow the groups are significantly different
                    
                    
                    t = cell2mat(multMatrix(:, 2))'; % list of bins
                    
                    N = ceil(25/stepsize); % these many consecutive bins have to be significant
                    x = diff(t)==stepsize;
                    f = find([false,x]~=[x,false]);
                    g = find(f(2:2:end)-f(1:2:end-1)>=N,1,'first');
                    if ~isempty(t(f(2*g-1)))
                        respLat = multMatrix{f(2*g-1), 2}; % the first timewindow the groups start to be different for a while
                    end
                    
                    
                end
%                 [max_gr, max_val] = Utilities.findMaxGroup(psth{1, 2}(:, abs(timelimits(1))*1e3+offset:abs(timelimits(1))*1e3+offset+ceil(stimDur)), labels);
                
            elseif method == 2 % omega squared
                % comparison type = 3 --> compute omega squared across time 
                multMatrix = Utilities.slidingWindowANOVA(psth{1, 1}, labels, abs(timelimits)*1e3+offset, alpha, 0, [], binSize, stepsize, 3);
                if ~isempty(multMatrix)
                    [mv, mt] = max(cell2mat(multMatrix(:, 3)));
                    respLat = multMatrix{mt, 2};
                    
                end
                
            end
            
        end
        
    else
      
        num_std_dvs = n_stdDevs;
        
        % 'baseline' psth - note that this is post stimON but before the response
        % this is because I have short stimOFF times and responses bleed into the interstimulus interval
        % ALO NOTE - using the smoothed psth because it's cleaner to measure threshold crossings
        baselinePsth = psth{1, 2}(:, abs(timelimits(1))*1e3:abs(timelimits(1))*1e3+offset); 
        
        threshold = mean(mean(baselinePsth)) + num_std_dvs*std(mean(baselinePsth));
        
        % find max group (to asses category selectivity)
        [max_gr, max_val] = Utilities.findMaxGroup(psth{1, 2}(:, abs(timelimits(1))*1e3+offset:abs(timelimits(1))*1e3+offset+ceil(stimDur)), labels);
        
        % split psth into all groups 
        for ng = 1:length(unique(labels))
                   
            % ALSO NOTE - using the smoothed psth because it's cleaner to measure threshold crossings
            testPsth{ng, 1} = psth{1, 2}(find(labels == ng), abs(timelimits(1))*1e3+offset:end);
            
        end

        % another way to find max group
        maxFR = cell2mat(cellfun(@(x) max(mean(x,1)), testPsth, 'UniformOutput', false));
        first_t = [];
        
%         % find the response latency for all groups and pick the earliest
%         if sum(maxFR >= threshold) >= 1 % at least 1 group is above threshold
%             
%             
%             % consecutive bins being above threshold
%             for ct = 1:length(testPsth)
%                 
%                 testFR = mean(testPsth{ct, 1}, 1);
%                 
%                 ttimes = abs(timelimits(1))*1e3+offset:size(testPsth{ct, 1}, 2)+abs(timelimits(1))*1e3+offset-1;
%                 
%                 t = ttimes(testFR >= threshold);
%                 
%                 % FR has to stay above threshold for at least a few ms
%                 N = 5; % Required number of consecutive numbers following a first one
%                 x = diff(t)==1;
%                 f = find([false,x]~=[x,false]);
%                 g = find(f(2:2:end)-f(1:2:end-1)>=N,1,'first');
%                 if ~isempty(t(f(2*g-1)))
%                     first_t(ct) = t(f(2*g-1)); % First t followed by >=N consecutive numbers
%                 else
%                     first_t(ct) = nan;
%                 end
%                 
%             end
%             if sum(isnan((first_t))) ~= length(testPsth)
%                 respLat = min(first_t); % first time it crosses threshold
%             else
%                 respLat = 0;
%             end
% 
%         end




    % time that max group crosses
    if max(maxFR) >= threshold
        [~, id] = max(maxFR);
        testFR = mean(testPsth{id, 1}, 1);
        ttimes = abs(timelimits(1))*1e3+offset:size(testPsth{1, 1}, 2)+abs(timelimits(1))*1e3+offset-1;
        
        t = ttimes(testFR >= threshold);
        
        %FR has to stay above threshold for at least a few ms
        N = 25; % Required number of consecutive numbers following a first one
        x = diff(t)==1;
        f = find([false,x]~=[x,false]);
        g = find(f(2:2:end)-f(1:2:end-1)>=N,1,'first');
        if ~isempty(t(f(2*g-1)))
            respLat = t(f(2*g-1)); % First t followed by >=N consecutive numbers
        else
            respLat = 0;
        end
        
    end

    end
    
    
end

end