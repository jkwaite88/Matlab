%AntennaBeamPositionOnScene

clear
%Antenna Beam Parameters
beamAngles = -40:15:40;
beamwidths = 15.*ones(size(beamAngles));
xBeamLimit = 200; %feet
yBeamLimit = 200; %feet
rotateBeams = 0;

%radar Parameters
bandwidth = 250e6; %Hz
c = 3e8; % m/s
c_fps = c*3.28084;
rangeResolution = c_fps/(2*bandwidth);
rangeLimit = xBeamLimit;

%roadParameters
roadRanges = [12 24];
roadWidths = 12;%[12 12 12];
roadRotation = 0;
roadOffsetX = 0;
roadOffsetY = 60;




figure(1);
clf;
hold on;
beamEdgeLeft = beamAngles-beamwidths/2;
beamEdgeRight = beamAngles+beamwidths/2;
%plot Roads
for i = 1:length(roadRanges)
    x = [-xBeamLimit -xBeamLimit xBeamLimit xBeamLimit];
    y = [roadRanges(i)-roadWidths/2 roadRanges(i)+roadWidths/2 roadRanges(i)+roadWidths/2 roadRanges(i)-roadWidths/2];
    xx = x*cosd(-roadRotation) - y*sind(-roadRotation) + roadOffsetX;
    yy = x*sind(-roadRotation) + y*cosd(-roadRotation) + roadOffsetY; 
    h = fill(xx, yy, 'k')
    set(h,'FaceColor','k','EdgeColor','k','FaceAlpha',0,'EdgeAlpha',1);
    stophere = 1;
end
%plot Beams
rangeBin = 0:rangeResolution:rangeLimit;
for i = 1:length(beamAngles)
    for j = 2:length(rangeBin)
        x = [rangeBin(j-1)*sind(beamEdgeLeft(i)) rangeBin(j-1)*sind(beamEdgeRight(i)) rangeBin(j)*sind(beamEdgeRight(i)) rangeBin(j)*sind(beamEdgeLeft(i))];
        y = [rangeBin(j-1)*cosd(beamEdgeLeft(i)) rangeBin(j-1)*cosd(beamEdgeRight(i)) rangeBin(j)*cosd(beamEdgeRight(i)) rangeBin(j)*cosd(beamEdgeLeft(i))];
        xx = x*cosd(-rotateBeams) - y*sind(-rotateBeams);
        yy = x*sind(-rotateBeams) + y*cosd(-rotateBeams);
        h = fill(xx, yy, 'g')
        set(h,'FaceColor','g','EdgeColor','g','FaceAlpha',0,'EdgeAlpha',1);
        stophere = 1;
    end
end


hold off;
axis equal
%axis([-xBeamLimit xBeamLimit -yBeamLimit yBeamLimit])