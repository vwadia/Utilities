function [b_visualResponsive,p_visualResponsive,OrangeMatrixMinusBaselineNormalized,OrangeMatrixResponsiveMinusBaselineNormalized] = orangeplot_FOB(Monkeys,Dates)
    TimeWindowResponse = [50, 300];
    TimeWindowBaseline = [0, 50];

    Paradigms = {'_Passive_Fixation_New_FOB.mat'};
    strct = load([Monkeys{1} Dates{1} Paradigms{1}]);
    b_visualResponsive = nan(length(Dates),1);
    p_visualResponsive = nan(length(Dates),1);
    p_visualResponsive_kruskalwallis = nan(length(Dates),1);

    b_faceSelective = nan(length(Dates),1);
    p_faceSelective = nan(length(Dates),1);
    for DateIndex = 1:length(Dates)
        strct = load([Monkeys{1} Dates{DateIndex} Paradigms{1}]);
        StartIndex = find(strct.strctUnit.m_aiPeriStimulusRangeMS==TimeWindowResponse(1));
        EndIndex = find(strct.strctUnit.m_aiPeriStimulusRangeMS==TimeWindowResponse(2));
        StartIndexBaseline = find(strct.strctUnit.m_aiPeriStimulusRangeMS==TimeWindowBaseline(1));
        EndIndexBaseline = find(strct.strctUnit.m_aiPeriStimulusRangeMS==TimeWindowBaseline(2));
        TrialsBaseline = mean(strct.strctUnit.m_a2bRaster_Valid(:,StartIndexBaseline:EndIndexBaseline),2);
        TrialsResponse = mean(strct.strctUnit.m_a2bRaster_Valid(:,StartIndex:EndIndex),2);
        [b_visualResponsive(DateIndex),p_visualResponsive(DateIndex)] = ttest2(TrialsBaseline,TrialsResponse);
        p_visualResponsive_kruskalwallis(DateIndex) = kruskalwallis(TrialsResponse,strct.strctUnit.m_aiStimulusIndexValid,'off');
        
        b_FaceTrial = strct.strctUnit.m_a2bStimulusToCondition(strct.strctUnit.m_aiStimulusIndexValid,1);
        TrialsFaceResponse = mean(strct.strctUnit.m_a2bRaster_Valid(b_FaceTrial,StartIndex:EndIndex),2);
        TrialsNonFaceResponse = mean(strct.strctUnit.m_a2bRaster_Valid(not(b_FaceTrial),StartIndex:EndIndex),2);
        FSI(DateIndex) = (mean(TrialsFaceResponse)-mean(TrialsNonFaceResponse))/(mean(TrialsFaceResponse)+mean(TrialsNonFaceResponse));
        [b_faceSelective(DateIndex),p_faceSelective(DateIndex)] = ttest2(TrialsFaceResponse,TrialsNonFaceResponse);
    end
    b_visualResponsive(isnan(b_visualResponsive)) = 0;
    b_visualResponsive = boolean(b_visualResponsive);
    b_faceSelective(isnan(b_faceSelective)) = 0;
    b_faceSelective = boolean(b_faceSelective);

    DatesResponsive = Dates(b_visualResponsive);
    DatesResponsive = Dates(p_visualResponsive_kruskalwallis<0.05);

    DatesResponsive = Dates(b_faceSelective);
    DatesResponsive = Dates(FSI>0.33);

    %All dates
    OrangeMatrix = nan(length(Dates),strct.strctUnit.m_iNumStimuli);
    OrangeMatrixMinusBaseline = nan(length(Dates),strct.strctUnit.m_iNumStimuli);
    for DateIndex = 1:length(Dates)
        strct = load([Monkeys{1} Dates{DateIndex} Paradigms{1}]);
        StartIndex = find(strct.strctUnit.m_aiPeriStimulusRangeMS==TimeWindowResponse(1));
        EndIndex = find(strct.strctUnit.m_aiPeriStimulusRangeMS==TimeWindowResponse(2));
        StartIndexBaseline = find(strct.strctUnit.m_aiPeriStimulusRangeMS==TimeWindowBaseline(1));
        EndIndexBaseline = find(strct.strctUnit.m_aiPeriStimulusRangeMS==TimeWindowBaseline(2));


        
%         OrangeMatrix(DateIndex,:) = mean(strct.strctUnit.m_a2fAvgFirintRate_Stimulus(:,StartIndex:EndIndex),2)';
%         OrangeMatrix(DateIndex,:) = mean(strct.strctUnit.m_a2fAvgFirintRate_Stimulus(:,StartIndex:EndIndex),2)';
% 
%         Baseline = nanmean(nanmean(strct.strctUnit.m_a2fAvgFirintRate_Stimulus(:,StartIndexBaseline:EndIndexBaseline)));
%         OrangeMatrixMinusBaseline(DateIndex,:) = OrangeMatrix(DateIndex,:) - Baseline;
%         
        LFPValid = strct.strctUnit.m_a2fLFP(strct.strctUnit.m_abValidTrials,:);
        LFPBaseline = -mean(mean(LFPValid(:,StartIndexBaseline:EndIndexBaseline),2),1);
        for StimulusIndex = 1:strct.strctUnit.m_iNumStimuli
            StimulusTrialIndices = find(strct.strctUnit.m_aiStimulusIndexValid == StimulusIndex);
            LFPResponsesTrials = LFPValid(StimulusTrialIndices,StartIndex:EndIndex);
            b_isWithinBoundsLFPResponsesTrials = all(LFPResponsesTrials<0.8,2);
            LFPResponses(DateIndex,StimulusIndex) = -mean(mean(LFPResponsesTrials(b_isWithinBoundsLFPResponsesTrials,:),2),1);
        end
         OrangeMatrix(DateIndex,:) = LFPResponses(DateIndex,:);
         OrangeMatrixMinusBaseline(DateIndex,:) = LFPResponses(DateIndex,:) - LFPBaseline;

        
    end
    OrangeMatrixNormalized = (OrangeMatrix)./repmat(max(OrangeMatrix,[],2),[1 size(OrangeMatrix,2)]);
    OrangeMatrixMinusBaselineNormalized = (OrangeMatrixMinusBaseline)./repmat(max(OrangeMatrixMinusBaseline,[],2),[1 size(OrangeMatrixMinusBaseline,2)]);
    figure(1)
    clf

    %I = imagesc(OrangeMatrixNormalized,[-max(max(abs(OrangeMatrixNormalized))),max(max(abs(OrangeMatrixNormalized)))]);
    I = imagesc(OrangeMatrixMinusBaselineNormalized,[-max(max(OrangeMatrixMinusBaselineNormalized)),max(max(OrangeMatrixMinusBaselineNormalized))]);

    orangemap = esa(300);
    [WhiteColor, Whitepos] = max(sum(orangemap,2));
    orangemap = orangemap([1:Whitepos round(linspace(Whitepos+1,size(orangemap,1)-2,Whitepos-1))],:);
    colormap(orangemap)

% Only reponsive dates
    OrangeMatrixResponsive = nan(length(DatesResponsive),strct.strctUnit.m_iNumStimuli);
    OrangeMatrixResponsiveMinusBaseline = nan(length(DatesResponsive),strct.strctUnit.m_iNumStimuli);

    for DateIndex = 1:length(DatesResponsive)
        strct = load([Monkeys{1} DatesResponsive{DateIndex} Paradigms{1}]);
        StartIndex = find(strct.strctUnit.m_aiPeriStimulusRangeMS==TimeWindowResponse(1));
        EndIndex = find(strct.strctUnit.m_aiPeriStimulusRangeMS==TimeWindowResponse(2));
        StartIndexBaseline = find(strct.strctUnit.m_aiPeriStimulusRangeMS==TimeWindowBaseline(1));
        EndIndexBaseline = find(strct.strctUnit.m_aiPeriStimulusRangeMS==TimeWindowBaseline(2));

        OrangeMatrixResponsive(DateIndex,:) = mean(strct.strctUnit.m_a2fAvgFirintRate_Stimulus(:,StartIndex:EndIndex),2)';
        Baseline = nanmean(nanmean(strct.strctUnit.m_a2fAvgFirintRate_Stimulus(:,StartIndexBaseline:EndIndexBaseline)));
        OrangeMatrixResponsiveMinusBaseline(DateIndex,:) = OrangeMatrixResponsive(DateIndex,:) - Baseline;
    end
    OrangeMatrixResponsiveNormalized = (OrangeMatrixResponsive)./repmat(max(OrangeMatrixResponsive,[],2),[1 size(OrangeMatrixResponsive,2)]);
    OrangeMatrixResponsiveMinusBaselineNormalized = (OrangeMatrixResponsiveMinusBaseline)./repmat(max(OrangeMatrixResponsiveMinusBaseline,[],2),[1 size(OrangeMatrixResponsiveMinusBaseline,2)]);

    figure(2)
    clf
    %I = imagesc(OrangeMatrixResponsiveNormalized,[-max(max(abs(OrangeMatrixResponsiveNormalized))),max(max(abs(OrangeMatrixResponsiveNormalized)))]);
    I = imagesc(OrangeMatrixResponsiveMinusBaselineNormalized,[-max(max(OrangeMatrixResponsiveMinusBaselineNormalized)),max(max(OrangeMatrixResponsiveMinusBaselineNormalized))]);

    orangemap = esa(300);
    [WhiteColor, Whitepos] = max(sum(orangemap,2));
    orangemap = orangemap([1:Whitepos round(linspace(Whitepos+1,size(orangemap,1)-2,Whitepos-1))],:);
    colormap(orangemap)

    
end