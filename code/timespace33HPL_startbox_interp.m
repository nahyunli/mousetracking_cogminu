function[vessle_xt, vessle_yt, t]=timespace33HPL_startbox_interp(vessle_x, vessle_y, vessle_t)
  %time을 기준으로 interpolate한 결과로 이것을 사용하는게 프리먼의 방법을 따른다
  %각 시행의 데이터가 길이가 다르고 이로 인해 조건별 평균내는 것이 안되기 때문에 각 시행별로 100개의 데이터
  %를 가지게 하는 과정. 시간을 101등분하여 각 101개의 시점에서의 x와 y 좌표를 interpolation으로 계산하는
  %과정이다. 
  t=vessle_t(1):1:vessle_t(end);
  
  %101 for x  
  x = vessle_t';
  y = vessle_x';

  [x, index] = unique(x); %just to prevent duplicate error
  vessle_xt = interp1(x, y(index), t,'linear')'; 
  
  %101 for y
  y1 = vessle_y';
  vessle_yt = interp1(x, y1(index), t,'linear')';     
 
  vessle_xt = vessle_xt';
  vessle_yt = vessle_yt';
end
  
