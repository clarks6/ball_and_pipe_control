% A MATLAB script to control Rowans Systems & Control Floating Ball 
% Apparatus designed by Mario Leone, Karl Dyer and Michelle Frolio. 
% The current control system is a PID controller.
%
% Created by Kyle Naddeo, Mon Jan 3 11:19:49 EST 
% Modified by Seth Freni 2/1/2022

%% Start fresh
close all; clc; clear device;

%% Connect to device
% device = open serial communication in the proper COM port
device = serialport("COM26",19200);
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
pwm = 5000;
while true
    %% Read current height
    [distance,manual_pwm,target,deadpan] = read_data(device);
    disp(distance);
    y = ir2y(distance); % Convert from IR reading to distance from bottom [m]
    
    %% Calculate errors for PID controller
    error_prev = error;             % D
    error      = target_y - y;      % P
    error_sum  = error + error_sum; % I
    
    %% Control
    prev_action = action;
    %action = % Come up with a scheme no answer is right but do something
    if y > target_y
        pwm = pwm - 100;
    elseif y < target_y
        pwm = pwm + 100;
    else
        pwm = pwm;
    end
    action = set_pwm(device,pwm);
    % set_pwm(device, pwm_value); % Implement action
        
    % Wait for next sample
    pause(sample_rate)
end

