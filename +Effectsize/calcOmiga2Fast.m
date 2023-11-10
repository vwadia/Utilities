%effect size calculation for 1-way regression model
%
%fast version of mes1way.m in effect size toolbox
%
%implemented by Shengxuan Ye, 2014
function [ es ] = calcOmiga2Fast ( x, y ) 


groupIx = unique(y); 
nGroup = length(groupIx); 
nSample = histc(y,unique(y)); 
dfErr=sum(nSample-1);


% grand mean
meanGrand=mean(x);

ssGroup=0;
ssErr=0;
for g=nGroup:-1:1
  % means of groups
  meanGroup(g)=sum(x(y==groupIx(g)))/nSample(g);
  % SS_a, or SS_effect, between-groups SS
  ssGroup=ssGroup + nSample(g)*(meanGroup(g)-meanGrand).^2;
  % SS_error, within-groups SS
  ssErr=ssErr + sum((x(y==groupIx(g))-repmat(meanGroup(g),nSample(g),1)).^2);
end

% within-groups MS
msErr=ssErr/dfErr;

% SS_t, the sum of both
ssTot=ssGroup+ssErr;

es=(ssGroup-(nGroup-1).*msErr)./(ssTot+msErr);

% % this is the same as 
% res = mes1way(x,'omega2','group',y);
% res.omega2
% 
% es

end
