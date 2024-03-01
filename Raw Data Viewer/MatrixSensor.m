classdef MatrixSensor < handle
    % MatrixSensor implements properties and methods associated with a
    % Matrix sensor
    %   
    
    properties (Constant)
        numLanes = 10;
        numZones = 16;
        numChannels = 16;
        numBeams = 16;
        numRangeBins = 80;
        numUarts = 2;
    end
    properties
        serialNumber
        
        algorithmVersion
        fpgaVersion
        fpaaVersion
        major
        minor
        build
        lanes = [Lane() Lane() Lane() Lane() Lane() Lane() Lane() Lane(),...
            Lane() Lane()];
        zones = [Zone() Zone() Zone() Zone() Zone() Zone() Zone() Zone(),...
            Zone() Zone() Zone() Zone() Zone() Zone() Zone() Zone()];
        channels = [Channel() Channel() Channel() Channel() Channel(),...
            Channel() Channel() Channel() Channel() Channel() Channel(),...
            Channel() Channel() Channel() Channel() Channel()];
        dspHardware
        rfHardware
        description
        approach
        location
        rfChannel
        replayInstalled
        dataSource
        port = [Uart() Uart()];
        measurementUnits
        washoutTime
        sensorHeight = 20;
        snowAlgorithms
        blindSensorCheck
        queueForming
        dataPort
        orientation = 0;
        minPulseWidth
        minChannelWidth
        thresholds
        antennaCoefficients
        dataPush
        source
        units
        unconstrainedDimensions
        fileDate
        dspVersion
    end
    
    properties(Dependent)
        supports
        NumSamplesPerChirp
    end
    
    
    methods
        function pulsesPerSecond = findPulsesPerSecond(obj)
            if obj.rfChannel == 0
                pulsesPerSecond = 1/279e-6;
            elseif obj.rfChannel == 1
                pulsesPerSecond = 1/281e-6;
            elseif obj.rfChannel == 2
                pulsesPerSecond = 1/278e-6;
            elseif obj.rfChannel == 3
                pulsesPerSecond = 1/277e-6;
            elseif obj.rfChannel == 4
                pulsesPerSecond = 1/283e-6;
            elseif obj.rfChannel == 5
                pulsesPerSecond = 1/275e-6;
            elseif obj.rfChannel == 6
                pulsesPerSecond = 1/287e-6;
            elseif obj.rfChannel == 7
                pulsesPerSecond = 1/271e-6;
            else
                pulsesPerSecond = 1/279e-6;
            end
                
        end
        
        function set.dspVersion(obj,version)
            obj.dspVersion = version;
            
        end
        
        function supports = get.supports(obj)
            supports = MatrixSupport(obj.dspVersion);
        end
        
        function NumSamplesPerChirp = get.NumSamplesPerChirp(obj)
            numSamplesUpChirp = 256;
            if obj.rfChannel == 0
                NumSamplesPerChirp = numSamplesUpChirp + 23;
            elseif obj.rfChannel == 1
                NumSamplesPerChirp = numSamplesUpChirp + 25;
            elseif obj.rfChannel == 2
                NumSamplesPerChirp = numSamplesUpChirp + 22;
            elseif obj.rfChannel == 3
                NumSamplesPerChirp = numSamplesUpChirp + 21;
            elseif obj.rfChannel == 4
                NumSamplesPerChirp = numSamplesUpChirp + 27;
            elseif obj.rfChannel == 5
                NumSamplesPerChirp = numSamplesUpChirp + 19;
            elseif obj.rfChannel == 6
                NumSamplesPerChirp = numSamplesUpChirp + 31;
            elseif obj.rfChannel == 7
                NumSamplesPerChirp = numSamplesUpChirp + 15;
            else
                NumSamplesPerChirp = numSamplesUpChirp + 23;
            end
                
        end
        
        function railSensor = IsRailSensor(obj)
            ind = strfind(obj.serialNumber,'SS300');
            railSensor = false;
            if ~isempty(ind)
                railSensor = true;
            end
        end
        
    end
    
end

