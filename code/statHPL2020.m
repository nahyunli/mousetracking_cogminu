%refer to https://stats.stackexchange.com/questions/156808/interpretation-of-hartigans-dip-test
% https://www.frontiersin.org/articles/10.3389/fpsyg.2013.00700/full
% for bimodality test

% change the significance bars for the times series plots
% add mini two way interaction plots
% !!!proofcheck the codes(espcially the two way interaction bar for the velocity times series)
%%
clc;close all;clear all
expType=3;%1=HV 2=HH
%
loc='C:\Users\Minu Kim\Desktop\work\hplab\location_based_simon_mouse\raw_jieun';
loc = [pwd '\']
cd(loc)
runStr = [loc '\*.mat'];
fileNames = dir(runStr);

load(fileNames.name);

% 
% problemp=2:16;
% fiRaw.total_raw=fiRaw.total_raw(logical(sum(fiRaw.total_raw(:,1)==problemp(1,:),2)),:);
% fiRaw.total_raw_pangle=fiRaw.total_raw_pangle(logical(sum(fiRaw.total_raw_pangle(:,1)==problemp(1,:),2)),:);
% fiRaw.avg_raw=fiRaw.avg_raw(logical(sum(fiRaw.avg_raw(:,1)==problemp(1,:),2)),:);
% fiRaw.avg_raw_pa=fiRaw.avg_raw_pa(logical(sum(fiRaw.avg_raw_pa(:,1)==problemp(1,:),2)),:);
%
dvlbl={'tLength','InitT','MT','RT','AUC','xFlip','yFlip','xEntrop','yEntrop',...
 'maxVelo','maxVeloTime','minVelo','minVeloTime' ,'meanAngle', 'n2c', 'flip2D', 'Entrop2d', 'Overshoot2d'};
way2lab={'n0c*n1c','n0c*n1ic','n0ic*n1c','n0ic*n1ic'}; %cC, iC, cI, iI
way3lab={'n0c*n1c after repit','n0c*n1ic after repit','n0ic*n1c after repit','n0ic*n1ic after repit',...
'n0c*n1c after altern','n0c*n1ic after altern','n0ic*n1c after altern','n0ic*n1ic after altern'};
%
%ANOVAs
%데이터 정리하기
ivsIDX=1:8;%데이터에서의 독립변수 위치
dvsIDX=9:26;%데이터에서의 종속변수 위치
paIDX=5:105;

ivs=[1 2 3];%분석에 필요한 독립변수
% [avged_raw, ~] = mlavg(fiRaw.total_raw, ivs);

%angle data만 따로 추출, 복소수니께....
mpa = sortrows([fiRaw.w2.avg_raw_pa(:,1:4) mean(fiRaw.w2.avg_raw_pa(:,5:end),2)], ivs);
dat=sortrows(fiRaw.w2.avg_raw, ivs);dat(:,22)=angle(mpa(:,5));
fiRaw.w2.avg_raw=sortrows(fiRaw.w2.avg_raw, ivs);fiRaw.w2.avg_raw(:,22)=angle(mpa(:,5));

for it = 1:size(ivs,2)
    ivsTray(:,it) = dat(:,ivs(it));
end

FACTNAMES22 = {'N0','N1'}; 
for i=1:size(dvsIDX,2)
    stat.w2.anovatbl{i}=HP_anovaN([ivsTray dat(:,dvsIDX(i))] ,FACTNAMES22); 
    if i==1; pcomp_2w(:,1)=stat.w2.anovatbl{i}(:,1);end
    pcomp_2w(:,i+1)=stat.w2.anovatbl{i}(:,5);
end

stat.w2.anovatbl=cell2table(stat.w2.anovatbl, 'VariableNames',dvlbl); 
pcomp_2w.Properties.VariableNames = ['source' dvlbl];
stat.w2.pval_comp=pcomp_2w;   % p-value for each dependent variables
save([loc 'Stat_oct25.mat'],'stat','-v7.3')


%%

clear ivs ivsTray FACTNAMES22 dat
ivs=[1 2 3 4];
%angle data만 따로 추출, 복소수니께....
% fiRaw.w3.avg_raw_pa(:,1:4)에서 4번열이 원래 소수점이었는데 정수 1,2로 바뀜.
mpa2 = sortrows([abs(fiRaw.w3.avg_raw_pa(:,1:4)) mean(fiRaw.w3.avg_raw_pa(:,5:end),2)], ivs);
dat=sortrows(fiRaw.w3.avg_raw, ivs);
dat(:,22)=angle(mpa2(:,5));
fiRaw.w3.avg_raw=sortrows(fiRaw.w3.avg_raw, ivs);fiRaw.w3.avg_raw(:,22)=angle(mpa2(:,5));

% for it = 1:size(ivs,2)
%     ivsTray(:,it) = dat(:,ivs(it)); %1,2,3,4열만 뽑아옴. IV 모음.
% end

ivsTray(:, 1:size(ivs,2)) = dat(:,1:size(ivs,2)); %1,2,3,4열만 뽑아옴. IV 모음.

FACTNAMES22 = {'N0','N1','Repetition'}; 
for i=1:size(dvsIDX,2) %각 DV에 대해서 anova 분석
    %cell 안에 각 DV에 대해 3-way anova 분석한 결과(table) 집어넣기
    stat.w3.anovatbl{i}=HP_anovaN([ivsTray dat(:,dvsIDX(i))] ,FACTNAMES22); 
    if i==1 
        pcomp_3w(:,1)=stat.w3.anovatbl{i}(:,1); %첫 번째에만 어떤 factor에서 나온 통계값인지 알려주는 열 집어넣기
    end
    pcomp_3w(:,i+1)=stat.w3.anovatbl{i}(:,5); %p-value가 5번째 column이므로 5번 column만 가져와서 집어넣기
end
stat.w3.anovatbl=cell2table(stat.w3.anovatbl, 'VariableNames',dvlbl);
pcomp_3w.Properties.VariableNames = ['source' dvlbl];
stat.w3.pval_comp=pcomp_3w;  
save([loc 'Stat_oct25.mat'],'stat','-v7.3')

%% Visualization Part 
% Grand Average for plots   
x=1:2;
range=[2 3];

[gdat, stderror] = mlavgHPL(fiRaw.w2.avg_raw,range);%for 2way  
[gdatM, ~] = mlavgHPL(mpa,range);gdat(:,22)=angle(gdatM(:,5));clear gdatM
[~,gdatMstd] = mlavgHPL([mpa(:,1:4) angle(mpa(:,5))],range);stderror(:,22)=gdatMstd(:,5);clear gdatMstd

range1=[4 2 3];
[gdat1, stderror1] = mlavgHPL(fiRaw.w3.avg_raw,range1);%for 3way  
[gdatM, ~] = mlavgHPL(mpa2,range1);gdat1(:,22)=angle(gdatM(:,5));clear gdatM
[~,gdatMstd] = mlavgHPL([mpa2(:,1:4) angle(mpa2(:,5))],range1);stderror1(:,22)=gdatMstd(:,5);clear gdatMstd

srs = stat.w2.pval_comp.source;srs=[srs(2); srs(3); srs(6)];%2-way: N0, N1, N0*N1
srs2 = stat.w3.pval_comp.source;srs2=[srs2(2); srs2(3); srs2(4); srs2(8); srs2(9); srs2(10); srs2(14)]; %3-way: N0, N1, Repetition, N0*N1, N0*Repetition, N1*Repetition, N0*N1*Repetition
%%
for i = 1: size(dvlbl,2)
    if i ~=14
        mxy= max(gdat(:,dvsIDX(i)))*1.1; miy= min(gdat(:,dvsIDX(i)))*0.9; % maximum y, minimum y --> to set graph range below
    elseif i==14
        mxy= max(gdat(:,dvsIDX(i)))*.9; miy= min(gdat(:,dvsIDX(i)))*1.1;
    end
    figure('units','normalized','outerposition',[0 0 1 1])
    subplot(2, 2,1)
    errorbar(x, [gdat(1,dvsIDX(i)) gdat(2,dvsIDX(i))],[stderror(1,dvsIDX(i)) stderror(2,dvsIDX(i))],'-bo','MarkerFaceColor','blue')
    hold on 
    errorbar(x, [gdat(3,dvsIDX(i)) gdat(4,dvsIDX(i))],[stderror(3,dvsIDX(i)) stderror(4,dvsIDX(i))],'--bs','MarkerFaceColor','blue')    
%     plot(x, [gdat(1,dvsIDX(i)) gdat(2,dvsIDX(i))] ,'-bo','MarkerFaceColor','blue') 
%     hold on
%     plot(x, [gdat(3,dvsIDX(i)) gdat(4,dvsIDX(i))],'--bs','MarkerFaceColor','blue') 
    xlim([0 3]);ylim([miy mxy]); %set the graph range
    xticklabels({'','','After Nonconflict(N-1)','','After Conflict(N-1)'})
    title('2Way Plot: n0*n1')
    [lgd, icons, plots, txt]= legend('Congruent(N0)','Incongruent(N0))');     
        
    subplot(2,2,2)
    text(1,8,'2Way ANOVA','FontSize',14)   
    hold on
    text(ones(1,3),7:-1:5,char(srs),'FontSize',14)   
    pv=stat.w2.pval_comp(:,i+1); %1번 열은 source이므로
    pv=[pv{2,1}; pv{3,1}; pv{6,1}];
    pvn = strcat('p =    ', num2str(pv));
    text(ones(1,3)*3,7:-1:5,char(pvn),'FontSize',14)   

    text(8,8,'3Way ANOVA','FontSize',14)   
    text(ones(1,7)*7,7:-1:1,char(srs2),'FontSize',14)   
    pv=stat.w3.pval_comp(:,i+1);
    pv=[pv{2,1}; pv{3,1}; pv{4,1}; pv{8,1}; pv{9,1}; pv{10,1}; pv{14,1}];
    pvn = strcat('p =    ', num2str(pv));
    text(ones(1,7)*12,7:-1:1,char(pvn),'FontSize',14)   
    xlim([0 16]);ylim([0 9]);
    vline(6,'r');hline(7.5,'r') %draw vertical, horizontal lines
    set(gca,'xtick',[]);set(gca,'ytick',[]);
    title('RM ANOVA Stat Table')
    
    subplot(2,2,3)   
    tgdat = gdat1(gdat1(:,4)==1,:);stderror2=stderror1(gdat1(:,4)==1,:);
    errorbar(x, [tgdat(1,dvsIDX(i)) tgdat(2,dvsIDX(i))],[stderror(1,dvsIDX(i)) stderror2(2,dvsIDX(i))],'-bo','MarkerFaceColor','blue')
    hold on 
    errorbar(x, [tgdat(3,dvsIDX(i)) tgdat(4,dvsIDX(i))],[stderror(3,dvsIDX(i)) stderror2(4,dvsIDX(i))],'--bs','MarkerFaceColor','blue')    
%     plot(x, [tgdat(1,dvsIDX(i)) tgdat(2,dvsIDX(i))] ,'-bo','MarkerFaceColor','blue') 
%     hold on
%     plot(x, [tgdat(3,dvsIDX(i)) tgdat(4,dvsIDX(i))],'--bs','MarkerFaceColor','blue') 

%15번 그림에서 3,4 subplot 그림 범위 이상함
    xlim([0 3]);ylim([miy mxy]);
    xticklabels({'','','After Nonconflict(N-1)','','After Conflict(N-1)'})
    title('3Way Plot: n0*n1 after Congruency Repetition')    
    clear tgdat
    
    subplot(2,2,4)       
    tgdat = gdat1(gdat1(:,4)==2,:);stderror2=stderror1(gdat1(:,4)==2,:);
    errorbar(x, [tgdat(1,dvsIDX(i)) tgdat(2,dvsIDX(i))],[stderror(1,dvsIDX(i)) stderror2(2,dvsIDX(i))],'-bo','MarkerFaceColor','blue')
    hold on 
    errorbar(x, [tgdat(3,dvsIDX(i)) tgdat(4,dvsIDX(i))],[stderror(3,dvsIDX(i)) stderror2(4,dvsIDX(i))],'--bs','MarkerFaceColor','blue')        
%     plot(x, [tgdat(1,dvsIDX(i)) tgdat(2,dvsIDX(i))] ,'-bo','MarkerFaceColor','blue') 
%     hold on
%     plot(x, [tgdat(3,dvsIDX(i)) tgdat(4,dvsIDX(i))],'--bs','MarkerFaceColor','blue') 
    xlim([0 3]);ylim([miy mxy]);
    xticklabels({'','','After Nonconflict(N-1)','','After Conflict(N-1)'})
    title('3Way Plot: n0*n1 after Congruency Alternation')    

    
%    suptitle(sprintf('DV: %s',char(dvlbl(i))))    
    savefig(gcf, [loc 'figures/' sprintf('W2_ANOVAPLOTS_%s',char(dvlbl(i)))])
    saveas(gcf,[loc 'figures/' sprintf('W2_ANOVAPLOTS_%s',char(dvlbl(i))) '.tiff'])    
   close
end
%%
%define boundarys 
boundry = find(gdat(1,:)==99999);
xvessleIDX= boundry(1)+1:boundry(2)-1; yvessleIDX= boundry(2)+1:boundry(3)-1; 
tvessleIDX= boundry(3)+1:boundry(4)-1; vvessleIDX= boundry(4)+1:boundry(5)-1;           
avessleIDX= boundry(5)+1:boundry(5)+99;           
vx=1:100;x=2:101;
%%
%velocity times series stat
%%

%Velocity
[gdatv, ~] = mlavgHPL(fiRaw.w2.avg_raw,[1,2,3]);%for 2way  
[gdat1v, ~] = mlavgHPL(fiRaw.w3.avg_raw,[1,4,2,3]);%for 3way  

%1sub/N0/N1/CongRep
plot1=gdatv(1:4,1:3);plot2=gdat1v(1:8,1:4);
for cn=1:2:3
    t1=gdatv(sum(gdatv(:,2:3)==plot1(cn,2:3),2)==2,:);
    t2=gdatv(sum(gdatv(:,2:3)==plot1(cn+1,2:3),2)==2,:);
    t3=[t1;t2];t3=[t3(:,1) t3(:,3) t3(:,vvessleIDX)];
    [~,fArray1] = oneF(t3);
    V2way.(sprintf('raw%d', round(cn/2)))=fArray1;      
    clear t1 t2 t3 fArray2 fArray1     
end
%two way interaction for PS poster
t2a=[gdatv(:,1:3) gdatv(:,vvessleIDX)];
csize=size(t2a,2)-3;
for i=1:csize
    p=HP_anovaN([t2a(:,1:3) t2a(:,3+i)] ,{'n0','n1'});
    fdr(1,i) = p{6,5};clear p  %for fdr correction   
end
[t2Vsr] = mafdr(fdr,'BHFDR',true);%fdr corrected p-value   
    
for cn=1:2:8
    t1=gdat1v(sum(gdat1v(:,2:4)==plot2(cn,2:4),2)==3,:);
    t2=gdat1v(sum(gdat1v(:,2:4)==plot2(cn+1,2:4),2)==3,:);
    t3=[t1;t2];t3=[t3(:,1) t3(:,3) t3(:,vvessleIDX)];    
    [~,fArray1] = oneF(t3);
    V3way.(sprintf('raw%d', round(cn/2)))=fArray1;        
    clear t1 t2 t3 fArray1     
end

%main effects
[vOneN0, ~] = mlavgHPL(fiRaw.total_raw,[1,2]);%for 2way 
vOneN0=[vOneN0(:,1) vOneN0(:,2) vOneN0(:,vvessleIDX)];
[~,fArray1] = oneF(vOneN0);
V2way.main_n0=fArray1;clear fArray1  

[vOneN1, ~] = mlavgHPL(fiRaw.total_raw,[1,3]);%for 2way  
vOneN1=[vOneN1(:,1) vOneN1(:,3) vOneN1(:,vvessleIDX)];
[~,fArray1] = oneF(vOneN1);
V2way.main_n1=fArray1;clear fArray1  

% Result
%{
No significant difference detected 
No significant difference detected 
No significant difference detected 
No significant difference detected 
No significant difference detected 
%}
%%
%initiation time calcuation

%initiation time 시점 찾는 코드
tinfo=gdat(:,tvessleIDX);initP=gdat(:,10);tinfo1=gdat1(:,tvessleIDX);initP1=gdat1(:,10);
ppoint=tinfo-initP;ppoint(ppoint<=0)=9999;
ppoint1=tinfo1-initP1;ppoint1(ppoint1<=0)=9999;
ppoint=min(ppoint,[],2);ppoint1=min(ppoint1,[],2);

for i = 1:size(ppoint,1)
    initPIDX(i,:)=find(abs(tinfo(i,:)-initP(i,:))==ppoint(i,:),1);
    initPIDX2(i,:)=tinfo(i,initPIDX(i,:)-1);
    initPIDX(i,:)=initPIDX(i,:)-1;
end
for i = 1:size(ppoint1,1)
    initPIDX11(i,:)=find(abs(tinfo1(i,:)-initP1(i,:))==ppoint1(i,:),1);
    initPIDX22(i,:)=tinfo1(i,initPIDX11(i,:)-1);
    initPIDX11(i,:)=initPIDX11(i,:)-1;
end

%아래 minitS에서 1씩 빼주는건 angle plot 그래프가 0부터 시작하므로 스텝이 1씩 앞으로 땡겨져야 하기 때문
minitS = mean(initPIDX)-1;minitR = mean(initPIDX2);
minitS2 = [mean(initPIDX11(1:4))-1; mean(initPIDX11(5:8))-1];minitR2 = [mean(initPIDX22(1:4)); mean(initPIDX22(5:8))];

%%
%velocity figure
figure('units','normalized','outerposition',[0 0 1 1])
set(gca,'Position',[0.1 .12 0.88 0.84]);
prtsha_HPL(x,gdat(1,vvessleIDX),stderror(1,vvessleIDX),'b','b')
hold on
prtsha_HPL(x,gdat(2,vvessleIDX),stderror(2,vvessleIDX),'b','--b')
prtsha_HPL(x,gdat(3,vvessleIDX),stderror(3,vvessleIDX),'r','r')
prtsha_HPL(x,gdat(4,vvessleIDX),stderror(4,vvessleIDX),'r','--r')
% [lg,hobj,~,~]=legend({'cC','iC','cI','II'},'Location','northeast');   
legend({'cC','iC','cI','iI'},'Location','northeast');legend boxoff;   
% hl = findobj(hobj,'type','line');set(hl,'LineWidth',2.5);
% ht = findobj(hobj,'type','text');set(ht,'FontSize',30);set(ht,'FontName',ftname);
% set(lg,'position',[.86 .72 .10 .20])
% sigplotter4(V2way.raw1,2.2,x,.1, 'b');%dat/bar위치/x/thickness, color
% sigplotter4(V2way.raw2,2.3,x,.1, 'r');%dat/bar위치/x/thickness, color

sigplotter4(V2way.main_n0,2.38,x,.12, [0 .8 .2]);text(4,2.443 ,'N Main Effect (Blue vs Red lines)');
sigplotter4(V2way.main_n1,2.26,x,.12, [1 .8 0]);text(4,2.323,'N-1 Main Effect (Solid vs Dashed lines)');
sigplotter4(t2Vsr,2.14,x,.12, 'k');text(4,2.203,'N * N-1 Interaction');

ylabel('Speed (px/ms)');xlabel('Time Step')
ylim([0 2.5]);xlim([0 101]);
vline(minitS+1, 'k', sprintf('Mean Initiation Point: %.2f ms', minitR));
plot([0 101], [0 0],'w','LineWidth',2.5,'HandleVisibility','off')
% title('Velocity within a trial window')

srgA1=30:32;mv1=round(mean(gdat(:,vvessleIDX(:,srgA1)),2),3);%time step으로는 30~33
srgA2=65:66;mv2=round(mean(gdat(:,vvessleIDX(:,srgA2)),2),3);
mv1=reshape(mv1,[2 2])';mv2=reshape(mv2,[2 2])';
%actual time rage for selected times steps
tr1=[round(mean(gdat(:,tvessleIDX(:,srgA1(1))),1)) round(mean(gdat(:,tvessleIDX(:,srgA1(end)+1)),1))];
tr1(2,:)=[round(mean(gdat(:,tvessleIDX(:,srgA2(1))),1)) round(mean(gdat(:,tvessleIDX(:,srgA2(end)+1)),1))];
round(mean(gdat(:,tvessleIDX(:,end)),1))

axes('Position',[.175 .55 .14 .23])
    errorbar(mv1(1,:),[nan nan],'b','LineWidth', 1.5)
    hold on
    errorbar(mv1(2,:),[nan nan],'r','LineWidth', 1.5) 
    xlim([0 3]);ylim([0 2.5]);xticklabels({'','C','IC'})
    xlabel('Prev Trial C');ylabel('Speed')
axes('Position',[.67 .55 .14 .23])    
    errorbar(mv2(1,:),[nan nan],'b','LineWidth', 1.5)
    hold on
    errorbar(mv2(2,:),[nan nan],'r','LineWidth', 1.5)    
    xlim([0 3]);ylim([0 2.5]);xticklabels({'','','C','','IC'})
    xlabel('Prev Trial C');ylabel('Speed')
    
%detailed stats for the first figure

%세부분석    
sa1=[fiRaw.w2.avg_raw(:,1:3) mean(fiRaw.w2.avg_raw(:,vvessleIDX(:,srgA1)),2)];
sa1_1=sa1(sa1(:,3)==1,:);
sa1_2=sa1(sa1(:,3)==2,:);
HP_anovaN([sa1_1(:,1:2) sa1_1(:,4)] ,'Cong')
HP_anovaN([sa1_2(:,1:2) sa1_2(:,4)] ,'Cong')
[mlavg(sa1_1,2) mlavg(sa1_2,2)]

sa2=[fiRaw.w2.avg_raw(:,1:3) mean(fiRaw.w2.avg_raw(:,vvessleIDX(:,srgA2)),2)];
sa2_1=sa2(sa2(:,3)==1,:);
sa2_2=sa2(sa2(:,3)==2,:);
HP_anovaN([sa2_1(:,1:2) sa2_1(:,4)] ,'Cong')
HP_anovaN([sa2_2(:,1:2) sa2_2(:,4)] ,'Cong')
[mlavg(sa2_1,2) mlavg(sa2_2,2)]
clear sa1 sa2 sa1_1 sa1_2 sa2_1 sa2_2

%main effect
%actual time rage for selected times steps(N0)
srgA1=14:32;mv1=mean(vOneN0(:,srgA1+2),2);
srgA2=37:99;mv2=mean(vOneN0(:,srgA2+2),2);
tr1=[round(mean(gdat(:,tvessleIDX(:,srgA1(1))),1)) round(mean(gdat(:,tvessleIDX(:,srgA1(end)+1)),1))];
tr1(2,:)=[round(mean(gdat(:,tvessleIDX(:,srgA2(1))),1)) round(mean(gdat(:,tvessleIDX(:,srgA2(end)+1)),1))];
HP_anovaN([vOneN0(:,1:2) mv1] ,'Cong')
HP_anovaN([vOneN0(:,1:2) mv2] ,'Cong')

mlavg([vOneN0(:,1:2) mv1], 2)
mlavg([vOneN0(:,1:2) mv2], 2)

%actual time rage for selected times steps(N1)
srgA1=4:28;mv1=mean(vOneN1(:,srgA1+2),2);
tr1=[round(mean(gdat(:,tvessleIDX(:,srgA1(1))),1)) round(mean(gdat(:,tvessleIDX(:,srgA1(end)+1)),1))];
HP_anovaN([vOneN1(:,1:2) mv1] ,'Cong')
mlavg([vOneN1(:,1:2) mv1], 2)

%%
%grand trajectory
figure('units','normalized','outerposition',[0 0 1 1])
set(gca,'Position',[0.08 .12 0.90 0.84]);

plot(gdat(1,xvessleIDX),gdat(1,yvessleIDX),'b')
hold on
plot(gdat(2,xvessleIDX),gdat(2,yvessleIDX),'--b')
plot(gdat(3,xvessleIDX),gdat(3,yvessleIDX),'r')
plot(gdat(4,xvessleIDX),gdat(4,yvessleIDX), '--r')
for ini = 1:4
    err = ones(1,size(xvessleIDX(1):xvessleIDX(1)+initPIDX(ini)-1,2)).*0.2;
    prtsha_HPL(gdat(ini,xvessleIDX(1):xvessleIDX(1)+initPIDX(ini)-1),gdat(ini,yvessleIDX(1):yvessleIDX(1)+initPIDX(ini)-1), err ,'k','k')
end
legend({'cC','iC','cI','iI'},'Location','northeast');legend boxoff;  
ylabel('Y Coordinate (px)');xlabel('X Coordinate (px)')
xlim([-100 350]);ylim([-10 35]);
%title('Average Trajectory by Conditions')
%%
%statistical analysis of angle
%complex plane version
range=[1 2 3];[pdat00, ~] = mlavgHPL(fiRaw.total_raw_pangle, range); 
% range=[1 2 3];[pdat00, ~] = mlavgHPL(fiRaw.total_raw_wangle, range); 
range=[2 3];[pdat, ~] = mlavgHPL(pdat00, range);pdat=[pdat(:,1:4) angle(pdat(:,5:end))]; 
[~, pdat_std] = mlavgHPL([pdat00(:,1:4) angle(pdat00(:,5:end))], range); 
pdat_std(:,1:4)=pdat(:,1:4);

range=[1 4 2 3];[pdat02, ~] = mlavgHPL(fiRaw.total_raw_pangle, range); 
range=[4 2 3];[pdat1, ~] = mlavgHPL(pdat02, range);pdat1=[pdat1(:,1:4) angle(pdat1(:,5:end))]; 
[~, pdat1_std] = mlavgHPL([pdat02(:,1:4) angle(pdat02(:,5:end))], range); 
pdat1_std(:,1:4)=pdat1(:,1:4);
aIDX=5:104;%NaIDX=aIDX-2;
pdat00=[pdat00(:,1:4) angle(pdat00(:,5:end));];
pdat02=[pdat02(:,1:4) angle(pdat02(:,5:end));];
pdat00=sortrows(pdat00,[2 3]);pdat02=sortrows(pdat02,[4 2 3]);

%1sub/N0/N1/CongRep
plot1=pdat(1:4,1:3);plot2=pdat1(1:8,1:4);
for cn=1:2:3
    t1=pdat00(sum(pdat00(:,2:3)==plot1(cn,2:3),2)==2,:);
    t2=pdat00(sum(pdat00(:,2:3)==plot1(cn+1,2:3),2)==2,:);
    t3=[t1;t2];t3=[t3(:,1) t3(:,3) t3(:,aIDX)];
    if cn==1
        [~,fArray1] = oneF(t3);
        f2way.(sprintf('raw%d', 1))=fArray1;        
    else
        [~,fArray2] = oneF(t3);
        f2way.(sprintf('raw%d', 2))=fArray2;           
    end
    clear t1 t2 t3 fArray2 fArray1     
end

%two way interaction for PS poster
csize=size(pdat00,2)-4;
for i=1:csize
    p=HP_anovaN([pdat00(:,1:3) pdat00(:,4+i)] ,{'n0','n1'});
    fdr(1,i) = p{6,5};clear p  %for fdr correction   
end
[t2Asr] = mafdr(fdr,'BHFDR',true);%fdr corrected p-value   
clear csize fdr

for cn=1:2:8
    t1=pdat02(sum(pdat02(:,2:4)==plot2(cn,2:4),2)==3,:);
    t2=pdat02(sum(pdat02(:,2:4)==plot2(cn+1,2:4),2)==3,:);
    t3=[t1;t2];t3=[t3(:,1) t3(:,3) t3(:,aIDX)];    
    [fArray1] = oneF(t3);
    f3way.(sprintf('raw%d', round(cn/2)))=fArray1;        
    clear t1 t2 t3 fArray1     
end

[ang_n0, ~] = mlavgHPL(fiRaw.total_raw_pangle, [1 2]); 
[ang_n1, ~] = mlavgHPL(fiRaw.total_raw_pangle, [1 3]); 
% [ang_n0, ~] = mlavgHPL(fiRaw.total_raw_wangle, [1 2]); 
% [ang_n1, ~] = mlavgHPL(fiRaw.total_raw_wangle, [1 3]); 
ang_n0=[ang_n0(:,1:2) angle(ang_n0(:,5:end))];
ang_n1=[ang_n1(:,1) ang_n1(:,3) angle(ang_n1(:,5:end))];
[tt1,fArray1] = oneF(ang_n0);
f2way.main_n0=fArray1;clear fArray1
[tt2,fArray1] = oneF(ang_n1);
f2way.main_n1=fArray1;clear fArray1
% tt2=tt2./100;

%%
%angle plot
figure('units','normalized','outerposition',[0 0 1 1])
set(gca,'Position',[0.1 .12 0.88 0.84]);
paIDX=5:104;

range=[1 2 3];[pdat00, ~] = mlavgHPL(fiRaw.total_raw_pangle, range); 
% range=[1 2 3];[pdat00, ~] = mlavgHPL(fiRaw.total_raw_wangle, range); 

range=[2 3];[pdat, ~] = mlavgHPL(pdat00, range);pdat=[pdat(:,1:4) angle(pdat(:,5:end))]; 
pdat_std0= [pdat00(:,1:4) angle(pdat00(:,5:end))]; 
[~, pdat_std] = mlavgHPL(pdat_std0, range); 
pdat_std(:,1:4)=pdat(:,1:4);


prtsha_HPL(x,pdat(1,paIDX),pdat_std(1,paIDX),'b','b')
hold on
prtsha_HPL(x,pdat(2,paIDX),pdat_std(2,paIDX),'b','--b')
prtsha_HPL(x,pdat(3,paIDX),pdat_std(3,paIDX),'r','r')
prtsha_HPL(x,pdat(4,paIDX),pdat_std(4,paIDX),'r','--r')
% set(gca,'FontSize',20)
xlim([0 101]);ylim([-.5 1.27])
legend({'cC','iC','cI','iI'});legend boxoff;  
vline(minitS+1, 'k', sprintf('Mean Initiation Point: %.2f ms', minitR));
ylabel('Angle (Radian)');xlabel('Time Step')

% title('Angle within a trial window')
% sigplotter4(f2way.raw1,1.1,x,.1, 'b');%dat/bar위치/x/thickness, color
% sigplotter4(f2way.raw2,1.1,x,.05, 'r');%dat/bar위치/x/thickness, color
sigplotter4(f2way.main_n0,1.185,x,.085, [0 .8 .2]);text(4,1.23 ,'N Main Effect (Blue vs Red lines)','FontSize',10,'FontName','Times');
sigplotter4(f2way.main_n1,1.1,x,.085, [1 .8 0]);text(4,1.145 ,'N-1 Main Effect (Solid vs Dashed lines)','FontSize',10,'FontName','Times');
sigplotter4(t2Asr,1.015,x,.085, 'k');text(4,1.06,'N * N-1 Interaction','FontSize',10,'FontName','Times' );
% sigplotter4(tt2,1.05,x,.05, [1 .8 .0]);
% sigplotter4(f2way.main_n1,1.05,x,.05, [1 .8 0]);%text(5,1.0045,vname(1),'FontSize',7);



rangez=[1 2 3];[pdat00z, ~] = mlavgHPL(fiRaw.total_raw_pangle, rangez); 
% rangez=[1 2 3];[pdat00z, ~] = mlavgHPL(fiRaw.total_raw_wangle, rangez); 
rangez=[2 3];[pdatz, ~] = mlavgHPL(pdat00z, rangez);


srgA1=19:24;mv1=angle(mean(pdatz(:,srgA1+4),2));
srgA2=32:33;mv2=angle(mean(pdatz(:,srgA2+4),2));
mv1=reshape(mv1,[2 2])';mv2=reshape(mv2,[2 2])';

axes('Position',[.43 .58 .14 .23])
    errorbar(mv1(1,:),[nan nan],'b','LineWidth', 1.5)
    hold on
    errorbar(mv1(2,:),[nan nan],'r','LineWidth', 1.5) 
    xlim([0 3]);ylim([-.1 .55]);xticklabels({'','C','IC'})
    xlabel('Prev Trial C');ylabel('Radian')
axes('Position',[.67 .58 .14 .23])
    errorbar(mv2(1,:),[nan nan],'b','LineWidth', 1.5)
    hold on
    errorbar(mv2(2,:),[nan nan],'r','LineWidth', 1.5)    
    xlim([0 3]);ylim([-.1 .55]);xticklabels({'','C','IC'})
    xlabel('Prev Trial C');ylabel('Radian')
    
%actual time rage for selected times steps
tr1=[round(mean(gdat(:,tvessleIDX(:,srgA1(1))),1)) round(mean(gdat(:,tvessleIDX(:,srgA1(end)+1)),1))];
tr1(2,:)=[round(mean(gdat(:,tvessleIDX(:,srgA2(1))),1)) round(mean(gdat(:,tvessleIDX(:,srgA2(end)+1)),1))];
round(mean(gdat(:,tvessleIDX(:,end)),1))    

range=[1 2 3];[pdat00, ~] = mlavgHPL(fiRaw.total_raw_pangle, range);    
% pdat00=[pdat00(:,1:4) angle(pdat00(:,5:end));];    

%세부분석 이거다시    
sa1=[pdat00(:,1:3) mean(pdat00(:,srgA1+4),2)];
sa1_1=sa1(sa1(:,3)==1,:);
sa1_2=sa1(sa1(:,3)==2,:);
avg1=[angle(mlavg(sa1_1,2)) angle(mlavg(sa1_2,2))]

sa1_1=[sa1_1(:,1:3) angle(sa1_1(:,4))];
sa1_2=[sa1_2(:,1:3) angle(sa1_2(:,4))];    
HP_anovaN([sa1_1(:,1:2) sa1_1(:,4)] ,'Cong')
HP_anovaN([sa1_2(:,1:2) sa1_2(:,4)] ,'Cong')
%%
sa2=[pdat00(:,1:3) mean(pdat00(:,srgA2+4),2)];
sa2_1=sa2(sa2(:,3)==1,:);
sa2_2=sa2(sa2(:,3)==2,:);
avg2=[angle(mlavg(sa2_1,2)) angle(mlavg(sa2_2,2))]

sa2_1=[sa2_1(:,1:3) angle(sa2_1(:,4))];
sa2_2=[sa2_2(:,1:3) angle(sa2_2(:,4))];    
HP_anovaN([sa2_1(:,1:2) sa2_1(:,4)] ,'Cong')
HP_anovaN([sa2_2(:,1:2) sa2_2(:,4)] ,'Cong')
clear sa1 sa2 sa1_1 sa1_2 sa2_1 sa2_2


%main effect
% [pdatN0, ~] = mlavgHPL(fiRaw.total_raw_wangle, [1 2]);    
[pdatN0, ~] = mlavgHPL(fiRaw.total_raw_pangle, [1 2]);    
srgA1=6:73;mv1=angle(mean(pdatN0(:,srgA1+4),2));
srgA2=82:95;mv2=angle(mean(pdatN0(:,srgA2+4),2));
tr1=[round(mean(gdat(:,tvessleIDX(:,srgA1(1))),1)) round(mean(gdat(:,tvessleIDX(:,srgA1(end)+1)),1))];
tr1(2,:)=[round(mean(gdat(:,tvessleIDX(:,srgA2(1))),1)) round(mean(gdat(:,tvessleIDX(:,srgA2(end)+1)),1))];

HP_anovaN([pdatN0(:,1:2) mv1] ,'Cong')
HP_anovaN([pdatN0(:,1:2) mv2] ,'Cong')

mlavg([pdatN0(:,1:2) mv1], 2); ans(2,3)-ans(1,3)
mlavg([pdatN0(:,1:2) mv2], 2); ans(2,3)-ans(1,3)



% PS plot1
x=1:2;
voi=[10 11 13 22];
dvn={'Initiation Time', 'Movement Time', 'Area Under Curve', 'Mean Angle'};
ylab={'Time (msec)', 'Time (msec)', 'Area Size (pixel)', 'Angle (radian)'};
figure('units','normalized','outerposition',[0 0 1 1])
for i = 1:4
    if i ~=4;mxy= max(gdat(:,voi(i)))*1.1;miy= min(gdat(:,voi(i)))*0.9;
    elseif i==4;mxy= max(gdat(:,voi(i)))*.9;miy= min(gdat(:,voi(i)))*1.1;end
    figure('units','normalized','outerposition',[0 0 1 1])
    set(gca,'Position',[0.06 .07 0.92 0.89]);
    errorbar(x, [gdat(1,voi(i)) gdat(2,voi(i))],[stderror(1,voi(i)) stderror(2,voi(i))],'-bo','MarkerFaceColor','blue')
    hold on 
    errorbar(x, [gdat(3,voi(i)) gdat(4,voi(i))],[stderror(3,voi(i)) stderror(4,voi(i))],'--bs','MarkerFaceColor','blue')    

    xlim([0 3]);ylim([miy mxy]);
    xticklabels({'','','After Nonconflict(N-1)','','After Conflict(N-1)'})
    [lgd, icons, plots, txt]= legend('Congruent(N0)','Incongruent(N0))');  
    title(sprintf('%s',dvn{i}))
    ylabel(sprintf('%s',ylab{i}))    
    
    savefig(gcf, [loc 'figures/' sprintf('%s',dvn{i})])
    saveas(gcf,[loc 'figures/' sprintf('%s',dvn{i}) '.tiff'])    
    
%     
%     if i==1;set(gca,'Position',[0.06 .58 0.43 0.38]);
%     elseif i ==2;set(gca,'Position',[0.56 .58 0.43 0.38]);
%     elseif i ==3;set(gca,'Position',[0.06 .08 0.43 0.38]);
%     elseif i==4;set(gca,'Position',[0.56 .08 0.43 0.38]);end
end
%% angle, trajectory, speed 보여주기
%trajectory figure
%identify xy vessles   


%%
% grant figure
velo=[0 gdat(1,vvessleIDX)];p=plot3(gdat(1,xvessleIDX),gdat(1,yvessleIDX),velo );
p.LineWidth = 3;xlabel('X Coordinate (px)');ylabel('Y Coordinate (px)');
zlabel('Speed (px/ms)');
hold on 
p2=plot3(gdat(1,xvessleIDX(1:22)),gdat(1,yvessleIDX(1:22)),velo(1:22) ,'r');p2.LineWidth = 3;
x=[0 0 350 350];y=[0 12 12 0];z=ones(4, 4)*.96;sf=surf(x,y,z);
sf.EdgeColor=[1 1 1];sf.FaceColor=[.4 1 .2];sf.FaceAlpha=.5;
xlim([0 350])
ylim([0 12])
zlim([0 1.4])
%%
figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,1,1)
plot(fiRaw.w2.avg_raw(fiRaw.w2.avg_raw(:,2)==1,xvessleIDX)', fiRaw.w2.avg_raw(fiRaw.w2.avg_raw(:,2)==1,yvessleIDX)')
xlim([-150 350]);ylim([-50 100]);vline(0,':r');hline(0,':r');
title('Congruent trial trajectories')
subplot(2,1,2)
plot(fiRaw.w2.avg_raw(fiRaw.w2.avg_raw(:,2)==2,xvessleIDX)', fiRaw.w2.avg_raw(fiRaw.w2.avg_raw(:,2)==2,yvessleIDX)')
xlim([-150 350]);ylim([-50 100]);vline(0,':r');hline(0,':r');
title('Incongruent trial trajectories')
savefig(gcf, [loc 'figures/' '1)RawTrajectories'])
saveas(gcf,[loc 'figures/' '1)RawTrajectories' '.tiff']);close 

%%
%grand mean trajetory
%%
%%
figure('units','normalized','outerposition',[0 0 1 1])
subplot(3,1,1)
plot(gdat(1,xvessleIDX),gdat(1,yvessleIDX),'b')
hold on
plot(gdat(2,xvessleIDX),gdat(2,yvessleIDX),'--b')
plot(gdat(3,xvessleIDX),gdat(3,yvessleIDX),'r')
plot(gdat(4,xvessleIDX),gdat(4,yvessleIDX), '--r')
for ini = 1:4
    err = ones(1,size(xvessleIDX(1):xvessleIDX(1)+initPIDX(ini)-1,2)).*0.2;
    prtsha_HPL(gdat(ini,xvessleIDX(1):xvessleIDX(1)+initPIDX(ini)-1),gdat(ini,yvessleIDX(1):yvessleIDX(1)+initPIDX(ini)-1), err ,'k','k')
end
legend('C after Nonconflict','C after Conflict','IC after Nonconflict','IC after Conflict','Location','northeast') 
ylabel('Y Coordinate (px)');xlabel('X Coordinate (px)')
xlim([-100 350]);ylim([-10 35]);title('2Way Plot: n0*n1')

subplot(3,1,2)
tgdat = gdat1(gdat1(:,4)==1,:);initPIDX3=initPIDX11(1:4,:);
plot(tgdat(1,xvessleIDX),tgdat(1,yvessleIDX),'b')
hold on
plot(tgdat(2,xvessleIDX),tgdat(2,yvessleIDX),'--b')
plot(tgdat(3,xvessleIDX),tgdat(3,yvessleIDX),'r')
plot(tgdat(4,xvessleIDX),tgdat(4,yvessleIDX), '--r')
for ini = 1:4
    err = ones(1,size(xvessleIDX(1):xvessleIDX(1)+initPIDX3(ini)-1,2)).*0.2;
    prtsha_HPL(tgdat(ini,xvessleIDX(1):xvessleIDX(1)+initPIDX3(ini)-1),tgdat(ini,yvessleIDX(1):yvessleIDX(1)+initPIDX3(ini)-1), err ,'k','k')
end
ylabel('Y Coordinate (px)');xlabel('X Coordinate (px)')
title('3Way Plot: n0*n1 after Congruency Repetition');
xlim([-100 350]);ylim([-10 35]);
clear tgdat

subplot(3,1,3)
tgdat = gdat1(gdat1(:,4)==2,:);initPIDX3=initPIDX11(5:8,:);
plot(tgdat(1,xvessleIDX),tgdat(1,yvessleIDX),'b')
hold on
plot(tgdat(2,xvessleIDX),tgdat(2,yvessleIDX),'--b')
plot(tgdat(3,xvessleIDX),tgdat(3,yvessleIDX),'r')
plot(tgdat(4,xvessleIDX),tgdat(4,yvessleIDX), '--r')
for ini = 1:4
    err = ones(1,size(xvessleIDX(1):xvessleIDX(1)+initPIDX3(ini)-1,2)).*0.2;
    prtsha_HPL(tgdat(ini,xvessleIDX(1):xvessleIDX(1)+initPIDX3(ini)-1),tgdat(ini,yvessleIDX(1):yvessleIDX(1)+initPIDX3(ini)-1), err ,'k','k')
end
ylabel('Y Coordinate (px)');xlabel('X Coordinate (px)')
title('3Way Plot: n0*n1 after Congruency Alternation');
xlim([-100 350]);ylim([-10 35]);
subtitle('Mean Trajectory by condition')
savefig(gcf, [loc 'figures/' 'GrandMeanTrajectories'])
saveas(gcf,[loc 'figures/' 'GrandMeanTrajectories' '.tiff']);close 

%%
%acceleration
%tagainstzero
disp('hhh')
% cse1Acc = againstZbonf(total_cse1(:,avessleIDX));
% cse1V = againstZbonf(total_cse1(:,vvessleIDX));
% cse1Ang = againstZbonf(total_cse1(:,cseAvessleIDX));


for cn=1:2
    t1=total_cse2(total_cse2(:,4)==1,:);
    tray1 = againstZbonf(t1(:,avessleIDX));
    tray2 = againstZbonf(t1(:,vvessleIDX));
    tray3 = againstZbonf(t1(:,cseAvessleIDX));    
    cse2Acc.rep=tray1;cse2V.rep=tray2;cse2Ang.rep=tray3;
    clear tray1 tray2 tray3 t1
    
    t2=total_cse2(total_cse2(:,4)==2,:);

    tray1 = againstZbonf(t2(:,avessleIDX));
    tray2 = againstZbonf(t2(:,vvessleIDX));
    tray3 = againstZbonf(t2(:,cseAvessleIDX));  
    cse2Acc.alt=tray1;cse2V.alt=tray2;cse2Ang.alt=tray3;    
    clear tray1 tray2 tray3 t2
    
end

%for acceleration
[gdatv, ~] = mlavgHPL(fiRaw.w2.avg_raw,[1,2,3]);%for 2way  
[gdat1v, ~] = mlavgHPL(fiRaw.w3.avg_raw,[1,4,2,3]);%for 3way  

%1sub/N0/N1/CongRep
plot1=gdatv(1:4,1:3);plot2=gdat1v(1:8,1:4);
for cn=1:2:3
    t1=gdatv(sum(gdatv(:,2:3)==plot1(cn,2:3),2)==2,:);
    t2=gdatv(sum(gdatv(:,2:3)==plot1(cn+1,2:3),2)==2,:);
    t3=[t1;t2];t3=[t3(:,1) t3(:,3) t3(:,avessleIDX)];
    [fArray1] = oneF(t3);
    A2way.(sprintf('raw%d', round(cn/2)))=fArray1;      
    clear t1 t2 t3 fArray2 fArray1     
end
for cn=1:2:8
    t1=gdat1v(sum(gdat1v(:,2:4)==plot2(cn,2:4),2)==3,:);
    t2=gdat1v(sum(gdat1v(:,2:4)==plot2(cn+1,2:4),2)==3,:);
    t3=[t1;t2];t3=[t3(:,1) t3(:,3) t3(:,avessleIDX)];    
    [fArray1] = oneF(t3);
    A3way.(sprintf('raw%d', round(cn/2)))=fArray1;        
    clear t1 t2 t3 fArray1     
end
%
x=3:101;
figure('units','normalized','outerposition',[0 0 1 1])
subplot(4,1,1);set(gca,'Position',[0.06 .79 0.92 0.18]);
prtsha_HPL(x,gdat(1,avessleIDX),stderror(1,avessleIDX),'b','b')
hold on
prtsha_HPL(x,gdat(2,avessleIDX),stderror(2,avessleIDX),'b','--b')
prtsha_HPL(x,gdat(3,avessleIDX),stderror(3,avessleIDX),'r','r')
prtsha_HPL(x,gdat(4,avessleIDX),stderror(4,avessleIDX),'r','--r')
sigplotter2(A2way.raw1,1.8,x,.0015,'b');%(dat,locs,xvar2,tk, cl)  
legend('C after Nonconflict','C after Conflict','IC after Nonconflict','IC after Conflict','Location','northeast') 
ylabel('Acceleration(px/ms^2)');xlim([0 101]);%xlabel('Time Step');
% ylim([0 3]);% xlim([0 350]);
vline(minitS+1, 'k', sprintf('Mean Initiation Point: %f ms', minitR));hline(0,'--k');
title('2Way Plot: n0*n1')

subplot(4,1,2);set(gca,'Position',[0.06 .55 0.92 0.18]);
tgdat = gdat1(gdat1(:,4)==1,:);stderror2=stderror1(gdat1(:,4)==1,:);
prtsha_HPL(x,tgdat(1,avessleIDX),stderror2(1,avessleIDX),'b','b')
hold on
prtsha_HPL(x,tgdat(2,avessleIDX),stderror2(2,avessleIDX),'b','--b')
prtsha_HPL(x,tgdat(3,avessleIDX),stderror2(3,avessleIDX),'r','r')
prtsha_HPL(x,tgdat(4,avessleIDX),stderror2(4,avessleIDX),'r','--r')
sigplotter2(A3way.raw1,1.8,x,.0015,'b');%(dat,locs,xvar2,tk, cl)  
ylabel('Acceleration(px/ms^2)');xlim([0 101]);%xlabel('Time Step');
vline(minitS2(1)+1, 'k', sprintf('Mean Initiation Point: %f ms', minitR2(1)));hline(0,'--k');
title('3Way Plot: n0*n1 after Congruency Repetition');
clear tgdat stderror2

subplot(4,1,3);set(gca,'Position',[0.06 .31 0.92 0.18]);
tgdat = gdat1(gdat1(:,4)==2,:);stderror2=stderror1(gdat1(:,4)==2,:);
prtsha_HPL(x,tgdat(1,avessleIDX),stderror2(1,avessleIDX),'b','b')
hold on
prtsha_HPL(x,tgdat(2,avessleIDX),stderror2(2,avessleIDX),'b','--b')
prtsha_HPL(x,tgdat(3,avessleIDX),stderror2(3,avessleIDX),'r','r')
prtsha_HPL(x,tgdat(4,avessleIDX),stderror2(4,avessleIDX),'r','--r')
ylabel('Acceleration(px/ms^2)');xlim([0 101]);%xlabel('Time Step');
vline(minitS2(2)+1, 'k', sprintf('Mean Initiation Point: %f ms', minitR2(2)));hline(0,'--k');
title('3Way Plot: n0*n1 after Congruency Alternation');
clear tgdat stderror2

subplot(4,1,4);set(gca,'Position',[0.06 .07 0.92 0.18]);
prtsha_HPL(x,cse2way(1,avessleIDX),cse2waystd(1,avessleIDX),'k','k')
hold on
prtsha_HPL(x,cse3way(1,avessleIDX),cse3waystd(1,avessleIDX),'g','g')
prtsha_HPL(x,cse3way(2,avessleIDX),cse3waystd(2,avessleIDX),'m','m')
title('CSE Plot');
ylabel('CSE (px/ms^2)');xlabel('Time Step');xlim([0 101]);
legend('2Way CSE','3Way CSE: Repetition','3Way CSE: Alternation','Location','northeast') 
% sigplotter2(cse1Acc,1.8,x,.0015,'b');%(dat,locs,xvar2,tk, cl)  
sigplotter2(cse2Acc.rep,1.8,x,.001,'g');%(dat,locs,xvar2,tk, cl)  
suptitle('Acceleration within a trial window')
savefig(gcf, [loc 'figures/' '7)AccelerationData'])
saveas(gcf,[loc 'figures/' '7)AccelerationData' '.tiff']);close 
clear x

%%
%angle change
%1sub/N0/N1/CongRep
%%
%real number version
% range=[1 2 3];[pdat00, ~] = mlavgHPL(fiRaw.total_realAngle, range); 
% range=[2 3];[pdat, pdat_std] = mlavgHPL(pdat00, range); 
% pdat_std(:,1:4)=pdat(:,1:4);
% 
% range=[1 4 2 3];[pdat02, ~] = mlavgHPL(fiRaw.total_realAngle,range); 
% range=[4 2 3];[pdat1, pdat1_std] = mlavgHPL(pdat02,range); 
% pdat1_std(:,1:4)=pdat1(:,1:4);
%%

%%
x=2:101;paIDX=5:104;

% figure(231231)
% plot(1:100, tt2./100,'b')
% hold on 
% plot(1:100, fArray1,'r')

%%
% 이거 이상타
% pdat(:,7)=abs(pdat(:,7));%궁여지책.... 지우자 가급적
% pdat1(:,7:8)=abs(pdat1(:,7:8));%궁여지책.... 지우자 가급적
%%
figure('units','normalized','outerposition',[0 0 1 1])
subplot(4,1,1);set(gca,'Position',[0.06 .79 0.92 0.18]);

    prtsha_HPL(x,pdat(1,paIDX),pdat_std(1,paIDX),'b','b')
    hold on
    prtsha_HPL(x,pdat(2,paIDX),pdat_std(2,paIDX),'b','--b')
    prtsha_HPL(x,pdat(3,paIDX),pdat_std(3,paIDX),'r','r')
    prtsha_HPL(x,pdat(4,paIDX),pdat_std(4,paIDX),'r','--r')
    legend('C after Nonconflict','C after Conflict','IC after Nonconflict','IC after Conflict','Location','southeast') 
    ylabel('Angle (Radian)');%xlabel('Time Step')
%     ylim([-200 200]);% xlim([0 350]);
%     sigplotter2(f2way.raw2,1.8,x,-.14,'r');%(dat,locs,xvar2,tk, cl)  
    vline(minitS, 'k', sprintf('Mean Initiation Point: %f ms', minitR));xlim([0 101]);
    title('2Way Plot: n0*n1')


subplot(4,1,2);set(gca,'Position',[0.06 .55 0.92 0.18]);
    tpdat = pdat1(pdat1(:,4)==1,:);
    tpdat_std = pdat1_std(pdat1_std(:,4)==1,:);
    prtsha_HPL(x,tpdat(1,paIDX),tpdat_std(1,paIDX),'b','b')
    hold on
    prtsha_HPL(x,tpdat(2,paIDX),tpdat_std(2,paIDX),'b','--b')
    prtsha_HPL(x,tpdat(3,paIDX),tpdat_std(3,paIDX),'r','r')
    prtsha_HPL(x,tpdat(4,paIDX),tpdat_std(4,paIDX),'r','--r')
    ylabel('Angle (Radian)');%xlabel('Time Step')
    title('3Way Plot: n0*n1 after Congruency Repetition');
    clear tpdat tpdat_std
%     ylim([-200 200]);% xlim([0 350]);
%     sigplotter2(f3way.raw1,1.8,x,-.14,'b');%(dat,locs,xvar2,tk, cl)  
%     sigplotter2(f3way.raw2,1.8,x,-.14,'r');%(dat,locs,xvar2,tk, cl)      
    vline(minitS2(1), 'k', sprintf('Mean Initiation Point: %f ms', minitR2(1)));xlim([0 101]);
    clear tpdat

subplot(4,1,3);set(gca,'Position',[0.06 .31 0.92 0.18]);
    tpdat = pdat1(pdat1(:,4)==2,:);
    tpdat_std = pdat1_std(pdat1_std(:,4)==2,:);
    prtsha_HPL(x,tpdat(1,paIDX),tpdat_std(1,paIDX),'b','b')
    hold on
    prtsha_HPL(x,tpdat(2,paIDX),tpdat_std(2,paIDX),'b','--b')
    prtsha_HPL(x,tpdat(3,paIDX),tpdat_std(3,paIDX),'r','r')
    prtsha_HPL(x,tpdat(4,paIDX),tpdat_std(4,paIDX),'r','--r')
    ylabel('Angle (Radian)');%xlabel('Time Step')
    title('3Way Plot: n0*n1 after Congruency Alternation');
    suptitle('Mean Trajectory by condition')
%     sigplotter2(f3way.raw4,1.8,x,-.14,'r');%(dat,locs,xvar2,tk, cl)   
    vline(minitS2(2), 'k', sprintf('Mean Initiation Point: %f ms', minitR2(2)));xlim([0 101]);

subplot(4,1,4);set(gca,'Position',[0.06 .07 0.92 0.18]);
% prtsha_HPL(x,cse2way(1,cseAvessleIDX),cse2waystd(1,cseAvessleIDX),'k','k')
% hold on
% prtsha_HPL(x,cse3way(1,cseAvessleIDX),cse3waystd(1,cseAvessleIDX),'g','g')
% prtsha_HPL(x,cse3way(2,cseAvessleIDX),cse3waystd(2,cseAvessleIDX),'m','m')
% title('CSE Plot');
% ylabel('CSE (Radian)');xlabel('Time Step');xlim([0 101]);
% legend('2Way CSE','3Way CSE: Repetition','3Way CSE: Alternation','Location','northeast') 
% sigplotter2(cse1Ang,1.8,x,.08,'k');%(dat,locs,xvar2,tk, cl)  
% sigplotter2(cse2Ang.rep,1.8,x,-.08,'g');%(dat,locs,xvar2,tk, cl)      
% sigplotter2(cse2Ang.alt,1.8,x,.08,'m');%(dat,locs,xvar2,tk, cl)      
suptitle('Angle within a trial window')
savefig(gcf, [loc 'figures/' '3)AngleData'])
saveas(gcf,[loc 'figures/' '3)AngleData' '.tiff']);close 
%%
% %%Two way anlge change split
% figure('units','normalized','outerposition',[0 0 1 1])
% cv=round(minitS+1);
% pre_vvessleIDX=(paIDX(1:cv));preX=numel(pre_vvessleIDX);
% pos_vvessleIDX=(paIDX(cv+1:end));posX=numel(pos_vvessleIDX);
% 
% subplot(2,1,1)
% prtsha_HPL(1:cv,pdat(1,pre_vvessleIDX),pdat_std(1,pre_vvessleIDX),'b','b')
% hold on
% prtsha_HPL(1:cv,pdat(2,pre_vvessleIDX),pdat_std(2,pre_vvessleIDX),'b','--b')
% prtsha_HPL(1:cv,pdat(3,pre_vvessleIDX),pdat_std(3,pre_vvessleIDX),'r','r')
% prtsha_HPL(1:cv,pdat(4,pre_vvessleIDX),pdat_std(4,pre_vvessleIDX),'r','--r')
% legend('C after Nonconflict','C after Conflict','IC after Nonconflict','IC after Conflict','Location','southeast') 
% ylabel('Trajectory Angle in Radian');xlabel('Time Step')
% xlim([0 cv]);hline(0,':k')
% title('Pre Initiation: n0*n1')
% 
% subplot(2,1,2)
% prtsha_HPL(cv:100,pdat(1,pos_vvessleIDX),pdat_std(1,pos_vvessleIDX),'b','b')
% hold on
% prtsha_HPL(cv:100,pdat(2,pos_vvessleIDX),pdat_std(2,pos_vvessleIDX),'b','--b')
% prtsha_HPL(cv:100,pdat(3,pos_vvessleIDX),pdat_std(3,pos_vvessleIDX),'r','r')
% prtsha_HPL(cv:100,pdat(4,pos_vvessleIDX),pdat_std(4,pos_vvessleIDX),'r','--r')
% % legend('C after Nonconflict','C after Conflict','IC after Nonconflict','IC after Conflict','Location','southeast') 
% ylabel('Trajectory Angle in Radian');xlabel('Time Step')
% xlim([cv 101]);hline(0,':k')
% title('Post Initiation: n0*n1')
% savefig(gcf, [loc 'figures\' 'PrePostSeparatedAngle'])
% saveas(gcf,[loc 'figures\' 'PrePostSeparatedAngle' '.tiff']);close 
%%
%Angle pval
%10 window를 5씰 밀면서
% sw=0:5:99;sw(end)=[];
push=5;wsize=10;sw=0:push:90;
w31=pdat02(pdat02(:,4)==1,:);w32=pdat02(pdat02(:,4)==2,:);
gdat000 = mlavgHPL(fiRaw.w2.avg_raw,[1 2 3]);%for 2way  
gdat002 = mlavgHPL(fiRaw.w3.avg_raw,[1 4 2 3]);
gdat0021=gdat002(gdat002(:,4)==1,:);gdat0022=gdat002(gdat002(:,4)==2,:);clear gdat002

condtray = pdat00(:,1:3);condtray1 = w31(:,1:3);condtray2 = w32(:,1:3);
vcondtray = gdat000(:,1:3);vcondtray1 = gdat0021(:,1:3);vcondtray2 = gdat0022(:,1:3);
FACTNAMES222 = {'N0','N1'}; 
for i= 1:size(sw,2)
    dvtray=mean(pdat00(:,5+sw(i):5+sw(i)+wsize-1),2);
    stat.anglewd.anovatbl{i}=HP_anovaN([condtray dvtray] ,FACTNAMES222);     
    pcomp_aw(1,i) =num2cell(sw(i));
    pcomp_aw(2,i)=table2cell(stat.anglewd.anovatbl{i}(6,5));
    pcomp_aw(3,i)=table2cell(stat.anglewd.anovatbl{i}(6,7));  
    clear  dvtray
    %rep
    dvtray=mean(w31(:,5+sw(i):5+sw(i)+wsize-1),2);
    stat.anglewd2.anovatbl{i}=HP_anovaN([condtray1 dvtray] ,FACTNAMES222);     
    pcomp_aw2(1,i) =num2cell(sw(i));
    pcomp_aw2(2,i)=table2cell(stat.anglewd2.anovatbl{i}(6,5));
    pcomp_aw2(3,i)=table2cell(stat.anglewd2.anovatbl{i}(6,7));  
    clear  dvtray    
    %alt
    dvtray=mean(w32(:,5+sw(i):5+sw(i)+wsize-1),2);
    stat.anglewd3.anovatbl{i}=HP_anovaN([condtray2 dvtray] ,FACTNAMES222);     
    pcomp_aw3(1,i) =num2cell(sw(i));
    pcomp_aw3(2,i)=table2cell(stat.anglewd3.anovatbl{i}(6,5));
    pcomp_aw3(3,i)=table2cell(stat.anglewd3.anovatbl{i}(6,7));  
    clear  dvtray   
    
    %velo
    tempt1=gdat000(:,vvessleIDX);
    dvtray=mean(tempt1(:,1+sw(i):1+sw(i)+wsize-1),2);
    stat.v.anglewd.anovatbl{i}=HP_anovaN([vcondtray dvtray] ,FACTNAMES222);     
    pcomp_awV(1,i) =num2cell(sw(i));
    pcomp_awV(2,i)=table2cell(stat.v.anglewd.anovatbl{i}(6,5));
    pcomp_awV(3,i)=table2cell(stat.v.anglewd.anovatbl{i}(6,7));  
    clear  dvtray tempt1
    
    tempt1=gdat0021(:,vvessleIDX);
    dvtray=mean(tempt1(:,1+sw(i):1+sw(i)+wsize-1),2);
    stat.v1.anglewd.anovatbl{i}=HP_anovaN([vcondtray1 dvtray] ,FACTNAMES222);     
    pcomp_awV1(1,i) =num2cell(sw(i));
    pcomp_awV1(2,i)=table2cell(stat.v1.anglewd.anovatbl{i}(6,5));
    pcomp_awV1(3,i)=table2cell(stat.v1.anglewd.anovatbl{i}(6,7));  
    clear  dvtray tempt1   
    
    tempt1=gdat0022(:,vvessleIDX);
    dvtray=mean(tempt1(:,1+sw(i):1+sw(i)+wsize-1),2);
    stat.v2.anglewd.anovatbl{i}=HP_anovaN([vcondtray2 dvtray] ,FACTNAMES222);     
    pcomp_awV2(1,i) =num2cell(sw(i));
    pcomp_awV2(2,i)=table2cell(stat.v2.anglewd.anovatbl{i}(6,5));
    pcomp_awV2(3,i)=table2cell(stat.v2.anglewd.anovatbl{i}(6,7));  
    clear  dvtray tempt1       
    
    %accel
    tempt1=gdat000(:,avessleIDX);
    if i==19;dvtray=mean(tempt1(:,1+sw(i):1+sw(i)+wsize-2),2);else;
    dvtray=mean(tempt1(:,1+sw(i):1+sw(i)+wsize-1),2);end    
    stat.a.anglewd.anovatbl{i}=HP_anovaN([vcondtray dvtray] ,FACTNAMES222);     
    pcomp_awA(1,i) =num2cell(sw(i));
    pcomp_awA(2,i)=table2cell(stat.a.anglewd.anovatbl{i}(6,5));
    pcomp_awA(3,i)=table2cell(stat.a.anglewd.anovatbl{i}(6,7));  
    clear  dvtray tempt1
    
    tempt1=gdat0021(:,avessleIDX);
    if i==19;dvtray=mean(tempt1(:,1+sw(i):1+sw(i)+wsize-2),2);else;
    dvtray=mean(tempt1(:,1+sw(i):1+sw(i)+wsize-1),2);end    
    stat.a1.anglewd.anovatbl{i}=HP_anovaN([vcondtray1 dvtray] ,FACTNAMES222);     
    pcomp_awA1(1,i) =num2cell(sw(i));
    pcomp_awA1(2,i)=table2cell(stat.a1.anglewd.anovatbl{i}(6,5));
    pcomp_awA1(3,i)=table2cell(stat.a1.anglewd.anovatbl{i}(6,7));  
    clear  dvtray tempt1   
    
    tempt1=gdat0022(:,avessleIDX);
    if i==19;dvtray=mean(tempt1(:,1+sw(i):1+sw(i)+wsize-2),2);else;
    dvtray=mean(tempt1(:,1+sw(i):1+sw(i)+wsize-1),2);end    
    stat.a2.anglewd.anovatbl{i}=HP_anovaN([vcondtray2 dvtray] ,FACTNAMES222);     
    pcomp_awA2(1,i) =num2cell(sw(i));
    pcomp_awA2(2,i)=table2cell(stat.a2.anglewd.anovatbl{i}(6,5));
    pcomp_awA2(3,i)=table2cell(stat.a2.anglewd.anovatbl{i}(6,7));  
    clear  dvtray tempt1           
    
end

pcomp_aw=cell2mat(pcomp_aw);pcomp_aw2=cell2mat(pcomp_aw2);pcomp_aw3=cell2mat(pcomp_aw3);
pcomp_awA=cell2mat(pcomp_awA);pcomp_awA1=cell2mat(pcomp_awA1);pcomp_awA2=cell2mat(pcomp_awA2);
pcomp_awV=cell2mat(pcomp_awV);pcomp_awV1=cell2mat(pcomp_awV1);pcomp_awV2=cell2mat(pcomp_awV2);


figure('units','normalized','outerposition',[0 0 1 1])
plot(pcomp_aw(1,:)+1, pcomp_aw(2,:),'k')
hold on
plot(pcomp_aw2(1,:)+1, pcomp_aw2(2,:),'g')
plot(pcomp_aw3(1,:)+1, pcomp_aw3(2,:),'m')
xticks(pcomp_aw(1,:));ylabel('p-value');xlabel('Averaged Time Bins(Steps)');
legend('2Way p-val','3Way p-val: Repetition','3Way p-val: Alternation','Location','northeast') 
% xticklabels({'1~10','6~15','11~20','16~25','21~30','26~35','31~40','36~45','41~50',...
%     '46~55','51~60','56~65','61~70','66~75','71~80','76~85','81~90','86~95','91~100'})
hline(.05,':k','p = . 05')
xlim([0 95])
savefig(gcf, [loc 'figures/' 'Angle_n0n1_pvalue'])
saveas(gcf,[loc 'figures/' 'Angle_n0n1_pvalue' '.tiff']);close 


figure('units','normalized','outerposition',[0 0 1 1])
plot(pcomp_awV(1,:)+1, pcomp_awV(2,:),'k')
hold on
plot(pcomp_awV1(1,:)+1, pcomp_awV1(2,:),'g')
plot(pcomp_awV2(1,:)+1, pcomp_awV2(2,:),'m')
xticks(pcomp_awV(1,:));ylabel('p-value');xlabel('Averaged Time Bins(Steps)');
legend('2Way p-val','3Way p-val: Repetition','3Way p-val: Alternation','Location','northeast') 
hline(.05,':k','p = . 05')
xlim([0 95])
savefig(gcf, [loc 'figures/' 'Velocity_n0n1_pvalue'])
saveas(gcf,[loc 'figures/' 'Velocity_n0n1_pvalue' '.tiff']);close 

figure('units','normalized','outerposition',[0 0 1 1])
plot(pcomp_awA(1,:)+1, pcomp_awA(2,:),'k')
hold on
plot(pcomp_awA1(1,:)+1, pcomp_awA1(2,:),'g')
plot(pcomp_awA2(1,:)+1, pcomp_awA2(2,:),'m')
xticks(pcomp_awA(1,:));ylabel('p-value');xlabel('Averaged Time Bins(Steps)');
legend('2Way p-val','3Way p-val: Repetition','3Way p-val: Alternation','Location','northeast') 
hline(.05,':k','p = . 05')
xlim([0 95])
savefig(gcf, [loc 'figures/' 'Accel_n0n1_pvalue'])
saveas(gcf,[loc 'figures/' 'Accel_n0n1_pvalue' '.tiff']);close 

%%
%N0
clear condtray dvtray pcomp_aw_no stat.anglewd_no.anovatbl
range=[1 2];
[pdat000, ~] = mlavgHPL(fiRaw.total_raw_pangle, range);

push=5;
wsize=10;
sw=0:push:90;

pdat0007=[abs(pdat000(:,1:4)) angle(pdat000(:,5:end))];
condtray = pdat0007(:,1:2);
FACTNAMES222 = {'N0'}; 
for i= 1:size(sw,2)
    dvtray=mean(pdat0007(:,5+sw(i):5+sw(i)+wsize-1),2);
    stat.anglewd_no.anovatbl{i}=HP_anovaN([condtray dvtray] ,FACTNAMES222);     
    pcomp_aw_no(1,i) =num2cell(sw(i));
    pcomp_aw_no(2,i)=table2cell(stat.anglewd_no.anovatbl{i}(2,5));
    pcomp_aw_no(3,i)=table2cell(stat.anglewd_no.anovatbl{i}(2,7));  
end

pcomp_aw_no=cell2mat(pcomp_aw_no);

figure('units','normalized','outerposition',[0 0 1 1])
plot(pcomp_aw_no(1,:)+1, pcomp_aw_no(2,:))
xticks(pcomp_aw_no(1,:));ylabel('p-value');xlabel('Averaged Time Bins(Steps)');
hline(.05,':k','p = . 05')
xlim([0 95])
savefig(gcf, [loc 'figures/' 'Angle_n0_pvalue'])
saveas(gcf,[loc 'figures/' 'Angle_n0_pvalue' '.tiff']);close 




%%
x=2:101;
figure('units','normalized','outerposition',[0 0 1 1])
subplot(4,1,1);set(gca,'Position',[0.06 .79 0.92 0.18]);
prtsha_HPL(x,gdat(1,vvessleIDX),stderror(1,vvessleIDX),'b','b')
hold on
prtsha_HPL(x,gdat(2,vvessleIDX),stderror(2,vvessleIDX),'b','--b')
prtsha_HPL(x,gdat(3,vvessleIDX),stderror(3,vvessleIDX),'r','r')
prtsha_HPL(x,gdat(4,vvessleIDX),stderror(4,vvessleIDX),'r','--r')
legend('C after Nonconflict','C after Conflict','IC after Nonconflict','IC after Conflict','Location','southeast') 
sigplotter2(V2way.raw1,1.8,x,-.14,'b');%(dat,locs,xvar2,tk, cl)  
sigplotter2(V2way.raw2,1.8,x,.14,'r');%(dat,locs,xvar2,tk, cl)     

ylabel('Velocity (px/ms)');%xlabel('Time Step')
ylim([-0.14 3]);xlim([0 101]);
vline(minitS+1, 'k', sprintf('Mean Initiation Point: %f ms', minitR));
plot([0 101], [0 0],'w','LineWidth',1.5,'HandleVisibility','off')
title('2Way Plot: n0*n1')


subplot(4,1,2);set(gca,'Position',[0.06 .55 0.92 0.18]);
tpdat = gdat1(gdat1(:,4)==1,:);
tpdat_std = stderror1(gdat1(:,4)==1,:);
prtsha_HPL(x,tpdat(1,vvessleIDX),tpdat_std(1,vvessleIDX),'b','b')
hold on
prtsha_HPL(x,tpdat(2,vvessleIDX),tpdat_std(2,vvessleIDX),'b','--b')
prtsha_HPL(x,tpdat(3,vvessleIDX),tpdat_std(3,vvessleIDX),'r','r')
prtsha_HPL(x,tpdat(4,vvessleIDX),tpdat_std(4,vvessleIDX),'r','--r')
    sigplotter2(V3way.raw1,1.8,x,-.14,'b');%(dat,locs,xvar2,tk, cl)  
    sigplotter2(V3way.raw2,1.8,x,.14,'r');%(dat,locs,xvar2,tk, cl)   
ylabel('Velocity (px/ms)');%xlabel('Time Step')
title('3Way Plot: n0*n1 after Congruency Repetition');
clear tpdat tpdat_std
plot([0 101], [0 0],'w','LineWidth',1.5)
ylim([-0.14 3]);xlim([0 101]);
vline(minitS2(1)+1, 'k', sprintf('Mean Initiation Point: %f ms', minitR2(1)));
    
clear tgdat

subplot(4,1,3);set(gca,'Position',[0.06 .31 0.92 0.18]);
tpdat = gdat1(gdat1(:,4)==2,:);
tpdat_std = stderror1(gdat1(:,4)==2,:);
prtsha_HPL(x,tpdat(1,vvessleIDX),tpdat_std(1,vvessleIDX),'b','b')
hold on
prtsha_HPL(x,tpdat(2,vvessleIDX),tpdat_std(2,vvessleIDX),'b','--b')
prtsha_HPL(x,tpdat(3,vvessleIDX),tpdat_std(3,vvessleIDX),'r','r')
prtsha_HPL(x,tpdat(4,vvessleIDX),tpdat_std(4,vvessleIDX),'r','--r')
ylabel('Velocity (px/ms)');%xlabel('Time Step')
title('3Way Plot: n0*n1 after Congruency Alternation');
% suptitle('Mean Trajectory by condition','HandleVisibility','off')
plot([0 101], [0 0],'w','LineWidth',1.5)
ylim([-0.14 3]);xlim([0 101]);
vline(minitS2(2)+1, 'k', sprintf('Mean Initiation Point: %f ms', minitR2(2)));

subplot(4,1,4);set(gca,'Position',[0.06 .07 0.92 0.18]);
prtsha_HPL(x,cse2way(1,vvessleIDX),cse2waystd(1,vvessleIDX),'k','k')
hold on
prtsha_HPL(x,cse3way(1,vvessleIDX),cse3waystd(1,vvessleIDX),'g','g')
prtsha_HPL(x,cse3way(2,vvessleIDX),cse3waystd(2,vvessleIDX),'m','m')
ylabel('CSE Magnitude (px/ms)');xlim([0 101]);%xlabel('Time Step');
legend('2Way CSE','3Way CSE: Repetition','3Way CSE: Alternation','Location','northeast') 
sigplotter2(cse1V,1.8,x,.05,'k');%(dat,locs,xvar2,tk, cl)  
sigplotter2(cse2V.rep,1.8,x,-.05,'g');%(dat,locs,xvar2,tk, cl)      
title('CSE Plot');xlabel('Time Step')
suptitle('Velocity within a trial window')
savefig(gcf, [loc 'figures/' '4)VelocityData'])
saveas(gcf,[loc 'figures/' '4)VelocityData' '.tiff']);close 
%%
%ps plot2
% 여기부터





%%
% %diptest추가
% %angle
% diptray = [fiRaw.total_raw(:,1:4) angle(fiRaw.total_raw_pangle(:,5:end))];
% vtray = [fiRaw.total_raw(:,1:4) fiRaw.total_raw(:,vvessleIDX)];
% atray = [fiRaw.total_raw(:,1:4) fiRaw.total_raw(:,avessleIDX)];
% 
% nboot=500;
% dip2=[1,1;1,2;2,1;2,2];
% dip3=[1,1,1;1,2,1;2,1,1;2,2,1;1,1,2;1,2,2;2,1,2;2,2,2];
% % 2way
% for ts = 1:99
%     for d= 1: size(dip2,1)
%       diptemp = diptray(diptray(:,2)==dip2(d,1) & diptray(:,3)==dip2(d,2),ts+4)'; 
%       [angl_dip_score2w(d,ts), angl_dip_p2w(d,ts)] = hartigansdipsigniftest(diptemp, nboot);
%       
%       vtemp = vtray(vtray(:,2)==dip2(d,1) & vtray(:,3)==dip2(d,2),ts+4)'; 
%       [velo_dip_score2w(d,ts), velo_dip_p2w(d,ts)] = hartigansdipsigniftest(vtemp, nboot);
% 
%       atemp = atray(atray(:,2)==dip2(d,1) & atray(:,3)==dip2(d,2),ts+4)'; 
%       [acel_dip_score2w(d,ts), acel_dip_p2w(d,ts)] = hartigansdipsigniftest(atemp, nboot);
%       
%       clear diptemp vtemp atemp
%     end
% end
% 
% 
% for ts = 1:99
%     for d= 1: size(dip3,1)
%       diptemp = diptray(diptray(:,2)==dip3(d,1) & diptray(:,3)==dip3(d,2) & diptray(:,4)==dip3(d,3),ts+4)'; 
%       [angl_dip_score3w(d,ts), angl_dip_p3w(d,ts)] = hartigansdipsigniftest(diptemp, nboot);
% 
%       vtemp = vtray(vtray(:,2)==dip3(d,1) & vtray(:,3)==dip3(d,2) & vtray(:,4)==dip3(d,3),ts+4)'; 
%       [velo_dip_score3w(d,ts), velo_dip_p3w(d,ts)] = hartigansdipsigniftest(vtemp, nboot);
% 
%       atemp = atray(atray(:,2)==dip3(d,1) & atray(:,3)==dip3(d,2) & atray(:,4)==dip3(d,3),ts+4)'; 
%       [acel_dip_score3w(d,ts), acel_dip_p3w(d,ts)] = hartigansdipsigniftest(atemp, nboot);
%       
%       clear diptemp vtemp atemp
%     end
% end
% 
% dtest.w2.angl_dip_score2w=angl_dip_score2w;dtest.w3.angl_dip_score3w=angl_dip_score3w;
% dtest.w2.velo_dip_score2w=velo_dip_score2w;dtest.w3.velo_dip_score3w=velo_dip_score3w;
% dtest.w2.acel_dip_score2w=acel_dip_score2w;dtest.w3.acel_dip_score3w=acel_dip_score3w;
% dtest.w2.angl_dip_p2w=angl_dip_p2w;dtest.w3.angl_dip_p3w=angl_dip_p3w;
% dtest.w2.velo_dip_p2w=velo_dip_p2w;dtest.w3.velo_dip_p3w=velo_dip_p3w;
% dtest.w2.acel_dip_p2w=acel_dip_p2w;dtest.w3.acel_dip_p3w=acel_dip_p3w;
% save([loc 'figures\' 'DipTestMay16ADCO.mat'],'dtest','-v7.3')

%%
%dip test 안할땐 걍 데이터 로드해
load('C:\Users\Hansol\Google 드라이브\ASU\10) congitive control 2019hplab\codes\raw\HV\figures\DipTestMay16ADCO.mat')

figure('units','normalized','outerposition',[0 0 1 1])
subplot(3,1,1)
plot(1:size(dtest.w2.angl_dip_score2w,2), dtest.w2.angl_dip_score2w(1,:),'b')
hold on
plot(1:size(dtest.w2.angl_dip_score2w,2), dtest.w2.angl_dip_score2w(2,:),'--b')
% sigplotterHPL(dtest.w2.angl_dip_p2w(4,:),'c')
plot(1:size(dtest.w2.angl_dip_score2w,2), dtest.w2.angl_dip_score2w(3,:),'r')
plot(1:size(dtest.w2.angl_dip_score2w,2), dtest.w2.angl_dip_score2w(4,:),'--r')
legend('C after Nonconflict','C after Conflict','IC after Nonconflict','IC after Conflict','Location','southeast') 
ylabel('Dip Test Statistics');xlabel('Time Step')
hline(dtest.w2.angl_dip_score2w(find(dtest.w2.angl_dip_p2w==.05,1)),':k', 'p=.05')
title('2Way Plot: n0*n1')
vline(minitS, 'k', sprintf('Mean Initiation Point: %f ms', minitR))

subplot(3,1,2)
tpdat = dtest.w3.angl_dip_score3w(1:4,:);
plot(1:size(tpdat,2), tpdat(1,:),'b')
hold on
plot(1:size(tpdat,2), tpdat(2,:),'--b')
plot(1:size(tpdat,2), tpdat(3,:),'r')
plot(1:size(tpdat,2), tpdat(4,:),'--r')
ylabel('Dip Test Statistics');xlabel('Time Step')
title('3Way Plot: n0*n1 after Congruency Repetition');
hline(dtest.w3.angl_dip_score3w(find(dtest.w3.angl_dip_p3w==.05,1)),':k', 'p=.05')
vline(minitS2(1)+1, 'k', sprintf('Mean Initiation Point: %f ms', minitR2(1)))
clear tpdat 
    
subplot(3,1,3)
tpdat = dtest.w3.angl_dip_score3w(5:8,:);
plot(1:size(tpdat,2), tpdat(1,:),'b')
hold on
plot(1:size(tpdat,2), tpdat(2,:),'--b')
plot(1:size(tpdat,2), tpdat(3,:),'r')
plot(1:size(tpdat,2), tpdat(4,:),'--r')
ylabel('Dip Test Statistics');xlabel('Time Step')
title('3Way Plot: n0*n1 after Congruency Repetition');
hline(dtest.w3.angl_dip_score3w(find(dtest.w3.angl_dip_p3w==.05,1)),':k', 'p=.05')
vline(minitS2(2)+1, 'k', sprintf('Mean Initiation Point: %f ms', minitR2(2)))
title('3Way Plot: n0*n1 after Congruency Alternation');
suptitle('Dip Stats (angle) withing a trial windown')
clear tpdat
savefig(gcf, [loc 'figures\' '6)DipTestAngle'])
saveas(gcf, [loc 'figures\' '6)DipTestAngle' '.tiff']);close 


figure('units','normalized','outerposition',[0 0 1 1])
subplot(3,1,1)
plot(1:size(dtest.w2.velo_dip_score2w,2), dtest.w2.velo_dip_score2w(1,:),'b')
hold on
plot(1:size(dtest.w2.velo_dip_score2w,2), dtest.w2.velo_dip_score2w(2,:),'--b')
% sigplotterHPL(dtest.w2.velo_dip_p2w(4,:),'c')
plot(1:size(dtest.w2.velo_dip_score2w,2), dtest.w2.velo_dip_score2w(3,:),'r')
plot(1:size(dtest.w2.velo_dip_score2w,2), dtest.w2.velo_dip_score2w(4,:),'--r')
legend('C after Nonconflict','C after Conflict','IC after Nonconflict','IC after Conflict','Location','northwest') 
ylabel('Dip Test Statistics');xlabel('Time Step');ylim([0 .1]);
hline(dtest.w2.velo_dip_score2w(find(dtest.w2.velo_dip_p2w==.05,1)),':k', 'p=.05')
title('2Way Plot: n0*n1')
vline(minitS, 'k', sprintf('Mean Initiation Point: %f ms', minitR))

subplot(3,1,2)
tpdat = dtest.w3.velo_dip_score3w(1:4,:);
plot(1:size(tpdat,2), tpdat(1,:),'b')
hold on
plot(1:size(tpdat,2), tpdat(2,:),'--b')
plot(1:size(tpdat,2), tpdat(3,:),'r')
plot(1:size(tpdat,2), tpdat(4,:),'--r')
ylabel('Dip Test Statistics');xlabel('Time Step');ylim([0 .1]);
title('3Way Plot: n0*n1 after Congruency Repetition');
hline(dtest.w3.velo_dip_score3w(find(dtest.w3.velo_dip_p3w==.05,1)),':k', 'p=.05')
vline(minitS2(1)+1, 'k', sprintf('Mean Initiation Point: %f ms', minitR2(1)))
clear tpdat 
    
subplot(3,1,3)
tpdat = dtest.w3.velo_dip_score3w(5:8,:);
plot(1:size(tpdat,2), tpdat(1,:),'b')
hold on
plot(1:size(tpdat,2), tpdat(2,:),'--b')
plot(1:size(tpdat,2), tpdat(3,:),'r')
plot(1:size(tpdat,2), tpdat(4,:),'--r')
ylabel('Dip Test Statistics');xlabel('Time Step');ylim([0 .1]);
title('3Way Plot: n0*n1 after Congruency Repetition');
hline(dtest.w3.velo_dip_score3w(find(dtest.w3.velo_dip_p3w==.05,1)),':k', 'p=.05')
vline(minitS2(2)+1, 'k', sprintf('Mean Initiation Point: %f ms', minitR2(2)))
title('3Way Plot: n0*n1 after Congruency Alternation');
suptitle('Dip Stats (velocity) withing a trial windown')
clear tpdat
savefig(gcf, [loc 'figures\' '5)DipTestVelocity'])
saveas(gcf,[loc 'figures\' '5)DipTestVelocity' '.tiff']);close 

figure('units','normalized','outerposition',[0 0 1 1])
subplot(3,1,1)
plot(1:size(dtest.w2.acel_dip_score2w,2), dtest.w2.acel_dip_score2w(1,:),'b')
hold on
plot(1:size(dtest.w2.acel_dip_score2w,2), dtest.w2.acel_dip_score2w(2,:),'--b')
% sigplotterHPL(dtest.w2.acel_dip_p2w(4,:),'c')
plot(1:size(dtest.w2.acel_dip_score2w,2), dtest.w2.acel_dip_score2w(3,:),'r')
plot(1:size(dtest.w2.acel_dip_score2w,2), dtest.w2.acel_dip_score2w(4,:),'--r')
legend('C after Nonconflict','C after Conflict','IC after Nonconflict','IC after Conflict','Location','northwest') 
ylabel('Dip Test Statistics');xlabel('Time Step');ylim([0 .1]);
hline(.0088,':k', 'p=.05')
title('2Way Plot: n0*n1')
vline(minitS, 'k', sprintf('Mean Initiation Point: %f ms', minitR))

subplot(3,1,2)
tpdat = dtest.w3.acel_dip_score3w(1:4,:);
plot(1:size(tpdat,2), tpdat(1,:),'b')
hold on
plot(1:size(tpdat,2), tpdat(2,:),'--b')
plot(1:size(tpdat,2), tpdat(3,:),'r')
plot(1:size(tpdat,2), tpdat(4,:),'--r')
ylabel('Dip Test Statistics');xlabel('Time Step');ylim([0 .1]);
title('3Way Plot: n0*n1 after Congruency Repetition');
hline(.0121,':k', 'p=.05')
vline(minitS2(1)+1, 'k', sprintf('Mean Initiation Point: %f ms', minitR2(1)))
clear tpdat 
    
subplot(3,1,3)
tpdat = dtest.w3.acel_dip_score3w(5:8,:);
plot(1:size(tpdat,2), tpdat(1,:),'b')
hold on
plot(1:size(tpdat,2), tpdat(2,:),'--b')
plot(1:size(tpdat,2), tpdat(3,:),'r')
plot(1:size(tpdat,2), tpdat(4,:),'--r')
ylabel('Dip Test Statistics');xlabel('Time Step');ylim([0 .1]);
title('3Way Plot: n0*n1 after Congruency Repetition');
hline(.0121,':k', 'p=.05')
vline(minitS2(2)+1, 'k', sprintf('Mean Initiation Point: %f ms', minitR2(2)))
title('3Way Plot: n0*n1 after Congruency Alternation');
suptitle('Dip Stats (acceleration) withing a trial windown')
clear tpdat
savefig(gcf, [loc 'figures\' '7)DipTestAcceleration'])
saveas(gcf,[loc 'figures\' '7)DipTestAcceleration' '.tiff']);close 