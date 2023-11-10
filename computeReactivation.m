function names = computeReactivation(params, alpha)
% Function to assess whether or not a given cell has reactivated during imagination
% Takes in params struct that provides the options and computes accordingly
% vwadia June2023


ITOnly = params.ITOnly;
BlineType = params.BlineType;

if params.useThreshold
    perStimBase = params.perStim;
    n_stdDevs = 5;
end


load([sessID{ss} filesep 'RecallData_NoFreeRec.mat'])

strctCELL = struct2cell(strctCells')';
switch BlineType
    case 1
        BTimeCourse = RecallData.EncodingTimeCourse;
        b_end = 1500;
    case 2
        BTimeCourse = RecallData.PreCRBaselineTimeCourse;
        b_end = 5000;
    case 3
        BTimeCourse = RecallData.PreTrialBaselineTimeCourse;
        b_end = 5000;
end

CRTimeCourse = RecallData.CRTimeCourse;

if ITOnly
    IT_Cells = cellfun(@(x) strcmp(x, 'RFFA') || strcmp(x, 'LFFA'), strctCELL(:, 4));
    %         full_strctCELL = strctCELL;
    strctCELL = strctCELL(IT_Cells, :);
    strctCells = strctCells(IT_Cells);
    
    BTimeCourse = BTimeCourse(IT_Cells, :);
    CRTimeCourse = CRTimeCourse(IT_Cells, :);
    
    EncTimeCourse = RecallData.EncodingTimeCourse(IT_Cells, :);
end


end