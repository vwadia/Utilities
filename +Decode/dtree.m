
function [predictions,groundtruth, Mdl] = dtree(features,labels)
Mdl                  = fitctree(features,labels,...
                       'Leaveout','on',...
                       'Prior','uniform');
[predictions,~,~,~]  = kfoldPredict(Mdl);
groundtruth          = labels;
end

