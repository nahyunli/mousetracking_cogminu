function [aucc, nX, nY] = auc1HPL(nX, nY)
  %AUC, area under curve를 구하는 법
  %http://www.semspirit.com//wp-content/uploads/sites/17154/2017/11/ROC-CURVE-AUR-VALUE.png
  %한 예로 위의 사이트 젤 처음 나오는 그림에서 분홍색 부분의 넓이를 적분을 이용해 구하는 것이라고 보면 된다. 
  %trapz function으로 간편하게 구할 수 있음, 다만 궤적이 y=0 선 위에 있어야 한다 (y값이 마이너스면 안된다는 말.)
  %area under curve를 그대로 종속 변인으로 사용하는 것은 아니고 AUC 에서 각 궤적의 시작과 끝을 직선으로 연결하는
  %선의 AUC 넓이 만큼을 제거해 줘야 한다. 즉, AUC는 시작점에서 끝점으로 갈 수 있는 가장 이상적인 직선 궤적으로 부터의
  %deviation을 측정하는 개념으로 보면 된다. 자세한 내용은 첨부된 논문과 사진을 참조
  xtray=nX';ytray=nY';
  aucT(1,1)=trapz(xtray,ytray); %(1)피험자가 만든 궤적의 Area under curve
  aucT(1,2)=trapz([xtray(1) xtray(end)],[ytray(1) ytray(end)]); % (2)파험자 궤적의 시작점과 끝점을 다이텍트하게 연결하는 직선의 area under curve
  aucc=aucT(1,1)-aucT(1,2); %(1)에서 (2)를 빼면 이상적인 궤적(2)로부터의 deviation을 계산 할 수 있다.   
  
  %아래 부분은 다음과 같은 처리 때문에 존재
  %궤적은 크게 convex or concave shaped curves 두개 가 있을 수 있는데, 혹이 아래로 향하는
  %convex curve AUC가 음의 값을 같는다. 이번 실험 디자인의 경우 distractor target이 항상 동일한 방향에(수직으로 반대방향)
  %있었던 바 혹의 "방향"이 큰 의미를 가지지 않으므로 음의 AUC를 보여주는 혹의 경우 한번더 위아래를 뒤집어 준다. 
  %결과적으로 AUC크기도 절대값을 취한 새 값을 가지게 된다. 
  
  if aucc<0
      clear aucT aucc
      ydiff=diff(nY');ny=zeros(1,101);
      for it=2:101;ny(it)=ny(it-1)-ydiff(it-1);end
      nY=ny';   

      aucT(1,1)=trapz(xtray,ny); %(1)피험자가 만든 궤적의 Area under curve
      aucT(1,2)=trapz([xtray(1) xtray(end)],[ny(1) ny(end)]); % (2)파험자 궤적의 시작점과 끝점을 다이텍트하게 연결하는 직선의 area under curve
      aucc=aucT(1,1)-aucT(1,2); %(1)에서 (2)를 빼면 이상적인 궤적(2)로부터의 deviation을 계산 할 수 있다.        
      clear ydiff ny
  end
  
end

