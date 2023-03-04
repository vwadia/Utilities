function bootstrap = getBaselineMI(density)

% Preserve the number of examples in each group (i.e. the prior)
groupSizes = [ 0 cumsum(cellfun(@(x) size(x,1),density))];
nrSamples  = 1:groupSizes(end);
X          = cell2mat(density');  
nrIter     = 1000;
bootstrap  = NaN(nrIter,size(X,2));

parfor i=1:nrIter
    
    % Shuffle the firing rate data
    whichSamples   = Shuffle(nrSamples); 
    X_iter         = X(whichSamples,:);
    
    % Group by category
    density        = groupData(X_iter,groupSizes);
    bootstrap(i,:) = Decode.computeMIfromDensity(density);

end

end


% Helper functions
function density = groupData(X,groupSizes)

    density = cell(1,length(groupSizes)-1); 
    for i=1:length(groupSizes)-1
        density{i} = X(groupSizes(i)+1:groupSizes(i+1),:);
    end

end