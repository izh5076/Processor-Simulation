%class that encapsulates and represents a CPU task. 

classdef Task
    properties 
        TaskType = 0;
        TaskLifetime = 0;
    end
    methods
        function obj = Task(val, Lifetime)
                 obj.TaskType = val;
                 obj.TaskLifetime = Lifetime;
        end
    end
end
