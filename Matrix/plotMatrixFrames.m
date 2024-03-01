%plotMatrixFrames
clear;  % ReadDAQData
SAMPLE_RATE = 1e6;
NUM_HEADER_SAMPLES = 3;
FFT_SIZE = 256;


%FILE_NAME = 'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\MatrixRain\2023-10-01\Miday_St_Rain5_20231001_113114.daq';
%FILE_NAME = 'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\MatrixRain\2023-09-30\RCA_Blvd_NoRain2_20230930_083337.daq';
%FILE_NAME = "C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\MatrixRain\2023-09-30\RCA_Blvd_NoRain4_20230930_105120.daq";
FILE_NAME = 'C:\Data\MatrixRain\2023-10-13\MatrixRailCornerReflector_43feet_moving_20231013_113416.daq';

[filepath,name,ext] = fileparts(FILE_NAME);
plotVideoFileName = strcat(filepath,'\',name,'.avi');

z = ReadProcessDaqDataFunction(FILE_NAME);

z.DataMatrix_dB = 20*log10(abs(z.DataMatrix));

%%


matrixRangeCellEdges = 0:(FFT_SIZE/2+1);
matrixRangeCellCenters = 1:(FFT_SIZE/2+1);
matrixBeamEdgeAnglesDeg = linspace(0,90,17);%these are not the real angles
matrixBeamCentersAnglesDeg = (matrixBeamEdgeAnglesDeg(2:end) + matrixBeamEdgeAnglesDeg(1:(end-1)))/2;
matrixBeamCentersAnglesDeg = linspace(0,90,16);%these are not the real angles

matrix_FOV_cell_x =  matrixRangeCellCenters.' * cosd(matrixBeamCentersAnglesDeg);
matrix_FOV_cell_y =  matrixRangeCellCenters.' * sind(matrixBeamCentersAnglesDeg);

fig_h1 = figure(1);
clf(fig_h1)
ax1 = axes;
cla(ax1,"reset")
colorbar(ax1)

% fig_h2 = figure(2);
% clf(fig_h2)
% for r = 1:4
%     for c = 1:4
%         plotNum = (r-1)*4 + c;
%         subplot(4,4, plotNum)
%         ax2(r, c) = gca;
%     end
% end 

for frame = 1:z.numFrames
    surf(ax1, matrix_FOV_cell_x, matrix_FOV_cell_y, squeeze(z.DataMatrix_dB(:,:,frame)), EdgeAlpha=0.1);
    axis(ax1,"equal")
    view(ax1,0,90)
    title(ax1, sprintf('Frame %d / %d\n', frame, z.numFrames ))
    colorbar(ax1)
    xlim([0 130]) 
    ylim([0 130])
    clim(ax1, [0 90])

    F(frame) = getframe(fig_h1);

%     for r = 1:4
%         for c = 1:4
%             antNum = (r-1)*4 + c;
%             plot(ax2(r,c), z.dataMatrix(:,antNum,frame))
%             axis(ax2(r,c), [-inf inf -200 800])
%         end
%     end
    
    %drawnow
    %pause(0.00001)
    if (mod(frame,100)== 0)
        fprintf('frame %d\n', frame)
    end
end


%%
 writerObj = VideoWriter(plotVideoFileName);
 writerObj.FrameRate = 30;

open(writerObj);
% write the frames to the video
for i=1:length(F)
    % convert the image to a frame
    frame = F(i) ;    
    writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);
