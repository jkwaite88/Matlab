classdef MatrixSupport < handle
    %MatrixSupport Class that shows whether or not a feature is supported
    %   Detailed explanation goes here
    
    properties
        version
    end
    
    properties(Dependent)
        ClutterMap
        HistMode
        RadarImage
        TrackZonesChannels
        DominantActiveBin
        SysTimeStamp
        BlindSensor
        UnconstrainedDetections
    end
    
    methods
        function obj = MatrixSupport(dspVersion)
            obj.version = dspVersion;
        end
        
        function supported = get.ClutterMap(obj)
            supported = obj.version >= datenum(2013,10,29);
        end
        
        function supported = get.BlindSensor(obj)
            supported = obj.version >= datenum(2013,10,29);
        end
        
        function supported = get.HistMode(obj)
            supported = obj.version >= datenum(2014,1,10);
        end
        
        function supported = get.RadarImage(obj)
            supported = obj.version >= datenum(2014,12,2);
        end
        
        function supported = get.TrackZonesChannels(obj)
            supported = obj.version >= datenum(2014,9,12);
        end
        
        function supported = get.DominantActiveBin(obj)
            supported = obj.version >= datenum(2014,9,18);
        end
        
        function supported = get.SysTimeStamp(obj)
            supported = obj.version >= datenum(2014,12,24);
        end
        
        function supported = get.UnconstrainedDetections(obj)
            supported = obj.version >= datenum(2014,6,5);
        end
        
    end
    
end

