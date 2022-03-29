%code to start the Enviroment
timesample=0.5; 
g=9.8;        %Gravity
m= 1.4/1e6;   %mass of the ball
rho=1.225;    %Rho
V=6.55483e-5; %Volume 
Veq=2.4384;   %

C2=(((2*g)/(Veq))*((M-(rho*V))/m)); % value of C2
C3=6.3787*10^(-4);                  %Value of C3

TF= ((C3*C2)/(s*(s+C2)+(C3*C2)));   %Unity Feedback
sys= ss(TF);                        

lsim(sys,pwm,timesample); 






