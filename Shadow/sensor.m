classdef sensor
    properties
       serialNumber
       startTime
       endTime
       testResult
    end
    
    methods
        function obj = sensor(sn, st, et, tr)
            obj.serialNumber = sn;
            obj.startTime = st;
            obj.endTime = et;
            obj.testResults = tr;
    %             
%             sn_indexes = find(strcmp(T.SerialNumber, sn));
%             mn_time = min(datenum(T.TestResultDate(sn_indexes)));
%             obj.startTime = mn_time;
%             mx_time = max(datenum(T.TestResultDate(sn_indexes)));
%             obj.endTime = mx_time;
%             r = find(strcmp(T.TestResultPass(sn_indexes), 'Failed'));
%             if ~isempty(r)
%                 obj.testResult = 'Failed';
%             else
%                 obj.testResult = 'Pass';
%             end                
        end
       
    end
    
end