%matrixRain
clear;  
FFT_SIZE = 256;
C = colorC;

%FILE_NAME = 'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\MatrixRain\2023-09-30\RCA_Blvd_NoRain2_20230930_083337.daq';
%FILE_NAME =  'C:\Data\MatrixRain\2023-09-30\RCA_Blvd_NoRain4_20230930_105120.daq';
FILE_NAME =  'C:\Data\20231009_Florida_Crossing\MatrixRainMidwayRD9_fixed.daq';
FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Matrix Test and Raw Data - General\Matrix Rail Rain Data\MatrixRainFloridaParkingLot\3-54 Recording\ISLAND RADAR RAIN CHASER 12-16-2023 - 3.50PM.5_fixed.daq';

z = ReadProcessDaqDataFunction(FILE_NAME);
z.DataMatrix_dB = 20*log10(abs(z.DataMatrix));
%%
% calculate block FFT  on frame dimension
if 0
    block_fft_size = 256;
    
    max_i = floor(z.numFrames/block_fft_size)*block_fft_size;
    block_fft_index = 0;
    for i = 1:block_fft_size:max_i
        block_fft_index = block_fft_index + 1;
        temp = z.DataMatrix(:,:,i:(i+block_fft_size-1));
        block_fft(:,:,i:(i+block_fft_size-1)) = fft(temp,block_fft_size,3);
    end
    
    
    matrixRangeCellEdges = 0:(FFT_SIZE/2+1);
    matrixRangeCellCenters = 1:(FFT_SIZE/2+1);
    matrixBeamEdgeAnglesDeg = linspace(90,0,17);%these are not the real angles
    matrixBeamCentersAnglesDeg = (matrixBeamEdgeAnglesDeg(2:end) + matrixBeamEdgeAnglesDeg(1:(end-1)))/2;
    matrixBeamCentersAnglesDeg = linspace(90,0,16);%these are not the real angles
    
    matrix_FOV_cell_x =  matrixRangeCellCenters.' * cosd(matrixBeamCentersAnglesDeg);
    matrix_FOV_cell_y =  matrixRangeCellCenters.' * sind(matrixBeamCentersAnglesDeg);
end

%% Calc block statistics - standard deviation
std_block_size  = 512;
z.DataMatrixStd = movstd(abs(z.DataMatrix), std_block_size, 0, 3);
z.DataMatrixMean = movmean(abs(z.DataMatrix), std_block_size, 3);
z.DataMatrixMedian = movmedian(abs(z.DataMatrix), std_block_size, 3);

%%
fig_h1 = figure(1);
clf(fig_h1)
ax1 = axes;
cla(ax1,"reset")
colorbar(ax1)

fig_h2 = figure(2);
clf(fig_h2)
ax2 = axes;
cla(ax2,"reset")
colorbar(ax2)

fig_h3 = figure(3);
clf(fig_h3)
ax3 = axes;
cla(ax3,"reset")
colorbar(ax3)

%% plot FFT
if 0
    for frame = 1:1:size(z.DataMatrix_dB,3)
        surf(ax1, matrix_FOV_cell_x, matrix_FOV_cell_y, squeeze(z.DataMatrix_dB(:,:,frame)), EdgeAlpha=0.1);
        axis(ax1,"equal")
        view(ax1,0,90)
        title(ax1, sprintf('FFT Magnitude - Frame %d / %d\n', frame, z.numFrames ))
        colorbar(ax1)
        xlim(ax1, [0 130]) 
        ylim(ax1, [0 130])
        clim(ax1, [0 90])
    
        drawnow
    
    end
end

%% plot Block FFT
if 0
    antennas = [5 8 ];
    rangeBins = [26 27];
    for frame = 1:block_fft_size:size(block_fft,3)
        surf(ax1, matrix_FOV_cell_x, matrix_FOV_cell_y, squeeze(z.DataMatrix_dB(:,:,frame)), EdgeAlpha=0.1);
        axis(ax1,"equal")
        view(ax1,0,90)
        title(ax1, sprintf('Frame %d / %d\n', frame, z.numFrames ))
        colorbar(ax1)
        xlim(ax1, [0 130]) 
        ylim(ax1, [0 130])
        clim(ax1, [0 90])
        
        temp = squeeze(20*log10(abs(block_fft(rangeBins(1), antennas(1), frame:(frame+block_fft_size-1)))));
        plot(ax2,temp)
        axis(ax2,[-inf inf 40 100])
        drawnow
    
    end
end
%%    
if 0
    temp = squeeze(20*log10(abs(block_fft(35, 4, frame:(frame+block_fft_size-1)))));
    plot(ax2,temp)
    axis(ax2,[-inf inf 40 100])
    drawnow
end


%%

matrixRangeCellCenters = 1:(FFT_SIZE/2+1);matrixBeamCentersAnglesDeg = linspace(0,90,16);%these are not the real angles
matrix_FOV_cell_x =  matrixRangeCellCenters.' * cosd(matrixBeamCentersAnglesDeg);
matrix_FOV_cell_y =  matrixRangeCellCenters.' * sind(matrixBeamCentersAnglesDeg);

dataMean = 20*log10(mean(abs(z.DataMatrix),3));
dataVar = 20*log10(var(abs(z.DataMatrix),0,3));

figure(3)
clf
surf(matrix_FOV_cell_x, matrix_FOV_cell_y, dataMean, EdgeAlpha=0.2);

axis("equal")
view(0,90)
title('Mean')
colorbar
xlim([0 130]) 
ylim([0 130])
clim([0 90])

%%
figure(4)
clf
surf(matrix_FOV_cell_x, matrix_FOV_cell_y, dataVar, EdgeAlpha=0.1);

axis("equal")
view(0,90)
title('Variance')
colorbar
xlim([0 130]) 
ylim([0 130])
%clim([0 90])


%%
%plot stuff versus time
vehicleTime = [1	5	12	32	33	41	46	53	59	70	92	95	113	118	121	154	180	182	185	194	198	199	205	232	238	244	249	255	304	305	318	324	329	334	341	342	344	348	349	355	416	419	423	431	446	452	455	470	473	477	481	484	504];
% antNum = 4;
% rangeBins = [15 22];

antNum = 2;
rangeBins = [22 29];
%rangeBins = [22 28];

frameInterval = (z.NUM_UP_CHIRP_SAMPLES + z.NUM_DOWN_CHIRP_SAMPLES) * z.NUM_ANTENNAS * 1e-6;
frameOffset =16.5;

x_seconds = (1:size(z.DataMatrix_dB,3)) * frameInterval -frameOffset;

figure(5)
clf
rows = 6;
cols = 1;
subplot(rows,cols,[1 2])
hold on;
plot(x_seconds, squeeze(z.DataMatrix_dB(rangeBins(1),antNum,:)), color='blue')
plot(x_seconds, squeeze(z.DataMatrix_dB(rangeBins(2),antNum,:)), color='red', LineStyle='--')
plot(vehicleTime, 55, marker= 'diamond',Color='black')

grid on
axis([-inf inf 10 80])
title('FFT Magnitude dB')
xlabel('Seconds')
ylabel('dB')
legend('Near Lane', 'Far Lane', 'Vehicles')

subplot(rows,cols,[3 4])
hold on;
plot(x_seconds, squeeze(abs(z.DataMatrix(rangeBins(1),antNum,:))), color='blue')
plot(x_seconds, squeeze(abs(z.DataMatrix(rangeBins(2),antNum,:))), color='red', LineStyle=':')
plot(vehicleTime, 500, marker= 'diamond',Color='black')

grid on
axis([-inf inf -inf inf])
title('FFT Magnitude')
xlabel('Seconds')
ylabel('')
legend('Near Lane', 'Far Lane', 'Vehicles')



subplot(rows,cols, 5)
hold on
plot(x_seconds, squeeze(z.DataMatrixMean(rangeBins(1),antNum,:)), color='blue')
plot(x_seconds, squeeze(z.DataMatrixMedian(rangeBins(1),antNum,:)), color='red', LineStyle='--')
axis([-inf inf -inf inf])
title('Mean and Median for Near Range Bin')
xlabel('Seconds')
grid on
legend('Mean', 'Median')

subplot(rows,cols, 6)
plot(x_seconds, squeeze(z.DataMatrixStd(rangeBins(1),antNum,:)), color='blue')
axis([-inf inf -inf inf])
title('Standard Deviation for Near Range Bin')
xlabel('Seconds')
grid on
legend('Standard Deviation')
%% plot several andtenna range bin combinations versus time

rangeBins = [ 5 10 15 22 30 40 50];
num_range_bins = size(rangeBins, 2);
frameInterval = (z.NUM_UP_CHIRP_SAMPLES + z.NUM_DOWN_CHIRP_SAMPLES) * z.NUM_ANTENNAS * 1e-6;
frameOffset =16.5;

x_seconds = (1:size(z.DataMatrix_dB,3)) * frameInterval -frameOffset;

figure(6)
clf
hold on;


for bin_i = 1:num_range_bins
    subplot(num_range_bins,1, bin_i)
    hold on;
    for ant_num = 1:16
        rangeBin = rangeBins(bin_i);
        plot(x_seconds, squeeze(z.DataMatrix_dB(rangeBin, ant_num,:)), color=C.color01(ant_num,:))
    end
    grid on;
    axis([-inf inf 10 80])
    ylabel(sprintf('dB - Range Bin %d',rangeBin))

end
xlabel('Seconds')

grid on


