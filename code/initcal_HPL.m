function [initpf, detl, speed, lngth, accel]=initcal_HPL(nX, nY, nT)

  xdiff=diff(nX,[],1);
  ydiff=diff(nY,[],1);
  tdiff=diff(nT,[],1);
 
    distan = sqrt(xdiff.^2 + ydiff.^2); 
    lngth=sum(distan);%�� ������ �Ÿ�
    speed = distan./tdiff; %�� ��ǥ �� �ӵ� (ex ��ǥ1->��ǥ2 �̵� �ӵ�), �׷��� �ӵ��� �����ʹ� 100(101-1)���� �ִ�. 
    initp=find(speed>.96); %�ӵ��� �ʴ� "0.96"�ȼ��� �ʰ� �ϴ� �κ��� initiation point�� ��� (Erb et al. �� ����)
    
    if isempty(initp)==1 %�ӵ��� ��ü������ �ʾ ���ؼӵ��� �ʰ��� �� ���� Ʈ���̾��� ��� �Ÿ��� ����
        detl = 0;     
        initpf=0;        
    else
        initpf2=initp(1)+1;
        initpf=nT(initpf2);           
        detl = 1;
    end
    accel = diff(speed,[],1)./ diff(nT(2:end,:),[],1);
end

