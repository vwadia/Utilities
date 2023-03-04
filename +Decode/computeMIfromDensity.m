% Input is the PTSH of the cells, cell format, [spike counts ,time]
% for each distinct category

function MI = computeMIfromDensity(density, binData)


if nargin<2
    binData = true;
end

timesteps      = size(density{1},2);
X              = cell2mat(density');
groups         = cell2mat(cellfun(@(x,y) y*ones(1,size(x,1)),density,...
                  num2cell(1:length(density)),'UniformOutput',false))';
MI             = NaN(1,length(timesteps));



% Discretize the firing rates to afew different levels
if binData
   maxResponse       = 5;   
   levels            = 11;
   bins              = linspace(0,maxResponse,levels);
   X(X>=maxResponse) = maxResponse;
   X(isnan(X))       = 1;
   X                 = discretize(X,bins);
    
    
end


% Compute the Mutual Information at each time step
for i=1:timesteps
    if ~(sum(isnan(X(:,i)))>0)
        MI(i) = Decode.mutualInformation(X(:,i),groups);
    end

end
    
    
    
    
    
end