function[vessle_xt, vessle_yt, vessle_tt]=timespace33HPL(vessle_x, vessle_y, vessle_t)
  %time�� �������� interpolate�� ����� �̰��� ����ϴ°� �������� ����� ������
  %�� ������ �����Ͱ� ���̰� �ٸ��� �̷� ���� ���Ǻ� ��ճ��� ���� �ȵǱ� ������ �� ���ະ�� 100���� ������
  %�� ������ �ϴ� ����. �ð��� 101����Ͽ� �� 101���� ���������� x�� y ��ǥ�� interpolation���� ����ϴ�
  %�����̴�. 
  t0=(vessle_t(end)-vessle_t(1))/100;
  t=vessle_t(1):t0:vessle_t(end);
  
  %101 for x  
  x = vessle_t';
  y = vessle_x';

  [x, index] = unique(x); %just to prevent duplicate error
  vessle_xt = interp1(x, y(index), t,'linear')'; 
  
  %101 for y
  y1 = vessle_y';
  vessle_yt = interp1(x, y1(index), t,'linear')';     
  
  %101 for time  
  vessle_tt = t';  
  
end
  
