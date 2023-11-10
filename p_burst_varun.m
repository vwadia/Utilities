%Function p_burst
%NOTE: Calls POISSCDF function in the STATISTICS toolbox
%CALLING:
%[BOB, EOB, SOB]=p_burst(InTrain, StartT, StopT)
%		InTrain: Timestamps of the spike train.
%		StartT and StopT : Time limits for analysis. Spike count between
%			these time limits are used to calculate Average Spike Rate AvgSpkRate
%			for analyzing the complete spike train.
%			Note: Burst results may not be valid outside limits.
%OUTPUTS:
%		BOB: A row vector containing indices for Begining Of Burst.
%		EOB: A row vector containing indices for End Of Burst.
%		SOB: A row vector containing Surprise Of Burst.
%		Note: Spike Train(BOB)gives the actual times. The Spike Train
%			however must be stripped off "zero","Nan" and "Inf"
%PROBLEMS:
%		If you get an error: One or more output arguments 
%		not assigned during call to 'distchck'
%		Change the spike Train dimension by passing
%		a transpose(Spike Train)
% First Version Jan 5, 1998: S.Chenchal Rao
% edited by vwadia 10/2023

function [BOB, EOB, SOB]=p_burst_varun(InTrain, StartT, StopT, Anchor, MinSPInBurst, Signif, AvgSpkRate, MaxXT, doDisplay)
%Returns Spike Index of BOB, EOB abd Surprise Of Burst
%The spike train is a series of timestamps
%******************User Parameters************************
if nargin == 8, doDisplay = false; 
elseif nargin == 7, MaxXT = 50; doDisplay = false; end

if nargin == 3
    Anchor = 50;
    MinSPInBurst = 4;
    Signif = 0.01;
    MaxXT = 50;
    doDisplay = false;
    fprintf('Using default parameters \n\n')
    
end

% fprintf('Anchor: %d \n', Anchor)
% fprintf('MinSPInBurst: %d \n', MinSPInBurst)
% fprintf('Signif: %d \n', Signif)

% MaxXT = 250;%Max Xtra Time
% MaxXT = 10;%Max Xtra Time
MaxXS= 10;%Max Xtra Spikes %10
% MinSPInBurst= 4; %5;%Minimum spkes in a Burst %2
% Anchor=50;%Anchor Time
% Anchor = 500; % decreasing this increases SI
% Signif = 2.5000e-05;
% Signif = 0.01;
UserSI=-log(Signif);
%UserSI = 10;
Tol=1e-300;
%****************Spike Train Properties*****************
if(size(InTrain,1))>1
   InTrain=InTrain';
end
SPT=InTrain(InTrain > 0 & InTrain < Inf)';
StopT=max(0,StopT);%traps NaN
StartT=max(0,StartT);%traps NaN
if(~StopT),StopT=max(SPT);end
if(~StartT),StartT=min(SPT);end
minT=min(StartT,StopT);
maxT=max(StartT,StopT);
StartT=minT;StopT=maxT;
Duration=StopT-StartT;
%Average Spike Rate AvgSpkRate
if  exist('AvgSpkRate') ~= 1
    if(~isempty(SPT))
        %Calculate Average spike rate between start and stop time
        AvgSpkRate=(length(find(SPT>= StartT & SPT <= StopT)))/(Duration);
        %if there are no spikes in the selected interval
        %find AvgSpkRate for the entire trial
        if (AvgSpkRate==0)
            AvgSpkRate=(length(SPT)-1)/(max(SPT)-min(SPT));
        end
        %if there are no spikes in the spike train or
        %n spikes in train is less than 4 - changed to minSPInBurst by
        %vwadia 10/2023
        if(AvgSpkRate==0 | length(SPT)<=MinSPInBurst)
            BOB=[];
            EOB=[];
            SOB=[];
            return
        end
    else
        BOB=[];
        EOB=[];
        SOB=[];
        return
    end
end

%MaxSpikes=length(SPT);
MaxSpikes = find(SPT >= StopT,1); % first non-interval spike time

% added by Varun 10/23 - if no spikes after chosen interval prog fails 
if isempty(MaxSpikes)
    MaxSpikes=length(SPT);
end

ISI=diff(SPT(1:MaxSpikes));%Inter Spike Intervals
%################Parameter Initializations##############
%******Flags, Counters, Indices and Rel. OPs************
ISBURST=0;
BNo=1;CurrBNo=0;%Burst No for indexing
MinBOB=5000;%Dummy
MaxEOB=0;%Dummy
OldBOB=0;OldEOB=0;
PrevBOB=0;PrevEOB=0;
CurrBOB=0;CurrEOB=0;
CurrEOB_XS=0;CurrXS=0;CurrXT=0;%Vars for Extra Time
MaxSI=0;
%*******************Iteration vars**********************
Iterate=1;IC=1;%Iteration Counter
FromI=0;ToI=0; %Current portion of Spike Train
%FspAB=1;%First spike After Burst
FspAB = find(SPT >= StartT,1);



Temp=0;Done=0;
%******************Output Arguments*********************
BOB=[];EOB=[];SOB=[];%AvgSpkRateST be set to EMPTY
if FspAB == MaxSpikes,
%     disp('Something wrong with the spktrain, unable to process');
    return
end
%########################################################
while(FspAB <= MaxSpikes-1 | ~Done) % so will only look for bursts in interval given
   Iterate=1;
   while(Iterate)
      %***************FIND EOB****************************
      if (IC==1)
         FromI=FspAB;
      else
         FromI=CurrBOB;
      end
      cISI=cumsum(ISI(FromI:length(ISI)))+Anchor;
      Prob=(poisscdf([1:length(cISI)]', cISI.*AvgSpkRate))+Tol;
      Prob=(1-Prob);SI=-log(Prob);
      %find index that maximizes SI
      Temp=(find(diff(SI)<0));
      if (length(Temp)>1)
         CurrEOB=Temp(min(find(Temp >1))); % maybe make this max? vwadia 10/23
         if(CurrEOB==1 & IC==1)
            FspAB=Temp(min(find(diff(Temp) >MinSPInBurst)))+1;
            if (isempty(FspAB) | FspAB>=MaxSpikes-MinSPInBurst)
               Done=1;
               ISBURST=0;
               Iterate=0;
            end
            break %Break out of Iteration
         end
         CurrEOB_XS=0;Curr_XT=0;
         %check for extra spikes and extra time
         %Find index to next MaxSI
         CurrEOB_XS=min(find(SI > SI(CurrEOB)));
         if(~isempty(CurrEOB_XS))
            CurrXS=CurrEOB_XS-CurrEOB-1;
            CurrXT=SPT(CurrEOB_XS)-SPT(CurrEOB); % but these are extra ms?
            if(CurrXS <= MaxXS & CurrXT <= MaxXT)
               CurrEOB=CurrEOB_XS;
               CurrEOB_XS=0;
            end
         end
      elseif (length(Temp)==1 & ~isempty(Temp))
         CurrEOB=Temp;
      elseif(isempty(Temp))
         %Index to the max 
         CurrEOB=length(SI);
      else
      end
      CurrEOB=CurrEOB+FromI;
      
      %***************FIND BOB****************************
      ToI=FspAB;
      BSPT=SPT(CurrEOB:-1:ToI);
      cISI=cumsum(abs(diff(BSPT)))+Anchor;
      Prob=poisscdf([1:length(cISI)]',cISI.*AvgSpkRate)+Tol;
      Prob=(1-Prob);
      SI=-log(Prob);
      Temp=max(find(SI==max(SI)));
      %What if Temp = [];??
      if (isempty(Temp))
         disp('ERROR finding BOB ==> Temp is EMPTY')
         [Temp]
      end
      CurrBOB=find(SPT==BSPT(Temp+1));
      
      %if diff between CurrEOB and recently found BOB is < criteria
%       CurrEOB-CurrBOB
      if (CurrEOB-CurrBOB) < MinSPInBurst
         ISBURST=0;
         Iterate=0;
         FspAB=CurrEOB+1;
         FromI=FspAB;
         break;%Break out of Iteration loop
      end
      %Check for convergence among 3 values for each
      if(OldBOB==CurrBOB & OldEOB==CurrEOB )
         %Converged
         %disp(['Burst Number ',num2str(BNo),' Converged in ',num2str(IC),' iterations'])
         %disp(['BOB Index ',num2str(CurrBOB),' EOB Index 'num2str(CurrEOB)])
         Iterate=0;
         ISBURST=1;
         break
      else
         IC=IC+1;
         PrevBOB=OldBOB;
         PrevEOB=OldEOB;
         OldBOB=CurrBOB;
         OldEOB=CurrEOB;
      end
      %find max and min
      CurrBNo=max(CurrBNo,BNo);
      if(CurrBNo)
         MaxEOB=max(CurrEOB,MaxEOB);
         MinBOB=min(CurrBOB,MinBOB);
      end
      if(IC==10)
         MaxEOB=CurrEOB;MinBOB=CurrBOB;
      elseif(IC>20)
         CurrEOB=MaxEOB;CurrBOB=MinBOB;
         Iterate=0;
         ISBURST=1;
      else
      end
      %disp(['End of Iteration cycle : ',num2str(IC-1)])
      
   end%while(Iterate) 
   if(ISBURST)
      %CHECK CRITERIA
      MaxSI=-log(1-(poisscdf(CurrEOB-CurrBOB,(SPT(CurrEOB)-SPT(CurrBOB))*AvgSpkRate)));
      if(CurrEOB-CurrBOB >= MinSPInBurst & MaxSI>UserSI)
         BOB(BNo)=CurrBOB;
         EOB(BNo)=CurrEOB;
         SOB(BNo)=MaxSI;
         BNo=BNo+1;
      end
      FspAB=CurrEOB+1;
      CurrBOB=FspAB;
      IC=1;
   else
      IC=1;
   end
   %Check limits
   if(FspAB >= MaxSpikes-2)
      Done=1;
      Iterate=0;
      break
   end
end%while(FspAB <= MaxSpikes-1)
%****************************DISPLAY***********************************
if doDisplay,
clf
colors_='rbm';
colors_=repmat(colors_,1,ceil(length(EOB)/length(colors_)));
%It takes less time to put '+' than draw line/ticks
%h=plot(SPT,1,'k+');
set(line([SPT SPT],[0.95 1.05]),'color',[0 0 0],'linewidth',0.1);
hold on
axis([0 max(SPT) 0 2])
set(findobj('type','axes'),'color',[1 1 1],'ytick',[],'box','on')
for EB=1:length(EOB)
   plot(SPT(BOB(EB):EOB(EB)),1.1,strcat(colors_(EB),'+'));
end
end
%This part depends on the user...
% MIN INTER BURST INTERVAL
%InterBDiff=SPT(BOB(2:length(BOB)))-SPT(EOB(1:length(EOB)-1));


