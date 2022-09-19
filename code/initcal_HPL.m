function [initpf, detl, speed, lngth, accel]=initcal_HPL(nX, nY, nT)

  xdiff=diff(nX,[],1);
  ydiff=diff(nY,[],1);
  tdiff=diff(nT,[],1);
 
    distan = sqrt(xdiff.^2 + ydiff.^2); 
    lngth=sum(distan);%각 궤적의 거리
    speed = distan./tdiff; %각 좌표 별 속도 (ex 좌표1->좌표2 이동 속도), 그래서 속도는 데이터는 100(101-1)개만 있다. 
    initp=find(speed>.96); %속도가 초당 "0.96"픽셀을 초과 하는 부분을 initiation point로 잡기 (Erb et al. 논문 기준)
    
    if isempty(initp)==1 %속도가 전체적으로 늦어서 기준속도를 초과한 적 없는 트라이얼의 경우 거르기 위함
        detl = 0;     
        initpf=0;        
    else
        initpf2=initp(1)+1;
        initpf=nT(initpf2);           
        detl = 1;
    end
    accel = diff(speed,[],1)./ diff(nT(2:end,:),[],1);
end

