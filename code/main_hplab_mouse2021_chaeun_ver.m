%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mousetracking Study Code for HPLAB
% What it does
% 1. Processes data and rearranges data for further analyses
% 2. Average trials that belongs to the same conditions     
% 3. Extract additional DVs that include the followings:
%    trejectory length, initiation time, movement time, RT, area under curve, 
%    movement flips, entropys, maximun &minimum velocities
% For more information type 'help torganizerHPL' in the command window
% by Hansol Rheem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;close all;clear all
cutoff=2.5; %sd 단위로 trial 제외 기준
loc='C:\Users\Minu Kim\Documents\GitHub\mouse_tracking';
fn = 'HV';
cd(loc)

exp = 1;
x = readtable([loc,filesep,'compiled_bin.xlsx']);
    
%
clear i csvStr loc
%x.id=cellfun(@str2num,x.id); %already double data type
subnum=unique(x.id);

disp('finishing reading table')
disp('')
disp('start converting trajectories')
%
for i = 1:size(subnum,1)
    tmtray = x(x.id==subnum(i),:);%모든 피험자가 종합된 데이터에서 한 피험자 데이터만 뽑아서 처리하기 위함 
    fprintf('Participant %d data processing \n',i)  
    parInfo{i,1}=tmtray.id(1);
    ovACC = tmtray.acc; %tmtray.acc: double
    %ovACC=  tmtray.acc(~strcmp(tmtray.acc, 'undefined'),:);
    tmtray.acc(strcmp(tmtray.acc, 'undefined'))=0; %{'0'};
    parInfo{i,2}=mean(ovACC);clear ovACC;%overall ACC 시작 못한 트라이얼은 제외   %str2double(ovACC);
    ovRT=tmtray.rt(tmtray.response_time_get_start_click~=1500,:);
    parInfo{i,3}=mean(ovRT);clear ovRT; %overall RT 시작 못한 트라이얼은 제외          

%

    %AUC등 각종 DV를 계산 할 function, eptray는 분석을 위해 최종적으로 정리된 데이터
    %et 는 trial 어떤 기준으로 몇개의 trial이 삭제 되었는지를 보여주는 matrix\
    disp("start converting")
    
    [eptray, et, dcheck, pAngle2, orgXY,angleTemp, wAngle2] = torganizerHPL_minu(tmtray,cutoff); 
        
    disp("end converting")
    for tt = 4:11;
        parInfo{i,tt}=et(tt-3);
    end
    
    if i==1
       counter=1;
    end  
        
    s1=size(eptray,1);total_raw(counter:counter+s1-1,:)=eptray;
    dpicheck(counter:counter+s1-1,:)=dcheck;  
    total_raw_pangle(counter:counter+s1-1,:)=pAngle2;
    total_raw_wangle(counter:counter+s1-1,:)=wAngle2;
    orX(counter:counter+s1-1,:)=orgXY.x;
    orY(counter:counter+s1-1,:)=orgXY.y;  
    realAngle(counter:counter+s1-1,:)=angleTemp;     
    counter=counter+s1;  
    clear tmtray bkIDX bload prac eptray et ovACC dcheck pAngle2 orgXY wAngle2 
end    

%
fiRaw.datalabel={'(1)id' '(2)n0' '(3)n1' '(4)n2' '(5)taskType' '(6)btwC' '(7)withC' '(8)tarLoc' '(9)tLength'...
    '(10)InitT' '(11)MT' '(12)RT' '(13)AUC' '(14)xFlip' '(15)yFlip' '(16)xEntrop' '(17)yEntrop' '(18)maxVelo' '(19)maxTime'...
    '(20)minVelo' '(21)minTime' '(22) complexnum' '(23)bin' '(24)flip2D' '(25)Entropy2D' '(26)Overshoot2D' ...    
    '(31~131)Xcoordinate' '(133~233)Ycoordinate' '(235~335)timeStamp' '(337~436)velocity', '(438~536)acceleration'};

fiRaw.dvlbl={'tLength','InitT','MT','RT','AUC','xFlip','yFlip','xEntropy','yEntropy',...
 'maxVelo','maxTime','minVelo','minTime' ,'complexnum', 'n2c', 'flip2D', 'Entrop2d', 'Overshoot2d'};
%나중에 복붙해서 사용하라고, 각 콜롬 명칭 스트링으로 입력
fiRaw.id=total_raw(:,1);
fiRaw.n0=total_raw(:,2);
fiRaw.n1=total_raw(:,3);
fiRaw.n2=total_raw(:,4);
fiRaw.taskType=total_raw(:,5);
fiRaw.btwC=total_raw(:,6);
fiRaw.withC=total_raw(:,7);
fiRaw.tarLoc=total_raw(:,8);
fiRaw.tLength=total_raw(:,9);
fiRaw.IT=total_raw(:,10);
fiRaw.MT=total_raw(:,11);
fiRaw.RT=total_raw(:,12);
fiRaw.AUC=total_raw(:,13);
fiRaw.xFlip=total_raw(:,14);
fiRaw.yFlip=total_raw(:,15);
fiRaw.Entropy_x=total_raw(:,16);
fiRaw.Entropy_y=total_raw(:,17);
fiRaw.velocity_max=total_raw(:,18);
fiRaw.Time_max=total_raw(:,19);
fiRaw.velocity_min=total_raw(:,20);
fiRaw.Time_Min=total_raw(:,21);
fiRaw.complexnum=total_raw(:,22);
fiRaw.bin=total_raw(:,23);
fiRaw.flip2d=total_raw(:,24);
fiRaw.Entropy2D=total_raw(:,25);
fiRaw.overshoot2D=total_raw(:,26);
fiRaw.coordinates_x=total_raw(:,31:131);
fiRaw.coordinates_y=total_raw(:,133:233);
fiRaw.timestamp=total_raw(:,235:335);
fiRaw.velocity=total_raw(:,337:436);
fiRaw.acceleration=total_raw(:,438:536);
fiRaw.pangle=total_raw_pangle;
fiRaw.wangle=total_raw_wangle;
fiRaw.original_x=orX;
fiRaw.original_y=orY;
fiRaw.realAngle=realAngle;

save([fn '_processedData.mat'],'fiRaw','-v7.3')



%%
clear all, clc, close all

clc;close all;clear all
expType=3;
cutoff=2.5; %sd 단위로 trial 제외 기준
loc='C:\Users\Minu Kim\Documents\GitHub\mouse_tracking';
fn = 'HV';
cd(loc)

type = "word"; % choose between location, word, arrow

load("HV_processedData.mat");

% n0 congruency vs. bin

table1 = table(fiRaw.id, fiRaw.n0, fiRaw.n1, fiRaw.bin, fiRaw.RT, fiRaw.IT, fiRaw.MT, ...
fiRaw.AUC, fiRaw.xFlip, fiRaw.yFlip, fiRaw.Entropy_x, fiRaw.Entropy_y,  ...
fiRaw.Time_max, fiRaw.complexnum, fiRaw.flip2d, fiRaw.Entropy2D, fiRaw.overshoot2D, ...
fiRaw.new_IT, fiRaw.new_MT, ... 
'VariableNames',{'id','n0','n1','bin','rt','it','mt','auc','xflip','yflip', 'entrypy_x',...
'entropy_y', 'time_max', 'complexnum', 'flip2d', 'entropy2d', 'overshoot2d', 'new_it', 'new_mt'});

sss = grpstats(table1, ["id","n0", "n1"]);
ssss = grpstats(sss, ["n0","n1"]);

writetable(sss,'indiv.xlsx')
writetable(ssss,'grand.xlsx')

% figure;
% plot(ssss.mean_mean_x_cor(1,:),ssss.mean_mean_y_cor(1,:), '-r')
% hold on
% plot(ssss.mean_mean_x_cor(2,:),ssss.mean_mean_y_cor(2,:), '-b')
% hold on
% plot(ssss.mean_mean_x_cor(3,:),ssss.mean_mean_y_cor(3,:), '-g')
% hold on
% plot(ssss.mean_mean_x_cor(4,:),ssss.mean_mean_y_cor(4,:), '-c')
% hold on
% plot(ssss.mean_mean_x_cor(5,:),ssss.mean_mean_y_cor(5,:), '--r')
% hold on
% plot(ssss.mean_mean_x_cor(6,:),ssss.mean_mean_y_cor(6,:), '--b')
% hold on
% plot(ssss.mean_mean_x_cor(7,:),ssss.mean_mean_y_cor(7,:), '--g')
% hold on
% plot(ssss.mean_mean_x_cor(8,:),ssss.mean_mean_y_cor(8,:), '--c')
% hold on

