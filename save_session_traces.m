% Compute for each cell the spike field coherence with most medial macro
% contacts. 

function  save_session_traces(data,params)


% Parameters
[params,FsDown]           = Utilities.get_opt(params,'FsDown',500); % down sampling to 500hz
[params,micros_to_use]    = Utilities.get_opt(params,'micros_to_use',... %  picking channels by brain area
                            {'uRAC','uLAC'});
[params,macros_to_use]    = Utilities.get_opt(params,'macros_to_use',... % similar for macros
                            {});
[params,save_dir]         = Utilities.get_opt(params,'save_dir',...
                            ['G:\decisionTask_cache\precomputed_cacheFiles\acc_micros_500\']); % where to save stuff 
[params,beh_dir]          = Utilities.get_opt(params,'beh_dir',... % which task we running this for
                            ['G:\Data\Decision Making\Behavior']);
 [params,remove_spikes]   = Utilities.get_opt(params,'remove_spikes',false);
                        
% Behavior files                        
files            = dir([beh_dir,'\*.mat']);      
temp             = cellfun(@(x) load([beh_dir,'\',x],'sessioncellinfo'),...
                   {files.name});
events_cell      = cellfun(@(x) x.eventsTask,{temp.sessioncellinfo},...
                   'UniformOutput',false);
sessions          = prep_names({files.name});


                        
 
for i=1:length(sessions)
    
    % Does this session have cells
    idx_cell      = ismember({data.sessionID},sessions{i});
    
    % Exctract channel information from session
    channels      = map_channels(sessions{i});
    all_chan      = channels.allChannels;

    % Which channels to use
    chan_idx      = [];
    if ~isempty(micros_to_use)
       [temp,~]  = get_chan_nr(all_chan,micros_to_use);
       chan_idx  = cat(2,chan_idx,temp);
    end
    
    if ~isempty(macros_to_use)
        [temp,~] = most_medial(all_chan,macros_to_use);
        chan_idx  = cat(2,chan_idx,temp);

        % Add the adjacent contact, in order to compute difference
        chan_idx = reshape([chan_idx;chan_idx+1],1,2*length(chan_idx));
    end
    

    
    % Extract raw data from the specified channels
    events    = events_cell{i};
    exp_start = events(:,2)==55;
    exp_end   = events(:,2)==66;
    
    if sum(idx_cell>0) && remove_spikes
        data_raw  = ft.read_raw(sessions{i},chan_idx,FsDown,...
                    [events(exp_start,1),events(exp_end,1)],[],...
                     data(idx_cell));   
    else
        data_raw  = ft.read_raw(sessions{i},chan_idx,FsDown,...
                    [events(exp_start,1),events(exp_end,1)]);   
    end

            
            
    temp      = strrep(sessions{i},'\','_');
    temp      = strrep(temp,'/','_');
    
    if ~exist(save_dir,'dir')
        mkdir(save_dir)
    end

    save([save_dir,temp,'.mat'],'data_raw','params','-v7.3');


end






end % main function

% What channels to use
function [chan_nr,area_name] = get_chan_nr(micros,areas)
chan_idx  = ismember(micros(:,3),areas);
chan_nr  = cell2mat(micros(chan_idx,1));
area_name = micros(chan_idx,3); 
end

% Macrios only, use most medial contact
function [chan_nr,area_name] = most_medial(chans,areas)
chan_nr = NaN(1,length(areas));
area_name = cell(1,length(areas));
for i=1:length(areas)
    chan_idx  = find(ismember(chans(:,3),areas{i}),1,'first');
    chan_nr(i)  = cell2mat(chans(chan_idx,1));
    area_name{i} = chans(chan_idx,3); 

end
end

function file_names = prep_names(file_names)

for i=1:length(file_names)
    
    % remove the file extension
    idx_keep      = strfind(file_names{i},'.')-1;
    file_names{i} = file_names{i}(1:idx_keep);
    
    % remove second underscore (if there is one)
    idx_keep      = strfind(file_names{i},'_');
    if length(idx_keep)>1
        file_names{i}(idx_keep(2)) = '\';
        
    end

end

end


function data_raw  = prep_macros(data_raw,compute_diff)

%{
    The purpose of this script is to keep the most medial contacts, and to
    also add the difference between the most medial and the next most
    medial to the list of electrodes. 
%}

most_medial     = 1:2:length(data_raw.label);
to_remove       = setdiff(1:length(data_raw.label),most_medial);


if compute_diff
    for i=1:length(most_medial)

        % Replace with difference
        data_raw.trial{1}(most_medial(i),:) = data_raw.trial{1}(most_medial(i),:)-...
                                            data_raw.trial{1}(to_remove(i),:);

    end
end

data_raw.trial{1}(to_remove,:) = [];
data_raw.label(to_remove) = [];

end

