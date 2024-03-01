%This script is assumes there is no curruptions in the data file.
tic;
clear
SAMPLES_PER_SEC = 1e6;
POSITIVE_FULL_SCALE = 32767;
NEGATIVE_FULL_SCALE = -32768;
NUM_SAMPS_IN_HEADER = 3;
FramesToRead = 500;
FFT_SIZE = 256;
bytesPerSample = 2;
BeamAnglesLeftToRight = ([86 78.4 71.8 66.1 60.9 55.9 51.1 48.9 41.1 38.9 34.1 29.1 23.9 18.2 11.6 4.0]+45)*pi/180; 
PRT = 279e-6; %pulse repitition time
PRF = 1/PRT; %pulse repitition frequency
c=3e8;
f=24.125e9;
lambda_m = c/f;
lambda_ft = lambda_m*3.28084;
lambda_mile = lambda_ft/5280;

%Enter the file name to be fixed here.  The new fixed file will
% have "_fixed" appended to it. 
%FILE_NAME =  'C:\Data\2007_04_03\AntennaPattern_LidOn2.daq';
% FILE_NAME =  'C:\Data\20121116_XCVR_ModPlastic\20121116_XCVR_BID146_PlasticAbsorberA_AGC0p5_SpinBackward.daq';
%FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\2019-06-12  - Doppler\RubyRiver6-12-19-32pt-2.daq';
%FILE_NAME =  'C:\Data\LaquintaTest.daq';
% FILE_NAME =  'C:\Data\HPol_Board114a0p5.daq';
% FILE_NAME =  'C:\Data\2011_09_16\AntChambXCVRNewHPolBrd_PGA1_NoBias_set1.daq';
%FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\2019-07-09\UniversityAve_Doppler32_1144.daq';
%FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\2019-07-09\UniversityAve_RegularSwitchingPattern_1136.daq';
%FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\2019-07-11\PetesAppliance_1645.daq';
FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\2019-07-23\FreightTrain1616.daq';

fignumb=47;
%%%%%%%%%%%%%%%%%%%%%%%%%%*******************************%%%%%%%%%%%%%%%%%5
%titleStr = 'Antenna Patterns';
titleStr = FILE_NAME;
dateStr = datestr(now,29); 
%dmToWrite = [];
%[NUM_UP_CHIRP_SAMPLES, NUM_DOWN_CHIRP_SAMPLES, NUM_ANTENNAS] = findChirpParametersFromWaspDaqFile(FILE_NAME);
[NUM_UP_CHIRP_SAMPLES, NUM_DOWN_CHIRP_SAMPLES, NUM_ANTENNAS] = findChirpParametersFromDaqFile(FILE_NAME);

%NUM_ANTENNAS=1;
fprintf(1,'\n\nAmplitude Test\nFile: %s\n', FILE_NAME);

fid = fopen(FILE_NAME,'r');
if (fid == -1)
   error('Unable to open file');
end


numSampsInChirp = NUM_UP_CHIRP_SAMPLES + NUM_DOWN_CHIRP_SAMPLES;
numSampsPerPulse = numSampsInChirp + NUM_SAMPS_IN_HEADER;

nsampstoread = 16*220*60;
[data1,numRead] = fread(fid,[numSampsPerPulse,  nsampstoread],'int16');


%find number of doppler chirps
indxDop=find(data1(3,:) == 1,1);
indxDop2=find(data1(3,indxDop:end) == 0, 1);
NUM_DOP_CHIRPS=find(data1(3,(indxDop+indxDop2-1):end)==1,1)-1;
samplesToThrowAway = (indxDop+indxDop2-2)*numSampsPerPulse;

%read data to process
numSampsPerDopplerBlock = numSampsPerPulse*NUM_DOP_CHIRPS;
numSampsPerFrame = numSampsPerDopplerBlock * NUM_ANTENNAS;
numSampstoRead = numSampsPerFrame * FramesToRead;
status = fseek(fid, samplesToThrowAway*bytesPerSample, 'bof'); %skip incomplete frame
[data2,numRead] = fread(fid,[numSampsPerPulse,  numSampstoRead/numSampsPerPulse],'int16');
fclose(fid);


%remove last incomplete frame
t1 = NUM_SAMPS_IN_HEADER + 1;
t2 = NUM_SAMPS_IN_HEADER + NUM_UP_CHIRP_SAMPLES;
x2=size(data2,2);
Num_Frames=floor(x2/(NUM_DOP_CHIRPS*NUM_ANTENNAS));
datasize=Num_Frames*NUM_DOP_CHIRPS*NUM_ANTENNAS;
%data=reshape(data2(t1:t2,1:datasize),Num_Frames,NUM_ANTENNAS,...
%    NUM_DOP_CHIRPS,NUM_UP_CHIRP_SAMPLES);
data=reshape(data2(t1:t2,1:datasize),NUM_UP_CHIRP_SAMPLES,NUM_DOP_CHIRPS,...
    NUM_ANTENNAS,Num_Frames);
clear data2 data1;

window = chebwin(NUM_UP_CHIRP_SAMPLES,70);
windowD = chebwin(NUM_DOP_CHIRPS, 70);

%Remove mean
for i = 1:NUM_ANTENNAS
    data(:,:,i,:) = data(:,:,i,:) - mean(data(:,:,i,:),[2,3,4]);
end
%data = data - mean(data,[2,3,4]);

%do fft
Window = repmat(window,1,NUM_DOP_CHIRPS, NUM_ANTENNAS, Num_Frames);
Data2 = fft(data.*Window,FFT_SIZE);
clear Window
Data = Data2(1:(end/2+1),:,:,:);  %throwing out the symmetric part of the data
clear Data2
WindowD = repmat(windowD', size(Data,1), 1, NUM_ANTENNAS, Num_Frames);
DataDop = fftshift(fft(Data.*WindowD,[],2),2);
DatadBDop=20*log10(abs(DataDop));
clear WindowD
dopplerIndexs = (-NUM_DOP_CHIRPS/2:NUM_DOP_CHIRPS/2-1);
f_doppler = PRF*(dopplerIndexs/NUM_DOP_CHIRPS);

AntennaRangeBin = [24 24 24  20 20 21 21 21 21 22 23 24  24  25  27 28];
[maxBinsAcrossTime maxBinsAcrossTimeIdx] = max(abs(Data),[],[2 4],'linear');
maxBinInRange = 30;
[maxBinPerAnt maxBinPerAntIdx] = max(squeeze(maxBinsAcrossTime(1:maxBinInRange,:,:)), [], 1);
%% - find doppler detection threshold
dopplerDetectionThreshold =  20*log10(mean(abs(DataDop(:, :, :, [1:12 end-3:end])),4)) + 11;




%%
figure(1);clf;
rangePlot = 1;
dopplerPlot = 2;
subplot(1,2,rangePlot);
range_axis_handle = gca;
subplot(1,2,dopplerPlot);
doppler_axis_handle = gca;
axis_handle = gca;

figure(2);clf;
rd_row=4; rd_column=4;
rd_figure = gcf;

figure(3);clf
plot(max(squeeze(20*log10(abs(Data(:,1,8,:)))),[],2))

figure(4);clf;hold on
d = squeeze(20*log10(abs(Data(35,:,8,:))));
d1= reshape(d,[1, numel(d)]);
plot(d1,'b')
plot((((1:size(Data,4))-1)*NUM_DOP_CHIRPS)+1,squeeze(20*log10(abs(Data(35,1,8,:)))),'.r')
%plot(squeeze(20*log10(abs(Data(35,1,8,:)))),'b')
% plot(squeeze(20*log10(abs(Data(27,1,8,:)))),'g')
% plot(squeeze(20*log10(abs(Data(33,1,8,:)))),'r')
figure(5);clf;hold on
d = squeeze(20*log10(abs(Data(27,:,8,:))));
d1= reshape(d,[1, numel(d)]);
plot(d1,'b')
plot((((1:size(Data,4))-1)*NUM_DOP_CHIRPS)+1,squeeze(20*log10(abs(Data(27,1,8,:)))),'.r')
figure(6);clf;hold on
d = squeeze(20*log10(abs(Data(22,:,8,:))));
d1= reshape(d,[1, numel(d)]);
plot(d1,'b')
plot((((1:size(Data,4))-1)*NUM_DOP_CHIRPS)+1,squeeze(20*log10(abs(Data(22,1,8,:)))),'.r')


figure(7);clf; hold on
plot(squeeze(data(:,1,8,1:5)))

figure(8);clf;
dp_row=4; dp_column=4;
dp_figure = gcf;

figure(9);clf
for antennaNum = 1:16
    
    subplot(4,4,antennaNum)
    [maxDop, maxDopIdx] = max(DatadBDop(AntennaRangeBin(antennaNum),:,antennaNum,:),[],2);
    plot(squeeze(maxDopIdx))
    axis([-inf inf 25 45])
end

figure(10);clf;
for antennaNum = 1:16
        subplot(4,4,antennaNum)
        plot(squeeze(20*log10(abs(maxBinsAcrossTime(:,:,antennaNum)))))
        title(sprintf('Max index: %d', maxBinPerAntIdx(antennaNum))); 
end
figure(11);clf
maxPerFrame = squeeze(max(20*log10(abs(Data)),[],[1,2,3]));
plot(maxPerFrame)
title('Max Frame Return')

figure(12);clf;
rd_row=4; rd_column=4;
rd_detection_figure = gcf;
%%
figure(13);clf
antenna = 8;
rangeBin = 13;
[maxDoppler, maxDopplerIdx] = max(DatadBDop, [], 2);
subplot(2,1,1)
scatter(1:size(maxDoppler,4),squeeze(maxDopplerIdx(rangeBin,1,antenna,:)),20,squeeze(maxDoppler(rangeBin,1,antenna,:)))
subplot(2,1,2)
%scatter(1:size(maxDoppler,4),squeeze(maxDoppler(rangeBin,1,antenna,:)),20)
plot(1:size(maxDoppler,4),squeeze(maxDoppler(rangeBin,1,antenna,:)))
dopplerDetectionThreshold;
%%
for frame = 52:size(DatadBDop,4)
    if 1 %plot range-magnitude and range-DcDoppler
        [binPatches, CartesianLookupTable] = plotMatrixCells(range_axis_handle, 20*log10(abs(squeeze(Data(:,1,:,frame)))), 0);
        [maxDop, maxDopIdx] = max(DatadBDop(:,:,:,frame),[],2);
        [binPatches, CartesianLookupTable] = plotMatrixCells(doppler_axis_handle, squeeze(maxDopIdx), 0);
        %[binPatches, CartesianLookupTable] = plotMatrixCells(doppler_axis_handle, squeeze(DatadBDop(:,1,:,frame)), 0);
    end
    if 1 %plot range-doppler
        figure(rd_figure)
        for row = 1:rd_column
            for col = 1:rd_row
                antenna = (row-1)*rd_column + col;
                subplot(rd_row,rd_column, antenna)
                mph = f_doppler*lambda_mile/(2*abs(cos(BeamAnglesLeftToRight(antenna))))*3600;
                %mesh(mph,1:70,squeeze(DatadBDop(1:70,:,antenna,frame)));
                s = surf(mph,1:129,squeeze(DatadBDop(1:129,:,antenna,frame)));
                s.EdgeColor = 'none';
                grid off;
                caxis([20 100])
                %colorbar
                view(0,90)
            end
        end
        sgtitle(sprintf('Range-Doppler - Frame: %d', frame))
    end
     if 1 %plot range-doppler detection
        figure(rd_detection_figure)
        for row = 1:rd_column
            for col = 1:rd_row
                antenna = (row-1)*rd_column + col;
                subplot(rd_row,rd_column, antenna)
                mph = f_doppler*lambda_mile/(2*abs(cos(BeamAnglesLeftToRight(antenna))))*3600;
                
                dopplerDetection = DatadBDop(:,:,antenna,frame);
                [lessThanThresh]= find(dopplerDetection<dopplerDetectionThreshold(:,:,antenna));
                dopplerDetection - dopplerDetection - dopplerDetectionThreshold(:,:,antenna);
                dopplerDetection(lessThanThresh) = 0;
                s = surf(mph,1:70,dopplerDetection(1:70,:));
                s.EdgeColor = 'none';
                grid off;
                caxis([0 80])
                %colorbar
                view(0,90)
            end
        end
        sgtitle(sprintf('Range-Doppler Detection - Frame: %d', frame))
    end
    
    if 1 %plot doppler
    figure(dp_figure)
        for row = 1:dp_row
            for col = 1:dp_column
                antennaNum = (row-1)*dp_column + col;
                subplot(dp_row,dp_column, antennaNum)
                plot(squeeze(DatadBDop(AntennaRangeBin(antennaNum),:,antennaNum,frame)))
                axis([-inf inf 40 100])
            end
        end
        
    end
    sgtitle(sprintf('Frame %d; Doppler Pulse %d', frame, frame*NUM_DOP_CHIRPS))
    drawnow
end


 
