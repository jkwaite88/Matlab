classdef TestingClass
    properties (Constant)
        IDLE = 4;
        START = 5;
        CONTINUING = 6;
        STOP = 7;

        INACTIVE = 0;
        ACTIVE = 1;
        
        dataFile1 = 'C:\Data\DataLogger\Logs\Log_2021-01-07.txt';
    end
    
    methods
        function data = readDataFile(dataFile)
            data = readtable(dataFile);
        end
        function data = invertSomeData(data)
            %invert some of the data
            data.R1Z1 = ~data.R1Z1;
            data.R1Z2 = ~data.R1Z2;
            data.R1Z3 = ~data.R1Z3;
            data.R1Z4 = ~data.R1Z4;
            data.R2Z1 = ~data.R2Z1;
            data.R2Z2 = ~data.R2Z2;
            data.R2Z3 = ~data.R2Z3;
            data.R2Z4 = ~data.R2Z4;
            data.LOOP1 = ~data.LOOP1;
            data.LOOP2 = ~data.LOOP2;
            data.LOOP3 = ~data.LOOP3;
            data.LOOP4 = ~data.LOOP4;
            data.XR = ~data.XR;
            data.IR = ~data.IR;
        
        end
    end
end
