classdef mx_message_0x08_OutputRadarData < handle
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
        hdr1 = struct('magicWord', zeros(1,7));
        hdr2 = struct('sectorId',  0, 'totalPacketLength', 0, 'version', 0 , 'frameNumber', 0, 'timeCpuCycles', 0, 'numDetectedObjects', 0, 'numTlvs', 0);
        pointCloudSpherical = struct('range', [], 'azimuthAngle', [], 'velocity', []);
        pointCloudSideInfo = struct('snr', [], 'noise', []);
        timingInfoStats = struct('interFrameProcessingTime', [], 'transmitOutputTime', [], 'interFrameProcessingMargin', [], 'interChirpProcessingMargin', [], 'activeFrameCPULoad', [], 'interFrameCPULoad', []);
        temperatureStats = struct('tempReportValid', []);
        temperatureReport = struct('time', [], 'tmpRx0Sens', [], 'tmpRx1Sens', [], 'tmpRx2Sens', [], 'tmpRx3Sens', [], 'tmpTx0Sens', [], 'tmpTx1Sens', [], 'tmpTx2Sens', [], 'tmpPmSens', [], 'tmpDig0Sens', [], 'tmpDig1Sens', []);

        heatmap = [];
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

        function procesHeader(obj, data)
            for i = (obj.index+1):(obj.index + 7)
                obj.hdr1.magicWord(i) = processUint8(obj, data);
            end
            obj.index = obj.index + 1;
            obj.hdr2.sectorId = data(obj.index);
            obj.hdr2.totalPacketLength = processUint32(obj, data);
            obj.hdr2.version = processUint32(obj, data);
            obj.hdr2.frameNumber = processUint32(obj, data);
            obj.hdr2.timeCpuCycles =processUint32(obj, data);
            obj.hdr2.numDetectedObjects = processUint32(obj, data);
            obj.hdr2.numTlvs = processUint32(obj, data);
           
            if obj.hdr2.numDetectedObjects > 0  %debug
                breakhere = 1;                  %debug
            end                                 %debug
        end

        function processPointCloud(obj, data)
            type = processUint32(obj, data);                %type MMWDEMO_OUTPUT_MSG_DETECTED_POINTS = 1
            length =  processUint32(obj, data);
            for i = 1:obj.hdr2.numDetectedObjects
                obj.pointCloudSpherical.range(i)        =  typecast(uint32(processUint32(obj, data)),'single');
                obj.pointCloudSpherical.azimuthAngle(i) =  typecast(uint32(processUint32(obj, data)),'single');
                obj.pointCloudSpherical.velocity(i)     =  typecast(uint32(processUint32(obj, data)),'single');
            end
        end

        function processPointCloudSideInfo(obj, data)
            type = processUint32(obj, data);                %type MMWDEMO_OUTPUT_MSG_DETECTED_POINTS_SIDE_INFO = 2
            length =  processUint32(obj, data);
            for i = 1:obj.hdr2.numDetectedObjects
                obj.pointCloudSideInfo.snr(i)        =  processUint16(obj, data);
                obj.pointCloudSideInfo.noise(i)      =  processUint16(obj, data);
            end
        end

        function processTimingInfoStats(obj, data)
            type = processUint32(obj, data);                %type MMWDEMO_OUTPUT_MSG_STATS = 3
            length =  processUint32(obj, data);
            obj.timingInfoStats.interFrameProcessingTime    =  processUint32(obj, data);
            obj.timingInfoStats.transmitOutputTime          =  processUint32(obj, data);
            obj.timingInfoStats.interFrameProcessingMargin  =  processUint32(obj, data);
            obj.timingInfoStats.interChirpProcessingMargin  =  processUint32(obj, data);
            obj.timingInfoStats.activeFrameCPULoad          =  processUint32(obj, data);
            obj.timingInfoStats.interFrameCPULoad           =  processUint32(obj, data);
        end

        function processTemperatureStats(obj, data)
            type = processUint32(obj, data);                %type MMWDEMO_OUTPUT_MSG_TEMPERATURE_STATS = 4
            length =  processUint32(obj, data);
            obj.temperatureStats.tempReportValid    =  processUint32(obj, data);
            obj.temperatureReport.time    =  processUint32(obj, data);
            obj.temperatureReport.tmpRx0Sens    =  processInt16(obj, data);
            obj.temperatureReport.tmpRx1Sens    =  processInt16(obj, data);
            obj.temperatureReport.tmpRx2Sens    =  processInt16(obj, data);
            obj.temperatureReport.tmpRx3Sens    =  processInt16(obj, data);
            obj.temperatureReport.tmpTx0Sens    =  processInt16(obj, data);
            obj.temperatureReport.tmpTx1Sens    =  processInt16(obj, data);
            obj.temperatureReport.tmpTx2Sens    =  processInt16(obj, data);
            obj.temperatureReport.tmpPmSens     =  processInt16(obj, data);
            obj.temperatureReport.tmpDig0Sens   =  processInt16(obj, data);
            obj.temperatureReport.tmpDig1Sens   =  processInt16(obj, data);
        end

        function process_heatmap(obj, data)
            type = processUint32(obj, data);                %type MMWDEMO_OUTPUT_ZERO_DOPPLER = 5
            length =  processUint32(obj, data);
            if length == obj.HEATMAP_STEERING_VECTOR_BEAMFORMING_SIZE
               
                for rangeBin = 1:obj.RANGE_BINS
                    for beam = 1:obj.NUM_STEERING_BEAMS
                        obj.heatmap(rangeBin, beam) = processUint8(obj, data);
                    end
                end
            
            elseif length == obj.HEATMAP_FFT_BEAMFORMING_SIZE
                for rangeBin = 1:obj.RANGE_BINS
                    for beam = 1:obj.NUM_FFT_BEAMS
                        obj.heatmap(rangeBin, beam) = processUint8(obj, data);
                    end
                end
            else
                %size is incorrect
            end
        end

        function obj = mx_message_0x08_OutputRadarData(data) %constructor
            obj.procesHeader(data);
            obj.processPointCloud(data);
            obj.processPointCloudSideInfo(data);
            obj.processTimingInfoStats(data);
            obj.processTemperatureStats(data);
            obj.process_heatmap(data);
        end
        

    end
end