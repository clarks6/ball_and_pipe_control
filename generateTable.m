function [q_table] = generateTable(timestep)
    highVel = 0.9144/timestep;
     lowVel = -highVel;
     stepVel = (highVel/19.9978);
    
    %%creating the qTable
    for i = 1:40
        for j = 1:40
            actionTable(:,i,j) = [1550:50:3500]; 
            posTable(i,:,j) = [0:0.0229:0.9144]';
            velTable(i,j,:) = [lowVel:stepVel:highVel]; 
            for k = 1:40
                %rewardTable(i,j,k) = round(10*rand());
                rewardTable(i,j,k) = 0;
            end
        end
    end
    %%(action, postion, velocity, reward)
    q_table = cat(4,actionTable,posTable,velTable,rewardTable);
    % using Ex. max(qTable(:,2,3,4))
    % we can find the max reward at 
    % position 2, velocity 3
end