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

%{
1~83 83
84~165 82
166~247 82
248~329 82
330~411 82
412~493 82
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;close all;clear all
expType=3;%1=HV 2=HH
%%
if expType==1
    loc='C:\Users\Hansol\Google ����̺�\ASU\10) congitive control 2019hplab\codes\raw\HV\';
    fn = 'HV';
elseif expType==2
    loc='C:\Users\Hansol\Google ����̺�\ASU\10) congitive control 2019hplab\codes\raw\HH\';
    fn = 'HH';  
elseif expType==3
    %hplab EEG study
    loc='C:\Users\Sang.A.Cho\Desktop\EEG_Data\Codes_Mouse-Tracking';
    fn = 'HV';
end
cd(loc);
runStr = [loc '/*.csv'];  
fileNames = dir(runStr);
x=readtable(fileNames(1).name);
% clearvars -except x
cutoff=2.5;%sd ������ trial ���� ����
subnum=unique(x.subject_nr);
%%

for i = 1:size(subnum,1)
    tmtray = x(x.subject_nr==subnum(i),:);%��� �����ڰ� ���յ� �����Ϳ��� �� ������ �����͸� �̾Ƽ� ó���ϱ� ���� 
    tmtray=  tmtray(~strcmp(tmtray.block, 'prac'),:);%practice trial ����
    OSclean(tmtray);
    %if subnum(i)>11;tmtray=OSclean(tmtray);end
    fprintf('Participant %d data processing \n',i)  

    parInfo{i,1}=tmtray.subject_nr(1);
    ovACC = tmtray.correct;
    %ovACC=  tmtray.correct(~strcmp(tmtray.correct, 'undefined'),:);
    tmtray.correct(strcmp(tmtray.correct, 'undefined'))=0;%{'0'};
        
    parInfo{i,2}=mean(ovACC);clear ovACC;%overall ACC ���� ���� Ʈ���̾��� ����   
    %parInfo{i,2}=mean(str2double(ovACC));clear ovACC;%overall ACC ���� ���� Ʈ���̾��� ����   
        
    ovRT=tmtray.response_time_get_response_bef + tmtray.response_time_get_response_pos; %double
    %ovRT= str2double(tmtray.response_time_get_response_bef)+str2double(tmtray.response_time_get_response_pos); 
    ovRT=ovRT(tmtray.response_time_get_start_click~=1500,:); %overall RT ���� ���� Ʈ���̾��� ���� 
    parInfo{i,3}=mean(ovRT);clear ovRT;          
       
    %�����Ϳ��� �� ��� ��ġ ǥ��
    for bs = 1:numel(unique(tmtray.block))  
        bkIDX(bs,:)=find(strcmp(tmtray.block, sprintf('block%d',bs)),1):find(strcmp(tmtray.block, sprintf('block%d',bs)), 1,'last');
    end
        
    %AUC�� ���� DV�� ��� �� function, eptray�� �м��� ���� ���������� ������ ������
    %et �� trial � �������� ��� trial�� ���� �Ǿ������� �����ִ� matrix
    [eptray, et, dcheck,pAngle2,orgXY,angleTemp, wAngle2] = torganizerHPL(tmtray,bkIDX,cutoff,expType); 
    
    for tt = 4:11;parInfo{i,tt}=et(tt-3);end
    
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
partDEMO=cell2table(parInfo, 'VariableNames',{'pNum' 'MeanACC' 'MeanRT' 'RTcut' 'AfterRTCut' 'ACCcut' 'AfterIccCut' 'first2Trials' 'VeloCut' 'DeletedTrials' 'DeletedPercent'});  

%%
% Averager    
range=[1 2 3 4];%n0, n1, congruence rep �� �������� ��ճ���
[avg_raw, ~] = mlavgHPL(total_raw,range);  
[avg_raw_pa, ~] = mlavgHPL(total_raw_pangle,range);  

range=[1 2 3];%n0, n1�� �������� ��ճ���
[avg_raw2, ~] = mlavgHPL(total_raw,range);  
[avg_raw_pa2, ~] = mlavgHPL(total_raw_pangle,range);  
%%
fiRaw.datalabel={'(1)ParNo' '(2)n0c' '(3)n1c' '(4)congrepeit' '(5)taskType' '(6)btwC' '(7)withC' '(8)tarLoc' '(9)tLength'...
    '(10)InitT' '(11)MT' '(12)RT' '(13)AUC' '(14)xFlip' '(15)yFlip' '(16)xEntrop' '(17)yEntrop' '(18)maxVelo' '(19)maxTime'...
    '(20)minVelo' '(21)minTime' '(22) complexnum' '(23)n2c' '(24)flip2D' '(25)Entropy2D' '(26)Overshoot2D' ...    
    '(31~131)Xcoordinate' '(133~233)Ycoordinate' '(235~335)timeStamp' '(337~436)velocity'};

fiRaw.dvlbl={'tLength','InitT','MT','RT','AUC','xFlip','yFlip','xEntrop','yEntrop',...
 'maxVelo','maxTime','minVelo','minTime' ,'complexnum', 'n2c', 'flip2D', 'Entrop2d', 'Overshoot2d'};
%���߿� �����ؼ� ����϶��, �� �ݷ� ��Ī ��Ʈ������ �Է�
fiRaw.total_raw=total_raw;
fiRaw.total_raw_pangle=total_raw_pangle;
fiRaw.total_raw_wangle=total_raw_wangle;
fiRaw.w3.avg_raw=avg_raw;%n0, n-1 congruency,congruence rep������ ��ճ� ������
fiRaw.w3.avg_raw_pa=avg_raw_pa;
fiRaw.w2.avg_raw=avg_raw2;
fiRaw.w2.avg_raw_pa=avg_raw_pa2;
fiRaw.origcoor.x=orX;
fiRaw.origcoor.y=orY;
fiRaw.total_realAngle=realAngle;
fiRaw.origcoor.label={'partnum','n0','n1','tarloc','coordinates'};
fiRaw.partDEMO=partDEMO;% ������ ��Ȯ�� ��� RT ���� ���Ե� ����
save([loc fn '_processedData2020.mat'],'fiRaw','-v7.3')

% system('shutdown -s')
% 


