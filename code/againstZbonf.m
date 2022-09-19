function [bonfArray, Q] = againstZbonf(dat)

%     dat=plot1(:,vvessleIDX);
    csize=size(dat,2);

    for i=1:csize
        [~,p]=ttest(dat(:,i));
        fdr(1,i)=p;
        bonfArray(1,i)=p*100;clear p
    end
    [Q] = mafdr(fdr,'BHFDR',true);
    
    if sum(Q<.05)==0
       Q=ones(1,csize)*999;
        fprintf('No significant difference detected \n');
    end
    
    if sum(bonfArray<.05)==0
       bonfArray=ones(1,csize)*999;
        fprintf('No significant difference detected \n');
    end
end

