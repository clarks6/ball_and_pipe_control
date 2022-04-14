function [reward_new, reward_added] = getReward(distanceNew, distanceOld, reward)

if (distanceNew < distanceOld)
    reward_new = reward + 10;
    reward_added = 10;
else
    reward_new = reward - 1;
    reward_added = -1;
end
return