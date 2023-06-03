function [rL, rL_Std] = computeRespLatPoisson(psth, labels, sortedOrder, timelimits, stimDur, applyFRCap, typeOfBaseline, num_std_dvs)
% cleaned up version of the code in the Screening.poissonLatency script
% Takes in raster and smoothed psth
% 1 - Uses the raster to compute response latency with p_burst
% 2 - If asked, applies and avg FR threshold (< 0.5hz in the spike collection window)
% 3 - Then uses the smoothed psth to ensure that one of the groups changes
%       by 3.5std devs of the cells baseline within the spike collection window
% 4 - Unless that neuron has a 10*std dev response to any one stimulus (concept cell like coding)
% 
% INPUTS:
%     1. psth (1x3 cell array with raster, smoothed psth, times)
%     2. labels (for classwise comparison)
%     3. sortedOrder (essentially individual stim labels)
%     4. timelimits (when is stim On/Off?)
%     5. stimDur (how long was stim on the screen)
%     6. Option to include an avg FR threshold (for IT neurons mainly)
%     7. option to use trial spike rate or cell spike rate for p_burst
%     8. Optional: Number of std deviations for classwise threshold (default = 3.5)
% 
% OUTPUTS:
%     1. Response latency
%     2. Std dev of that computed response latency
%     3. Group with max response?
%     
% vwadia March/2023

%% ---------------------------FIX THIS----------------------------------
% re-write to onclude options struct with applyFRCap, typeofBasline,
% num_std_devs, and theshold option ( <-- for non-category cells)
%% --------------------------------------------------------------
if nargin == 7, num_std_dvs = 3.5; end
if nargin == 6, typeOfBaseline = 'trial'; num_std_dvs = 3.5; end
if nargin == 5, applyFRCap = true; typeOfBaseline = 'trial'; num_std_dvs = 3.5; end

nonResp = false;

if ~strcmp(typeOfBaseline, 'Cell') && ~strcmp(typeOfBaseline, 'cell')...
       && ~strcmp(typeOfBaseline, 'trial') && ~strcmp(typeOfBaseline, 'Trial')
   error("invalid 'typeOfBaseline' parameter");
end

%% step 1: using p_burst to compute the individual trial response latency
exCell = psth{1, 1}; 


BOB = zeros(1, size(exCell, 1));
EOB = zeros(1, size(exCell, 1));
SOB = zeros(1, size(exCell, 1));
stamps = zeros(size(exCell, 1), 3);
onTimes = [];

if strcmp(typeOfBaseline, 'Cell') || strcmp(typeOfBaseline, 'cell')
    avgSpikRate = mean(mean(exCell(:, -timelimits(1)*1e3-50:-timelimits(1)*1e3))); % baseline FR of cell 
end

for it = 1:size(exCell, 1)    
   
    % spike timestamps - note that function gets rid of negative numbers
    times = find(exCell(it, :) == 1);
    
    % note start time can't be 0
    startT = -timelimits(1)*1e3+50; % Starting at an offset to avoid spurious early values 
    endT = (-timelimits(1)*1e3)+stimDur;

%     can manually input an average spike rate - per trial works best so far
if strcmp(typeOfBaseline, 'trial') || strcmp(typeOfBaseline, 'Trial')
%     avgSpikRate = sum(times > -timelimits(1)*1e3 & times < -timelimits(1)*1e3+50)/50; % baseline FR per trial
    avgSpikRate = sum(times > -timelimits(1)*1e3-50 & times < -timelimits(1)*1e3)/50; % baseline FR per trial
end
    [b, e, s] = Utilities.p_burst(times, startT, endT, 0, avgSpikRate); 
    
    if ~isempty(b)   
        train = times;
        
        % in cases with multiple burtst take one with max surprise
        if length(s) > 1
            [~, pos] = max(s);
            stamps(it, 1) = train(b(pos));
            stamps(it, 2) = train(e(pos));
            stamps(it, 3) = s(pos);
        else % else take the first 
            stamps(it, 1) = train(b);
            stamps(it, 2) = train(e);
            stamps(it, 3) = s;
        end
    end
end

% numRespTrials = sum(stamps(:, 1) ~= 0);
onTimes = stamps(find(stamps(:, 1) ~= 0), 1);
adjOnTimes = onTimes(onTimes > -timelimits(1)*1e3);
adjOnTimes = adjOnTimes - (-timelimits(1)*1e3);
adj = adjOnTimes;

rL = mean(adj); % response latency - already adjusted for stim on time
rL_Std = std(adj);

% if no responsive trials 
if isnan(rL)
    return
end

%% step 3 - thresholding the max group after RLcomp
exCell = psth{1, 2}; % smoothed psth is better for threshold crossing

m_b_psth(1, 1) = mean(mean(exCell(:, -timelimits(1)*1e3-50:-timelimits(1)*1e3)));
m_b_psth(1, 2) = std(mean(exCell(:, -timelimits(1)*1e3-50:-timelimits(1)*1e3)));

ctr = 1;
m_t_psth = [];
for lb = unique(labels)'
    m_b_psth(ctr, 1) = mean(mean(exCell(find(labels == lb), -timelimits(1)*1e3-50:-timelimits(1)*1e3)));
    m_b_psth(ctr, 2) = std(mean(exCell(find(labels == lb), -timelimits(1)*1e3-50:-timelimits(1)*1e3)));
    
    if -timelimits(1)*1e3+rL+ceil(stimDur) > size(exCell, 2)
        t_psth = exCell(find(labels == lb), -timelimits(1)*1e3+floor(rL):end);
    else
        t_psth = exCell(find(labels == lb), -timelimits(1)*1e3+floor(rL):-timelimits(1)*1e3+floor(rL)+ceil(stimDur));
    end
    
    
    m_t_psth(ctr, :) = mean(t_psth, 1);
    
    
    ctr = ctr + 1;
end

if -timelimits(1)*1e3+rL+ceil(stimDur) > size(exCell, 2)
    full_t_psth = exCell(:, -timelimits(1)*1e3+floor(rL):end);
else
    full_t_psth = exCell(:, -timelimits(1)*1e3+floor(rL):-timelimits(1)*1e3+floor(rL)+ceil(stimDur));
end

% find max group
[max_gr, max_val] = Utilities.findMaxGroup(full_t_psth, labels); % find pos group
[min_gr, min_val] = Utilities.findMaxGroup(full_t_psth, labels, true); % find neg group

% threshold 
if ~(max_val > (m_b_psth(max_gr, 1) + num_std_dvs*m_b_psth(max_gr, 2)))...
        &&  ~(min_val < (m_b_psth(min_gr, 1) - num_std_dvs*m_b_psth(min_gr, 2)))...       
    nonResp = true;
end

%% step 2 - Make sure avg FR is greater than 0.5Hz 

if applyFRCap
    exCell = psth{1, 2};
    if -timelimits(1)*1e3+ceil(rL)+ceil(stimDur) > size(exCell, 2)
        spike_psth = exCell(:, -timelimits(1)*1e3+floor(rL):end);
    else
        spike_psth = exCell(:, -timelimits(1)*1e3+floor(rL):-timelimits(1)*1e3+floor(rL)+ceil(stimDur));
    end
    if mean(mean(spike_psth)) < 0.5 % oh
        nonResp = true;
    end
end

%% step 4 - save the cell if it has concept like coding
exCell = psth{1, 1}; 

cell_b_psth(1, 1) = mean(mean(exCell(:, -timelimits(1)*1e3-50:-timelimits(1)*1e3)));
cell_b_psth(1, 2) = std(mean(exCell(:, -timelimits(1)*1e3-50:-timelimits(1)*1e3)));
ctr = 1;
notime_m_t_psth = [];
for sO = unique(sortedOrder)'
    if -timelimits(1)*1e3+rL+ceil(stimDur) > size(exCell, 2)
        notime_t_psth = exCell(find(sortedOrder == sO), -timelimits(1)*1e3+floor(rL):end);
    else
        notime_t_psth = exCell(find(sortedOrder == sO), -timelimits(1)*1e3+floor(rL):-timelimits(1)*1e3+floor(rL)+ceil(stimDur));
    end
    notime_m_t_psth(ctr) = mean(mean(notime_t_psth));
    ctr = ctr+1;
end

rC = (notime_m_t_psth - cell_b_psth(1, 1))./cell_b_psth(1, 2);

if max(rC) >= 10
    nonResp = false;
end

if nonResp
    rL = nan;
    rL_Std = nan;
else
    rL = mean(adj);
    rL_Std = std(adj);
end


end





