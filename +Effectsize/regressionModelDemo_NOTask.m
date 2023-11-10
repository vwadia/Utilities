%
% regressionModel demo
%
% same data as in ndtDecodingDemo_NOTask.m
%

%%
load('W:\results\ndtdemo\NOcells_ndtDemo.mat', 'cellStats_forDemo');
cellsToProcess = cellStats_forDemo;

pStart = 0;     % in sec
pEnd   = 3;       % in sec

stepSize = 100 / 1000; %sec
binSize  = 500 / 1000;%sec
binStartTS = (pStart:stepSize:pEnd-binSize) .* 1e6;
binEndTS = (pStart+binSize:stepSize:pEnd) .* 1e6;

%% fit model to all cells
methodToUse=1; % 1 jerry method, 2 mes1way,  3 ANOVA

% each row is a cell; each colum a timepoint
omega2All = nan(length(cellsToProcess), length(binStartTS)); 

useOnlySigCell=0;
nrCellsUsed=0;
% loop over all cells of this task
for k=1:length(cellsToProcess)  % loop over all cells
    cellStats = cellsToProcess(k);

    %==== prepare trial data (task-specific data)
    timestampsOfCell = cellStats.timestamps;  % timestamp of each spike of this cell
    stimuliCategories = cellStats.stimuliCategories;    % 1,2,3,4,5  (there are 5 cateogires)
    periodsToUse = cellStats.periods;  % from/to timestamps of the trials
    
    % to enable binary classification, decode here category 5 vs all only (1=houses,2=landscapes,3=cars,4=phones,5=animals)
    stimuliCategories_binary = stimuliCategories;
    
    % only use tuned cells?
    [pAnova,ANOVATAB] = anova1(cellStats.countStimulus, stimuliCategories,'off');
    if pAnova>0.05  & useOnlySigCell
        continue;
    end
    
    nrCellsUsed=nrCellsUsed+1;
    %stimuliCategories_binary(find(stimuliCategories==1)) = 1;
    %stimuliCategories_binary(find(stimuliCategories==2)) = 1;
    %stimuliCategories_binary(find(stimuliCategories==3)) = 0;
    %stimuliCategories_binary(find(stimuliCategories==4)) = 0;
    %stimuliCategories_binary(find(stimuliCategories==5)) = 0;
    stimuliCategories_binary(find(stimuliCategories_binary~=1)) = 2;

    %=== bin spike counts (all trials)
    
    trialNum = size(periodsToUse,1);
    
    windowCounts = nan(trialNum, length(binStartTS)); 
    
    for trialNr = 1:trialNum
       tStart = binStartTS + periodsToUse(trialNr, 2); 
       tEnd = binEndTS + periodsToUse(trialNr, 2); 
       
       for binNr = 1:length(tStart)
            windowCounts(trialNr,binNr) = sum(timestampsOfCell >= tStart(binNr) & timestampsOfCell <= tEnd(binNr)); 
       end
    end
    
    %% run model for each bin  
    
    %x = stimuliCategories_binary;  % binary labels
    
    x = stimuliCategories; % 1-5 categories
    
    parfor binNr = 1:length(binStartTS)
        es=0;
        y = windowCounts(:,binNr); % binned firing rate

        switch(methodToUse)
            case 1
                %=== speed-improved version
                
                % y is spike counts; x is category label (categorical)
                [ es ] = calcOmiga2Fast ( y,x );   % calculate effect size (1-way ANOVA)
        
            case 2
                %=== using effect size toolbox (same to calcOmiga2Fast, but slow)
                % HOWEVER, if the design gets more complicated (repeated measure, random factors etc) this has to be used as the fast version does not support this.
                [~,idx]=sort(x);
                
                res = mes1way(y(idx),'omega2','group',x(idx));
                es = res.omega2;
 
            case 3
                %=== using ANOVA
                [pAnova,ANOVATAB] = anova1(y,x,'off');
                MSE = ANOVATAB{3,4};
                SStot = ANOVATAB{4,2};
                SS1 = ANOVATAB{2,2};
                df = ANOVATAB{2,3};
                es = (SS1-df*MSE)/(SStot+MSE);
        end
        
        omega2All(k,binNr) = es;
    end
    
    disp(['Progress: k=' num2str(k)]);
end


%% 
isnan=2;
[m,sd,se,n]=calcMeanSEOfSample(omega2All,isnan);

omega2Av = mean( omega2All );
t=(binStartTS+binSize/2)/1000;

figure;
subplot(2,2,1);
plot( t, m, 'b', t, m+se, 'b--', t, m-se, 'b--');

ylabel('\omega^2');
xlabel('time [ms]');

title(['nr cell used=' num2str(nrCellsUsed) ' Method:' num2str(methodToUse)]);

