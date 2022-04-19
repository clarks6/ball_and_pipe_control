# Ball and Pipe Control System
MATLAB codes to open serial communication with a ball and pipe system. The system is made of a vertical cylinder with a ping pong ball controlled by a fan on the bottom and height measured by a time of flight sensor on top. The objective is to balance the ball at a target altitude. 



# Control Method- Q-learning
Q-Learning is a type of reinforcement learning. Reinforcement learning is a system that learns to make desicions on its own based off of the information it has learned. Within Q-learning there is a reward value with every reward there is a state and action. For a simple Q-Learning the action could be to move up, down, left, and right.Taking this definition of action and state it can be seen that every unit of space in the enviroment, the physical place the learning is taking place, has an action that can occur. With this a Q Table can be constructed which will be taked about in more detail after the Bellmans equation.Q-leaning does not need a supervisor since it uses rewards as a way of telling right from wrong. Q-learning is a model free learning and does not use the normal reward method. In order to use this different reward method the Bellmans equation has to be used to find values of Q. 

Q-Leaning equation/Bellmans Equation-
<p align="center">
<img src="https://latex.codecogs.com/svg.image?NewQ(s,a)=&space;Q(s,a)&plus;\alpha&space;[R(s,a)&plus;\gamma&space;max{(NextQ)}(s,a)-Q(s,a)]">
</p>

Each section of the Bellmans equation has a specfic value assocaited with each part. The Alpha is the Learning rate meaning how fast does the leanring occur. To slow will make the learning take to long and to fast of a learning rate may not allow the computer keep up. After the Alpha is the reward. For every state action pair or for every action of each state there is a corresponding reward that is assigned from the reward function set up by the designer. The next part of the equation is lamda which is the discount factor. This means how much do you want to account for the future. When using Q-learning you must be able to look at the next state and know the action that produces the greatest reward. This will then be placed into the Bellman equation. Then the current Q value is substracted inside of  () of the discount factor.  With this equation a new Q valuue is generated and can be placed into the Q table. The layout of the Q table can be seen below. 

Simpified Q Table-

![image](https://user-images.githubusercontent.com/98828696/164008060-f12caffb-e527-4e6d-b924-ccf89d54109a.png)

This is a simplier Q table then the one used for the ball and pipe but helps understand the idea. From the table you can see that this matrix could get very large based off the number of actions the enviroment has and the number of states within the environment. From the picture again every state and action meet at one point if followed untill the column or row touch at a single point. At this point the is where the value of Q should be either found or updated. For this table the matrix is only 2 dimension however in more complex designs like the bal and pipe 3 dimensional matrixs are used. Making the Q table a little more complex. However the big take away from the table is that every state and action has a Q value which is achieved from bellmans equation and is a value that depends on the current state, reward, and the the next state. Lastly for the Q table it can either be used to update values of Q or to search for the best action based of the current state. 
