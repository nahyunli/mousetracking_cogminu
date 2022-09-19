function sigplotterHPL(dat, col)
% dat=dtest.w2.angl_dip_p2w(1,:);
% dat2=ftbl3(1,:,:,:);
btray = dat<.05;
% btray2 = dat2(:,:,wav,chn);
    
    if sum(btray)==0
        ...
    else
        tidx=find(btray~=0);
        for ts = 1:size(tidx,2)
            bar(tidx(ts), .15, 1,'FaceColor', col,'EdgeColor','none','FaceAlpha',.1,'HandleVisibility','off')
%             bar(tidx(ts), -.15, 1,'FaceColor', 'c','EdgeColor','none','FaceAlpha',.2 ) 
            %width =100
        end
    end
%     hold on    
    
%     if sum(btray2)==0
%         ...
%     else
%             tidx2=xvar(find(btray2~=0));        
%             for ts = 1:size(tidx,2)
%                 bar(tidx2(ts)+100, 2, 200,'FaceColor', 'r','EdgeColor','none','FaceAlpha',.3 )
%                 bar(tidx2(ts)+100, -2, 200,'FaceColor', 'r','EdgeColor','none','FaceAlpha',.3 )              
%             end
%     end
% %     hold off
    
end

