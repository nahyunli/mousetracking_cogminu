function [test2]=sigplotter4(dat,locs,xvar2,tk, cl)
% dat=t2Vsr;locs=2.14;xvar2=x;tk=.12;cl='k';
% sigplotter4(t2Vsr,2.14,x,.12, 'k');



% barwt=unique(round(diff(xvar2),4));barwt=fliplr(barwt(2:3));
xvar2=xvar2-.5;
% barWidth=
% xvar2=xvar2-.5;
% xvar2=xvar2+.5;
dat(dat>.05)=-99999;
dat(dat==0)=1;dat(dat>0)=1;dat(dat==-99999)=0;
btray = dat;

% test=2:101;
% test2=test(:,logical(dat));
% btray2 = dat2(:,:,wav,chn);
    
    if sum(btray)==0
        ...
    else
        tidx=xvar2(find(btray~=0));
%         tidx(2,:)=tidx(1,:);
        
        for ts = 1:size(tidx,2)
            ah=bar([tidx(:,ts); nan],[locs tk;nan(1,2)], 1,'stacked','HandleVisibility','off');%, 'BarWidth', barWidth );
            ah(1).FaceAlpha = .0;ah(1).EdgeAlpha = .0;
            ah(2).FaceColor = cl;
            ah(2).EdgeColor = 'none';
            ah(2).FaceAlpha = .45;
        end
    end

    
end



