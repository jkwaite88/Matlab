%function binPatches = plotMatrixCells(matrixCellsPlotAxis, magnitude)
%This function takes an axis handle and magnitude data. magnitud must be an
%N-by-16 matrix. The sixteen beam shapes are plotted.
function [binPatches, CartesianLookupTable] = plotMatrixCellsAndDots(axis_handle, cellMagnitude, dotMagnitude, useActualBeams)

NUM_BEAMS = 16;
NUM_BINS = size(cellMagnitude,1);
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

CartesianLookupTable = struct('x',zeros(NUM_BEAMS,NUM_BINS),...
    'y',zeros(NUM_BEAMS,NUM_BINS));

AnglesLeftToRight = BeamAnglesLeftToRight + HalfBeamWidthsLeftToRight;
xdata = zeros(4,NUM_BEAMS*NUM_BINS);
ydata = zeros(4,NUM_BEAMS*NUM_BINS);
slantRange = FT_PER_BIN/2:FT_PER_BIN:NUM_BINS*FT_PER_BIN;
effectiveHeight = sensorHeight - AVERAGE_TARGET_HEIGHT;
groundRange = (sqrt(slantRange.^2 - effectiveHeight.^2));
imag_indices = find(real(groundRange)==0); %find imag values and real ==0
groundRange(imag_indices) = linspace(FT_PER_BIN/2,...
    groundRange(imag_indices(end)+1)-FT_PER_BIN/2,numel(imag_indices));
groundRange = real(groundRange);
bin_bound = zeros(1,numel(groundRange)+1);
bin_bound(2:(end-1)) = (groundRange(2:end)+groundRange(1:(end-1)))/2;
bin_bound(1) = groundRange(1)-(groundRange(2)-groundRange(1))/2;
bin_bound(end) = groundRange(end)+(groundRange(end)-groundRange(end-1))/2;
left_angles = BeamAnglesLeftToRight - HalfBeamWidthsLeftToRight;
right_angles = BeamAnglesLeftToRight + HalfBeamWidthsLeftToRight;

cosValues = cos(BeamAnglesLeftToRight);
sinValues = sin(BeamAnglesLeftToRight);

for beamNum = 1:NUM_BEAMS
    
    for binNum = 1:NUM_BINS
%         range_values = [groundRange(ind2)-FT_PER_BIN/2, groundRange(ind2)+FT_PER_BIN,...
%             groundRange(ind2)+FT_PER_BIN groundRange(ind2)-FT_PER_BIN];
%         angle_values = [left_angles(ind1), left_angles(ind1), right_angles(ind1),...
%             right_angles(ind1)];
        range_values = [bin_bound(binNum), bin_bound(binNum+1), bin_bound(binNum+1), bin_bound(binNum)];
        angle_values = [left_angles(beamNum), left_angles(beamNum), right_angles(beamNum),...
            right_angles(beamNum)];
        
        xdata(:,(beamNum-1)*(NUM_BINS)+binNum) =...
            (range_values.*cos(angle_values))';
        ydata(:,(beamNum-1)*(NUM_BINS)+binNum) =...
            (range_values.*sin(angle_values))';
        
        if slantRange(binNum) < effectiveHeight
            gRange = 0;
        else
            gRange = sqrt(slantRange(binNum)^2 - effectiveHeight^2);
        end
        
        CartesianLookupTable(beamNum,binNum).x = gRange*cosValues(beamNum);
        CartesianLookupTable(beamNum,binNum).y = gRange*sinValues(beamNum);

    end
end
%zdata = -0.0*ones(4,NUM_BEAMS*NUM_BINS);
c = reshape(cellMagnitude,numel(cellMagnitude),1);
binPatches = patch(xdata,ydata,c,'Parent',axis_handle,'EdgeAlpha',...
    0,'FaceColor','flat','EdgeColor','none');
axis(axis_handle, 'square')

end