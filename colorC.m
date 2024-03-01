classdef colorC < handle
    %This class creates an array of colors that can be used to return RGB
    %values.

    properties (Constant = true)
        color = ... 
        [
            [0 0 255]       %blue
            [255 0 0]       %red
            [0 255 127]     %springgreen
            [30	144 255]    %dodgerblue   
            [219 112 147]   %palevioletred    
            [240 230 140]   %khaki   
            [255 160 122]   %Light salmon
            [238 130 238]   %violet
            [0 206 209]     %darkturquoise
            [255 20 14]     %deeppink
            [255 140 0]     %darkorange
            [255 255 0]     %yellow
            [127 255 0]     %chartreuse
            [0 191 255]     %deepskyblue
            [216 191 21]    %thistle
            [255 0 255]     %fuchsia
            [47 79 79]      %darkslategray
            [34 139 34]     %forestgreen
            [128 128 0]     %olive
            [72 61 139]     %darkslateblue
            [178 34 34]     %firebrick
            [0 0 128]       %navy
            [154 205 50]    %yellowgreen
            [143 188 143]   %darkseagreen
            [153 50 204]    %darkorchid  
        ];
    end
    properties (GetAccess = public, SetAccess = private)
        colorIndex = 1;
        numColors = 0;
        color01 = [];
    end
    properties (GetAccess = public, SetAccess = public)
        returnValuesBetween0and1 = 1;
    end
    methods
        function obj = colorC()
            obj.numColors = size(obj.color,1);
            obj.color01 = obj.color./255;
        end

        function rgb = getColorByIdx(obj,i)
            %getColorByIdx  - Retrun color rgb value by index into the
            %colors array. Indexs larger than the size of the array will
            %wrap around to the beginning.
            idx = mod(i-1, obj.numColors)+1;
            if obj.returnValuesBetween0and1
                rgb = obj.color01(idx, :);
            else
                rgb = obj.color(idx, :);
            end
        end
        function rgb = getNextColor(obj)
            %getNextColor - this method will return the next color in the
            %colors array.
            idx = mod(obj.colorIndex-1, obj.numColors)+1;
            if obj.returnValuesBetween0and1
                rgb = obj.color01(idx,:);
            else            
                rgb = obj.color(idx,:);
            end
            obj.colorIndex =  obj.colorIndex + 1;
            if obj.colorIndex > obj.numColors
                obj.colorIndex = 1;
            end
        end
    end
end