function y=fun_2d_screw_dislocation_afterslip(x1, param)
% 2-D dislocation model function

% param
% y=  slip_rate/pi*atan(x/locking_depth)+yshift;
% % size(param)
% 
% interseismic slip
% y= param(1)/pi*atan((x-param(4))/param(2))+param(3);
% y1= param(1)/pi*atan((x1-param(4))/param(2))+param(3);
% y1= param(1)/pi*atan((x1-param(4))/param(2))+param(3)+param(5)*(x1-param(4));

%afterslip
% y2= param(6)/pi*atan((x1-param(4))/param(7)) - param(6)/pi*atan((x1-param(4))/param(8)) + param(3);

% y12=y1+y2;
% y12=y1+0;

% y3=param(1)/pi*atan((x1-param(4))/param(2))+param(3)+param(5)*(x1-param(4))  + param(6)/pi*atan((x1-param(4))/param(7)) - param(6)/pi*atan((x1-param(4))/param(8));
y3=param(1)/pi*atan((x1-param(4))/param(2))+param(3)+param(5)*(x1-param(4))  + param(6)/pi*atan((x1-param(4))/param(7)) - param(6)/pi*atan((x1-param(4))/param(8));

% y12=y1;

% x=x1*cos(param(5))-y12*sin(param(5));
 x=x1;
% y=x1*sin(param(5))+y12*cos(param(5));
y=y3;
    