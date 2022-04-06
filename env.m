%code to start the Enviroment
clear;
runs = 1000;
reward_current = 0;
target_Y = 0.5;
y_values = zeros(1,runs);
pwm_values = zeros(1,runs);
rewards = zeros(1,runs);
time = 1:runs;

syms  s
timesample=[0 0.25]; 
%x0= [4095 4095];
g=9.8;        % Gravity
m= 2.7e-3; % mass of the ball
rho=1.225;    % Rho
V=3.35e-5; % Volume 
Veq=2.4384;   %
pwm=[4000-2727.0447 4000-2727.0447];
C2=((2*g)/(Veq))*((m-(rho*V))/m); % value of C2
C3=6.3787e-4;                     % Value of C3

N = [C3*C2];
D = sym2poly(s*(s+C2));
TF = tf(N,D);
sys= ss(TF);                        

% if Y > 0.9144
%     Y = 0.9144;
% end

explore = 0.9;
previous_states = [];
for i=1:runs
    pwm_values(i) = pwm(1);
    [Y, X, previous_states] = lsim(sys,pwm,timesample,previous_states);
    previous_states = [previous_states(end-2), previous_states(end)];
    
    % bound Y values
    for j = 1:length(timesample)
        if Y(j) > 0.9144
            Y(j) = 0.9144;
        end
        if Y(j) < 0
            Y(j) = 0;
        end
    end
    % bound previous state values
     for j = 1:length(timesample)
        if previous_states(j) > 12.6356
            previous_states(j) = 12.6356;
        end
        if previous_states(j) < 0
            previous_states(j) = 0;
        end
    end

    y_values(i) = Y(2);
    new = target_Y-Y(2);
    old = target_Y-Y(1);
    reward_current = getReward(abs(new), abs(old), reward_current);
    rewards(i) = reward_current;
    
%     if reward < -20
%         break
%     end
    
    p = rand;
    if p <= explore/2
        x = rand*100;
        pwm = pwm+x;
    elseif (p > explore/2 && p <= explore)
        x = rand*100;
        pwm = pwm-x;
    else
        pwm = pwm;
    end

    % bound pwm values
    if pwm(1) < -2727.0447
        pwm = [-2727.0447 -2727.0447];
    elseif pwm(1) > 4095-2727.0447
        pwm = [4095-2727.0447 4095-2727.0447];
    end

end
pwm_values = pwm_values+2727.0447;
figure(1)
plot(time,y_values)
title("Y Values")
grid on
figure(2)
plot(time,pwm_values)
title("PWM Values")
grid on
figure(3)
plot(time,rewards)
title("Reward")
grid on

% q table
% 3 dimensions
% 1) y-value (0-0.9114)
% 2) velocity (y_new-y_old)/timestep
% 3) PWM values (0-4095)
% pick size of dimensions
% fill table and use valeus for reward