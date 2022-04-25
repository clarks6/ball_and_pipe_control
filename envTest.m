% a script to test the model at low or zero exploration
% it is a modified version of the environment script
% Created by: Seth Freni
clear;
runs = 10000;
reward_current = 0;
target_Y = 0.5;
y_values = zeros(1,runs);
pwm_values = zeros(1,runs);
rewards = zeros(1,runs);
time = 1:runs;
distanceOld=0;
bestQValue = -100;
veloc_old = 0;

explore = 0.05;

syms  s
timesample=[0 0.25]; 

% vectors for finding q_table index
max_veloc = 0.9144/timesample(2);
v_step = (max_veloc/24.8816);
pwm_array = 1530:30:3000;
y_value_array = 0:0.0183:0.9144;
velocity_array = (-max_veloc):v_step:max_veloc;

% call the function to create the initial q table
load("checkpoint10.mat")

%{
 transfer function
G(s)=(C3*C2)/(s*(s+C2))
%}

g=9.8;        % Gravity
m= 0.1;    % mass of the ball
rho=1.225;    % Rho
V=3.35e-5;    % Volume 
Veq=2.4384;   %
pwm=[3000-2727.0447 3000-2727.0447];
C2=((2*g)/(Veq))*((m-(rho*V))/m); % value of C2
C3=6.3787e-4;                     % Value of C3

N = C3*C2;
D = sym2poly(s*(s+C2));
TF = tf(N,D);
sys= ss(TF);                        

previous_states = [];
for i=1:runs
    pwm_values(i) = pwm(1);
    %{
        simulate ball and pipe
        inputs: 
            sys: transfer function G(s) modeling ball and pipe
            pwm: real PWM value-2727.0447
            timesample: time between each action: 0.25s
            previous_states: the state the ball and pipe was in during the
            previous run
        outputs:
            Y: [previous height, current height]
            X: timestep
            previous_states: the end state from the current run
    %}
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
    
    veloc = (Y(2)-Y(1))/timesample(2);
    
    % calculate current and added reward
    [reward_current, reward_added] = getReward(target_Y, Y(2), Y(1), veloc_old, veloc, reward_current);
    rewards(i) = reward_current;
    
    veloc_old = veloc;

    v_test = velocity_array - veloc;
    y_test = y_value_array - Y(2);
    bestQValue = -200;
    min_vel = 20;
    min_y = 100;
    %{
        iterate through array of values
        PWM iteration finds best next value and the reward for switching to it
        velocity and y value iterations find current location to set PWM    
    %}
    for k = 1:40
        if abs(v_test(k)) < min_vel
            min_vel = abs(v_test(k));
            z = k;
        end
         if abs(y_test(k)) < min_y
             min_y = abs(y_test(k));
             y = k;
         end
    end
    for l = 1:40
        if  q_table(l,y,z,4) > bestQValue
            bestQValue = q_table(l,y,z,4);
            best_index = k;
        end
    end
    
    explore_index = round(rand*19)+1;
    explore_index2 = round(rand*19)+21;
    p = rand;
    
    if p < explore/2 % pick a random PWM value to explore with
        pwm = [pwm_array(explore_index)-2727.0447 pwm_array(explore_index)-2727.0447];
    elseif p > explore/2 && p < explore % pick a random PWM value to explore with
        pwm = [pwm_array(explore_index2)-2727.0447 pwm_array(explore_index2)-2727.0447];
    else
        pwm = [pwm_array(best_index)-2727.0447 pwm_array(best_index)-2727.0447];
    end

    % bound pwm values
    if pwm(1) < 1550-2727.0447
        pwm = [1550-2727.0447 1550-2727.0447];
    elseif pwm(1) > 3500-2727.0447
        pwm = [3500-2727.0447 3500-2727.0447];
    else
        pwm = pwm;
    end

    % bound pwm values
    if pwm(1) < 1550-2727.0447
        pwm = [1550-2727.0447 1550-2727.0447];
    elseif pwm(1) > 4000-2727.0447
        pwm = [3500-2727.0447 3500-2727.0447];
    end
end

% visualize history
pwm_values = pwm_values+2727.0447;
% Y values over time
figure(1)
plot(time,y_values)
title("Y Values")
grid on

% PWM values over time
figure(2)
plot(time,pwm_values)
title("PWM Values")
grid on

% Total reward over time
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