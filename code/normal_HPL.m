function[vessle_x,  vessle_y]=normal_HPL(nX, nY)
     vessle_x=nX;vessle_y=nY;

     %normalize to [0, 1] for y
     vessle_x=(vessle_x./vessle_x(end));     
     vessle_y=(vessle_y./vessle_y(end)).*1.5;    
     
%      subplot(2,1,1)
%      plot(nX, nY)
%      subplot(2,1,2)     
%      plot(vessle_x, vessle_y)
end
  