function prtsha_HPL(X,Y, sterror, col, linstl)

   %궤적 위아래로 standard error를 그려주는 코드
   yerr_1=sterror(1,:);
        ll9=Y(1,:) - yerr_1; 
        ul9=Y(1,:) + yerr_1;
        fill([X(1,:), fliplr(X(1,:))], [ll9 fliplr(ul9)], col, 'facealpha', .2, 'edgealpha', 0,'HandleVisibility','off')
   hold on
   plot(X,Y, linstl); 
 
end

