% a script to train the model and update the q table
% Created by: Seth Freni and Ronan Harkins 
clear; clc;
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
a = 1;
b = 2;
c = 3;
stuck = 0;

syms  s
timesample=[0 0.25]; 

% vectors for finding q_table index
max_veloc = 0.9144/timesample(2);
v_step = (max_veloc/24.8816);
pwm_array = 1530:30:3000;
y_value_array = 0:0.0183:0.9144;
velocity_array = (-max_veloc+v_step):v_step:max_veloc;

% call the function to create the initial q table
q_table = generateTable(timesample(2));

%{
 transfer function
G(s)=(C3*C2)/(s*(s+C2))
%}

g=9.8;        % Gravity
m= 2.7e-3;    % mass of the ball
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

explore = 0.9;
previous_states = [];
for tot=1:1000
    disp(tot)
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
    
        %x = find(pwm_array == (pwm(1)+2727.0447));
        v_test = velocity_array - veloc;
        y_test = y_value_array - Y(2);
        pwm_test = pwm_array - (pwm(1)+2727.0447);
        min_pwm = 5000;
        bestQValue = -100;
        min_vel = 100;
        min_y = 100;
        %{
            iterate through array of values
            PWM iteration finds best next value and the reward for switching to it
            velocity and y value iterations find current location to set PWM    
        %}
        for k = 1:40
            if abs(v_test(k)) < min_vel
                min_vel = v_test(k);
                z = k;
            end
             if abs(y_test(k)) < min_y
                 min_y = abs(y_test(k));
                 y = k;
             end
             if abs(pwm_test(k)) < min_pwm
                min_pwm = abs(pwm_test(k));
                x = k;
            end
        end
        for l = 1:40
            if bestQValue < q_table(l,y,z,4)
                bestQValue = q_table(l,y,z,4);
                best_index = k;
            end
        end
    
        q_table(x,y,z,4) = reward_added + 0.8*bestQValue;
        
        % select next PWM value
        explore_index = round(rand*24)+1;
        explore_index2 = round(rand*24)+26;
    
        p = rand;
            
        if p < explore/2 % pick a random PWM value to explore with
            pwm = [pwm_array(explore_index)-2727.0447 pwm_array(explore_index)-2727.0447];
        elseif p > explore/2 && p < explore % pick a random PWM value to explore with
            pwm = [pwm_array(explore_index2)-2727.0447 pwm_array(explore_index2)-2727.0447];
        else
            pwm = [pwm_array(best_index)-2727.0447 pwm_array(best_index)-2727.0447];
        end
    
        % bound pwm values
        if pwm(1) < 1530-2727.0447
            pwm = [1530-2727.0447 1530-2727.0447];
        elseif pwm(1) > 3000-2727.0447
            pwm = [3000-2727.0447 3300-2727.0447];
        else
            pwm = pwm;
        end
    
    end
   
    reward_current = 0;
    explore = explore - 0.05;
    if explore <0.05
        explore = 0.05;
    end

    explore_index = round(rand*39)+1;
    pwm = [pwm_array(explore_index)-2727.0447 pwm_array(explore_index)-2727.0447];
    previous_states = [];
    % save a checkpoint every 100 runs
    if (mod(tot,100) == 0)
         checkpoint = "checkpoint" + num2str(tot/100) + ".mat";
         save(checkpoint, 'q_table')

        % visualize history
        pwm_values = pwm_values+2727.0447;
        % Y values over time
        figure(a)
        plot(time,y_values)
        title("Y Values")
        grid on
        
        % PWM values over time
        figure(b)
        plot(time,pwm_values)
        title("PWM Values")
        grid on
        
        % Total reward over time
        figure(c)
        plot(time,rewards)
        title("Reward")
        grid on
        a = a+3;
        b = b+3;
        c = c+3;
     end
end



% q table
% 3 dimensions
% 1) y-value (0-0.9114)
% 2) velocity (y_new-y_old)/timestep
% 3) PWM values (0-4095)
% pick size of dimensions
% fill table and use valeus for reward