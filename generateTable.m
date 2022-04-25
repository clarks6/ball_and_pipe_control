function [q_table] = generateTable(timestep)

%% Variables
 tensorLen  = 50;                   % All sides of tensor must be equal to concatonate,
                                    % and can be set here
 highVel = 0.9144/timestep;         % Calculates velocity table max with a given timestep
 lowVel = -highVel;                 % Set min velocity table value
 stepVel = (highVel/24.8816);   % Calulates velocity table step value

%% Creating the qTable
for i = 1:tensorLen
    for j = 1:tensorLen
        actionTable(:,i,j) = [1530:30:3000];                    % PMW action table
        posTable(i,:,j) = [0:0.0183:0.9144]';                   % Tube Position table
        velTable(i,j,:) = [lowVel+stepVel:stepVel:highVel];     % Velocity table
        for k = 1:tensorLen
           % rewardTable(i,j,k) = round(10*rand());              % Randomized reward table
            rewardTable(i,j,k) = -101;              % Randomized reward table

        end
    end
end

%% Concatonate all 4 tables
q_table = cat(4,actionTable,posTable,velTable,rewardTable);
% qTable(action, postion, velocity, reward)
% Using Ex. max(qTable(:,2,3,4))
% we can find the max reward at 
% position 2, velocity 3