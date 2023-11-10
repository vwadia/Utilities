function Mdl = SVMdecoder_mdl(X,Y)
% 
 t    = templateSVM('Standardize',false,'KernelFunction', 'linear');
 Mdl   = fitcecoc(X,Y,'Prior','uniform','Learners',t);

% Mdl   = fitcecoc(X,Y,'Prior','uniform','Learners',t,'OptimizeHyperparameters',...
%         {'BoxConstraint','KernelScale'});
% close all;


end
