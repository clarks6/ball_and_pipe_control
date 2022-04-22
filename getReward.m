function [reward_new, reward_added] = getReward(target_Y, distanceNew, distanceOld, veloc_old, veloc_new, reward)
        
    if distanceNew-distanceOld == 0
        if distanceNew ~= target_Y
            reward_added = -1;
        else
            reward_added = 1000;
        end
    elseif distanceNew > target_Y
        if veloc_new < veloc_old
            reward_added = (distanceOld-target_Y)/target_Y*10;
        elseif veloc_new == veloc_old
            reward_added = -100;
        else
            reward_added = -1;
        end
    else
        if veloc_new > veloc_old
            reward_added = abs(distanceOld-target_Y)/target_Y*10;
        elseif veloc_new == veloc_old
            reward_added = -100;
        else
            reward_added = -1;
        end
    end
    reward_new = reward + reward_added;

end
