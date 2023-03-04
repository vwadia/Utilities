function new_labels = one_vs_all(labels)

unique_levels = unique(labels);
new_labels    = false(length(labels),length(unique_levels));

for i=1:length(unique_levels)
    new_labels(:,i) = ismember(labels,unique_levels(i));
end

end