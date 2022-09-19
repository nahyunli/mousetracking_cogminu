function [eptray, erlist,dcheck, pAngle2, orgXY,angleTemp, wAngle2] = torganizerHPL_minu(tmtray,cutoff)
disp("beginning torganizerHPL")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 참고 2019.5.11: 여기 코드는 마우스 트래킹을 첨 배우는 사람의 이해를 돕기 위해 for loop을 돌려서 trial
% 별로 preprocessing을 하도록 작성되었는데, 그렇기 때문에 코드가 돌아가는 속도가 매우 느림. 그러므로 코드에 익숙해 졌다
% 싶으면 matrix 연산을 이용해서 데이터 처리 속도를 향상시키길 권장
%
% 참고) eptray column index
% (1)ParticipantNo.
% (2)n0 congruence
% (3)n-1 congruence
% (4)n-2 congruence-> congruence repetition으로 변경
% (5)taskType 1=빨초/2=파노
% (6)btwC
% (7)withC
% (8)target location
%    HV[expType1]: (1)왼쪽-빨, (2)오른쪽-초 (3)위-파 (4)아래-노
%    HH[expType2]: (1)왼쪽위-빨, (2)오른쪽위-초 (3)왼쪽아래-노 (4)오른쪽아래-파
% (9)trajectory 길이
% (10)initiation time
% (11)movement time (RT-Initiation time, 실제로 이동에 걸린 시간)
% (12)RT
% (13)Area Under Curve
% (14)xflip:마우스를 움직이는 동안 움직임의 방향을 꺾은 횟수(횡)
% (15)yflip: 마우스를 움직이는 동안 움직임의 방향을 꺾은 횟수(종)
% (16)X 엔트로피
% (17)Y 엔트로피
% (18)최고 속도
% (19)최고 속도 출현 시점
% (20)0이 아닌 최저 속도
% (21)최저 속도 출현 시점
% (22)phase angle 분석을 위한 복소수 여기 넣어 두기 -> 지우고 따로 보관함
% (23)bin 
% (24)flip2D
% (25)Entropy2D
% (26)Overshoot2D
% (31~131) x좌표
% (133~233) y좌표
% (235~335) 시간정보, trial시작하고 각각의 xy좌표에 도달하기까지 얼마의 시간이 걸렸는가
% (337~436) 속도정보
% (438~536) 가속도정보
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%


epc = tmtray.id(1);

eptray(1:size(tmtray,1),1)=tmtray.id(1); %subject number
%             eptray(epc,1)=str2num(tmtray.id{1}); %subject number
eptray(1:size(tmtray,1),2)=tmtray.n0(:,:);%n0 congruence
eptray(1:size(tmtray,1),3)=tmtray.n1(:,:);%n1 congruence
eptray(1:size(tmtray,1),4)=tmtray.n2(:,:);%n2 congruence
eptray(1:size(tmtray,1),5)=tmtray.taskType(:,:);%taskType 1=빨초/2=파노
eptray(1:size(tmtray,1),6)=tmtray.btwC(:,:);
eptray(1:size(tmtray,1),7)=tmtray.withC(:,:);
eptray(1:size(tmtray,1),8)=tmtray.targ_loc;%%HV[expType1]: (1)왼쪽-빨, (2)오른쪽-초 (3)아래-노 (4)위-파
eptray(1:size(tmtray,1),23)=tmtray.bin;
eptray(1:size(tmtray,1),30)=99999;%이 이후부터는 x,y좌표 밑 시간 정보가 들어간다.

%좌표 처리
%실험에 사용한 프로그램의 경우 (1)시행시작~큐제시, (2)큐제시~타겟 선택 구간을 따로 tracking 하기 때문에 두
%구간의 좌표가 따로 기록이 되고, 그래서 이 구간의 좌표를 합쳐야 한다. 그것이 아래 코드가 하는 것


for i = 1:size(tmtray,1)
    
    nX = split(tmtray.x_coords(i), ["[","]",", "]);
    nX = str2double(nX(2:end-1));
    
    nY = split(tmtray.y_coords(i), ["[","]",", "]);
    nY = str2double(nY(2:end-1));
    
    nT = split(tmtray.times(i), ["[","]",", "]);
    nT = str2double(nT(2:end-1));
    
    
%101 interpolation
%각 움직임의(궤적) 좌표를 구성하는 데이타 개수(x, y, t rotn)가 다르기 때문에 궤적을 평균을 낼수가 없다. 그래서 interpolation을 이용해서
%각 궤적마다 101개의 x,y,t 값을 가지게 처리해야 한다. 예를 들어 세개의 점으로 구성된 선A와 다섯개의
%점으로 구성된 선B가 있다고 치자. 이 경우에 두 선의 평균을 내기 위해 데이터(점)의 개수를 네개로 통일하고자 할 때
%1) 우선 선 A위에 임의의 점 네개를 찍고, 선B 위에 임의의 점 네개를 찍으면 그 선 자체의 모양은 변하지
%않지만 테이터의 개수가 동일해지기 때문에 평균을 낼 수가 있다.

[nX, nY, nT] = timespace33HPL(nX, nY, nT);
nXo(i,:)=nX';nYo(i,:)=nY';

%좌표 정렬하기: 각 궤적간 직접비교를 하기 위해 해야할 다른 처리는 좌표를 한 방향으로 정렬시키는 것이다. 예를 들어 우상단 타켓을 향한 궤적과
%좌상단 타겟을 향한 궤적을 비교하기 위해서 둘 중 하나는 다른 방향으로 돌려야 할 필요가 있다. 우상단 궤적을 한바퀴 돌려 좌상단 타겟을 향한 궤적을 만든다거나...
%이 실험의 경우에는 HV실험의 경우 모든 궤적을 오른쪽 타겟을(초록색) 향하도록, HH 실험의 경우 우상단 타겟을(초록색) 향하게 정렬하도록 코드를 작성하였다.
%중요)!!! open sesame프로그램이 기록한 좌표는 상하 반전되어있는 좌표이기 때문에 이점을 고려해서 좌표 이점을 고려해서 정렬 작업을 해야 한다.


% 모든 좌표를 오른쪽 타켓(초) 로 정렬하려면, 왼쪽 타켓들 (빨)향한 궤적을 좌우 반전, 위 타겟(파)를 상하 반전, 그 다음 한 방향으로 정렬된 파, 초 타겟을
% 향한 궤적을 시계방향으로 90도 돌려야 한다.
%->위쪽을 향한 궤적을 상하 반전 시키는 이유는 얘들이 이미 상하 반전이 된 상태에서 기록되었기 때문

if eptray(i,8)==1 %빨 좌우 반전
    %%%%%%% must check if horizontal trajectories should be
    %%%%%%% flipped upside down
    xdiff=diff(nX);
    nz=zeros(1,101);
    for it=2:101;
        nz(it)=nz(it-1)-xdiff(it-1);
    end
    nX=nz'; clear nz xdiff
elseif eptray(i,8)==3 %파 상하 반전
    ydiff=diff(nY);ny=zeros(1,101);
    for it=2:101;ny(it)=ny(it-1)-ydiff(it-1);end
    nY=ny'; clear ny ydiff
end

if eptray(i,8)==3 || eptray(i,8)==4 %파노 시계방향 90도 회전
    ytp= nY';xtp= nX';
    a=(atan((ytp(1,end)-0)/(xtp(1,end)-0)) - atan((xtp(1,end)-0)/(ytp(1,end)-0))) * (180/pi);
    theta = -90; % to rotate 90 clockwise
    R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    % Rotate your point(s)
    point = [xtp; ytp]; % arbitrarily selected
    rotpoint = R*point;
    nX=rotpoint(1,:)'; %ycor data goes to x to flip45%이거 일부로 그렇게 한건가
    nY=rotpoint(2,:)';%xcor goes to y to flip 45
end

nY=nY-min(nY);%가로로 눕히면 일부 라인이 y=0 라인 아래로 내러가기 때문에 auc 계산이 복잡해짐

%init & velo & linelength
[initpf, detl(i,1), nV, eptray(i,9), acel] = initcal_HPL(nX, nY, nT);
%eptray(epc,9)=궤적 길이

%rescaler
%모든 궤적이 정확하게 같은 위치(픽셀단위)에서 종료 되는 것이 아니기 때문에 평균 궤적을 보게 되면 각 궤적의
%끝이 조금 씩 흩어져 있는 것을 볼 수 있는데, 아래 코드를 쓰게 되면 궤적의 크기 단위를 아얘 변경하고 (1 by 1.5, 단위 없음) 끝점을
%맞추게 된다. 굳이 안써도 되나 이게 무슨말인지 궁금하면 주석해제하고 결과가 어떻게 달라지는지 보기
%[nX,  nY]=normal_HPL(nX, nY);

%RT, Init
eptray(i,10)= initpf;%initiation time
eptray(i,11)= nT(end)-initpf;%movement time (RT-Initiation time, 실제로 이동에 걸린 시간)
eptray(i,12)= nT(end);%RT
dcheck(i,3)=eptray(i,12);


% AUC -> 선생님이 강조한 부분, 자세한 내용은 help auc1HPL
[eptray(i,13), nX, nY] = auc1HPL(nX, nY);%area under curve
nY=nY-nY(1); %다시 y좌표를 0부터 시작하게 정렬

%spatial flip
%마우스를 움직이는 동안 움직임의 방향을 꺾은 횟수 (첨부 사진 참조)
eptray(i,14)= flipcounterHPL(nX');%xflip
eptray(i,15)= flipcounterHPL(nY');%yflip

%spatial disorder
%궤적의 엔트로피 값, 간단하게 말하면 궤적이 얼마나 다이나믹한 정도인지를 보여주는 건데, 일반적으로 간질환자가
%조작한 것 처럼 자글자글하게 생긴 궤적이 엔트로피 값이 더 크게 나온다. (첨부 사진 참조)
%옆에 들어간 "3"은 궤적의 엔트로피를 측정할 윈도우의 크기, 특별한 사유가 없다면 3을 그대로 쓰는게 좋다, 자세한 건
%첨부된 Hehman et al 논문을 참조
eptray(i,16)= spatialDOD_HPL(nX',3);%xDOD,
eptray(i,17)= spatialDOD_HPL(nY',3);%yDOD

%min max
%최고 움직임 속도와 0이 아닌 최저 속도, 그리고 한 시행내에서 최고저 속도가 나타난 시점
[eptray(i,18),eptray(i,19)] = max(nV,[],1);%최고 속도, 최고 속도 출현 시점(첫번째 좌표에서 마지막 촤표 이동 중)
nonz=nV(nV~=0);
if isempty(nonz)
    detl(i,1)=0;
else
    [eptray(i,20),~] = min(nonz,[],1);
    eptray(i,21) = find(nV==eptray(i,20),1);
end
eptray(i,19)=eptray(i,19)+1;
eptray(i,21)=eptray(i,21)+1;
%왜냐면 속도는 n+1포인트 지점에서의 속도니까, 즉 A지점에서 B 지점으로 이동할 때의 속도는 B지점에서의 속도이므로

%Phase angle data
%궤적의 각도 구하는 function
[weightedAngle1(i,:),pAngle1(i,:),angleTemp(i,:)] = panglecalHPL(nX', nY');
eptray(i,22)=mean(angleTemp(i,:),2);

%2D indices of flip, entropy, overshoot
[eptray(i,24)] = flipcounter2D(nX', nY');
[eptray(i,25)] = spatialDOD2D(nX', nY' ,3);
[eptray(i,26)] = maxOvershoot2D(nX', nY',1);

eptray(i,31:131)=nX';%x좌표
eptray(i,132)=99999;
eptray(i,133:233)=nY';%y표
eptray(i,234)=99999;
eptray(i,235:335)=nT';%시간정보
eptray(i,336)=99999;
eptray(i,337:436)=nV';%속도정보
eptray(i,437)=99999;
eptray(i,438:536)=acel';%속도정보
clear nX nY nT nV
end

pAngle2 = [eptray(:,1:4) pAngle1];  %조건 코딩과 궤적의 각도 데이터를 같이 넣어 놓아야 나중에 분석할 때 용이하기 때문
angleTemp=[eptray(:,1:4) angleTemp];
wAngle2 = [eptray(:,1:4) weightedAngle1];

%
%여기서 부터 trial 제거 들어간다.
%각 기준에 맞지 않아 제거할 trial은 0으로 표시, 남는 trial은 1로 표시
%xyflip cri

zs_surv(:,1)=detl;
% 아까 위에서 속도가 0.96px/ms 기준을 단 한번도 초과한 적이 없는 trials들

% zs1=zscore(eptray(:,13)+eptray(:,14)); %x&y flip을 통해서 엄청 이상한 모양의 궤적 제거
% zs_surv(:,7)=logical((zs1>-cutoff).*(zs1<cutoff));

flist =logical(prod(zs_surv,2));%위의 7가지 기준 중 단하나라도 걸렸으면 0
erlist= size(zs_surv,1) - sum(zs_surv,1);%각 cutoff 기준에 해당해서 제거되야할 trial들, 중복되는 경우가 있어서 전체 제거 trial은 이 합보다 적다
erlist(1,7) = size(zs_surv,1) - sum(flist);%실제로 제거된 trial 수
erlist(1,8) = (erlist(1,7)/size(zs_surv,1))*100;%제거된 trial비율

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

