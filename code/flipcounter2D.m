function [nxcount] = flipcounter2D(x, y)

 xtray = diff(x,[],2);
 ytray = diff(y,[],2); 
         
        xtray(xtray>0)=1;%moving forward
        xtray(xtray<0)=-1;%moving backward
        ytray(ytray>0)=1;%moving forward
        ytray(ytray<0)=-1;%moving backward

        
        
        %filling zeros with previous value
        for i = 1:size(x,1)
            for ii = 1:size(x,2)-2
                if xtray(i,ii+1)==0              
                   xtray(i,ii+1) = xtray(i,ii);
                end
                if ytray(i,ii+1)==0              
                   ytray(i,ii+1) = ytray(i,ii);
                end
            end
        end
                
        %marking the range where change in direction occurs        
        for i = 1:size(x,1)
                 for ii = 1:size(x,2)-2
                     if xtray(i,ii) ~= xtray(i,ii+1)
                        xff(i,ii) = 1;
                     elseif xtray(i,ii) == xtray(i,ii+1)
                        xff(i,ii) = 0;
                     end
                     if ytray(i,ii) ~= ytray(i,ii+1)
                        yff(i,ii) = 1;
                     elseif ytray(i,ii) == ytray(i,ii+1)
                        yff(i,ii) = 0;
                     end                     
                 end
        end
        
        mergedxy=xff+yff;
        mergedxy(mergedxy>0)=1;
        nxcount =sum(mergedxy,2)-1;
        nxcount(nxcount<=-1,:)=0;
%         plot(1:101, x(1,:))
end



  
