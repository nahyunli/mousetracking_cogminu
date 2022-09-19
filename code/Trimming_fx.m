% trimming data for each subject
% 1) 1st, 2nd trials of each block
% 2) rt ouliers
% 3) trials following error
% 4) trials following RT outliers
%
% if inbound=-1, inbound is set to -N*std
% elseif inbound~=-1, inbound is set to a fixed value
 


function [DVList_T] = Trimming_fx(RespList_T,inbound,Nstd,DV)
%% %%%%%%%%%%%%%%%%%%%%%% Trimming %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Raw Data
List_T = RespList_T;
firstsecond_ids = find(List_T.n1cong==0 | List_T.n2cong==0); % 첫번째, 두번재 시행 버리기
raw_ids = setdiff(1:size(List_T,1),firstsecond_ids); % 첫번째, 두번째 이외의 시행
% 1) Remove 1st,2nd trial and calculate mean, std
raw_T = List_T(raw_ids,:); % table of data before trimming(1st,2nd 시행만 버린 상태)
raw_T_resp = raw_T(raw_T.rt~=0,:); 
% raw_T(raw_T.rt==0,:)=[]; % exclude no response trials
TGM = varfun(@mean, raw_T_resp, 'GroupingVariables', {'n1cong','n0cong','switch_repeat'}, 'OutputFormat', 'table'); % table of mean for each cond
TGS = varfun(@std, raw_T_resp, 'GroupingVariables', {'n1cong','n0cong','switch_repeat'}, 'OutputFormat', 'table'); % table of std for each cond

%%% if trimming by both RT and MT
if DV=='w'
    DV='rt';
    trim2=1;
else 
    trim2=0;
end

%% for each DV
% criteria
if inbound==-1
    inbound = TGM{:,['mean_',DV]}-TGS{:,['std_',DV]}*Nstd; % 하한선은 -(mean+Nstd)
else
    inbound = inbound*ones(4,1);
end
outbound = TGM{:,['mean_',DV]}+TGS{:,['std_',DV]}*Nstd; % 상한선은 +(mean+Nstd)
% rt oulier trial 뽑아내기
out_ids = []; 
% original code
% % out_ids = [out_ids; raw_T.trial(raw_T{:,DV} < inbound)];
% out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 1 & raw_T{:,DV} < inbound(1))];
% out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 2 & raw_T{:,DV} < inbound(2))];
% out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 1 & raw_T{:,DV} < inbound(3))];
% out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 2 & raw_T{:,DV} < inbound(4))];
% out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 1 & raw_T{:,DV} > outbound(1))];
% out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 2 & raw_T{:,DV} > outbound(2))];
% out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 1 & raw_T{:,DV} > outbound(3))];
% out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 2 & raw_T{:,DV} > outbound(4))];

%%% switch
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 1 & raw_T.switch_repeat==2 & raw_T{:,DV} < inbound(1))];
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 2 & raw_T.switch_repeat==2 & raw_T{:,DV} < inbound(2))];
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 1 & raw_T.switch_repeat==2 & raw_T{:,DV} < inbound(3))];
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 2 & raw_T.switch_repeat==2 & raw_T{:,DV} < inbound(4))];
%%% repeat
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 1 & raw_T.switch_repeat==1 & raw_T{:,DV} < inbound(1))];
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 2 & raw_T.switch_repeat==1 & raw_T{:,DV} < inbound(2))];
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 1 & raw_T.switch_repeat==1 & raw_T{:,DV} < inbound(3))];
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 2 & raw_T.switch_repeat==1 & raw_T{:,DV} < inbound(4))];

%%% switch
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 1 & raw_T.switch_repeat==2 & raw_T{:,DV} > outbound(1))];
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 2 & raw_T.switch_repeat==2 & raw_T{:,DV} > outbound(2))];
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 1 & raw_T.switch_repeat==2 & raw_T{:,DV} > outbound(3))];
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 2 & raw_T.switch_repeat==2 & raw_T{:,DV} > outbound(4))];
%%% repeat
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 1 & raw_T.switch_repeat==1 & raw_T{:,DV} > outbound(1))];
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 2 & raw_T.switch_repeat==1 & raw_T{:,DV} > outbound(2))];
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 1 & raw_T.switch_repeat==1 & raw_T{:,DV} > outbound(3))];
out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 2 & raw_T.switch_repeat==1 & raw_T{:,DV} > outbound(4))];

% marking outlier
List_T.acc(ismember(List_T.trial,out_ids)) = 9; % RT outlier를 9로 marking

%% if trimming by both RT and MT, additionally do the second trimming
%%% depending on the MT
if trim2==1
    DV='mt';
    inbound=-1;
    % criteria
    if inbound==-1
        inbound = TGM{:,['mean_',DV]}-TGS{:,['std_',DV]}*Nstd; % 하한선은 -(mean+Nstd)
    else
        inbound = inbound*ones(4,1);
    end
    outbound = TGM{:,['mean_',DV]}+TGS{:,['std_',DV]}*Nstd; % 상한선은 +(mean+Nstd)
    % rt oulier trial 뽑아내기
    out_ids = []; 
    % out_ids = [out_ids; raw_T.trial(raw_T{:,DV} < inbound)];
% original
%     out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 1 & raw_T{:,DV} < inbound(1))];
%     out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 2 & raw_T{:,DV} < inbound(2))];
%     out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 1 & raw_T{:,DV} < inbound(3))];
%     out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 2 & raw_T{:,DV} < inbound(4))];
%     out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 1 & raw_T{:,DV} > outbound(1))];
%     out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 2 & raw_T{:,DV} > outbound(2))];
%     out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 1 & raw_T{:,DV} > outbound(3))];
%     out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 2 & raw_T{:,DV} > outbound(4))];
    
    
    
    
    % switch
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 1 & raw_T.switch_repeat==2 & raw_T{:,DV} < inbound(1))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 2 & raw_T.switch_repeat==2 & raw_T{:,DV} < inbound(2))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 1 & raw_T.switch_repeat==2 & raw_T{:,DV} < inbound(3))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 2 & raw_T.switch_repeat==2 & raw_T{:,DV} < inbound(4))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 1 & raw_T.switch_repeat==2 & raw_T{:,DV} > outbound(1))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 2 & raw_T.switch_repeat==2 & raw_T{:,DV} > outbound(2))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 1 & raw_T.switch_repeat==2 & raw_T{:,DV} > outbound(3))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 2 & raw_T.switch_repeat==2 & raw_T{:,DV} > outbound(4))];
    % repeat
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 1 & raw_T.switch_repeat==1 & raw_T{:,DV} < inbound(1))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 2 & raw_T.switch_repeat==1 & raw_T{:,DV} < inbound(2))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 1 & raw_T.switch_repeat==1 & raw_T{:,DV} < inbound(3))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 2 & raw_T.switch_repeat==1 & raw_T{:,DV} < inbound(4))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 1 & raw_T.switch_repeat==1 & raw_T{:,DV} > outbound(1))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 1 & raw_T.n0cong == 2 & raw_T.switch_repeat==1 & raw_T{:,DV} > outbound(2))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 1 & raw_T.switch_repeat==1 & raw_T{:,DV} > outbound(3))];
    out_ids = [out_ids; raw_T.trial(raw_T.n1cong == 2 & raw_T.n0cong == 2 & raw_T.switch_repeat==1 & raw_T{:,DV} > outbound(4))];
    
    
    % marking outlier
    List_T.acc(ismember(List_T.trial,out_ids)) = 9; % MT outlier를 9로 marking
end

%% marking n1acc and 1st,2nd trial
List_T.n1acc(2:end) = List_T.acc(1:end-1);
List_T.acc(firstsecond_ids) = 9; % 첫째, 둘째 시행 9로 marking

DVList_T = List_T;
    
return