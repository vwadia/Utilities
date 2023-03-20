function idx = balance_groups(labels,re_ref)

if nargin<2
    re_ref = 0.9;
end

unique_labels     = unique(labels); % number of levels
class_id          = cellfun(@(x) find(ismember(labels,x)),...
                    num2cell(unique_labels),'UniformOutput',false);
nr_inst           = cellfun(@(x) numel(x),class_id);
                
[ref_size,~] = min(nr_inst);
ref_size     = round(ref_size*re_ref);

idx               = cell(size(class_id));
for i=1:length(unique_labels)
    temp   = Utilities.Shuffle(class_id{i});
    idx{i} = temp(1:ref_size);
end

end