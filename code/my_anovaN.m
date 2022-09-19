function stat_table = my_anovaN(DATA,FACTNAMES,BFactor)
% =============================================
% N-way ANOVA analysis
% Matlab function "anovan" (statistics toolbox) is required.
%
% Coluums of DATA should be arranged in order of
% Subject Number, Factor1, Factor2, Factor3 ..., and Dependent Variable.
%
% Usage1 (all with-subject variables)
%    stats = my_anovaN(DATA, FACTNAMES)
% Usage2 (mixed variables)
%    stats = my_anovaN(DATA, FACTNAMES,BFactor)
% 
% BFactor is the factor number having between variable in FACTNAMES.
%   e.g. FACTNAMES = {'F1','F2','F3'};
%       if "F1"is between-subject variable, then BFactor = 1
%       if both of "F1" and "F2" are betwen-subj, BFactor = [1,2];

[r,c] = size(DATA);
Nfactor = c-1;

factor_cel = cell(1,Nfactor);
for i_factor = 1:Nfactor
    factor_cel{1,i_factor} = DATA(:,i_factor);
end

if nargin < 3   %if within
    [p,table,stats,terms] = anovan(DATA(:,end), factor_cel, 'model', 'full', 'display','off','random',1,'varnames', [{'Subj'},FACTNAMES]);
else
    nestmat = zeros(Nfactor,Nfactor);
    nestmat(1,BFactor+1) = 1;    
    [p,table,stats,terms] = anovan(DATA(:,end), factor_cel, 'model', 'full', 'display','off','random',1,'nested',nestmat,'varnames', [{'Subj'},FACTNAMES]);
end
stats = table(1:end-2,[1:3 5:7]);

for i=2:size(stats,1)
    stats{i,2} = my_decimaker_func(stats{i,2},4);
    stats{i,4} = my_decimaker_func(stats{i,4},4);
    stats{i,5} = my_decimaker_func(stats{i,5},2);
    stats{i,6} = my_decimaker_func(stats{i,6},4);
end
stats{1,2} = 'SumSq';
stats{1,3} = 'df';
stats{1,4} = 'MeanSq';
stats{1,6} = 'p';

stat_table = cell2table(stats(2:end,:),'VariableNames',stats(1,:));


