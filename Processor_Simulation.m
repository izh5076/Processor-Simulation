%using a custom class to represent a task with a lifetime and a type of
%operation. 
import pkg.Task.*

% delete all workspace variables
clear;
% terminate all graphics and all figures.
close all;
clc;

%initialize random engine
rng('shuffle')




%initialize a variable to hold the maximum size of the queue
SizeOfArrivingTaskQueue = 150;

%initialize a variable to hold the maximum size of the processing queue
SizeOfProcessingQueue = 100; 

%initialize the arriving tasks Queue
ArrivingTasksQueue (1:SizeOfArrivingTaskQueue) = Task(0, 0);

%initializing the processing cores

%core1
PE1_Queue (1:SizeOfProcessingQueue) = Task(0, 0);

%core2
PE2_Queue (1:SizeOfProcessingQueue) = Task(0, 0);

%core3
PE3_Queue (1:SizeOfProcessingQueue) = Task(0, 0);

%initializing the arriving queue with the 20 specified tasks
ArrivingTasksQueue(1) = Task(1, 4); 
ArrivingTasksQueue(2) = Task(1, 4);
ArrivingTasksQueue(3) = Task(1, 5);
ArrivingTasksQueue(4) = Task(1, 5);
ArrivingTasksQueue(5) = Task(1, 5);
ArrivingTasksQueue(6) = Task(2, 5);
ArrivingTasksQueue(7) = Task(3, 5);
ArrivingTasksQueue(8) = Task(2, 5);
ArrivingTasksQueue(9) = Task(3, 5);
ArrivingTasksQueue(10) = Task(2, 5);
ArrivingTasksQueue(11) = Task(3, 4);
ArrivingTasksQueue(12) = Task(3, 4);
ArrivingTasksQueue(13) = Task(3, 4);
ArrivingTasksQueue(14) = Task(2, 4);
ArrivingTasksQueue(15) = Task(2, 4);
ArrivingTasksQueue(16) = Task(2, 4);
ArrivingTasksQueue(17) = Task(2, 4);
ArrivingTasksQueue(18) = Task(1, 4);
ArrivingTasksQueue(19) = Task(2, 4);
ArrivingTasksQueue(20) = Task(3, 4);

% initialize simulation timer
Armageddon = 100000; 

%initializing the start of the simulation period
SimulationTimer = 1;


%initializing the minimum and maximum lifetime of tasks
task_min_lifetime = 2;
task_max_lifetime = 5;



%defining a variable to keep track of the idle cycles. 
SchedulerIdle_cycles = 0; 
PE1_Idle_Cycles = 0; 
PE2_Idle_Cycles = 0; 
PE3_Idle_Cycles = 0; 

%initializing overload flags
ArrivingQueueOverloadFlag = 0; 
PE1_OverloadFlag = 0;
PE2_OverloadFlag = 0; 
PE3_OverloadFlag = 0; 

%initializing a counter to determine the core to put the task in
Core_Counter = 1; 


%initializing individual end of queues
ArrivingQueue_End = 20;
PE1_Queue_End = 1; 
PE2_Queue_End = 1; 
PE3_Queue_End = 1; 

%temporary object that holds the task to be moved
TempTask = Task(0, 0); 


%initializing the type of the task to add to the arriving task queue
Task_To_Add_Type = 0; 

%initializing the lifetime of the task to add to the arriving task queue
Task_To_Add_Lifetime = 0; 


%selecting the type of scheduler to use

Scheduler_Type = input("Enter the type of scheduler you'd like" + newline + "(1 for Round Robin, 2 for general purpose, 3 for specific processing core types)" + newline);

%checking the input of the scheduler type, if invalid, ask for input again
if(Scheduler_Type > 3 || Scheduler_Type < 1)
    while(Scheduler_Type > 3 || Scheduler_Type < 1)
        disp("invalid input"); 
        Scheduler_Type = input("Please enter a number from 1 to 3 to select the type of scheduler you'd like to use"); 
    end
end

%Starting simulation timer
start_time = tic;

%simulation loop
while (SimulationTimer <= Armageddon)
    %round robin style scheduler
    if(Scheduler_Type == 1)
        %moving task at head of arriving queue to its respective 
        if(ArrivingTasksQueue(1).TaskLifetime > 0)
        TempTask = Task(ArrivingTasksQueue(1).TaskType, ArrivingTasksQueue(1).TaskLifetime); 
        if(Core_Counter == 1)
            if (PE1_Queue_End < SizeOfProcessingQueue)
                    PE1_Queue(PE1_Queue_End) = TempTask;
                    PE1_Queue_End = PE1_Queue_End + 1; 
            elseif(PE1_Queue_End >= SizeOfProcessingQueue)
                    PE1_OverloadFlag = 1; 
                    break; 
            end
        elseif(Core_Counter == 2)
            if (PE2_Queue_End < SizeOfProcessingQueue) 
                    PE2_Queue(PE2_Queue_End) = TempTask;
                    PE2_Queue_End = PE2_Queue_End + 1;
            elseif(PE2_Queue_End >= SizeOfProcessingQueue)
                    PE2_OverloadFlag = 1; 
                    break; 
            end
        else
                if (PE3_Queue_End < SizeOfProcessingQueue)
                    PE3_Queue(PE3_Queue_End) = TempTask;
                    PE3_Queue_End = PE3_Queue_End + 1; 
                elseif(PE3_Queue_End >= SizeOfProcessingQueue)
                    PE3_OverloadFlag = 1; 
                    break; 
                end
        end
        %get rid of the task in the arriving queue by shifting the queue 
        %and change the end of the pointer to the end of the arriving queue
        ArrivingTasksQueue(1).TaskType = 0;
        ArrivingTasksQueue(1).TaskLifetime = 0; 
        ArrivingTasksQueue = circshift(ArrivingTasksQueue, -1);
        ArrivingQueue_End = ArrivingQueue_End - 1; 
        TempTask = Task(0, 0);
        
        else
            %if we don't have any tasks to put into the core queues, we
            %increment the idle cycles
           SchedulerIdle_cycles = SchedulerIdle_cycles + 1;   
        end
        
        %if the pointer to the specific core is between 1 and 3 add one, if
        %it is 3, we start the pointer back to 1
        if(Core_Counter <= 2 && Core_Counter >= 1)
            Core_Counter = Core_Counter + 1; 
        else
            Core_Counter = 1;
        end
        
    %General purpose cores with scheduling priority being on the core with
    %the least amount of tasks. 
    elseif(Scheduler_Type == 2)
        if(ArrivingTasksQueue(1).TaskLifetime > 0)
        TempTask = Task(ArrivingTasksQueue(1).TaskType, ArrivingTasksQueue(1).TaskLifetime); 
        
        %hierarchy logic, if core 1's queue is the least full, add it to
        %that one, if core two's queue is the least full, add to that one,
        %if core three's queue is the least full, add to that one
        
        if(PE1_Queue_End <= PE2_Queue_End && PE1_Queue_End <= PE3_Queue_End)
            if (PE1_Queue_End < SizeOfProcessingQueue)
                    PE1_Queue(PE1_Queue_End) = TempTask;
                    PE1_Queue_End = PE1_Queue_End + 1; 
             %check if core 1 is overloaded
            elseif(PE1_Queue_End >= SizeOfProcessingQueue)
                    PE1_OverloadFlag = 1; 
                    break; 
            end
        elseif(PE2_Queue_End <= PE1_Queue_End && PE2_Queue_End <= PE3_Queue_End)
            %check if core two is overloaded
            if (PE2_Queue_End < SizeOfProcessingQueue) 
                    PE2_Queue(PE2_Queue_End) = TempTask;
                    PE2_Queue_End = PE2_Queue_End + 1;
            elseif(PE2_Queue_End >= SizeOfProcessingQueue)
                    PE2_OverloadFlag = 1; 
                    break; 
            end
        else
                %check if core 3 is overloaded
                if (PE3_Queue_End < SizeOfProcessingQueue)
                    PE3_Queue(PE3_Queue_End) = TempTask;
                    PE3_Queue_End = PE3_Queue_End + 1; 
                elseif(PE3_Queue_End >= SizeOfProcessingQueue)
                    PE3_OverloadFlag = 1; 
                    break; 
                end
        end
        
        %if a talk is moved from the arriving queue delete it from the
        %arriving task queue, if not, increment the scheduler idle cycles
        
        ArrivingTasksQueue(1).TaskType = 0;
        ArrivingTasksQueue(1).TaskLifetime = 0; 
        ArrivingTasksQueue = circshift(ArrivingTasksQueue, -1);
        ArrivingQueue_End = ArrivingQueue_End - 1; 
        TempTask = Task(0, 0);
        
        else
           SchedulerIdle_cycles = SchedulerIdle_cycles + 1;   
        end
    %Specific processing core type scheduler
    else
        %if there is a task to move, move it to the temp variable for the
        %arriving task queue
        if(ArrivingTasksQueue(1).TaskLifetime > 0)
        TempTask = Task(ArrivingTasksQueue(1).TaskType, ArrivingTasksQueue(1).TaskLifetime); 
        %if the temporary variable is a load instruction, check core 1, if
        %it is not overloaded, add it to the queue. 
        if(TempTask.TaskType == 1)
            if (PE1_Queue_End < SizeOfProcessingQueue)
                    PE1_Queue(PE1_Queue_End) = TempTask;
                    PE1_Queue_End = PE1_Queue_End + 1; 
            elseif(PE1_Queue_End >= SizeOfProcessingQueue)
                    PE1_OverloadFlag = 1; 
                    break; 
            end
        
        %if the temporary task is an add instruction, check if core 2 is
        %overloaded, if not, move it to the PE2 Queue
        elseif(TempTask.TaskType == 2)
            if (PE2_Queue_End < SizeOfProcessingQueue) 
                    PE2_Queue(PE2_Queue_End) = TempTask;
                    PE2_Queue_End = PE2_Queue_End + 1;
            elseif(PE2_Queue_End >= SizeOfProcessingQueue)
                    PE2_OverloadFlag = 1; 
                    break; 
            end
        % if the temporary variable is a multiplication instruction, check
        % if core 3 is overloaded, if not, move it to PE3 queue
        else
                if (PE3_Queue_End < SizeOfProcessingQueue)
                    PE3_Queue(PE3_Queue_End) = TempTask;
                    PE3_Queue_End = PE3_Queue_End + 1; 
                elseif(PE3_Queue_End >= SizeOfProcessingQueue)
                    PE3_OverloadFlag = 1; 
                    break; 
                end
        end
        %if we have moved a task from the arriving queue to a processing
        %queue, delete the task by resetting the task at the head of the
        %queue and shifting the queue forward one position. if there is no
        %task to add, we increment the scheduler idle cycles
        ArrivingTasksQueue(1).TaskType = 0;
        ArrivingTasksQueue(1).TaskLifetime = 0; 
        ArrivingTasksQueue = circshift(ArrivingTasksQueue, -1);
        ArrivingQueue_End = ArrivingQueue_End - 1; 
        TempTask = Task(0, 0);
        
        else
           SchedulerIdle_cycles = SchedulerIdle_cycles + 1;   
        end
    end 
    
   
%checking to see if we should add a task to the arriving queue, if yes,
%add the task, and move the task queue end to
    
    %initializing a variable to represent a random probability
    Probability = rand(); 
    
    %if the probability is within the 12 percent margin to add a new task
    %to the arrival queue, we set the value to a random number between 2
    %and 5 for the lifetime. 
    if(Probability <= 0.12)
        Task_To_Add_Lifetime = randi([task_min_lifetime, task_max_lifetime]);
        Probability = rand();
        
        %if the probability is within 50 percent margin, we have a "load" instruction
        if(Probability <= 0.5)      
           Task_To_Add_Type = 1; 
        
        %if the probability is greater than 50, less than or equal to 75, we have an "add instruction
        elseif(Probability > 0.5 && Probability <=0.75)     
            Task_To_Add_Type = 2;
            
        %if the probability value is greater than 75 percent, we have a mul
        %instruction. 
        else
            Task_To_Add_Type = 3; 
        end
        ArrivingQueue_End = ArrivingQueue_End + 1; 
        
        %Checking to see if the arriving task queue exceeds the max size
        %Also checking if tasks in queue still have cycles left
        %if yes, we set our flag and break out of the simulation. 
        if(ArrivingQueue_End >= SizeOfArrivingTaskQueue &&  ArrivingTasksQueue(SizeOfArrivingTaskQueue).TaskLifetime > 0)
            ArrivingQueueOverloadFlag = 1; 
            break; 
        end

        ArrivingTasksQueue(ArrivingQueue_End) = Task(Task_To_Add_Type, Task_To_Add_Lifetime); 
        
    end
    %checking to see if core 1's task queue is empty, if it is, then we add
    %one to the core one idle cycles, if the task is finished, then we
    %shift the queue, if there are no tasks in the queue, we just add to
    %the idle cycles for this core. 
    if(PE1_Queue(1).TaskLifetime == 0)
        PE1_Idle_Cycles = PE1_Idle_Cycles + 1; 
        if(PE1_Queue_End > 1)
            PE1_Queue(1).TaskType = 0;
            PE1_Queue = circshift(PE1_Queue, -1);
            PE1_Queue_End = PE1_Queue_End - 1;
        end
        
    %Checking if the task at the head of the queue isn't 0, if it isn't
    %then we subtract one from the task lifetime
    else
       PE1_Queue(1).TaskLifetime = PE1_Queue(1).TaskLifetime - 1;
       
    end
    
    %Checking the processing queue for core two the same way as we checked
    %for core 1
    if(PE2_Queue(1).TaskLifetime == 0)
        PE2_Idle_Cycles = PE2_Idle_Cycles + 1;  
        if(PE2_Queue_End > 1)
            PE2_Queue(1).TaskType = 0;
            PE2_Queue = circshift(PE3_Queue, -1);
            PE2_Queue_End = PE2_Queue_End - 1;
        end
    else
       PE2_Queue(1).TaskLifetime = PE2_Queue(1).TaskLifetime - 1; 
    end
   
    %checking the processing queue for core 3 the same way we checked core
    %1 and 2's task queue. 
    if(PE3_Queue(1).TaskLifetime == 0)
        PE3_Idle_Cycles = PE3_Idle_Cycles + 1; 
        if(PE3_Queue_End > 1)
            PE3_Queue(1).TaskType = 0;
            PE3_Queue = circshift(PE3_Queue, -1);
            PE3_Queue_End = PE3_Queue_End - 1;
        end
    else
       PE3_Queue(1).TaskLifetime = PE3_Queue(1).TaskLifetime - 1; 
              
    end
   
    %incrementing the simulation timer
    SimulationTimer  = SimulationTimer + 1; 
end

%displaying the elapsed time
toc(start_time); 

%displaying the idle cycles for each core
disp("The number of scheduler Idle cycles is " + SchedulerIdle_cycles); 
disp("The number of PE1 Idle Cycles is " + PE1_Idle_Cycles); 
disp("The number of PE2 Idle Cycles is " + PE2_Idle_Cycles); 
disp("The number of PE3 Idle Cycles is " + PE3_Idle_Cycles); 

disp(newline); 

%displaying the overload flags for each core and the scheduler
disp("Scheduler Overload Flag = " + ArrivingQueueOverloadFlag); 
disp("PE1 Overload Flag = " + PE1_OverloadFlag); 
disp("PE2 Overload Flag = " + PE2_OverloadFlag);
disp("PE3 Overload Flag = " + PE3_OverloadFlag); 

disp(newline); 

%displaying the total number of cycles performed in the simulation

%subtract 1 from simulation timer as we index from 1
SimulationTimer = SimulationTimer - 1; 
disp("Total number of cycles in this simulation " + SimulationTimer); 



