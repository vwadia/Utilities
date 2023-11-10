function confusionMat = slidingWindowDecode(timeTraces,labels,xAxis,ROI,trials,criteria)

method          = 'multinomial'; % decoder to use
whereToDecode   = cellfun(@(x) closestTo(xAxis,x),num2cell(ROI));


X               = cell2mat(timeTraces');                    
confusionMat    = cell(1,length(whereToDecode));


% Compute a confusion matrix at each time point
for i=1:length(whereToDecode)
    [~,confusionMat{i}] = Decode.decodeCategory(X(:,whereToDecode(i)),labels,criteria,...
                                             method, trials); 
end


end