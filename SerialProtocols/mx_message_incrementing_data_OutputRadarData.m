classdef mx_message_incrementing_data_OutputRadarData < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties (Constant)
        RANGE_BINS                               = 150;
        NUM_STEERING_BEAMS                       = 30;
        NUM_FFT_BEAMS                            = 64;
        HEATMAP_STEERING_VECTOR_BEAMFORMING_SIZE = 4500; %30 Beams * 150 Range Bins
        HEATMAP_FFT_BEAMFORMING_SIZE             = 9600; %64 Beams * 150 Range Bins
    end
    properties
        index = 0;
        hdr = struct('data', zeros(1,4));
        bdy = struct('data', []);
        
    end

    methods
        function value = processUint8(obj, data)
            value = 0;
            obj.index = obj.index + 1;
            value = value + data(obj.index);
        end
        function value = processInt16(obj, data)
            value = 0;
            obj.index = obj.index + 1;
            value = value + data(obj.index);
            obj.index = obj.index + 1;
            value = value +  data(obj.index)*2^8;
            value = int16(value);
        end
        function value = processUint16(obj, data)
            value = 0;
            obj.index = obj.index + 1;
            value = value + data(obj.index);
            obj.index = obj.index + 1;
            value = value +  data(obj.index)*2^8;
        end
        function value = processUint16_incrementing_data(obj, data)
            value = 0;
            obj.index = obj.index + 1;
            value = value + data(obj.index)*2^8;
            obj.index = obj.index + 1;
            value = value +  data(obj.index);
        end
        function value = processUint32(obj, data)
            value = 0;
            obj.index = obj.index + 1;
            value = value + data(obj.index);
            obj.index = obj.index + 1;
            value = value +  data(obj.index)*2^8;
            obj.index = obj.index + 1;
            value = value +  data(obj.index)*2^16;
            obj.index = obj.index + 1;
            value =  value + data(obj.index)*2^24;
        end

%         function processHeader(obj, msg)
%             for i = 1:4
%                 obj.hdr.data(i) = processUint16_incrementing_data(obj, msg.hdr.data(i));
%             end
%         end
        function processBody(obj, msg)
            dataSize = uint16(floor((double(msg.hdr.bdySize)-8)/2));
            for i = 1:dataSize
                obj.bdy.data(i) = processUint16_incrementing_data(obj, msg.bdy.data);
            end
        end


        function obj = mx_message_incrementing_data_OutputRadarData(msg) %constructor
            temp = uint16(floor((double(msg.hdr.bdySize)-8)/2));
            obj.bdy.data = zeros(1,temp);
            %            obj.processHeader(msg);
            obj.processBody(msg);
        end
        

    end
end