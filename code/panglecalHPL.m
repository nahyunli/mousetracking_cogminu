function [wtheta, pAngle1, theta] = panglecalHPL(x, y)
% x=nX';
% y=nY';

% 각 데이터 포인트를 centering 해야 하기 때문 
xdiff=diff(x,[],2);
ydiff=diff(y,[],2);

% %이거 센터드시 주석처리, 언센터드시에만 활성화
% xdiff=x;
% ydiff=y;


theta=atan2(ydiff, xdiff);%theta in radian thus does not require angle funtion
gamma=sqrt(ydiff.^2+xdiff.^2);
wtheta=gamma.*exp(theta.*1i);
theta=theta+((theta<0)*2*pi);%convert minus angle value to positive

pAngle1=exp(theta.*1i);% itpc계산을 위함
% pAngle1=gamma.*exp(theta.*1i);%vector+phase angle integrated using euler's formula
% CompVex=mean(gamma.*exp(theta.*1i),2);  %which is in eulers form r*e^(theta*i)

%abs(mean(CompVex) mean vector length ->ITPC
%angle(mean(CompVex) mean phase angle
end
% https://rosettacode.org/wiki/Averages/Mean_angle
% https://www.mathworks.com/matlabcentral/answers/113701-how-do-i-convert-from-complex-numbers-a-bi-to-a-polar-form-r-theta
% atan(5/12) theta in radian
% rad2deg(atan(5/12)) theta in degree
% 
% For example, lets say there were two data points: (1,1) and (2,4). The previous code were calculating the angles of the line connecting (0,0) & (1,1), and the line connecting  (0,0) & (2,4). 
% Now the current code centers the coordinates so that angles of the line connecting (0,0) & (1,1), and the line connecting (0,0) & (1,3) are calculated  
