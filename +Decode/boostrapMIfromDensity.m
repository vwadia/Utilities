% Given a PSTH, compute the null distribution for the effect size at each
% point aroun the fixation

function [bootstrap,CI]  = boostrapMIfromDensity(density,threshold)

nrIterations   = 1000;
anovaGroups    = cell2mat(cellfun(@(x,y) y*ones(size(x,1),1),density,...
                 num2cell(1:length(density)), 'UniformOutput',false)');          
X              = cell2mat(density');
nrTimePoints   = size(X,2);
bootstrap      = NaN(nrIterations,nrTimePoints);



for i=1:nrTimePoints
    for j=1:nrIterations
        
       temp       = Shuffle(anovaGroups); % shuffle the labels
       densitynew = cellfun(@(x) X(temp==x,i),...
                    num2cell(unique(anovaGroups)),'UniformOutput',false);
       bootstrap(j,i)  =  Decode.computeMIfromDensity(densitynew');
    end
end


CI = getCI(bootstrap,threshold);


end




function CI = getCI(bootstrap, threshold)

CI = NaN(1,size(bootstrap,2));
for i=1:size(bootstrap,2)
    
    range = linspace(min(bootstrap(:,i)),max(bootstrap(:,i)),1000);
    
    for j = 1:length(range)
        
        
        if ( sum(bootstrap(:,i)<range(j))./size(bootstrap,1))>=threshold
            CI(i) = range(j);
            break;
        end
        
    end
end

end











