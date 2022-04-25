%{
 A MATLAB function to generate the initial q table for the environment

    Input:
        timestep: time between actions, used for calculating maximum
        possible velocity

    Output:
        q_table: the initial q table with all values preset as random or 0
            (up to user)
    Created by: Keith Soules
%}
function [qTable] = generateTable(timestep)

%% Variables
 tensorLen  = 50;                   % All sides of tensor must be equal to concatonate,
                                    % and can be set here
 highVel = 0.9144/timestep;         % Calculates velocity table max with a given timestep
 lowVel = -highVel;                 % Set min velocity table value
 stepVel = (highVel - lowVel)/50;   % Calulates velocity table step value

%% Creating the qTable
for i = 1:tensorLen
    for j = 1:tensorLen
        actionTable(:,i,j) = [1060:60:4000];                    % PMW action table
        posTable(i,:,j) = [0:0.0183:0.9144]';                   % Tube Position table
        velTable(i,j,:) = [lowVel+stepVel:stepVel:highVel];     % Velocity table
        for k = 1:tensorLen
            rewardTable(i,j,k) = round(10*rand());              % Randomized reward table
        end
    end
end

%% Concatonate all 4 tables
qTable = cat(4,actionTable,posTable,velTable,rewardTable);
% qTable(action, postion, velocity, reward)
% Using Ex. max(qTable(:,2,3,4))
% we can find the max reward at 
% position 2, velocity 3
