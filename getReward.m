function [reward_new] = getReward(distanceNew, distanceOld, reward)

if (distanceNew < distanceOld)
    reward_new = reward + 10;
else
    reward_new = reward - 1;
end
return