function [dat1_balanced, dat2_balanced, resampledStructure] = balanceSpikesSFC(dat1, dat2)
% This function takes in 2 data structures (matrices for SFC)
% figures out which one has more spikes, subsamples it and returns the 
% balanced structures
% 
%     INPUT:
%         1. dat1 - data structure 1
%         2. dat2 - data structure 2
%         
%     OUTPUT:
%         1. dat1_balanced
%         2. dat2_balanced
%         3. resampledStructure - which data structure was downsampled?
% vwadia2023
n_spikes1 = sum(dat1(:));
n_spikes2 = sum(dat2(:));

if n_spikes1 == n_spikes2
    
    dat1_balanced = dat1;
    dat2_balanced = dat2;
    resampledStructure = 0;
    
elseif n_spikes1 > n_spikes2
    
    spikyCond = dat1; 
    reduction = n_spikes1 - n_spikes2;
    resampledStructure = 1;
    
elseif n_spikes1 < n_spikes2
    
    spikyCond = dat2;
    reduction = n_spikes2 - n_spikes1;
    resampledStructure = 2;

end

allSpikeInds = find(spikyCond(:) == 1);

indsToFlip = randsample(allSpikeInds, reduction);

spikyCond_balanced = spikyCond;
spikyCond_balanced(indsToFlip) = 0;

if n_spikes1 > n_spikes2
    
    assert(isequal(spikyCond, dat1), 'Data is mixed up'); 
    dat1_balanced = spikyCond_balanced;
    dat2_balanced = dat2;
    assert(resampledStructure == 1);
    
elseif n_spikes1 < n_spikes2
    
    assert(isequal(spikyCond, dat2), 'Data is mixed up'); 
    dat2_balanced = spikyCond_balanced;
    dat1_balanced = dat1;
    assert(resampledStructure == 2);
end

end