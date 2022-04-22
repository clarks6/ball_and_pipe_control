%{
 A MATLAB function to generate reward for the model
    If the ball is stuck at the top, lose 1000 points. 
    If the ball sits at the target, gain 1000 points.
    If error improves, gain points equal to 100-percent error.
    If error gets worse, lose 1 point.

    Inputs:
        target_Y: height attempting to reach
        distanceNew: current height of ball
        distanceOld: previous height of ball
        veloc_old: previous velocity of ball
        veloc_new: current velocity of ball
        reward: current overall reward
    Outputs:
        reward_new: reward of step
        reward_added: reward 
%}
function [reward_new, reward_added] = getReward(target_Y, distanceNew, distanceOld, veloc_old, veloc_new, reward)
        
    if distanceNew-distanceOld == 0
        if distanceNew ~= target_Y
            if distanceNew > 0.9
                reward_added = -1000;
            else
                reward_added = -1;
            end
        else
            reward_added = 1000;
        end
    elseif distanceNew > target_Y && (distanceNew-distanceOld ~= 0)
        if veloc_new < veloc_old
            reward_added = 100-100*(distanceOld-target_Y)/target_Y;
        else
            reward_added = -1;
        end
    elseif distanceNew < target_Y  && (distanceNew-distanceOld ~= 0)
        if veloc_new > veloc_old
            reward_added = 100-100*abs(distanceOld-target_Y)/target_Y;
        else
            reward_added = -1;
        end
    end
    reward_new = reward + reward_added; % reward_new = total reward of runs
                                        % reward_added = reward used for q_table 

end
