% Test the performance of the different decoders by generated some 
% test cases. This will be used to benchmark performance. 


%% Test case 1
categories        = [1 2 3 4];
lambda            = [1 10 21 31]; 
nrTrials          = 52;
nrFixPerTrial     = [6:12];

availableDecoders = { 'poisson-nb',...   % Poisson Naive Bayes
                      'multinomial',...  % Multinomial logistic regression
                      'dis-analysis'};   % Discriminant analysis

availableDecoders = { 'multinomial'}; 

nrPoints = 10000;
bins     = 100;
% Visualize the distributions with these parameters
h = figure('NumberTitle','off','Name','Test Cases For Decoders');
ax(1) = subplot(4,2,1,'Parent',h); 
[counts, centers] = hist(random('Poisson',lambda(categories(1)),1,nrPoints),bins);
bar(ax(1),centers,counts/sum(counts),0.8); ylabel(ax(1),'Probability');
title(['Category 1, \lambda = ' num2str(lambda(1))]); xlabel('Spike Count');

ax(2) = subplot(4,2,2,'Parent',h); 
[counts, centers] = hist(random('Poisson',lambda(categories(2)),1,nrPoints),bins);
bar(ax(2),centers,counts/sum(counts),0.8);
title(['Category 2, \lambda = ' num2str(lambda(2))]); xlabel('Spike Count');

ax(3) = subplot(4,2,3,'Parent',h);
[counts, centers] = hist(random('Poisson',lambda(categories(3)),1,nrPoints),bins);
bar(ax(3),centers,counts/sum(counts),0.8);
title(['Category 3, \lambda = ' num2str(lambda(3))]); xlabel('Spike Count');ylabel(ax(3),'Probability');


ax(4) = subplot(4,2,4,'Parent',h); 
[counts, centers] = hist(random('Poisson',lambda(categories(4)),1,nrPoints),bins);
bar(ax(4),centers,counts/sum(counts),0.8);
title(['Category 4, \lambda = ' num2str(lambda(4))]); xlabel('Spike Count');


xlim(ax(1),[0 max(xlim(ax(4)))]);
linkaxes(ax,'x');


%% Simulate the trials, given the number of fixations per trial
trials      = [];
fixCategory = [];
for i=1:nrTrials   
    nrFixThisTrial = nrFixPerTrial(randi(numel(nrFixPerTrial),1));
    trials         = [trials, i*ones(1,nrFixThisTrial)];
    fixCategory    = [fixCategory, categories(randi(numel(categories),1,nrFixThisTrial))];
end

% Generate an observed firing rate
FR = cellfun(@(x) random('Poisson',lambda(categories(x)),1,1),... 
                                    num2cell(fixCategory));

confusionMat = []; 
ax = [];
% Try decoder
for i = 1:length(availableDecoders)
    [MDL{i},confusionMat{i}] = decodeCategory(FR',fixCategory',true(length(FR),1),...
                                        availableDecoders{i}, trials');
    
    normparam = repmat(sum(confusionMat{i},2),1,size(confusionMat{i},2));                          
    ax(4+i) = subplot(4,2,4+i,'Parent',h); imagesc(confusionMat{i}./normparam); colorbar;
                            title([availableDecoders{i},', MI: ' num2str(computeMI(confusionMat(i)))]);
                            xlabel('Predicted'); ylabel('Ground Truth');
end

ax(8) = subplot(4,2,8,'Parent',h); 
bar(1:length(availableDecoders),100*cellfun(@(x) trace(x), confusionMat)/length(FR)',0.4);
ylim(ax(8),[0 100]); ylabel('Decoder Accuracy (% correct)');
set(ax(8), 'XTickLabel', availableDecoders);
