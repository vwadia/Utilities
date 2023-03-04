%% Single cell/Population decoding
% startStop     = sessioncellinfo.startStop;
% neuralData    = sessioncellinfo.neuraldata;
% nrLearnTrials = sessioncellinfo.nrLearnTrials;
% cellinfo      = sessioncellinfo.cellInfo;
% nrCells       = size(cellinfo,2);



MDL                = [];
confusionMat       = [];
whichCells         = [22];
decoder            = {'poisson-nb',...   % Poisson Naive Bayes
                      'svm',...          % Support vector machines
                      'multinomial',...  % Multinomial logistic regression
                      'dis-analysis'};   % Discriminant analysis
                  
decoder            = {'poisson-nb'};

startoflook        = startStop(:,1);
endoflook          = startStop(:,2);
trials             = startStop(:,4);
lookDuration       = (endoflook-startoflook)/1e6;

decodingCriteria   = [];
decodingCriteria(:,1) = startStop(:,4)<=nrLearnTrials; % Use only the learning strials
decodingCriteria(:,2) = lookDuration>0.1; % Use only the learning strials

decoderBinSize =  0.3; % in seconds
stepSize       =  0.05;
startofWindow  = -0.5:stepSize:0.75;
endofWindow    = -0.5+decoderBinSize:stepSize:0.75+decoderBinSize;
window         = [startofWindow' endofWindow'];

window         = [-0.5 0;0.1 0.5]*1e6;
baselineWindow  = 1;

confusionMat = [];
for k=1:length(decoder)
    for i=1:length(whichCells)
        %for j=1:size(window,1)
            [MDL{k}{i},confusionMat{k}{i}]       = singleCellDecode(startStop,...
                                                        neuralData,...
                                                        whichCells(i),...
                                                        window,...
                                                        decoder{k}, ...
                                                        decodingCriteria,...
                                                        baselineWindow);
        %end
        fprintf('%s\n',['Fit [' decoder{k} '], Cell ' num2str(i) '/' num2str(nrCells)]);
    end
end
%% Convert the confusion matrix to percent
% accuracy = [];
% for k=1:length(confusionMat{1})
%     for i=1:length(confusionMat{1}{k})
%         [accuracy{k}(i,:), ~] = computeDecodingAccuracy(confusionMat{1}{k}{i});
%     end
% end
% 

