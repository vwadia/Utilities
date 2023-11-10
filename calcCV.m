%
%coefficient of variation CV
%
%note sensitivity to rate changes, assumes a stationary rate of the underlying process that generates the spike train (its rate).
%see calcCV2.m for an alternative
%
%adapted from eq 9.10 p322 in Gabiani&Koch99

function CV = calcCV(ISI_inSec)

CV = std(ISI_inSec)/mean(ISI_inSec);
