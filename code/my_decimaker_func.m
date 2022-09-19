%
%   D = my_decimaker_func(X,NofDP)
%
%   to have double-type data at certain deciaml places.
%
%   Usage:
%   X is a M-be-N matrix.
%   NofDP stands for the number of decimal places. Default is 2.
%
%   Reference: Jong Moon Choi,
%              Dept. of Psychology, University of Maryland -- College Park
%
%   Created by Sep. 26, 2011
%
%   All rights are Not reserved.

function D = my_decimaker_func(X,NofDP)

[Nrow, Ncol] = size(X);

D = X*0;
for i_row = 1:Nrow
    for i_col = 1:Ncol

        temp = X(i_row, i_col);
        
        if nargin==1 
            mysquare = 2;
        else
            mysquare = NofDP;
        end
            
        D_temp =    round(temp*10^mysquare)/10^mysquare;
        D(i_row,i_col) = D_temp;
                    
    end
end