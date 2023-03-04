function expVar = computeExplainedVariance(obsResp, predResp)
% computes the explained variance per cell 
% Inputs:
%     1. Observed responses (single number representing response to held out trials in the right window - sum window and mean across trials)
%     2. Predicted responses 
% Outputs:
%     1. Explained Variance
% vwadia/2021

if ~isequal(length(obsResp), length(predResp))
    disp('Check Vector Lengths');
    keyboard
end


n = length(obsResp); % number of images
num = zeros(length(obsResp), 1);
den = zeros(length(obsResp), 1);
avgResp = mean(obsResp); % avg response 

% compute the numerator and denominator
for i = 1:n
    num(i) = (obsResp(i) - predResp(i))^2; 
    den(i) = (obsResp(i) - avgResp)^2;
end

% liang does this
num2 =  sum((obsResp - predResp).^2); % regression error
den2 = sum((obsResp - mean(obsResp)).^2); % total error
ev = 1-num2./den2;

% compute explained variance using formula 
expVar = 1 - (sum(num)/sum(den));

% indicates if my way is wrong
if ~isequal(expVar, ev)
    keyboard
end

end
