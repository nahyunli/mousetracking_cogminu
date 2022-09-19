%
%   [Xcalc, Xcnt, Xtable] = my_condcalc_func(X, MODE)
%
%   To make matrix of condition-specific calculation.
%
%   Usage:
%   X is a M-by-N matrix.
%   The last column of X should contain dependent variable
%
%   1.[Xcalc] = my_condcalc_func(X)
%   Xcalc is "# of trial types"-by-"# of factors + 1".
%   The last column of Xcalc contains mean value of each condition
%
%     my_condcalc_func(X,MODE) does other calculation such as median,
%     sum, or std (standard deviation). MODE is string either 'mean',
%     'median', 'sum', or 'std'. If MODE is not specified, it takes the
%     mean.
%
%   2.[~, Xcnt] = my_condcalc_func(X)
%   Xcnt is "# of trial types"-by-"# of factors + 1".
%   The last column of Xcnt contains # of trials of each condition
%
%   3.[~, ~, Xtable] = my_condcalc_func(X)
%   Xtable is is the 2-D table containing mean values.
%   Factor A (1st column in X) is sorted in row, and Factor B (2nd column in X) is sorted in column.
%   If the number of factors exceeds 2, error message will be generated.
%
%   Reference: Jong Moon Choi,
%              Dept. of Psychology, University of Maryland -- College Park
%
%   Created by Nov. 25, 2011
%
%   All rights are Not reserved.

function [Xcalc, Xcnt, Xtable] = my_condcalc_func(X, MODE)

if nargin == 1
    MODE = 'mean';
else
    avail = ismember(MODE,{'mean', 'median', 'sum', 'std'});
    if sum(avail) == 0
        error('MODE should be "mean", "median", "sum", or "std"; case sensitive')
    end
end

[r,c] = size(X);
Nfactor = c-1;

X = sortrows(X,[1:Nfactor]);

eq_ids = zeros(r,1);
for ix = 2:r
    eq_ids(ix,1) = isequal(X(ix-1,1:Nfactor),X(ix,1:Nfactor));
end

start_ids = find(eq_ids==0);
end_ids = [start_ids(2:end,:)-1; size(X,1)];

Ncomb = length(start_ids);
Xcalc_mat = [];
for i = 1:Ncomb
    X_code = X(start_ids(i):end_ids(i),1:end-1);
    X_data = X(start_ids(i):end_ids(i),end);
    tmpstr = ['Xcalc_mat = [Xcalc_mat; [mean(X_code,1) ', MODE, '(X_data,1)]];'];
    eval(tmpstr)
end

Xcalc = Xcalc_mat;

if nargout >1
    Xcnt = Xcalc;
    Xcnt(:,end) = [end_ids(1); diff(end_ids)];
end

if nargout >2
    
    if Nfactor > 2
        error('Number of factors exceeds two. CANNOT creat table. Delete X_table from OUTPUT')
    end
    
    Nlvl_A = length(unique(Xcalc(:,1)));
    Nlvl_B = 1;
    if Nfactor >1
        Nlvl_B = length(unique(Xcalc(:,2)));
    end
    
    X_sort = sortrows(Xcalc,Nfactor);
    Xtable = reshape(X_sort(:,end),Nlvl_A,Nlvl_B);
    
end

