function prtsha_HPLgr(X,Y, sterror, col, linstl)

   %���� ���Ʒ��� standard error�� �׷��ִ� �ڵ�
   yerr_1=sterror(1,:);
        ll9=Y(1,:) - yerr_1; 
        ul9=Y(1,:) + yerr_1;
        fill([X(1,:), fliplr(X(1,:))], [ll9 fliplr(ul9)], [0 0.6 0.3] , 'facealpha', .2, 'edgealpha', 0,'HandleVisibility','off')
   hold on
   plot(X,Y, linstl,'color',[0 0.6 0.3]); 
 
end

