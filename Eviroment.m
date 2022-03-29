%code to start the Enviroment

g=9.8;
m= 1.4/1e6;
rho=1.225;
V=6.55483e-5;
Veq=2.4384;

C2=(((2*g)/(Veq))*((M-(rho*V))/m));
C3=6.3787*10^(-4);

system= ((C3*C2)/(s*(s+C2)+(C3*C2)));
sys= ss(system);