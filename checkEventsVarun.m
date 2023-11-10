function checkEventsVarun()
% this function takes the events file from a recording session
% and the corresponding (possibly several) txt log files written by Matlab
% it comes up with the structure of the experimental run
% the output runStruct is a matrix, where each row is as follows:
% [ experimentID isPractice startTXT endTXT startNEV endNEV ]
% sometimes a TTL is missing from the NEV file, fill it in from the TXT
% file
%
% jdubois / aug16

dbstop if error

cd(fileparts(which(mfilename)));
returnhere = pwd;
cd ..
% setpaths; want this to be the same as my rastersMovie script
basePath = 'E:\Dropbox\Caltech\Thesis\Human_work\Cedars\SUAnalysis';

taskPath = 'Julien_Movie_Task';
patientID = 'P62CS';
finalDir = 'sort\final';
rawPath = 'raw';
sessionDir = dir([basePath filesep taskPath filesep patientID]);
sessionDir = sessionDir(~ismember({sessionDir.name}, {'.', '..', '.DS_Store'})); 
% currently works because P62 had only 1 session
sessionID = sessionDir(1).name;
dataRawDir = [basePath filesep taskPath filesep patientID filesep sessionID filesep rawPath];

cd(returnhere);

% conventions for TTLs
TTL = setTTLsJulien();

[nevFiles,nevDir] = uigetfile(fullfile(dataRawDir,'*.nev'),'Choose Neuralynx events files','Multiselect','on');
if ~iscell(nevFiles),nevFiles = {nevFiles};end
logFiles          = uigetfile(fullfile(nevDir,'*.txt'),'Choose ALL corresponding log files','Multiselect','on');
if ~iscell(logFiles),logFiles = {logFiles};end

% read events file
events =[];
for i = 1:length(nevFiles),
    events=[events;getRawTTLs(fullfile(nevDir,nevFiles{i}))];
end

% note the very first time stamp in the events file
nevTTLF = events(1,1);
nevTTLL = events(end,1);

ind      = ismember(events(:,2),...
    [1:10,TTL.startExp,TTL.endExp,TTL.startPractice,TTL.endPractice,TTL.startReal,TTL.endReal,TTL.keypress,TTL.startInstr]);
NEV_TTL    = events(ind,2);
NEV_tStamp = events(ind,1);

% runStructNEV = [];
% count = 0;
% fprintf('Run structure from .nev file\n');
% while count < length(ind),
%     count = count + 1;
%     switch events(ind(count),2),
%         case TTL.startPractice
%             if events(ind(count+1),2)~=TTL.endPractice,
%                 warning('Missing the end practice TTL');
%                 tStampEnd = NaN;
%             else
%                 tStampEnd = events(ind(count+1),1);
%             end
%             runStructNEV = [runStructNEV;...
%                 1 events(ind(count),1) tStampEnd];
%             fprintf('%d\t%s\t%s\n',1,num2str(events(ind(count),1)),num2str(tStampEnd));
%             
%         case TTL.startReal
%             if events(ind(count+1),2)~=TTL.endReal,
%                 warning('Missing the end real TTL');
%                 tStampEnd = NaN;
%             else
%                 tStampEnd = events(ind(count+1),1);
%             end
%             runStructNEV = [runStructNEV;...
%                 0 events(ind(count),1) tStampEnd];
%             fprintf('%d\t%s\t%s\n',0,num2str(events(ind(count),1)),num2str(tStampEnd));
%     end
% end
% fprintf('\n\n');

% read log files
% tStamp is in units of 1*e-9 days (cf. writeLog.m, now*10^9)
% to convert to us, we need to tStamp*24*60*60*10^6/(10^9)
factor = 24*60*60*(10^6)/(10^9);
% sort log files by date
dateLog = cell(1,length(logFiles));
for iLog = 1:length(logFiles),
    dateLog{iLog} = logFiles{iLog}(end-22:end-4);
    if iLog == 1
        day = dateLog{iLog}(1:10);
        fprintf('This experimental run was performed on %s\n',dateLog{iLog});
    else
        thisday = dateLog{iLog}(1:10);
        if ~strcmp(thisday,day),
            error('log files are from different days');
        end
    end
end
[~,indsort] = sort(dateLog);

logFiles = logFiles(indsort);
%dateLog  = dateLog(indsort);
TXT_TTL    = [];
TXT_tStamp = [];
tStampF = zeros(1,length(logFiles));
tStampL = zeros(1,length(logFiles));

% fprintf('Run structure from .txt files\n');
for iLog = 1:length(logFiles)
    fprintf('Log file %d (%s)\n',iLog,logFiles{iLog});
    fid = fopen(fullfile(nevDir,logFiles{iLog}),'r');
    C= textscan(fid,'%s%d%s','delimiter',';');
    fclose(fid);
    tStamp    = factor * cellfun(@str2double,C{1});
    ttl       = C{2};
    
    tStampF(iLog) = tStamp(1);
    tStampL(iLog) = tStamp(end);
    
    tmp = find(ttl==TTL.startExp);
    if ~isempty(tmp)
        fprintf('\tstartExp found at %d\n',tmp);
    else
        fprintf('\tstartExp not found!\n');
        tmp = find(floor(ttl/10)==5,1,'first');
        if ~isempty(tmp)
            fprintf('\t\tfirst instructions found at %d\n',tmp);
        else
            fprintf('\t\tinstructions not found!\n');
            tmp = find(ttl==33,1,'first');
            if ~isempty(tmp)
                fprintf('\t\t\tfirst keypress found at %d\n',tmp);
            else
                fprintf('\t\t\tkeypress not found!\n');
                error('Are you sure these are the right TTL codes??');
            end
        end
    end
    tmp = find(ttl==TTL.endExp);
    if ~isempty(tmp)
        fprintf('\tendExp found at %d\n',tmp);
    end
        
    %     % find start practice & start real triggers
    %     ind      = find(ismember(ttl,...
    %         [TTL.startPractice,TTL.endPractice,TTL.startReal,TTL.endReal]));
    %     % if these are not defined, find start experiment trigger
    %     if isempty(ind),
    %         ind      = find(ismember(ttl,...
    %             [TTL.startExp,TTL.endExp]));
    %     end
    %     count = 0;
    %     while count < length(ind),
    %         count = count + 1;
    %         switch ttl(ind(count)),
    %             case TTL.startExp
    %                 if ttl(ind(count+1))~=TTL.endExp,
    %                     error('Missing the end TTL');
    %                 end
    %                 runStructTXT = [runStructTXT;...
    %                     iLog 1 tStamp(ind(count)) tStamp(ind(count+1))];
    %                 fprintf('%d\t%d\t%s\t%s\n',iLog,1,num2str(tStamp(ind(count))),num2str(tStamp(ind(count+1))));
    %             case TTL.startPractice
    %                 if ttl(ind(count+1))~=TTL.endPractice,
    %                     error('Missing the end practice TTL');
    %                 end
    %                 runStructTXT = [runStructTXT;...
    %                     iLog 1 tStamp(ind(count)) tStamp(ind(count+1))];
    %                 fprintf('%d\t%d\t%s\t%s\n',iLog,1,num2str(tStamp(ind(count))),num2str(tStamp(ind(count+1))));
    %             case TTL.startReal
    %                 if ttl(ind(count+1))~=TTL.endReal,
    %                     error('Missing the end real TTL');
    %                 end
    %                 runStructTXT = [runStructTXT;...
    %                     iLog 0 tStamp(ind(count)) tStamp(ind(count+1))];
    %                 fprintf('%d\t%d\t%s\t%s\n',iLog,0,num2str(tStamp(ind(count))),num2str(tStamp(ind(count+1))));
    %         end
    %     end
    
    ind = ismember(ttl,...
        [1:10,TTL.startExp,TTL.endExp,TTL.startPractice,TTL.endPractice,TTL.startReal,TTL.endReal,TTL.keypress,TTL.startInstr]);
    
    TXT_TTL    =[TXT_TTL;ttl(ind)];
    TXT_tStamp =[TXT_tStamp;tStamp(ind)];
        
end

% can be used for correcting alignment
% remove first TXT_TTL until there is a match
% while 1
%     if sum(TXT_TTL(1:10)==NEV_TTL(1:10))==10,
%         break
%     else
%         TXT_TTL(1)=[];
%         TXT_tStamp(1)=[];
%     end
% end

% set to time elapsed since first TTL (for ease of plotting)
TXT_tStamp0 =[];NEV_tStamp0 =[];

TXT_tStamp0 = TXT_tStamp(find(TXT_TTL==4,1,'first'));
NEV_tStamp0 = NEV_tStamp(find(NEV_TTL==4,1,'first'));
fields2try = {'startExp','startPractice','endExp'};
iField = 1;
while (isempty(TXT_tStamp0) || isempty(NEV_tStamp0)) && iField<=length(fields2try)
    TXT_tStamp0 = TXT_tStamp(find(TXT_TTL==TTL.(fields2try{iField}),1,'first'));
    NEV_tStamp0 = NEV_tStamp(find(NEV_TTL==TTL.(fields2try{iField}),1,'first'));
    iField = iField + 1;
end     
if (isempty(TXT_tStamp0) || isempty(NEV_tStamp0))
    error('No matching TTL found; is there another we could rely on?');
end
TXT_tStamp = TXT_tStamp - TXT_tStamp0;
NEV_tStamp = NEV_tStamp - NEV_tStamp0;

displayFactor = 10^(-6);
figure('units','normalized','outerposition',[0 0 1 1]);hold on;
plot(TXT_tStamp*displayFactor,TXT_TTL,'k+');
plot(NEV_tStamp*displayFactor,NEV_TTL,'r+');
line((events(1,1)-NEV_tStamp0)*[1 1]*displayFactor,[32 67],'Color','r');
line((events(end,1)-NEV_tStamp0)*[1 1]*displayFactor,[32 67],'Color','r');
% mark logFiles start/end
c = distinguishable_colors(length(logFiles));
fidw = fopen(fullfile(nevDir,'timeStampsToInclude.txt'),'w');
for iLog = 1:length(logFiles),
    fill(([tStampF(iLog) tStampF(iLog) tStampL(iLog) tStampL(iLog)] - TXT_tStamp0)*displayFactor,...
        [32 67 67 32],c(iLog,:),'FaceAlpha',0.2,'EdgeColor','none');
    % print out the timeStamps to a file
     fprintf(fidw,'%s %s\n',...
        num2str(max(tStampF(iLog) - TXT_tStamp0 + NEV_tStamp0,nevTTLF)),... % 0s before first trigger
        num2str(min(tStampL(iLog) - TXT_tStamp0 + NEV_tStamp0,nevTTLL)));    % 0s after last trigger
    % print out the timeStamps to the command window
    fprintf('%s %s\n',...
        num2str(max(tStampF(iLog) - TXT_tStamp0 + NEV_tStamp0,nevTTLF)),... % 0s before first trigger
        num2str(min(tStampL(iLog) - TXT_tStamp0 + NEV_tStamp0,nevTTLL)));    % 0s after last trigger
end
fclose(fidw);
xlabel('Time in seconds');
ylabel('TTL code');
[d,sess] = fileparts(nevDir(1:end-1));
[~,sub]  = fileparts(d);
title(sprintf('%s -- session %s',sub,strrep(sess,'_','-')));
saveas(gcf,fullfile(nevDir,'timeline.png'));
% PRINT figure

%keyboard

% find time stamps in events file that correspond to start/end of each
% experiment or experimental phase

