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


--- | Action 1 | Action 2| Action 3
--- | --- | --- | ---
**state1** | Q(s1,a1) | Q(s1,a2)|Q(s1,a3)
**state2**| Q(s2,a1)| Q(s2,a2)|Q(s2,a3)
**state3**| Q(s3,a1)| Q(s3,a2)|Q(s3,a3)


This is a simplier Q table then the one used for the ball and pipe but helps understand the idea. From the table you can see that this matrix could get very large based off the number of actions the enviroment has and the number of states within the environment. From the picture again every state and action meet at one point if followed untill the column or row touch at a single point. At this point the is where the value of Q should be either found or updated. For this table the matrix is only 2 dimension however in more complex designs like the bal and pipe 3 dimensional matrixs are used. Making the Q table a little more complex. However the big take away from the table is that every state and action has a Q value which is achieved from bellmans equation and is a value that depends on the current state, reward, and the the next state. Lastly for the Q table it can either be used to update values of Q or to search for the best action based of the current state. 

# How to use code
There are mutiple files that are required to run and simulate the code for the ball and pipe project. 
### env.m file
The enviroment file has the bulk of all the code that is used for Q-learning. I order to simulate the the environment many inilizations need to be done witch can be seen at the begining of the file. When using the environment the first main part of the code is generating the Q table. In order to generate the Q-table the function is called from the generating Q table file. This table is randomized with random numbers so the Q-learning has some initial data to use and explore even if it is wrong it can be replaced. After the Q-table is made the system is initialized using transfer functions. Within this transfer function all constants such as gravity, mass of the ball, volume, and pwm are set. This part of the code is important in creating the environment. 
```
g=9.8;        % Gravity
m= 0.01;    % mass of the ball
rho=1.225;    % Rho
V=3.35e-5;    % Volume 
Veq=2.4384;   %
pwm=[4000-2727.0447 4000-2727.0447];
C2=((2*g)/(Veq))*((m-(rho*V))/m); % value of C2
C3=6.3787e-4;                     % Value of C3

N = C3*C2;
D = sym2poly(s*(s+C2));
TF = tf(N,D);
```
After the system is initilized the environment can be made. Inside a for loop of the amount of runs you want to do the environment is set up. Using the lsim function built into MATLAB. In order to do this the system,the input into the system,the time sample, and the previous state have to be given. The previous state is given from lsim. Also lsim outputs the heigh as seen below. 
```
[Y, X, previous_states] = lsim(sys,pwm,timesample,previous_states); 
```
To make sure values of Y are not being pushed passed the limits of the real system inside the pipe. The Y value of height is bounded to 0-0.9144 since that is the mac distance the ball can travel inside the pipe. Anouther imporant part of the environmenty is the reward function which can be seen in the get reward file. As the environmenmt is running new values of Q have been updated so when exploiting the value that best fits the siutation has to be used. So the table has to be searched for the specific state and determine what action it should take based of the Q table values. The Q-table is updated using the Bellmans equation. Using this equation inside the file each state and action should get a new Q-value after the simulation is run for a decent amount of runs. 
```
q_table(x,y,z,4) = reward_added + 0.8*bestQValue;
```
The last thing within the evironment is whether or not to explore or exploit. Our code chooses to ecplore 90% of the time and exploit 10% of the time. If exploring the pwm value can not just be random. From testing the actaul system of the ball and pipe the ball is not affected by a pwm of less than 1550. After this the ball can begins to move. So the randomization of pwm values is from the 1550 to the max value that can beused of 4950. At the end of the long for loop that just occured checkpoints are added for the when the code is run for long periods of time to make sure the data is saved and not lost if anything was to crash. These lines can be seen below and finshes off the environment file. 
```
  checkpoint = "checkpoint" + num2str(tot) + ".mat";
         save(checkpoint, 'q_table')
```
### getReward
The reward function is used to determine if an action was good or bad. Inside this file distanceOld and disatanceNew are used to determine if the action was correct. All this code does is see if the new distacne got closer to the target ditance than the old distance. If it did then the reward is plus 1. If the distance fif not get closer to the target distance reward is -10. Then this reward is fed back into the environment file and used to calculate Q. 
### real_world.m
The real world file is the code that connects to the device as provides the information so the Q-Learning can function. First connection to the device is key making sure the right COM port is being used. This can be found under device mananger. Second is a standard number that is used for this specific controller. This can be done withing this code
```
device = serialport("COM5",19200);
```
Also inside real world you need to set how fast you would want to sample with the the sample rate and also clarify the target hieght you are trying to active for this simulation. When you start real world there is no error so it is important to inizilize this to zero and have it change as the testing goes on. Within the real world you will have to amke sure that the height/distance is being read so that Q-learning knows what action to take based of the hieght that it is add. Also you need to know that action that was just taken so it can be used in the bellmans equation. This can be done using the line below.
```
[distance,manual_pwm,target,deadpan] = read_data(device);
```
With the data that is being read from the device the actions can be taken based off what is happining. Velocity can be found by using the new height and the old height and divding by time which would be the sampling rate of the device which was set ealier. When using Q learning you have to use the Q table that was created. So the Q table has to be called but first the best index value needs to be found from he Q table. SO by using a for loop the values around a specific stater action can be looked at and then the best Q value can be picked by using the indexing value that was found by searching the Q-table. This can be seen in the lines below. 
```
 for k=1:21
        if bestQValue < q_table(k,w,z,4)
            bestQValue = q_table(k,w,z,4);
            best_index = k;
        end
```
Afteer the value is found found for the index the Q-value corresponding to that specific index is oulled and set created into an action. Since this action is sent to set_pwm the device is going to recive this action and keep continuing for each sample that is taken. 
```
action = set_pwm(device,pwm);
```
It is important to make sure that the last thing in the code before the end of the entire for loop is to set the value of yold to the value of the current y since the current y will be the old value in the next interation. 
```
y_old = y;
```

### read_data.m
Read data is very imporant to the sucess of Q-Learning. If there is no feedback from the system that is being tested then no conculsions can be made and no progress will be made. In order to achive this the data has to be read from the device. As someone who is reading this output of the device it can be made sure that the data is readable by using the string line at the end of the called function as seen below. 
```
data = read(device,20,"string");
```
To allow more readablity when looking at the results the function str2double was used to convert the string value into double precison so the number can be qickly read. This was done for all the reading not just distance as shown below. 
```
distance   = str2double(extractBetween(data,2,5));
```
### set_pwm.m
Inside the set pwm file there are two imporant lines that allow this function to help with the functionality of the code. 
```
pwm_value = (max(min(pwm_value,4095),0));
```
This line makes sure the pwm does not go bellow zero as the fan does not have zero power and also the fan can not go past 4095. This makes sure only realistic values are supplied to the device controling the pwm. In order to write to the device the function used is write and has two inputs. 
```
write(device,action,"string");
```
Device is the serial port being used and action is the pwm value that the Q=learning decides to use. The string is just used so that the device is getting a string value. 
### generate_table 
The Generate table file is as the name suggests generating a table.
### Errors

