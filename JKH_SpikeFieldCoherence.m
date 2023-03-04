function SpikeField = JKH_SpikeFieldCoherence(Raster,LFP,LFPwindow);

paramsIn.Fs=1000;
paramsIn.tapers = [3 5]; 
paramsIn.tapers=[4 7]; % TW K;   K<=2*TW-1    MAIN/DEFAULT
paramsIn.fpass=[0.1 100]; % frequency range of interest
paramsIn.eSpikeField=[2 0.01]; 
paramsIn.pad=1; %-1 none, 0 to 512, 1 to 1024 ...  (2^x)


spikenumber = 0;
stLFP = 0;
stLFPenergy = 0;

for j = 1:size(Raster,1);
    
    for k = (1+LFPwindow):(size(Raster,2)-LFPwindow);
        if Raster(j,k);
            spikenumber = spikenumber + Raster(j,k);
            stLFP = stLFP + Raster(j,k) * LFP(j,k-LFPwindow:k+LFPwindow);
            %[stLFPenergy_temp, frequencies] = pmtm(LFP(j,k-LFPwindow:k+LFPwindow),3,length(LFP(j,k-LFPwindow:k+LFPwindow)),1000);
            [stLFPenergy_temp, frequencies] = mtspectrumc(LFP(j,k-LFPwindow:k+LFPwindow)',paramsIn);
            stLFPenergy = stLFPenergy + Raster(j,k)*stLFPenergy_temp;
        end
    end
end

SpikeField.STALFP = stLFP/spikenumber;
SpikeField.STAenergy = mtspectrumc(stLFP'/spikenumber,paramsIn);
SpikeField.stLFPenergy = (stLFPenergy/spikenumber);
SpikeField.frequencies = frequencies;
SpikeField.SFC = SpikeField.STAenergy./stLFPenergy;