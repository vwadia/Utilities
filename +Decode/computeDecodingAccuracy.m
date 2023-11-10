function [accuracy,significance] = computeDecodingAccuracy(confusionMatrix,p, computeSig)


if nargin<3
    computeSig = false;
end
if nargin<2 || isempty(p)
    p = ones(size(confusionMatrix,1),1)/size(confusionMatrix,1);
end
    
accuracy     = NaN(1,size(confusionMatrix,1));
significance = NaN(1,size(confusionMatrix,1));
    
for i=1:size(confusionMatrix,1)
    
    accuracy(i)      = confusionMatrix(i,i)/sum(confusionMatrix(i,:));
    
    if computeSig
        significance (i) = computeSignificance(confusionMatrix(i,i),...
                                            sum(confusionMatrix(i,:)),p(i));
    else
        significance(i) = NaN;
    end

end

end




function significance  = computeSignificance(hits, trials, p)
significance = binocdf(hits,trials,p);
end