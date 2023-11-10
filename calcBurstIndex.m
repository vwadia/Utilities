%
% calculates the burst index (BI) of a spike train, provided as a sequence of interspike intervals (ISI)
%
% this is the ratio of ISIs<10ms relative to ISIs>10ms
%
%used like this in Viskontas et al 2007, Favre et al 1999 Surgical Neurology, Legendry&Salcman 1985
%
%urut/jan13
function BI = calcBurstIndex(ISI_inSec)

lim=10/1000;   %in ms  less then 10ms

lowerLim=1/1000; % ISIs that are too small to be realistic ignore

BI = length(find(ISI_inSec<=lim & ISI_inSec>lowerLim))/length(find(ISI_inSec>lim & ISI_inSec>lowerLim));
