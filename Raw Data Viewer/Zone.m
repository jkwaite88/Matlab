classdef Zone
    %Zone Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        delay = 0;
        extend = 0;
        enabled = false;
        polygon = [struct('x',0,'y',0) struct('x',0,'y',0),...
            struct('x',0,'y',0) struct('x',0,'y',0)];
    end
    
    methods
        function handles = plotZones(obj, haxis, use_patches)
            handles = [];
            plot_color = [95/256 158/256 160/256];
            if obj.enabled
                if use_patches
                   handles = patch('Parent',haxis,'XData',[obj.polygon.x],...
                        'YData',[obj.polygon.y],'FaceColor','w','EdgeColor',plot_color,...
                        'FaceAlpha',0);
                else
                    
                        handles = line('Parent',axis_handle,'XData',...
                            [obj.polygon.x obj.polygon(1).x] ,'YData',...
                            [obj.polygon.x obj.polygon(2).x],'Color',plot_color);
                    
                end
            end
        end
    end
    
end

