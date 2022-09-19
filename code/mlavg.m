function [newtray_raw, wth_std, datstd] = mlavg(t_raw,range)
     
%      t_raw=[abs(fiRaw.pre.total_raw_pa(:,1:8)) angle(fiRaw.pre.total_raw_pa(:,9:end))];
%      boundry = find(t_raw(1,:)==99999);
%      xvessleIDX= boundry(1)+1:boundry(1)+101; yvessleIDX= boundry(2)+1:boundry(2)+101; tvessleIDX= boundry(3)+1:boundry(3)+101;   

%%
%within subject error bars
t_raw1=sortrows(t_raw, 1);
plist=unique(t_raw1(:,1));
gva=mean(t_raw1,1);
t_raw2=zeros(size(t_raw1));
for uo = 1:numel(unique(t_raw1(:,1)))
    tempW = t_raw1(t_raw1(:,1)==plist(uo),:);
    pva =mean(tempW,1); 
    tempW=tempW-pva+gva;
    t_raw2(t_raw1(:,1)==plist(uo),:)=tempW;
    clear tempW pva 
end
%%
% within subject CI: Masson &Loftus(2003)
%error term using HP_anovaN(x1,'N0')


%critical tvalue
dfe=7;%degree of freedome
alphalev=.05;%alpha level
alphaup = 1-alphalev/2;
criT = tinv(alphaup,dfe);%critical tvalue

%%
for cc=1:numel(range)
    t_raw2(:,range(cc))=t_raw1(:,range(cc)); 
end
clear t_raw1    

%%
     
    t_raw=sortrows(t_raw, range);
    t_raw2=sortrows(t_raw2, range);    
   
    for cc=1:numel(range)
        temptray(:,cc)=t_raw(:,range(cc)); 
    end
    
    mark1=zeros(size(t_raw,1),1); mark1(1)=1;

    for i3 = 1:size(mark1,1)-1
        if sum([temptray(i3,:)]~=[temptray(i3+1,:)])>=1
            mark1(i3+1,1)=1;
        end
    end
    mark2=find(mark1);
        
    for i=1:size(mark2,1)-1
        newtray_raw(i,:) = mean(t_raw(mark2(i):mark2(i+1)-1,:),1);
        newtray_raw_std(i,:) = std(t_raw(mark2(i):mark2(i+1)-1,:),[],1); 
        wth_std(i,:) = std(t_raw2(mark2(i):mark2(i+1)-1,:),[],1);         
    end
        newtray_raw(size(mark2,1),:) = mean(t_raw(mark2(end):end,:),1);    
        newtray_raw_std(size(mark2,1),:) = std(t_raw(mark2(end):end,:),[],1);  
        wth_std(size(mark2,1),:) = std(t_raw2(mark2(end):end,:),[],1);  
        
        pn = numel(unique(t_raw(:,1)));
       newtray_raw_std= newtray_raw_std./sqrt(pn); %btw error bars unused for now
%        datstd=newtray_raw_std;       
       datstd=wth_std;%removed btw subejct variance       
       wth_std= wth_std./sqrt(pn);        
    
       
end

% error bars calculated based on 
% http://www.cogsci.nl/blog/tutorials/156-an-easy-way-to-create-graphs-with-within-subject-error-bars
% old value ? subject average + grand average