% A MATLAB script to control Rowans Systems & Control Floating Ball 
% Apparatus designed by Mario Leone, Karl Dyer and Michelle Frolio. 
% The current control system is a PID controller.
%
% Created by Kyle Naddeo, Mon Jan 3 11:19:49 EST 
% Modified by Seth Freni 4/22/2022

%% Start fresh
close all; clc; clear device;
load("checkpoint10.mat")
y_old = 0;
pwm_array = 1530:40:3500;
max_veloc = 0.9144/timesample(2);
v_step = (max_veloc/24.8816);
y_value_array = 0:0.0183:0.9144;
velocity_array = (-max_veloc):v_step:max_veloc;

%% Connect to device
% device = open serial communication in the proper COM port
device = serialport("COM5",19200);
%% Parameters
target_y      = 0.5;   % Desired height of the ball [m]
sample_rate = 0.25;  % Amount of time between controll actions [s]

%% Give an initial burst to lift ball and keep in air
set_pwm(device, 50000); % Initial burst to pick up ball
pause(0.1) % Wait 0.1 seconds
set_pwm(device, 5000); % Set to lesser value to level out somewhere in
% the pipe

%% Initialize variables
action      = set_pwm(device, 5000); % Same value of last set_pwm   
error       = 0;
error_sum   = 0;

%% Feedback loop
pwm = 4095;
explore = 0.05; % percent to pick random PWM
while true
    %% Read current height
    
    [distance,manual_pwm,target,deadpan] = read_data(device);
%     disp(distance);
    
    y = ir2y(distance); % Convert from IR reading to distance from bottom [m]
    
    %% Calculate errors for PID controller
    error_prev = error;             % D
    error      = target_y - y;      % P
    error_sum  = error + error_sum; % I
    
    %% Control
    prev_action = action;
    %action = % Come up with a scheme no answer is right but do something

    v_test = velocity_array - veloc;
    y_test = y_value_array - Y(2);
    bestQValue = -100;
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
        pwm = pwm_array(explore_index);
    elseif p > explore/2 && p < explore % pick a random PWM value to explore with
        pwm = pwm_array(explore_index2);
    else
        pwm = pwm_array(best_index);
    end

    % bound pwm values
    if pwm(1) < 1530
        pwm = 1530;
    elseif pwm(1) > 3500
        pwm = 3500;
    else
        pwm = pwm;
    end
    pwm = pwm+42;

    action = set_pwm(device,pwm);
    %set_pwm(device,pwm);
%     disp(y);
    % set_pwm(device, pwm_value); % Implement action
        
    % Wait for next sample
    pause(sample_rate)
    y_old = y;
end

