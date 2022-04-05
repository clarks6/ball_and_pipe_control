syms  s

%%input environment
pwm=[3000;3000];
timesample=[0;0.25]; 

%%constants
x0= [];
g=9.8;        %Gravity
mBall= 0.01;   %mass of the ball
rhoAir=1.225;    %Rho
vBall=6.55483e-5; %Volume 
vEq=2.4384;   %

%%equation
%C2=(((2*g)/(Veq))*((m-(rho*V))/m)); % value of C2
%C3=6.3787*10^(-4);                  %Value of C3
%G = ((C3*C2)/(s*(s+C2)+(C3*C2)));   %Unity Feedback
c2 = (2*g*(mBall-rhoAir*vBall))/(vEq*mBall);
c3 = 6.3787 * 10^-4;
G = (c3*c2)/(s*(s+c2));
[N,D] = numden(G);
TF = tf(sym2poly(N),sym2poly(D));
sys= ss(TF);                        

[Y,X,~]= lsim(sys,pwm,timesample,x0);