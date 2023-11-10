% addpath(genpath('ObjectSpace'));
mcnPath =  ['Z:\LabUsers\vwadia\SUAnalysis' filesep 'ObjectSpace'];
% ---------------------------------ESSENTIAL FOR THIS TO WORK --------------------------------
% run this and make sure its configured
% Microsoft Visual c++ 2017 (2019 won't work) for c++ language config
% specifically NOT c language
% mex -setup -v
% -------------------------------------------------------------------------------------------

% install matconvnet - run once
% untar('Z:\LabUsers\vwadia\SUAnalysis\ObjectSpace\matconvnet-1.0-beta24.tar.gz') ;
% run(fullfile('matconvnet-1.0-beta24','matlab','vl_compilenn.m'));
% -------------------------------------------------------------------------------------------
% untar('C:\Users\varunwadia\Documents\SUAnalysis\ObjectSpace\matconvnet-1.0-beta25.tar.gz') ;
run(fullfile([mcnPath filesep 'matconvnet-1.0-beta25'],'matlab','vl_compilenn.m'));


%---------------------------------------------------------------------------------------------
% other installations I tried
% untar('C:\Users\varunwadia\Documents\SUAnalysis\ObjectSpace\matconvnet-1.0-beta17.tar.gz') ;
% run(fullfile('matconvnet-1.0-beta17','matlab','vl_compilenn.m'));

% untar('C:\Users\varunwadia\Documents\SUAnalysis\ObjectSpace\matconvnet-1.0-beta15.tar.gz') ;
% run(fullfile('matconvnet-1.0-beta15','matlab','vl_compilenn.m'));

% untar('C:\Users\varunwadia\Documents\SUAnalysis\ObjectSpace\matconvnet-1.0-beta15.tar.gz') ;
% run(fullfile('matconvnet-1.0-beta15','matlab','vl_compilenn.m'));
%---------------------------------------------------------------------------------------------

% set up matconvnet
% run(fullfile('matconvnet-1.0-beta24','matlab','vl_setupnn.m'));
run(fullfile([mcnPath filesep 'matconvnet-1.0-beta25'],'matlab','vl_setupnn.m'));
% ------------------------------------------------------------------------------------
% run(fullfile('matconvnet-1.0-beta17','matlab','vl_setupnn.m'));
% run(fullfile('matconvnet-1.0-beta15','matlab','vl_setupnn.m'));
% ------------------------------------------------------------------------------------
