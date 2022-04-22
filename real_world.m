% A MATLAB script to control Rowans Systems & Control Floating Ball 
% Apparatus designed by Mario Leone, Karl Dyer and Michelle Frolio. 
% The current control system is a PID controller.
%
% Created by Kyle Naddeo, Mon Jan 3 11:19:49 EST 
% Modified by Seth Freni 2/1/2022

%% Start fresh
close all; clc; clear device;
load("checkpoint5.mat")
y_old = 0;
y_value_array = 0.0435:0.0435:0.9144;
max_veloc = 0.9144/0.25;
v_step = (max_veloc/10.5);
velocity_array = -max_veloc:0.35:max_veloc;

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
%     if y > target_y
%         pwm = pwm - 10;
%     elseif y < target_y
%         pwm = pwm + 10;
%     end
    bestQValue = -100;
    veloc = (y-y_old)/0.25;
    v_test = velocity_array - veloc;
    y_test = y_value_array - y;
    bestQValue = -100;
    min_vel = 20;
    min_y = 100;

    for k = 1:21
        if abs(v_test(k)) < min_vel
            min_vel = v_test(k);
            z = k;
        end
        if abs(y_test(k)) < min_y
            min_y = y_test(k);
            w = k;
        end
    end

    for p=1:21
        if bestQValue < q_table(p,w,z,4)
            bestQValue = q_table(p,w,z,4);
            best_index = p;
        end
    end

    
    pwm = q_table(best_index,w,z,1)

    action = set_pwm(device,pwm);
    %set_pwm(device,pwm);
%     disp(y);
    % set_pwm(device, pwm_value); % Implement action
        
    % Wait for next sample
    pause(sample_rate)
    y_old = y;
end

