function [aucc, nX, nY] = auc1HPL(nX, nY)
  %AUC, area under curve�� ���ϴ� ��
  %http://www.semspirit.com//wp-content/uploads/sites/17154/2017/11/ROC-CURVE-AUR-VALUE.png
  %�� ���� ���� ����Ʈ �� ó�� ������ �׸����� ��ȫ�� �κ��� ���̸� ������ �̿��� ���ϴ� ���̶�� ���� �ȴ�. 
  %trapz function���� �����ϰ� ���� �� ����, �ٸ� ������ y=0 �� ���� �־�� �Ѵ� (y���� ���̳ʽ��� �ȵȴٴ� ��.)
  %area under curve�� �״�� ���� �������� ����ϴ� ���� �ƴϰ� AUC ���� �� ������ ���۰� ���� �������� �����ϴ�
  %���� AUC ���� ��ŭ�� ������ ��� �Ѵ�. ��, AUC�� ���������� �������� �� �� �ִ� ���� �̻����� ���� �������� ������
  %deviation�� �����ϴ� �������� ���� �ȴ�. �ڼ��� ������ ÷�ε� ���� ������ ����
  xtray=nX';ytray=nY';
  aucT(1,1)=trapz(xtray,ytray); %(1)�����ڰ� ���� ������ Area under curve
  aucT(1,2)=trapz([xtray(1) xtray(end)],[ytray(1) ytray(end)]); % (2)������ ������ �������� ������ ������Ʈ�ϰ� �����ϴ� ������ area under curve
  aucc=aucT(1,1)-aucT(1,2); %(1)���� (2)�� ���� �̻����� ����(2)�κ����� deviation�� ��� �� �� �ִ�.   
  
  %�Ʒ� �κ��� ������ ���� ó�� ������ ����
  %������ ũ�� convex or concave shaped curves �ΰ� �� ���� �� �ִµ�, Ȥ�� �Ʒ��� ���ϴ�
  %convex curve AUC�� ���� ���� ���´�. �̹� ���� �������� ��� distractor target�� �׻� ������ ���⿡(�������� �ݴ����)
  %�־��� �� Ȥ�� "����"�� ū �ǹ̸� ������ �����Ƿ� ���� AUC�� �����ִ� Ȥ�� ��� �ѹ��� ���Ʒ��� ������ �ش�. 
  %��������� AUCũ�⵵ ���밪�� ���� �� ���� ������ �ȴ�. 
  
  if aucc<0
      clear aucT aucc
      ydiff=diff(nY');ny=zeros(1,101);
      for it=2:101;ny(it)=ny(it-1)-ydiff(it-1);end
      nY=ny';   

      aucT(1,1)=trapz(xtray,ny); %(1)�����ڰ� ���� ������ Area under curve
      aucT(1,2)=trapz([xtray(1) xtray(end)],[ny(1) ny(end)]); % (2)������ ������ �������� ������ ������Ʈ�ϰ� �����ϴ� ������ area under curve
      aucc=aucT(1,1)-aucT(1,2); %(1)���� (2)�� ���� �̻����� ����(2)�κ����� deviation�� ��� �� �� �ִ�.        
      clear ydiff ny
  end
  
end

