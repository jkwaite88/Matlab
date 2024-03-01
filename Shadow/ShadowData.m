classdef ShadowData
    properties
       fileName
       serialNumbers
       sensorStartTimes
       sensorEndTimes
       sensorFirstFailTimes
       testResults
    end
    
    methods
        function obj = ShadowData(fileName)%, sensor_obj)
            obj.fileName = fileName;
            T = readtable(fileName, 'Sheet', 1);
            obj.serialNumbers = unique(T.SerialNumber);
            for i = 1:length(obj.serialNumbers)
                sensor_index = find(strcmp(T.SerialNumber, obj.serialNumbers{i}));
                [time, time_idx] = min(T.TestDate(sensor_index));
                obj.sensorFirstFailTimes(i) = time;
            end
            
        end
            
    end
    
end

