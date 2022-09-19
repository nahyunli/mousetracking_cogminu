function [eptray, erlist,dcheck, pAngle2, orgXY,angleTemp, wAngle2] = torganizerHPL(tmtray,bkIDX,cutoff, expType) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���� 2019.5.11: ���� �ڵ�� ���콺 Ʈ��ŷ�� ÷ ���� ����� ���ظ� ���� ���� for loop�� ������ trial
% ���� preprocessing�� �ϵ��� �ۼ��Ǿ��µ�, �׷��� ������ �ڵ尡 ���ư��� �ӵ��� �ſ� ����. �׷��Ƿ� �ڵ忡 �ͼ��� ����
% ������ matrix ������ �̿��ؼ� ������ ó�� �ӵ��� ����Ű�� ����
%
% ����) eptray column index            
% (1)ParticipantNo.
% (2)n0 congruence
% (3)n-1 congruence
% (4)n-2 congruence-> congruence repetition���� ����
% (5)taskType 1=����/2=�ĳ�
% (6)btwC 
% (7)withC
% (8)target location 
%    HV[expType1]: (1)����-��, (2)������-�� (3)��-�� (4)�Ʒ�-��            
%    HH[expType2]: (1)������-��, (2)��������-�� (3)���ʾƷ�-�� (4)�����ʾƷ�-��   
% (9)trajectory ����
% (10)initiation time   
% (11)movement time (RT-Initiation time, ������ �̵��� �ɸ� �ð�)
% (12)RT 
% (13)Area Under Curve
% (14)xflip:���콺�� �����̴� ���� �������� ������ ���� Ƚ��(Ⱦ)  
% (15)yflip: ���콺�� �����̴� ���� �������� ������ ���� Ƚ��(��) 
% (16)X ��Ʈ����
% (17)Y ��Ʈ����
% (18)�ְ� �ӵ� 
% (19)�ְ� �ӵ� ���� ����
% (20)0�� �ƴ� ���� �ӵ�
% (21)���� �ӵ� ���� ���� 
% (22)phase angle �м��� ���� ���Ҽ� ���� �־� �α� -> ����� ���� ������
% (23)n-2 congruence Ȥ�� ���� ���� �־�α�
% (24)flip2D 
% (25)Entropy2D
% (26)Overshoot2D
% (31~131) x��ǥ
% (133~233) y��ǥ
% (235~335) �ð�����, trial�����ϰ� ������ xy��ǥ�� �����ϱ���� ���� �ð��� �ɷȴ°�                 
% (337~436) �ӵ����� 
% (438~536) ���ӵ����� 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
epc=1;   
    for bn = 1:size(bkIDX,1) %������� ó��
        rIDX=bkIDX(bn,:);
        for rr = 1:size(rIDX,2)
            acctray(epc,1)=tmtray.correct(rIDX(rr),:);%str2double(tmtray.correct(rIDX(rr),:)); 
            eptray(epc,1)=tmtray.subject_nr(1); %subject number
            eptray(epc,2)=tmtray.n0(rIDX(rr),:);%n0 congruence    
            eptray(epc,3)=tmtray.n1(rIDX(rr),:);%n-1 congruence   
            if tmtray.n1(rIDX(rr),:)==tmtray.n2(rIDX(rr),:)
                eptray(epc,4)=1;%congruence repetition(C)
            else
                eptray(epc,4)=2;%congruence repetition IC                
            end
            eptray(epc,23)=tmtray.n2(rIDX(rr),:);%n-2 congruence  
            eptray(epc,5)=tmtray.taskType(rIDX(rr),:);%taskType 1=����/2=�ĳ�                  
            eptray(epc,6)=tmtray.btwC(rIDX(rr),:);%btwC  
            eptray(epc,7)=tmtray.withC(rIDX(rr),:);%withC             
            
            %target location code
            %HV[expType1]: (1)����-��, (2)������-�� (3)�Ʒ�-�� (4)��-��           
            %HH[expType2]: (1)������-��, (2)��������-�� (3)���ʾƷ�-�� (4)�����ʾƷ�-��            
            t_disp = [tmtray.tar1L(rIDX(rr),:) tmtray.tar2R(rIDX(rr),:) tmtray.tar3U(rIDX(rr),:) tmtray.tar4D(rIDX(rr),:)];            
            eptray(epc,8)=find(strcmp(tmtray.correct_button_get_response_pos(rIDX(rr),:), t_disp));%target location 
            
            eptray(epc,30)=99999;%�� ���ĺ��ʹ� x,y��ǥ �� �ð� ������ ����. 
                       
            %��ǥ ó��
            %���迡 ����� ���α׷��� ��� (1)�������~ť����, (2)ť����~Ÿ�� ���� ������ ���� tracking �ϱ� ������ ��
            %������ ��ǥ�� ���� ����� �ǰ�, �׷��� �� ������ ��ǥ�� ���ľ� �Ѵ�. �װ��� �Ʒ� �ڵ尡 �ϴ� ��
            
            %x ��ǥ
            xPre = split(tmtray.xpos_get_response_bef(rIDX(rr)),["[","]",", "]);xPre=str2double(xPre(2:end-1));
            xPos = split(tmtray.xpos_get_response_pos(rIDX(rr)),["[","]",", "]);xPos=str2double(xPos(2:end-1));
            nX = [xPre; xPos];%nX=nX-nX(1); clear xPre xPos 
            
            %y��ǥ
            yPre = split(tmtray.ypos_get_response_bef(rIDX(rr)),["[","]",", "]);yPre=str2double(yPre(2:end-1));
            yPos = split(tmtray.ypos_get_response_pos(rIDX(rr)),["[","]",", "]);yPos=str2double(yPos(2:end-1));
            nY = [yPre; yPos];%nY=nY-min(nY); clear yPre yPos             
            
            %time ����
            tPre = split(tmtray.timestamps_get_response_bef(rIDX(rr)),["[","]",", "]);tPre=str2double(tPre(2:end-1));
            tPos = split(tmtray.timestamps_get_response_pos(rIDX(rr)),["[","]",", "]);tPos=str2double(tPos(2:end-1));
            nT = [tPre; tPos];nT=nT-nT(1); clear tPre tPos    
            
            %101 interpolation
            %�� ��������(����) ��ǥ�� �����ϴ� ����Ÿ ����(x, y, t rotn)�� �ٸ��� ������ ������ ����� ������ ����. �׷��� interpolation�� �̿��ؼ�
            %�� �������� 101���� x,y,t ���� ������ ó���ؾ� �Ѵ�. ���� ��� ������ ������ ������ ��A�� �ټ�����
            %������ ������ ��B�� �ִٰ� ġ��. �� ��쿡 �� ���� ����� ���� ���� ������(��)�� ������ �װ��� �����ϰ��� �� ��
            %1) �켱 �� A���� ������ �� �װ��� ���, ��B ���� ������ �� �װ��� ������ �� �� ��ü�� ����� ������
            %������ �������� ������ ���������� ������ ����� �� ���� �ִ�. 

            dcheck(epc,1)=eptray(epc,1);            
            dcheck(epc,2)=size(nT,1);
            
            [nX, nY, nT] = timespace33HPL(nX, nY, nT);
            nXo(epc,:)=nX';nYo(epc,:)=nY';
            %��ǥ �����ϱ�: �� ������ �����񱳸� �ϱ� ���� �ؾ��� �ٸ� ó���� ��ǥ�� �� �������� ���Ľ�Ű�� ���̴�. ���� ��� ���� Ÿ���� ���� ������ 
            %�»�� Ÿ���� ���� ������ ���ϱ� ���ؼ� �� �� �ϳ��� �ٸ� �������� ������ �� �ʿ䰡 �ִ�. ���� ������ �ѹ��� ���� �»�� Ÿ���� ���� ������ ����ٰų�...
            %�� ������ ��쿡�� HV������ ��� ��� ������ ������ Ÿ����(�ʷϻ�) ���ϵ���, HH ������ ��� ���� Ÿ����(�ʷϻ�) ���ϰ� �����ϵ��� �ڵ带 �ۼ��Ͽ���.
            %�߿�)!!! open sesame���α׷��� ����� ��ǥ�� ���� �����Ǿ��ִ� ��ǥ�̱� ������ ������ ����ؼ� ��ǥ ������ ����ؼ� ���� �۾��� �ؾ� �Ѵ�.
            
            if expType ==1 || expType ==3%HV
            % ��� ��ǥ�� ������ Ÿ��(��) �� �����Ϸ���, ���� Ÿ�ϵ� (��)���� ������ �¿� ����, �� Ÿ��(��)�� ���� ����, �� ���� �� �������� ���ĵ� ��, �� Ÿ���� 
            % ���� ������ �ð�������� 90�� ������ �Ѵ�.                
            %->������ ���� ������ ���� ���� ��Ű�� ������ ����� �̹� ���� ������ �� ���¿��� ��ϵǾ��� ����
            
                if eptray(epc,8)==1 %�� �¿� ����
                    xdiff=diff(nX);nz=zeros(1,101);
                    for it=2:101;nz(it)=nz(it-1)-xdiff(it-1);end
                    nX=nz'; clear nz xdiff       
                end      
                if eptray(epc,8)==3 %�� ���� ����
                    ydiff=diff(nY);ny=zeros(1,101);
                    for it=2:101;ny(it)=ny(it-1)-ydiff(it-1);end
                    nY=ny'; clear ny ydiff     
                end   
                if eptray(epc,8)==3 || eptray(epc,8)==4 %�ĳ� �ð���� 90�� ȸ��                
                   ytp= nY';xtp= nX';
                   a=(atan((ytp(1,end)-0)/(xtp(1,end)-0)) - atan((xtp(1,end)-0)/(ytp(1,end)-0))) * (180/pi);
                   theta = -90; % to rotate 90 clockwise
                   R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
                   % Rotate your point(s)
                   point = [xtp; ytp]; % arbitrarily selected
                   rotpoint = R*point;
                   nX=rotpoint(1,:)'; %ycor data goes to x to flip45%�̰� �Ϻη� �׷��� �Ѱǰ�
                   nY=rotpoint(2,:)';%xcor goes to y to flip 45

%                    subplot(1,2,1)
%                    plot(nX, nY)
%                    subplot(1,2,2)
%                    plot(nX2, nY2)               
                end
            elseif  expType ==2%HH    
            % ��� ��ǥ�� ���� Ÿ��(��) �� �����Ϸ���, ���� Ÿ�ϵ� (��,��)���� ������ �¿� ���� ��Ų ��, �������� ���� �������� ����(����) ���� ���Ѿ�
            %->������ ���� ������ ���� ���� ��Ű�� ������ ����� �̹� ���� ������ �� ���¿��� ��ϵǾ��� ����
                if eptray(epc,8)==1 || eptray(epc,8)==3 %���� �¿� ����
                    xdiff=diff(nX);nz=zeros(1,101);
                    for it=2:101;nz(it)=nz(it-1)-xdiff(it-1);end
                    nX=nz'; clear nz xdiff                
                end                
                if eptray(epc,8)==1 || eptray(epc,8)==2 %���� ���� ����
                    ydiff=diff(nY);ny=zeros(1,101);
                    for it=2:101;ny(it)=ny(it-1)-ydiff(it-1);end
                    nY=ny'; clear ny ydiff     
                end                
            end
            nY=nY-min(nY);%���η� ������ �Ϻ� ������ y=0 ���� �Ʒ��� �������� ������ auc ����� ��������    
       
            %init & velo & linelength
            [initpf, detl(epc,1), nV, eptray(epc,9), acel]=initcal_HPL(nX, nY, nT);%eptray(epc,9)=���� ����
                        
            %rescaler
            %��� ������ ��Ȯ�ϰ� ���� ��ġ(�ȼ�����)���� ���� �Ǵ� ���� �ƴϱ� ������ ��� ������ ���� �Ǹ� �� ������
            %���� ���� �� ����� �ִ� ���� �� �� �ִµ�, �Ʒ� �ڵ带 ���� �Ǹ� ������ ũ�� ������ �ƾ� �����ϰ� (1 by 1.5, ���� ����) ������
            %���߰� �ȴ�. ���� �Ƚᵵ �ǳ� �̰� ���������� �ñ��ϸ� �ּ������ϰ� ����� ��� �޶������� ����
            %[nX,  nY]=normal_HPL(nX, nY);
            
            %RT, Init
            eptray(epc,10)= initpf;%initiation time           
            eptray(epc,11)= nT(end)-initpf;%movement time (RT-Initiation time, ������ �̵��� �ɸ� �ð�)
            eptray(epc,12)= nT(end);%RT   
            dcheck(epc,3)=eptray(epc,12);
            
            
            % AUC -> �������� ������ �κ�, �ڼ��� ������ help auc1HPL
            [eptray(epc,13), nX, nY] = auc1HPL(nX, nY);%area under curve
            nY=nY-nY(1); %�ٽ� y��ǥ�� 0���� �����ϰ� ����

            %spatial flip
            %���콺�� �����̴� ���� �������� ������ ���� Ƚ�� (÷�� ���� ����)
            eptray(epc,14)= flipcounterHPL(nX');%xflip   
            eptray(epc,15)= flipcounterHPL(nY');%yflip    
            
            %spatial disorder
            %������ ��Ʈ���� ��, �����ϰ� ���ϸ� ������ �󸶳� ���̳����� ���������� �����ִ� �ǵ�, �Ϲ������� ����ȯ�ڰ� 
            %������ �� ó�� �ڱ��ڱ��ϰ� ���� ������ ��Ʈ���� ���� �� ũ�� ���´�. (÷�� ���� ����)
            %���� �� "3"�� ������ ��Ʈ���Ǹ� ������ �������� ũ��, Ư���� ������ ���ٸ� 3�� �״�� ���°� ����, �ڼ��� ��
            %÷�ε� Hehman et al ���� ����
            eptray(epc,16)= spatialDOD_HPL(nX',3);%xDOD,   
            eptray(epc,17)= spatialDOD_HPL(nY',3);%yDOD    
            
            %min max
            %�ְ� ������ �ӵ��� 0�� �ƴ� ���� �ӵ�, �׸��� �� ���೻���� �ְ��� �ӵ��� ��Ÿ�� ����
            [eptray(epc,18),eptray(epc,19)] = max(nV,[],1);%�ְ� �ӵ�, �ְ� �ӵ� ���� ����(ù��° ��ǥ���� ������ ��ǥ �̵� ��)
            nonz=nV(nV~=0);
            if isempty(nonz)
               detl(epc,1)=0; 
            else            
                [eptray(epc,20),~] = min(nonz,[],1);
                eptray(epc,21) = find(nV==eptray(epc,20),1);
            end
            eptray(epc,19)=eptray(epc,19)+1;
            eptray(epc,21)=eptray(epc,21)+1;   
            %�ֳĸ� �ӵ��� n+1����Ʈ ���������� �ӵ��ϱ�, �� A�������� B �������� �̵��� ���� �ӵ��� B���������� �ӵ��̹Ƿ�

            %Phase angle data
            %������ ���� ���ϴ� function
            [weightedAngle1(epc,:),pAngle1(epc,:),angleTemp(epc,:)] = panglecalHPL(nX', nY');
            eptray(epc,22)=mean(angleTemp(epc,:),2);
            
            %2D indices of flip, entropy, overshoot            
            [eptray(epc,24)] = flipcounter2D(nX', nY');
            [eptray(epc,25)] = spatialDOD2D(nX', nY' ,3);
            [eptray(epc,26)] = maxOvershoot2D(nX', nY',1);            
            
            eptray(epc,31:131)=nX';%x��ǥ   
            eptray(epc,132)=99999;                  
            eptray(epc,133:233)=nY';%yǥ     
            eptray(epc,234)=99999;                  
            eptray(epc,235:335)=nT';%�ð�����                 
            eptray(epc,336)=99999;                  
            eptray(epc,337:436)=nV';%�ӵ����� 
            eptray(epc,437)=99999;                  
            eptray(epc,438:536)=acel';%�ӵ�����    
            clear nX nY nT nV
            epc=epc+1;
        end
        clear rIDX
    end
    
pAngle2 = [eptray(:,1:4) pAngle1]; clear pAngle1  %���� �ڵ��� ������ ���� �����͸� ���� �־� ���ƾ� ���߿� �м��� �� �����ϱ� ����  
angleTemp=[eptray(:,1:4) angleTemp];   
wAngle2 = [eptray(:,1:4) weightedAngle1];
   %%
   %���⼭ ���� trial ���� ����.
   %�� ���ؿ� ���� �ʾ� ������ trial�� 0���� ǥ��, ���� trial�� 1�� ǥ��
   zs=zscore(eptray(:,12)); %RT cutoff(outlier)
   zs_surv(:,1)=logical((zs>-cutoff).*(zs<cutoff));
   zs_surv(:,3)=logical(acctray);  %ACC Ʋ���� ����
   zs_surv(:,5)=eptray(:,23)~=0; % �� ��� ù��° ���� 
   for swp = size(acctray,1):-1:2
       % �������� outlier trial�� ���� ����   
        zs_surv(1,2)=1;
       if zs_surv(swp-1,1)==0
          zs_surv(swp,2)=0; 
       else
          zs_surv(swp,2)=1;            
       end
       % �������� incorrect trial�� ���� ����
       zs_surv(1,4)=1;       
       if acctray(swp-1,1)==0
          zs_surv(swp,4)=0; 
       else
          zs_surv(swp,4)=1;  
       end
   end
   %xyflip cri
   zs_surv(:,6)=detl; % �Ʊ� ������ �ӵ��� 0.96px/ms ������ �� �ѹ��� �ʰ��� ���� ���� trials�� 
%    zs1=zscore(eptray(:,13)+eptray(:,14)); %x&y flip�� ���ؼ� ��û �̻��� ����� ���� ����
%    zs_surv(:,7)=logical((zs1>-cutoff).*(zs1<cutoff));
   
   flist =logical(prod(zs_surv,2));%���� 7���� ���� �� ���ϳ��� �ɷ����� 0
   erlist= size(zs_surv,1) - sum(zs_surv,1);%�� cutoff ���ؿ� �ش��ؼ� ���ŵǾ��� trial��, �ߺ��Ǵ� ��찡 �־ ��ü ���� trial�� �� �պ��� ����
   erlist(1,7) = size(zs_surv,1) - sum(flist);%������ ���ŵ� trial ��
   erlist(1,8) = (erlist(1,7)/size(zs_surv,1))*100;%���ŵ� trial���� 
   
   eptray=eptray(flist,:);
   dcheck=dcheck(flist,:);
   pAngle2=pAngle2(flist,:);
   wAngle2=wAngle2(flist,:);
   nXo=nXo(flist,:);nYo=nYo(flist,:);
   angleTemp=angleTemp(flist,:);
      
   nXo=[abs(eptray(:,1:3)) abs(eptray(:,8)) nXo];nYo=[abs(eptray(:,1:3)) abs(eptray(:,8)) nYo];
   [X,~]=mlavgHPL(nXo,[4 2 3]);[Y,~]=mlavgHPL(nYo,[4 2 3]);
   
   ord=[4 6 8 2];
   lim=[-400 200 -20 20; -200 400 -20 20;-20 20 -400 200;-20 20 -200 400]; 
   figure('units','normalized','outerposition',[0 0 1 1])
   for i = 1:4
       subplot(3,3,ord(i))
       tX=X(X(:,4)==i,:);tY=Y(X(:,4)==i,:); 
       plot(tX(1,5:end), tY(1,5:end),'b')
       hold on
       plot(tX(2,5:end), tY(2,5:end),'r')
       plot(tX(3,5:end), tY(3,5:end),'--b')
       plot(tX(4,5:end), tY(4,5:end),'--r')
       xlim(lim(i,1:2)); ylim(lim(i,3:4))
       clear tX tY
       hline(0,':k');vline(0,':k');
   end   
   
   orgXY.x=nXo;orgXY.y=nYo;
   suptitle(sprintf('Participant %d Mean Trajectory',eptray(1,1)))   
   saveas(gcf,sprintf('Participant %d Mean TrajectoryADCO',eptray(1,1)),'tiff')
   close
   fprintf('  --%d trials excluded by cuttoff criteria, total of %d trials remaining \n',size(zs_surv,1)-sum(flist),sum(flist))  
   % 1partno/2subjectratubg/3loadlevel/4relevdim/5relevF/6irrelevF/7n0/8n1/9tarloc/10initT/11MvT/12RT
   % 13linelength/14auc/15xflip/16yflip/17xdod/18ydod/19maxV/20maxVo/21minV/22minVo/23probeACC
% 
% 
%     subplot(2,1,1)
%     plot(eptray(:,31:131)', eptray(:,133:233)')
%     title('all trajectories')
%     subplot(2,1,2)
%     plot(mean(eptray(:,31:131))', mean(eptray(:,133:233))')
%     title('mean trajectory')
% 
%     subplot(2,1,1)
%     for sn= 1:size(eptray,1) 
%         scatter(eptray(sn,31:131), eptray(sn,133:233),2, 'filled')
%         if sn==1;hold on;elseif sn==size(eptray,1);hold off;end 
%     end
%       subplot(2,1,2)
%     scatter(mean(eptray(:,31:131))', mean(eptray(:,133:233))',5, 'filled')
%     suptitle(sprintf('Par%d with average RT of %.0f',tmtray.subject_nr(1), mean(eptray(:,12),1)));
%     saveas(gcf,['P' mat2str(eptray(1,1)) '.tiff'])
%     close all




end

