function [eptray, erlist,dcheck, pAngle2, orgXY,angleTemp, wAngle2] = torganizerHPL_minu(tmtray,cutoff)
disp("beginning torganizerHPL")
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
% (23)bin 
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


epc = tmtray.id(1);

eptray(1:size(tmtray,1),1)=tmtray.id(1); %subject number
%             eptray(epc,1)=str2num(tmtray.id{1}); %subject number
eptray(1:size(tmtray,1),2)=tmtray.n0(:,:);%n0 congruence
eptray(1:size(tmtray,1),3)=tmtray.n1(:,:);%n1 congruence
eptray(1:size(tmtray,1),4)=tmtray.n2(:,:);%n2 congruence
eptray(1:size(tmtray,1),5)=tmtray.taskType(:,:);%taskType 1=����/2=�ĳ�
eptray(1:size(tmtray,1),6)=tmtray.btwC(:,:);
eptray(1:size(tmtray,1),7)=tmtray.withC(:,:);
eptray(1:size(tmtray,1),8)=tmtray.targ_loc;%%HV[expType1]: (1)����-��, (2)������-�� (3)�Ʒ�-�� (4)��-��
eptray(1:size(tmtray,1),23)=tmtray.bin;
eptray(1:size(tmtray,1),30)=99999;%�� ���ĺ��ʹ� x,y��ǥ �� �ð� ������ ����.

%��ǥ ó��
%���迡 ����� ���α׷��� ��� (1)�������~ť����, (2)ť����~Ÿ�� ���� ������ ���� tracking �ϱ� ������ ��
%������ ��ǥ�� ���� ����� �ǰ�, �׷��� �� ������ ��ǥ�� ���ľ� �Ѵ�. �װ��� �Ʒ� �ڵ尡 �ϴ� ��


for i = 1:size(tmtray,1)
    
    nX = split(tmtray.x_coords(i), ["[","]",", "]);
    nX = str2double(nX(2:end-1));
    
    nY = split(tmtray.y_coords(i), ["[","]",", "]);
    nY = str2double(nY(2:end-1));
    
    nT = split(tmtray.times(i), ["[","]",", "]);
    nT = str2double(nT(2:end-1));
    
    
%101 interpolation
%�� ��������(����) ��ǥ�� �����ϴ� ����Ÿ ����(x, y, t rotn)�� �ٸ��� ������ ������ ����� ������ ����. �׷��� interpolation�� �̿��ؼ�
%�� �������� 101���� x,y,t ���� ������ ó���ؾ� �Ѵ�. ���� ��� ������ ������ ������ ��A�� �ټ�����
%������ ������ ��B�� �ִٰ� ġ��. �� ��쿡 �� ���� ����� ���� ���� ������(��)�� ������ �װ��� �����ϰ��� �� ��
%1) �켱 �� A���� ������ �� �װ��� ���, ��B ���� ������ �� �װ��� ������ �� �� ��ü�� ����� ������
%������ �������� ������ ���������� ������ ����� �� ���� �ִ�.

[nX, nY, nT] = timespace33HPL(nX, nY, nT);
nXo(i,:)=nX';nYo(i,:)=nY';

%��ǥ �����ϱ�: �� ������ �����񱳸� �ϱ� ���� �ؾ��� �ٸ� ó���� ��ǥ�� �� �������� ���Ľ�Ű�� ���̴�. ���� ��� ���� Ÿ���� ���� ������
%�»�� Ÿ���� ���� ������ ���ϱ� ���ؼ� �� �� �ϳ��� �ٸ� �������� ������ �� �ʿ䰡 �ִ�. ���� ������ �ѹ��� ���� �»�� Ÿ���� ���� ������ ����ٰų�...
%�� ������ ��쿡�� HV������ ��� ��� ������ ������ Ÿ����(�ʷϻ�) ���ϵ���, HH ������ ��� ���� Ÿ����(�ʷϻ�) ���ϰ� �����ϵ��� �ڵ带 �ۼ��Ͽ���.
%�߿�)!!! open sesame���α׷��� ����� ��ǥ�� ���� �����Ǿ��ִ� ��ǥ�̱� ������ ������ ����ؼ� ��ǥ ������ ����ؼ� ���� �۾��� �ؾ� �Ѵ�.


% ��� ��ǥ�� ������ Ÿ��(��) �� �����Ϸ���, ���� Ÿ�ϵ� (��)���� ������ �¿� ����, �� Ÿ��(��)�� ���� ����, �� ���� �� �������� ���ĵ� ��, �� Ÿ����
% ���� ������ �ð�������� 90�� ������ �Ѵ�.
%->������ ���� ������ ���� ���� ��Ű�� ������ ����� �̹� ���� ������ �� ���¿��� ��ϵǾ��� ����

if eptray(i,8)==1 %�� �¿� ����
    %%%%%%% must check if horizontal trajectories should be
    %%%%%%% flipped upside down
    xdiff=diff(nX);
    nz=zeros(1,101);
    for it=2:101;
        nz(it)=nz(it-1)-xdiff(it-1);
    end
    nX=nz'; clear nz xdiff
elseif eptray(i,8)==3 %�� ���� ����
    ydiff=diff(nY);ny=zeros(1,101);
    for it=2:101;ny(it)=ny(it-1)-ydiff(it-1);end
    nY=ny'; clear ny ydiff
end

if eptray(i,8)==3 || eptray(i,8)==4 %�ĳ� �ð���� 90�� ȸ��
    ytp= nY';xtp= nX';
    a=(atan((ytp(1,end)-0)/(xtp(1,end)-0)) - atan((xtp(1,end)-0)/(ytp(1,end)-0))) * (180/pi);
    theta = -90; % to rotate 90 clockwise
    R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    % Rotate your point(s)
    point = [xtp; ytp]; % arbitrarily selected
    rotpoint = R*point;
    nX=rotpoint(1,:)'; %ycor data goes to x to flip45%�̰� �Ϻη� �׷��� �Ѱǰ�
    nY=rotpoint(2,:)';%xcor goes to y to flip 45
end

nY=nY-min(nY);%���η� ������ �Ϻ� ������ y=0 ���� �Ʒ��� �������� ������ auc ����� ��������

%init & velo & linelength
[initpf, detl(i,1), nV, eptray(i,9), acel] = initcal_HPL(nX, nY, nT);
%eptray(epc,9)=���� ����

%rescaler
%��� ������ ��Ȯ�ϰ� ���� ��ġ(�ȼ�����)���� ���� �Ǵ� ���� �ƴϱ� ������ ��� ������ ���� �Ǹ� �� ������
%���� ���� �� ����� �ִ� ���� �� �� �ִµ�, �Ʒ� �ڵ带 ���� �Ǹ� ������ ũ�� ������ �ƾ� �����ϰ� (1 by 1.5, ���� ����) ������
%���߰� �ȴ�. ���� �Ƚᵵ �ǳ� �̰� ���������� �ñ��ϸ� �ּ������ϰ� ����� ��� �޶������� ����
%[nX,  nY]=normal_HPL(nX, nY);

%RT, Init
eptray(i,10)= initpf;%initiation time
eptray(i,11)= nT(end)-initpf;%movement time (RT-Initiation time, ������ �̵��� �ɸ� �ð�)
eptray(i,12)= nT(end);%RT
dcheck(i,3)=eptray(i,12);


% AUC -> �������� ������ �κ�, �ڼ��� ������ help auc1HPL
[eptray(i,13), nX, nY] = auc1HPL(nX, nY);%area under curve
nY=nY-nY(1); %�ٽ� y��ǥ�� 0���� �����ϰ� ����

%spatial flip
%���콺�� �����̴� ���� �������� ������ ���� Ƚ�� (÷�� ���� ����)
eptray(i,14)= flipcounterHPL(nX');%xflip
eptray(i,15)= flipcounterHPL(nY');%yflip

%spatial disorder
%������ ��Ʈ���� ��, �����ϰ� ���ϸ� ������ �󸶳� ���̳����� ���������� �����ִ� �ǵ�, �Ϲ������� ����ȯ�ڰ�
%������ �� ó�� �ڱ��ڱ��ϰ� ���� ������ ��Ʈ���� ���� �� ũ�� ���´�. (÷�� ���� ����)
%���� �� "3"�� ������ ��Ʈ���Ǹ� ������ �������� ũ��, Ư���� ������ ���ٸ� 3�� �״�� ���°� ����, �ڼ��� ��
%÷�ε� Hehman et al ���� ����
eptray(i,16)= spatialDOD_HPL(nX',3);%xDOD,
eptray(i,17)= spatialDOD_HPL(nY',3);%yDOD

%min max
%�ְ� ������ �ӵ��� 0�� �ƴ� ���� �ӵ�, �׸��� �� ���೻���� �ְ��� �ӵ��� ��Ÿ�� ����
[eptray(i,18),eptray(i,19)] = max(nV,[],1);%�ְ� �ӵ�, �ְ� �ӵ� ���� ����(ù��° ��ǥ���� ������ ��ǥ �̵� ��)
nonz=nV(nV~=0);
if isempty(nonz)
    detl(i,1)=0;
else
    [eptray(i,20),~] = min(nonz,[],1);
    eptray(i,21) = find(nV==eptray(i,20),1);
end
eptray(i,19)=eptray(i,19)+1;
eptray(i,21)=eptray(i,21)+1;
%�ֳĸ� �ӵ��� n+1����Ʈ ���������� �ӵ��ϱ�, �� A�������� B �������� �̵��� ���� �ӵ��� B���������� �ӵ��̹Ƿ�

%Phase angle data
%������ ���� ���ϴ� function
[weightedAngle1(i,:),pAngle1(i,:),angleTemp(i,:)] = panglecalHPL(nX', nY');
eptray(i,22)=mean(angleTemp(i,:),2);

%2D indices of flip, entropy, overshoot
[eptray(i,24)] = flipcounter2D(nX', nY');
[eptray(i,25)] = spatialDOD2D(nX', nY' ,3);
[eptray(i,26)] = maxOvershoot2D(nX', nY',1);

eptray(i,31:131)=nX';%x��ǥ
eptray(i,132)=99999;
eptray(i,133:233)=nY';%yǥ
eptray(i,234)=99999;
eptray(i,235:335)=nT';%�ð�����
eptray(i,336)=99999;
eptray(i,337:436)=nV';%�ӵ�����
eptray(i,437)=99999;
eptray(i,438:536)=acel';%�ӵ�����
clear nX nY nT nV
end

pAngle2 = [eptray(:,1:4) pAngle1];  %���� �ڵ��� ������ ���� �����͸� ���� �־� ���ƾ� ���߿� �м��� �� �����ϱ� ����
angleTemp=[eptray(:,1:4) angleTemp];
wAngle2 = [eptray(:,1:4) weightedAngle1];

%
%���⼭ ���� trial ���� ����.
%�� ���ؿ� ���� �ʾ� ������ trial�� 0���� ǥ��, ���� trial�� 1�� ǥ��
%xyflip cri

zs_surv(:,1)=detl;
% �Ʊ� ������ �ӵ��� 0.96px/ms ������ �� �ѹ��� �ʰ��� ���� ���� trials��

% zs1=zscore(eptray(:,13)+eptray(:,14)); %x&y flip�� ���ؼ� ��û �̻��� ����� ���� ����
% zs_surv(:,7)=logical((zs1>-cutoff).*(zs1<cutoff));

flist =logical(prod(zs_surv,2));%���� 7���� ���� �� ���ϳ��� �ɷ����� 0
erlist= size(zs_surv,1) - sum(zs_surv,1);%�� cutoff ���ؿ� �ش��ؼ� ���ŵǾ��� trial��, �ߺ��Ǵ� ��찡 �־ ��ü ���� trial�� �� �պ��� ����
erlist(1,7) = size(zs_surv,1) - sum(flist);%������ ���ŵ� trial ��
erlist(1,8) = (erlist(1,7)/size(zs_surv,1))*100;%���ŵ� trial����

eptray=eptray(flist,:);
dcheck=dcheck(flist,:);
pAngle2=pAngle2(flist,:);
wAngle2=wAngle2(flist,:);
nXo=nXo(flist,:);
nYo=nYo(flist,:);
angleTemp=angleTemp(flist,:);

nXo=[abs(eptray(:,1:3)) abs(eptray(:,8)) nXo];
nYo=[abs(eptray(:,1:3)) abs(eptray(:,8)) nYo];

orgXY.x=nXo;
orgXY.y=nYo;






close

end

