function [catOrder, anovaType] = makeObjCatLabsScreening(subID, order)
% This function is used primarily for the screening task
% It takes in the subject ID from that days taskStruct and the order, returning 
% category labels for use in an anova or plotting
% 
% INPUTS:
%     1. subID
%     2. order
%     
% OUTPUTS:
%     1. category labels
%     2. anova type
%     
% vwadia July2021

% % ------------ P62CS April 17th2019 full Param Obj screen ------------------
if strcmp(subID, '62')
    anovaType = 'CategoryObject';
    faceInds = 412:612;
    objInds = [217:411 694:768 874:1122 1246:1593];
    textInds = [796:873 1220:1245];
    vegInds = [613:693 1123:1219];
    animInds = [1:216 769:795];
    
    catOrder = zeros(length(order), 1);
    catOrder(ismember(order, faceInds)) = 1;
    catOrder(ismember(order, textInds)) = 2;
    catOrder(ismember(order, vegInds)) = 3;
    catOrder(ismember(order, animInds)) = 4;
    catOrder(ismember(order, objInds)) = 5;
% % ------------------------ P71CS November 18th Category Screen ---------
elseif strcmp(subID, 'P71CS') 
    anovaType = 'CategoryObject';
    bodyInds = [1:10];
    faceInds = [11:24];
    fruitInds = [25:34];
    handInds = [35:44];
    technoInds = [45:54];
    
    catOrder = zeros(length(order), 1);
    catOrder(ismember(order, faceInds)) = 1;
    catOrder(ismember(order, bodyInds)) = 2;
    catOrder(ismember(order, fruitInds)) = 3;
    catOrder(ismember(order, handInds)) = 4;
    catOrder(ismember(order, technoInds)) = 5;

% % ------------------------ P71CS November 21st Recall Screen ------------
elseif strcmp(subID, 'P71CS_Object')
    anovaType = 'CategoryObject';
    faceInds = 64:97;
    objInds = [35:63 125:137 139 159:200];
    textInds = [117:124 156:158];
    vegInds = [98:116 140:155];
    animInds = [1:34 138];
    
    catOrder = zeros(length(order), 1);
    catOrder(ismember(order, faceInds)) = 1;
    catOrder(ismember(order, textInds)) = 2;
    catOrder(ismember(order, vegInds)) = 3;
    catOrder(ismember(order, animInds)) = 4;
    catOrder(ismember(order, objInds)) = 5;


% % ------------------------ P71CS November 23rd Large Object Screen ------
elseif strcmp(subID, 'P71_large')
    anovaType = 'CategoryObject';
    faceInds = 116:191;
    objInds = [69:115 220:229 259:299 361:434];
    textInds = [239:258 351:360];
    vegInds = [192:219 300:350];
    animInds = [1:68 230:238];
    
    catOrder = zeros(length(order), 1);
    catOrder(ismember(order, faceInds)) = 1;
    catOrder(ismember(order, textInds)) = 2;
    catOrder(ismember(order, vegInds)) = 3;
    catOrder(ismember(order, animInds)) = 4;
    catOrder(ismember(order, objInds)) = 5;


% % ------------------------ P71CS November 24th Recall Screen ------------
elseif strcmp(subID, 'P71CS_RecScreen2')
    anovaType = 'CategoryObject';
    % sampled from 1224 object set
    faceInds = 43:60;
    objInds = [21:42 61:64 75:102];
    vegInds = [65:74];
    animInds = [1:20];
    
    catOrder = zeros(length(order), 1);
    catOrder(ismember(order, faceInds)) = 1;
    catOrder(ismember(order, vegInds)) = 2;
    catOrder(ismember(order, animInds)) = 3;
    catOrder(ismember(order, objInds)) = 4;


% % ------------------------ P71CS November 25th Fast Object Screen ------
elseif strcmp(subID, 'P71CS_Fast')
    anovaType = 'CategoryObject';
    faceInds = 134:210;
    objInds = [85:133 236:255 283:356 409:500];
    textInds = [264:282 400:408];
    vegInds = [211:235 357:399];
    animInds = [1:84 256:263];
        
    catOrder = zeros(length(order), 1);
    catOrder(ismember(order, faceInds)) = 1;
    catOrder(ismember(order, textInds)) = 2;
    catOrder(ismember(order, vegInds)) = 3;
    catOrder(ismember(order, animInds)) = 4;
    catOrder(ismember(order, objInds)) = 5;


% % ------------------------ P73CS March 25th category screen -------------------
elseif strcmp(subID, 'P73CS')
    anovaType = 'CategoryObject';
    
    faceInds = [1:2:70]';
    textInds = [2:2:70]';
    placeInds = [71:87]';
    scrambledInds = [88:104]';
    objInds = [105:120]';
    
    catOrder = zeros(length(order), 1);
    catOrder(ismember(order, faceInds)) = 1;
    catOrder(ismember(order, textInds)) = 2;
    catOrder(ismember(order, placeInds)) = 3;
    catOrder(ismember(order, scrambledInds)) = 4;
    catOrder(ismember(order, objInds)) = 5;


% % --------------------- P73CS March 26th SA Face screen --------------
elseif strcmp(subID, 'P73CS_Full')
    anovaType = 'SingleCategory';
    catOrder = ones(length(order), 1);
    labels = catOrder;


% % ------------ P73CS March28th full Param Obj screen ------------------
elseif strcmp(subID, 'P73CS_ParamObj')
    anovaType = 'CategoryObject';
    faceInds = 412:612;
    objInds = [217:411 694:768 874:1122 1246:1593];
    textInds = [796:873 1220:1245];
    vegInds = [613:693 1123:1219];
    animInds = [1:216 769:795];
    
    catOrder = zeros(length(order), 1);
    catOrder(ismember(order, faceInds)) = 1;
    catOrder(ismember(order, textInds)) = 2;
    catOrder(ismember(order, vegInds)) = 3;
    catOrder(ismember(order, animInds)) = 4;
    catOrder(ismember(order, objInds)) = 5;


% ------------------------P73CS AIC Screen March 28th --------------------
elseif strcmp(subID, 'P73CS_LL_AIC')
    anovaType = 'CategoryObject';
    faceInds = [1:2:70]';
    textInds = [2:2:70]';
    placeInds = [71:85]';
    objInds = [86:100]';
    
    catOrder = zeros(length(order), 1);
    catOrder(ismember(order, faceInds)) = 1;
    catOrder(ismember(order, textInds)) = 2;
    catOrder(ismember(order, placeInds)) = 3;
    catOrder(ismember(order, objInds)) = 4;


% ------------------------ P73CS AIC ReScreen March 28th -----------------
elseif strcmp(subID, 'P73CS_AICReScreen')
    anovaType = 'CategoryObject';
    faceInds = [1:2:10]';
    textInds = [2:2:10]';
    placeInds = [11:12]';
    objInds = [13:15]';
    
    catOrder = zeros(length(order), 1);
    catOrder(ismember(order, faceInds)) = 1;
    catOrder(ismember(order, textInds)) = 2;
    catOrder(ismember(order, placeInds)) = 3;
    catOrder(ismember(order, objInds)) = 4;


% -------------------- P73CS March 31st Face view screenings---------------
% Directions are from the observers viewpoint eg. 'left' = left from my
% perspective looking at the photo
elseif strcmp(subID, 'P73CS_FWFast')
    anovaType = 'CategoryObject';
    front = [1:8:200];
    halfLeft = [2:8:200];
    fullLeft = [3:8:200];
    halfRight = [4:8:200];
    fullRight = [5:8:200];
    lookUp = [6:8:200];
    lookDown = [7:8:200];
    backOfHead = [8:8:200];
    objects = [201:232];
    catOrder = zeros(length(order), 1);
    catOrder(ismember(order, front)) = 1;
    catOrder(ismember(order, halfLeft)) = 2;
    catOrder(ismember(order, fullLeft)) = 3;
    catOrder(ismember(order, halfRight)) = 4;
    catOrder(ismember(order, fullRight)) = 5;
    catOrder(ismember(order, lookUp)) = 6;
    catOrder(ismember(order, lookDown)) = 7;
    catOrder(ismember(order, backOfHead)) = 8;
    catOrder(ismember(order, objects)) = 9;
% elseif strcmp(subID, 'P74CS_AIC') % per identity
%     anovaType = 'CategoryIdentity';
%     identityInds = [repelem(1:30, 18)'; repelem(16, 6)'; repelem(25, 6)'; repelem(17, 6)'];
%     placeInds = repelem(31, 72)'; 
%     objInds = repelem(32, 90)';
%     
%     catOrder = [identityInds; placeInds; objInds];
% -------------------- P75CS Sept 2nd Fingerprint Screen ------------------
%                                     AND
% -------------------- P76CS All Screens (4 of them) ----------------------
%                                     AND
% -------------------- P77CS Fingerprint Screen ----------------------%                                     
%                                   AND
% -------------------- P78CS Fingerprint Screens ----------------------%                                   
%                                   AND
% -------------------- P79CS Recall Screens & ReScreens -------------------
elseif strcmp(subID, 'P75CS_ObjScreen') || strcmp(subID, 'P76CSFast') || strcmp(subID, 'P76CSFast_2')...
        || strcmp(subID, 'P76CSRec_ReScreen') || strcmp(subID, 'P76CS_RecScreen3') || strcmp(subID, 'P76CS_RecScreen_3')...
        || strcmp(subID, 'P76CSRec_ReScreen_3') || strcmp(subID, 'P77CS_1') || strcmp(subID, 'P73CS_ParamObj_500')...
        || strcmp(subID, 'AllCells_ParamObj') || strcmp(subID, 'P78_Screen1') || strcmp(subID, 'P78CS_Screen2') || strcmp(subID, 'P79CS_1')...
        || strcmp(subID, 'P79CS_2') || strcmp(subID, 'P79CS_ReScreen_1') || strcmp(subID, 'P79CS_3') || strcmp(subID, 'P79CS_ReScreen_3')...
        || strcmp(subID, 'P79CS_4') || strcmp(subID, 'P79CS_ReScreen_4') || strcmp(subID, 'P80CS_2') || strcmp(subID, 'P80CS_RecScreen_1')...
        || strcmp(subID, 'P80CS_ReScreenRecall') || strcmp(subID, 'P80CS_RecScreen_2') || strcmp(subID, 'P80CS_2_Att2')...
        || strcmp(subID, 'P80CS_ReScreecRecall_2') || strcmp(subID, '81CS_forReal') || strcmp(subID, 'P81CS_2') || strcmp(subID, 'P81CS_AM')...
        || strcmp(subID, 'P81_synth') || strcmp(subID, 'P82CS_1') || strcmp(subID, 'P82CS_CL_1') || strcmp(subID, 'P82CS_CLReScreen') || strcmp(subID, 'P84CS_1')...
        || strcmp(subID, 'P84CS_RecScreen_1') || strcmp(subID, 'P84CS_ReScreenRecall_1') || strcmp(subID, 'P84CS_RecScreen_2') || strcmp(subID, 'P84CS_ReScreenRecall_2')...
        || strcmp(subID, 'P85CS_1') || strcmp(subID, 'P85CS_CLReScreen') || strcmp(subID, 'P85CS_RecScreen_1') || strcmp(subID, 'P85CS_ReScreenRecall')
    
    anovaType = 'CategoryObject';
    faceInds = 134:210;
    objInds = [85:133 236:255 283:289 291:356 409:500]; % chnged to include 290 in text vwadia march 2022
    textInds = [264:282 290 400:408];
    vegInds = [211:235 357:399];
    animInds = [1:84 256:263];
    
    catOrder = zeros(length(order), 1);
    catOrder(ismember(order, faceInds)) = 1;
    catOrder(ismember(order, textInds)) = 2;
    catOrder(ismember(order, vegInds)) = 3;
    catOrder(ismember(order, animInds)) = 4;
    catOrder(ismember(order, objInds)) = 5;
end

end