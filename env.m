%code to start the Enviroment
clear;
runs = 1000;
reward_current = 0;
target_Y = 0.5;
y_values = zeros(1,runs);
pwm_values = zeros(1,runs);
rewards = zeros(1,runs);
time = 1:runs;
distanceOld=0;

syms  s
timesample=[0 0.25]; 

% vectors for finding q_table index
max_veloc = 0.9144/timesample(2);
v_step = (max_veloc/10.5);
pwm_array = 2000:100:4000;
y_value_array = 0.0435:0.0435:0.9144;
velocity_array = -max_veloc:v_step:max_veloc;

q_table = generateTable(timesample(2));

% x0= [4095 4095];
g=9.8;        % Gravity
m= 2.7e-3;    % mass of the ball
rho=1.225;    % Rho
V=3.35e-5;    % Volume 
Veq=2.4384;   %
pwm=[4000-2727.0447 4000-2727.0447];
C2=((2*g)/(Veq))*((m-(rho*V))/m); % value of C2
C3=6.3787e-4;                     % Value of C3

N = C3*C2;
D = sym2poly(s*(s+C2));
TF = tf(N,D);
sys= ss(TF);                        

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

    % calculate reward
    new_error = target_Y-Y(2);
    old_error = target_Y-Y(1);
    [reward_current, reward_added] = getReward(abs(new_error), abs(old_error), reward_current);
    rewards(i) = reward_current;
    
    veloc = (Y(2)-Y(1))/timesample(1);

    x = find(pwm_array == pwm(1));
    y = find(y_value_array == Y(2));
    z = find(velocity_array == veloc);
    
    [bestQValue, best_index] = max(q_table(:,y,z,4));
    q_table(x,y,z) = reward_added + 0.8*bestQValue;
    
    explore_index = round(rand*20)+1;
    % select next PWM value
    p = rand;
    if p < explore
        pwm = [pwm_array(explore_index) pwm_array(explore_index)];
    else
        pwm = [pwm_array(best_index) pwm_array(best_index)];
    end
    pwm = pwm - 2727.0447;
    % bound pwm values
    if pwm(1) < 1600-2727.0447
        pwm = [1600-2727.0447 1600-2727.0447];
    elseif pwm(1) > 4000-2727.0447
        pwm = [4000-2727.0447 4000-2727.0447];
    end

    if mod(i,10000) == 0
        checkpoint = "checkpoint" + num2str(i/10000) + ".mat";
        save(checkpoint, 'q_table')
    end

end

% visualize results
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