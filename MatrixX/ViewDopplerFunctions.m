%function binPatches = plotMatrixCells(matrixCellsPlotAxis, magnitude)
%This function takes an axis handle and magnitude data. magnitud must be an
%N-by-16 matrix. The sixteen beam shapes are plotted.
function [binPatches, CartesianLookupTable] = plotMatrixCells(matrixCellsPlotAxis, magnitude, useActualBeams)

NUM_BEAMS = 16;
NUM_BINS = size(magnitude,1);
AVERAGE_TARGET_HEIGHT = 3;% feet
sensorHeight = 18; %feet
FT_PER_BIN = 2; %feet - update with more accurate vaule


if useActualBeams
    BeamAnglesLeftToRight(1)    = 86*pi/180;
    BeamAnglesLeftToRight(2)    = 78.4*pi/180;
    BeamAnglesLeftToRight(3)    = 71.8*pi/180;
    BeamAnglesLeftToRight(4)    = 66.1*pi/180;
    BeamAnglesLeftToRight(5)    = 60.9*pi/180;
    BeamAnglesLeftToRight(6)    = 55.9*pi/180;
    BeamAnglesLeftToRight(7)    = 51.1*pi/180;
    BeamAnglesLeftToRight(8)    = 48.9*pi/180;
    BeamAnglesLeftToRight(9)    =  41.1*pi/180;
    BeamAnglesLeftToRight(10)   =  38.9*pi/180;
    BeamAnglesLeftToRight(11)   = 34.1*pi/180;
    BeamAnglesLeftToRight(12)   = 29.1*pi/180;
    BeamAnglesLeftToRight(13)   = 23.9*pi/180;
    BeamAnglesLeftToRight(14)   = 18.2*pi/180;
    BeamAnglesLeftToRight(15)   = 11.6*pi/180;
    BeamAnglesLeftToRight(16)   = 4*pi/180;
    
    HalfBeamWidthsLeftToRight(1)  =  (4.04 * pi / 180);
    HalfBeamWidthsLeftToRight(2)  =  (3.52 * pi / 180);
    HalfBeamWidthsLeftToRight(3)  =  (3.01 * pi / 180);
    HalfBeamWidthsLeftToRight(4)  =  (2.71 * pi / 180);
    HalfBeamWidthsLeftToRight(5)  =  (2.55 * pi / 180);
    HalfBeamWidthsLeftToRight(6)  =  (2.46 * pi / 180);
    HalfBeamWidthsLeftToRight(7)  =  (2.30 * pi / 180);
    HalfBeamWidthsLeftToRight(8)  =  (1.92 * pi / 180);
    HalfBeamWidthsLeftToRight(9)  =  (1.92 * pi / 180);
    HalfBeamWidthsLeftToRight(10) =  (2.30 * pi / 180);
    HalfBeamWidthsLeftToRight(11) =  (2.46 * pi / 180);
    HalfBeamWidthsLeftToRight(12) =  (2.55 * pi / 180);
    HalfBeamWidthsLeftToRight(13) =  (2.71 * pi / 180);
    HalfBeamWidthsLeftToRight(14) =  (3.01 * pi / 180);
    HalfBeamWidthsLeftToRight(15) =  (3.52 * pi / 180);
    HalfBeamWidthsLeftToRight(16) =  (4.04 * pi / 180);
else
    BeamAnglesLeftToRight = linspace(90-90/32,90/32,16)*pi/180;
    HalfBeamWidthsLeftToRight = 90/32*ones(1,16)*pi/180;
end

CartesianLookupTable = struct('x',zeros(NUM_BEAMS,NUM_RANGE_BINS),...
    'y',zeros(NUM_BEAMS,NUM_RANGE_BINS));

AnglesLeftToRight = BeamAnglesLeftToRight + HalfBeamWidthsLeftToRight;
xdata = zeros(4,NUM_BEAMS*NUM_RANGE_BINS);
ydata = zeros(4,NUM_BEAMS*NUM_RANGE_BINS);
slantRange = FT_PER_BIN/2:FT_PER_BIN:NUM_RANGE_BINS*FT_PER_BIN;
effectiveHeight = sensorHeight - AVERAGE_TARGET_HEIGHT;
groundRange = sqrt(slantRange.^2 - effectiveHeight.^2);
indices = find(imag(groundRange)~=0);
groundRange(imag(groundRange)~=0) = linspace(FT_PER_BIN/2,...
    groundRange(indices(end)+1)+FT_PER_BIN/2,numel(indices));
groundRange = real(groundRange);
left_angles = BeamAnglesLeftToRight - HalfBeamWidthsLeftToRight;
right_angles = BeamAnglesLeftToRight + HalfBeamWidthsLeftToRight;

cosValues = cos(BeamAnglesLeftToRight);
sinValues = sin(BeamAnglesLeftToRight);

for ind1 = 1:NUM_BEAMS
    
    for ind2 = 1:NUM_RANGE_BINS
        range_values = [groundRange(ind2)-FT_PER_BIN/2, groundRange(ind2)+FT_PER_BIN,...
            groundRange(ind2)+FT_PER_BIN groundRange(ind2)-FT_PER_BIN];
        angle_values = [left_angles(ind1), left_angles(ind1), right_angles(ind1),...
            right_angles(ind1)];
        
        xdata(:,(ind1-1)*(NUM_RANGE_BINS)+ind2) =...
            (range_values.*cos(angle_values))';
        ydata(:,(ind1-1)*(NUM_RANGE_BINS)+ind2) =...
            (range_values.*sin(angle_values))';
        
        if slantRange(ind2) < effectiveHeight
            gRange = 0;
        else
            gRange = sqrt(slantRange(ind2)^2 - effectiveHeight^2);
        end
        
        CartesianLookupTable(ind1,ind2).x = gRange*cosValues(ind1);
        CartesianLookupTable(ind1,ind2).y = gRange*sinValues(ind1);

    end
end
zdata = -0.0*ones(4,NUM_BEAMS*NUM_RANGE_BINS);
c = zeros(4,NUM_BEAMS*NUM_RANGE_BINS);
binBeamPatches = patch(xdata,ydata,zdata,c,'Parent',axis_handle,'EdgeAlpha',...
    0,'FaceColor','flat','EdgeColor','none');

end