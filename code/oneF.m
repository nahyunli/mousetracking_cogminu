function [bonfArray, Q] = oneF(dat)
% dat=t3;
%     dat=plot1(:,vvessleIDX);
    csize=size(dat,2)-2;

    for i=1:csize
        p=HP_anovaN([dat(:,1:2) dat(:,2+i)] ,'cond');
%         p(2,5);
        bonfArray(1,i)=p{2,5}*100;  %for bonferroni correction     
        fdr(1,i) = p{2,5};clear p  %for fdr correction   
    end
    if sum(bonfArray<.05)==0
       bonfArray=0;
        fprintf('No significant difference detected \n');
    end
    [Q] = mafdr(fdr,'BHFDR',true);%fdr corrected p-value    
end

