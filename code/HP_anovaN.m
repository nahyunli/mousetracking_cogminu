function stat_table = HP_anovaN(DATA,FACTNAMES,BFactor)
% =============================================
% N-way ANOVA analysis
% Matlab function "anovan" (statistics toolbox) is required.
% my_decimaker_func is also required.
%
% Coluums of DATA should be arranged in order of
% Subject Number, Factor1, Factor2, Factor3 ..., and Dependent Variable.
%
% Usage1 (all with-subject variables)
%    stats = HP_anovaN(DATA, FACTNAMES)
%
% Usage2 (mixed variables)
%    stats = HP_anovaN(DATA, FACTNAMES,BFactor)
% 
% BFactor is the factor number having between variable in FACTNAMES.
%   e.g. FACTNAMES = {'F1','F2','F3'};
%       if "F1"is between-subject variable, then BFactor = 1
%       if both of "F1" and "F2" are between-subj, BFactor = [1,2];
% 
% Written by Moon (Dec. 2012)
% Modified by CSA, ICE (July. 2017)

[r,c] = size(DATA);
% number of factors including subj
Nfactor = c-1; 

factor_cel = cell(1,Nfactor);
% separate data of each factor into respective cell 
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
my_stats = table(1:end-2,[1:3,5:7,10:11]);

% calculate partial eta squared
for e=2:size(my_stats,1)
    % partial eta squared = SSeffect/(SSeffect+SSerror)
    % SSerror = MSerror*dfE
    my_stats{e,9} = my_stats{e,2}/(my_stats{e,2}+(my_stats{e,7}*my_stats{e,8}));
end;

for i=2:size(my_stats,1)
    my_stats{i,2} = my_decimaker_func(my_stats{i,2},4);
    my_stats{i,4} = my_decimaker_func(my_stats{i,4},4);
    my_stats{i,5} = my_decimaker_func(my_stats{i,5},2);
    my_stats{i,6} = my_decimaker_func(my_stats{i,6},4);
    my_stats{i,7} = my_decimaker_func(my_stats{i,7},4);
    my_stats{i,9} = my_decimaker_func(my_stats{i,9},4);
end

% re-order: 1(source),3(df),8(dfE),5(F),6(p),7(MSE),9(ES),2(SS),4(MS)
final_stats = my_stats(1:end, [1,3,8,5,6,7,9,2,4]);

final_stats{1,8} = 'SumSq';
final_stats{1,2} = 'df';
final_stats{1,9} = 'MeanSq';
final_stats{1,5} = 'p';
final_stats{1,6} = 'MSE'; % mean square error
final_stats{1,3} = 'dfE'; % df of error term
final_stats{1,7} = 'pEta2'; % partial eta squared

stat_table = cell2table(final_stats(2:end,:),'VariableNames',final_stats(1,:));


