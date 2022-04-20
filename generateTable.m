function [q_table] = generateTable(timestep)
    highVel = 0.9144/timestep;
     lowVel = -highVel;
     stepVel = (highVel - lowVel)/21;
    
    %%creating the qTable
    for i = 1:21
        for j = 1:21
            actionTable(:,i,j) = [2000:100:4000]; 
            posTable(i,:,j) = [0.0435:0.0435:0.9144]';
            velTable(i,j,:) = [lowVel+stepVel:stepVel:highVel]; 
            for k = 1:21
                %rewardTable(i,j,k) = round(10*rand());
                rewardTable(i,j,k) = round(10*rand());
            end
        end
    end
    %%(action, postion, velocity, reward)
    q_table = cat(4,actionTable,posTable,velTable,rewardTable);
    % using Ex. max(qTable(:,2,3,4))
    % we can find the max reward at 
    % position 2, velocity 3
end