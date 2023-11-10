
function distance  = pop_distance(features, labels, groups)


unique_labels = unique(labels);
unique_groups = unique(groups);
[~,score,latent,~] = pca(features);
nr_features_neaded     = find((cumsum(latent)/sum(latent))>0.95,1,'first');
features               = score(:,1:nr_features_neaded);
temp          = squareform(pdist(features,'mahalanobis'));
distance      = struct('d',[],'overlap',[],'within_group',[],...
                'across_group',[]);

for i=1:length(unique_groups)

        
       group_1 = all([ismember(groups,unique_groups(i)),...
                      ismember(labels,unique_labels(1))],2);
       group_2 = all([ismember(groups,unique_groups(i)),...
                      ismember(labels,unique_labels(2))],2);
       x_1     = features(group_1,:);
       x_2     = features(group_2,:);
       [hd, D] = HausdorffDist(x_1,x_2);
       [m1,m2, proj_res_1,proj_res_2,overlap,d] =  projection_test(x_1,x_2);
    
       distance(i).overlap      = overlap;
       distance(i).d            = d;
       distance(i).proj_res_1   = proj_res_1;
       distance(i).proj_res_2   = proj_res_2;
       distance(i).hd           = hd;
       distance(i).D            = D;
       distance(i).center_1_1   = cellfun(@(x) norm(x-m1),num2cell(x_1,2));
       distance(i).center_2_2   = cellfun(@(x) norm(x-m2),num2cell(x_2,2));
       distance(i).center_1_2   = cellfun(@(x) norm(x-m2),num2cell(x_1,2));
       distance(i).center_2_1   = cellfun(@(x) norm(x-m1),num2cell(x_2,2));
       within_group_1 = mean(sum(temp(group_1,group_1),2)/(sum(group_1)-1));
       within_group_2 = mean(sum(temp(group_2,group_2),2)/(sum(group_2)-1));
       across_group   = mean(sum(temp(group_1,group_2),2)/(sum(group_2)));
       distance(i).within_group = [within_group_1,within_group_2]./across_group;

       
end

end