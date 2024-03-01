classdef Channel
    %Channel Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mappedZones = false(1,16);
        state
        delay = 0;
        extend = 0;
        logic = 0;
        phase = 0;
        detectorInput = 0;
        inverted = false;
    end
    
    methods
    end
    
end

