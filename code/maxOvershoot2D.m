function [ovs] = maxOvershoot2D(x , y,mode)
% x & y = x & y coordinate
%must be alighned to quadrant1
%mode = 1forward, 2backward
% x=newtray_raw(:,xvessleIDX); y=newtray_raw(:,yvessleIDX);   
% x=x_b; y=y_b; 

%targe tmark
target(:,1) = x(:,end);
target(:,2) = y(:,end);

    if mode ==1
        ox = (x - target(:,1))>0; 
        oy = (y - target(:,2))>0;
        ovsfind = logical(ox.*oy); %find datapoint where both x,y exceed the destination location

            if sum(sum(ovsfind))==0
                ovs = zeros(size(ovsfind,1),1);
            else
                for ovsn = 1:size(ovsfind,1)
                    if sum(ovsfind(ovsn,:))==0
                       ovs(ovsn,:)=0; 
                    else
                        temptrayX=x(ovsn,ovsfind(ovsn,:))- target(ovsn,1);
                        temptrayY=y(ovsn,ovsfind(ovsn,:))- target(ovsn,2);                
                        distan = sqrt(temptrayX.^2 + temptrayY.^2);
                        ovs(ovsn,:)=max(distan);
                    end
                end
            end
    else
        ox = (x - x(:,1))<0; 
        oy = (y - y(:,1))<0;
        ovsfind = logical(ox.*oy); %find datapoint where both x,y exceed the destination location

            if sum(sum(ovsfind))==0
                ovs = zeros(size(ovsfind,1),1);
            else
                for ovsn = 1:size(ovsfind,1)
                    if sum(ovsfind(ovsn,:))==0
                       ovs(ovsn,:)=0; 
                    else
                        temptrayX=x(ovsn,ovsfind(ovsn,:))- x(ovsn,1);
                        temptrayY=y(ovsn,ovsfind(ovsn,:))- y(ovsn,1);                
                        distan = sqrt(temptrayX.^2 + temptrayY.^2);
                        ovs(ovsn,:)=max(distan);
                    end
                end
            end

    end
end

