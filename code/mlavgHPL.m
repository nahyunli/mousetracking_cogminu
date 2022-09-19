function [newtray_raw,  wth_std] = mlavgHPL(t_raw,range)
%%
    %within subject error bars
    t_raw1=sortrows(t_raw, 1);
    plist=unique(t_raw1(:,1));
    gva=mean(t_raw1,1);%grand average
    t_raw2=zeros(size(t_raw1));
    %within subject average
    for uo = 1:numel(unique(t_raw1(:,1)))
        tempW = t_raw1(t_raw1(:,1)==plist(uo),:);
        pva =mean(tempW,1); 
        tempW=tempW-pva+gva;%within-subject average를 빼줘서 standardization을 먼저함
        t_raw2(t_raw1(:,1)==plist(uo),:)=tempW;
        clear tempW pva 
    end
    
    %위의 standardization과정에서 컨디션 코딩이 변했으므로 다시 기입을 해주는 과정
    for cc=1:numel(range)
        t_raw2(:,range(cc))=t_raw1(:,range(cc)); 
    end
    clear t_raw1    

%%


    t_raw=sortrows(t_raw, range);
    t_raw2=sortrows(t_raw2, range);        
    psize= sqrt(size(plist,1));%standard error 분모
   
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
        newtray_raw_std(i,:) = std(t_raw(mark2(i):mark2(i+1)-1,:),1); 
        wth_std(i,:) = std(t_raw2(mark2(i):mark2(i+1)-1,:),[],1);                 
    end
        newtray_raw(size(mark2,1),:) = mean(t_raw(mark2(end):end,:),1);  
        newtray_raw_std(size(mark2,1),:) = std(t_raw(mark2(end):end,:),1);
        wth_std(size(mark2,1),:) = std(t_raw2(mark2(end):end,:),[],1);          
        newtray_raw_std= newtray_raw_std./psize;%between subjects error bar
        wth_std= wth_std./psize;%within subjects error bar    
end
% error bars calculated based on 
% http://www.cogsci.nl/blog/tutorials/156-an-easy-way-to-create-graphs-with-within-subject-error-bars
% old value ? subject average + grand average
