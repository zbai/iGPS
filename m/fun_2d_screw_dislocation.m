function y=fun_2d_screw_dislocation(x1, param)
% 2-D dislocation model function

% param
% y=  slip_rate/pi*atan(x/locking_depth)+yshift;
% % size(param)
% 
% y= param(1)/pi*atan((x-param(4))/param(2))+param(3);
y1= param(1)/pi*atan((x1-param(4))/param(2))+param(3);

x=x1*cos(param(5))-y1*sin(param(5));
% x1=x;
y=x1*sin(param(5))+y1*cos(param(5));
% y=y1;
    