% OUTPUTS
%  D - PSTH
%  D1 - 1ms PSTH

function [D,D1,times]=cellfile2rasterVarun(loadpath,timelimits,Binsize,TTLid,events)



% x=load(loadpath); % loads a cells.mat file which has a 'spikes' field

timeStampArray= loadpath.spikeTimeStamps;%x.spikes(x.spikes(:,2)==clusterID,3); % x = #, ClusterID, times of spikes, #, 

ttltimes=events(events(:,2)==TTLid,1); % timestamps TTLID = 1 = image onset

 % spike times, imageONtimes, timewindow, binsize
 [D,D1]=Utilities.extractRASTERSfromTimestamps(timeStampArray,ttltimes,timelimits,Binsize);
 
 % [D, D1] = extractRASTERSfromTimestamps(spikeTimeStampsMS,
 % ImageOnTimes,timelimits, Binsize);

    
times=(timelimits(1):0.001:(timelimits(2)+0.001))-0.001;
    

