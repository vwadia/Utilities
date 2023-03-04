
% compare effect size measures
%
%urut/oct14
%


load('exampleData.mat');   % example data that comes with the effect size toolbox

%% ==== on this comparison, all metrics agree (same value of omega^2 results)

%indsToUse = 1:length(com_post);  % all 3 groups

indsToUse = find( group<2); % only 2 groups

res=mes1way( com_post(indsToUse), 'omega2', 'group', group(indsToUse) );
es = res.omega2

[ es ] = calcOmiga2Fast ( com_post(indsToUse), group(indsToUse) );
es

[pAnova,ANOVATAB] = anova1(com_post(indsToUse), group(indsToUse) );
MSE = ANOVATAB{3,4};
SStot = ANOVATAB{4,2};
SS1 = ANOVATAB{2,2};
df = ANOVATAB{2,3};
es = (SS1-df*MSE)/(SStot+MSE);

es
                
%% 2-way Demo

mes2way(com_post,[group sex],'omega2','nBoot',10000)

n=10;
Y = [ randn(1,n)+4 randn(1,n)+2 randn(1,n)+1 randn(1,n)+2+1 randn(1,n)+4+1 randn(1,n)+1];
G1= [  ones(1,n)*0 ones(1,n)*1 ones(1,n)*2 ones(1,n)*0 ones(1,n)*1 ones(1,n)*2 ];
G2= [  ones(1,n)*0 ones(1,n)*0 ones(1,n)*0 ones(1,n)*1 ones(1,n)*1 ones(1,n)*1];


%===with interaction
[p,table,stats,terms] = anovan( Y, {G1 G2}, 'model', 'interaction');

%===without interaction
[p,table,stats,terms] = anovan( Y, {G1 G2}, 'model', 'linear');

%
% see http://pages.uoregon.edu/stevensj/strength.pdf for definitions
%
SS1 = table{2,2};
SS2 = table{3,2};
SS12 = table{4,2};

df1=table{2,3};
df2=table{3,3};

SStot=table{end,2};
MStot = table{end-1,5};

es1 = (SS1-(df1-1)*MStot)/(SStot+MStot);   %main 1
es2 = (SS2-(df2-1)*MStot)/(SStot+MStot) ;%main 2
es3 = (SS12-(df1-1)*(df2-1)*MStot)/(SStot+MStot) ;  %interaction
[es1 es2 es3]
