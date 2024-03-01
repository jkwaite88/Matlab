classdef mx_message_parser_incrementing_data < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties (Constant)
        MX_MESSAGE_1_WRITESTATICSETTINGS    = 1;
        MX_MESSAGE_2_WRITEDYNAMICSETTINGS   = 2;
        MX_MESSAGE_3_WRITESERIALNUMBER      = 3;
        MX_MESSAGE_4_READCALIBRATION        = 4;
        MX_MESSAGE_5_WRITECALIBRATION       = 5;
        MX_MESSAGE_6_READDEVICESTATUS       = 6;
        MX_MESSAGE_7_OUTPUTRADARDATA        = 7;
        MX_MESSAGE_8_OUTPUTRADARDATA        = 8;
        MX_MESSAGE_9_OUTPUTRAWDATA          = 9;

        NUM_RANGE_BINS                      = 150;
        NUM_CHANNELS                        = 12;
        NUM_BEAMFORMER_BEAMS                = 30;
        NUM_FFT_BEAMFORMER_BEAMS            = 64;
    end
    properties
        %msgId
        %msgData
        
        msgParsed
    end

    methods
        function obj = mx_message_parser_incrementing_data(input_msg)
            %Construct an instance of this class
            %obj.msgId = input_msg.bdy.msgId;
            %obj.msgData  = input_msg.bdy.data;
            %messageParser(obj);
            messageParser_incrementing_data(obj, input_msg);

        end


        function messageParser_incrementing_data(obj, input_msg)
            obj.msgParsed = mx_message_incrementing_data_OutputRadarData(input_msg);
        end
    end
end