

function [D,D1]=extractRASTERSfromTimestamps(timeStampArrayOUTnownow,ttltimes,timelimits,Binsize)



% conversion to ms happens here
D1(round((timelimits(2)-timelimits(1))*1000+2),length(ttltimes))=0; % matrix of 0s this large
D(round((timelimits(2)-timelimits(1))*1000+2),length(ttltimes))=0;

for ii=l(ttltimes) % goes from 1 to length(ttltimes)
    
    % timestamparrayOUTnownow = spike times
    % which = all the spikes in a window (timelimits(1) to timelimits(2)) around the TTL time 
    Which= (find(timeStampArrayOUTnownow>(ttltimes(ii)+timelimits(1)*1e6)      &   timeStampArrayOUTnownow<(ttltimes(ii)+timelimits(2)*1e6)));
    
   
    timeS=(double(timeStampArrayOUTnownow(Which))-double(ttltimes(ii)))/1e6+timelimits(1)*-1+0.001;
    timeS2=round(timeS*1000); % in ms
    try
        if ~isempty(timeS2)
            D1(timeS2,ii)=1;
            
            
%             D(:,ii)=(smooth(D1(:,ii),Binsize)*Binsize)*(1000/Binsize);
            D(:, ii)=(smooth(D1(:,ii),Binsize)*1000); % does this make a difference?
        end
    catch
%         keyboard
    end
    
    
end

% smooth makes the ends all crazy - so need to 0 them (why?)
% first binsize/2 rows (timestamps)
D(1:round(Binsize/2),:)=0;

% last binsize/2 rows (timestamps)
D(floor((timelimits(2)-timelimits(1))*1000-round(Binsize/2)):floor((timelimits(2)-timelimits(1))*1000+2),:)=0;