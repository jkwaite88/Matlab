classdef Lane < handle
    %Lane Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        stopbarDefined = false;
        stopbarDistance = 0;
        numNodes = 0;
        nodes = struct('x',0,'y',0,'width',0);
        state = 0;
        segLength
    end
    
    methods
        
        function handle = plotLanes(obj,haxis)
            % this function plots the lane on the given axis and returns
            % a handle to the plot
            if ~isempty(obj.state) && obj.state ~= 0 && obj.state ~= 7
                handle = zeros(1,3);
                x = [obj.nodes.x];
                y = [obj.nodes.y];
                radius = [obj.nodes.width]/2;
                reverse_x = fliplr(x);
                reverse_y = fliplr(y);
                slope = (reverse_y(1:end-1)-reverse_y(2:end)) ./ ...
                        (reverse_x(1:end-1)-reverse_x(2:end));
                theta_t   = atan2(-1*ones(1,length(slope)),slope);
                theta = [theta_t theta_t(end)];
                xs      = x + radius.*cos(theta);
                ys      = y + radius.*sin(theta);
                handle(1) = plot(xs,ys,'-k','Parent',haxis,'LineWidth',2);



                xe       = x - radius.*cos(theta);
                ye       = y - radius.*sin(theta);
                handle(2) = plot(xe,ye,'-k','Parent',haxis,'LineWidth',2);


                if obj.stopbarDefined

                    accumDist    = 0;
                    current_node = 1;
                    
                    while accumDist<obj.stopbarDistance && current_node <= length(obj.segLength)
                        accumDist = accumDist + obj.segLength(current_node);
                        current_node = current_node + 1;
                    end


                    if accumDist < obj.stopbarDistance % then stop_bar_dist is past the lane
                        theta = pi/2 - atan2(y(end),x(end-1));
                        x3 = [x(end)-radius(end).*cos(theta),...
                             x(end)+radius(end).*cos(theta)];
                        y3 = [y(end)-radius(end).*sin(theta),...
                             y(end)+radius(end).*sin(theta)];
                    else
                        % the current node now points to the node just past where the
                        % stop bar is

                        % calculate the total distance along the path from the start to
                        % the current node -1
                        temp = accumDist - obj.segLength(current_node-1);

                        % calculate the distance from the last node to our desired
                        % point
                        temp = obj.stopbarDistance - temp;

                        % ratio of point distancefrom previous node to segment distance
                        temp = temp/obj.segLength(current_node-1);

                        % linearly interpolate along the path to get our desired point
                        delta_x = x(current_node) - x(current_node-1);
                        delta_y = y(current_node) - y(current_node-1);

                        temp_x = x(current_node-1) + temp*delta_x;
                        temp_y = y(current_node-1) + temp*delta_y;


                        theta = pi/2-atan2(temp_y-y(1),x(1));
                        x3 = [temp_x-radius(current_node)*cos(theta),...
                             temp_x+radius(current_node)*cos(theta)];
                        y3 = [temp_y-radius(current_node)*sin(theta),...
                             temp_y+radius(current_node)*sin(theta)];

                    end
                    handle(3) = plot(x3,y3,'-k','Parent',haxis,'LineWidth',2);
                else
                    handle(3) = [];
                end
            else
                handle = [];
            end
        end
        
        function [x, y] = DistAlongPathToCartesian(obj,dist)
            x = zeros(size(dist));
            y = zeros(size(dist));
            dist = dist(:);
            for ind = 1:length(dist)
                if dist(ind) <= 0
                    x(ind) = obj.nodes(1).x;
                    y(ind) = obj.nodes(1).y;
                else
                    accumDist = 0;
                    currNode = 1;
                    while (accumDist < dist(ind)) && (currNode <= obj.numNodes-1)
                        accumDist = obj.segLength(currNode);
                        currNode = currNode + 1;
                    end
                    
                    if accumDist < dist(ind)
                        x(ind) = obj.nodes(end).x;
                        y(ind) = obj.nodes(end).y;
                    else
                        % the currNode now points to the node just past
                        % where the point is
                        
                        % calculate the total distance along the path from
                        % the start to the current node (node before our
                        % point)
                        temp = accumDist - obj.segLength(currNode-1);
                        % calculate the distance from the last node to our
                        % desired point
                        temp = dist(ind) - temp;
                        
                        % ratio of point distance from previous node to
                        % segment distance
                        temp = temp / obj.segLength(currNode-1);
                        
                        % linearly interpolate along the path to get our
                        % desired point
                        % x = node(x) + (distPoint/distSeg)*deltaNode(x)
                        % y = node(y) + (distPoint/distSeg)*deltaNode(y)
                        delta_x = obj.nodes(currNode).x - obj.nodes(currNode-1).x;
                        delta_y = obj.nodes(currNode).y - obj.nodes(currNode-1).y;
                        
                        x(ind) = obj.nodes(currNode-1).x + temp*delta_x;
                        y(ind) = obj.nodes(currNode-1).y + temp*delta_y;
                    end
                end
            end
        end
    end
    
end

