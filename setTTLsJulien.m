function TTL = setTTLs(experiment)

TTL.startExp         = 61;
TTL.endExp           = 66;
TTL.startPractice    = 62;
TTL.endPractice      = 63;
TTL.startReal        = 64;
TTL.endReal          = 65;
TTL.startInstr       = 51:59; % several screens of instructions
TTL.keypress         = 33;

if nargin~=0
    switch experiment
        case 'saccades'
            TTL.startFix       = 1;
            TTL.chgFixColor    = 2;
            TTL.endFix         = 3;
            TTL.startTarget    = 4;
            TTL.endTarget      = 5;
            TTL.endResp        = 6;
            TTL.startFeedback1 = 7;
            TTL.startFeedback2 = 8;
            TTL.startITI       = 9;
            TTL.trialAborted   = 10;
        case 'contNO'
            TTL.startFix    = 1;
            TTL.startProbe  = 2;
            TTL.startBlank  = 3;
            TTL.startResp1  = 4;
            TTL.startResp2  = 5;
            TTL.logTrial    = 10;
        case 'fLoc'
            TTL.startTrial   = 1;
            TTL.startITI     = 2;
            TTL.startBlock   = 3;
        case 'sternbergfMRI'
            TTL.startFix     = 1;
            TTL.endFix       = 10;
            TTL.startTrial   = 2;
            TTL.startEnc     = 3;
            TTL.startMaint   = 4;
            TTL.startProbe   = 5;
            TTL.endTrial     = 7;
        
        case {'loi_1','loi_2','socnsloi_1','socnsloi_2'}
            TTL.startFix     = 1;
            TTL.endFix       = 2;
            TTL.startITI     = 3;
            TTL.startBlock   = 4;
            TTL.startTrial   = 5;
            TTL.resp         = 9;
            TTL.logBlock     = 10;
        
        case {'newoldfacesv1_0','newoldfacesv2_0'} % fLoc
            TTL.stimON      = 1;
            TTL.stimOFF     = 2;
            TTL.fbON        = 41; % feedback on
            TTL.fbOFF       = 40; % feedback off

        case {'newoldfacesv1_1','newoldfacesv2_1','newoldfacesv2_3'} % encode/reinforce
            TTL.startScene  = 1;         % start new scene
            TTL.blue2green  = 2;        % color change (blue -> green)
            TTL.startLoom   = 3;        % start of looming
            TTL.endLoom     = 4;        % end of looming
            TTL.showFace    = 5;        % display face
            TTL.showName    = 6;        % display name
            TTL.showJob     = 7;        % display job
            TTL.encodeQ     = 8;        % display question
            TTL.startShrink = 9;        % start shrinking
            TTL.endShrink   = 10;        % end shrinking
            TTL.green2red   = 11;        % number switches to red
            TTL.endScene    = 12;        % end of mandatory waiting period
            if strcmp(experiment,'newoldfacesv2_3'),
                TTL.endProbe    = 13;
                TTL.startResp   = 14;
            end
            TTL.fbON             = 41; % feedback on
            TTL.fbOFF            = 40; % feedback off
            
        case {'newoldfacesv1_2','newoldfacesv2_2'} % newold
            TTL.startTrial  = 1;
            TTL.startProbe  = 2;
            TTL.endProbe    = 3;
            TTL.startResp   = 4;
            
        case {'newoldfacesv1_3','newoldfacesv2_4'} %assoc
            TTL.startTrial  = 1;
            TTL.startPrompt = 2;
            TTL.endPrompt   = 3;
            TTL.startCue    = 4;
            TTL.endCue      = 5;
            TTL.startRecall = 6;
            TTL.endRecall   = 7;
            TTL.startProbe  = 8;
            TTL.endProbe    = 9;
            TTL.startResp   = 10;
            
        case {'movie'}
            TTL.startFix     = 1;
            TTL.endFix       = 10;
            TTL.video        = 4;
            TTL.startQ       = 5;
            TTL.resp         = 6;
            TTL.startProbe   = 7;
            TTL.endProbe     = 8;
            TTL.startITI     = 9;
            
        case {'movieFull'}
            TTL.startFix     = 1;
            TTL.endFix       = 10;
            TTL.video        = 4;
            TTL.startShort   = 5;
            TTL.endShort     = 6;
            TTL.isOld        = 7;
            TTL.isNew        = 8;
    end
end
