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
c=3e8;
f=24.125e9;
lambda_m = c/f;
lambda_ft = lambda_m*3.28084;
lambda_mile = lambda_ft/5280;
B = 240e6;

%Enter the file name to be fixed here.  The new fixed file will
% have "_fixed" appended to it. 
% FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\2022-06-01\FrontRunner_900W_1147_Doppler.daq';
% FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\2022-06-01\FrontRunner_900W_2022_06_01_1110.daq';
FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\2022-06-02\Provo_900W_Doppler_20220602_121227.daq';
%FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\2022-06-02\Provo_900W_no_doppler_1247.daq';

%%

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
upChirpTime = NUM_UP_CHIRP_SAMPLES/SAMPLES_PER_SEC;
PRT = numSampsInChirp/SAMPLES_PER_SEC; %pulse repitition time
PRF = 1/PRT; %pulse repitition frequency
f_dot = B/upChirpTime;
f = SAMPLES_PER_SEC*(0:(FFT_SIZE/2))/FFT_SIZE;
r_meters = f*c/(f_dot*2);
r_feet = r_meters.*3.28084;


nsampstoread = numSampsPerPulse * NUM_ANTENNAS * 60 ;
[data1,numRead] = fread(fid,[numSampsPerPulse,  nsampstoread],'int16');


%find number of doppler chirps
indxDop=find(data1(3,:) == 1,1);
indxDop2=find(data1(3,indxDop:end) == 0, 1);
NUM_DOP_CHIRPS=find(data1(3,(indxDop+indxDop2-1):end)==1,1)-1;
samplesToThrowAway = (indxDop+indxDop2-2)*numSampsPerPulse;

indxZero=find(data1(3,:) == 0,1);
if indxZero == 1 % first sample may not be the start of a full doppler frame look for next 0 index
    indxOneAfterZero=find(data1(3,:) == 1,1);
    indxZeroAfer1=find(data1(3,indxOneAfterZero:end) == 0, 1);
    indxZero = indxZeroAfer1;
end
indxOne = find(data1(3,indxZero:end) == 1, 1);
NUM_DOP_CHIRPS = indxOne -1;
samplesToThrowAway = (indxZero - 1) * numSampsPerPulse;
clear data1


%read data to process
numSampsPerDopplerBlock = numSampsPerPulse*NUM_DOP_CHIRPS;
numSampsPerFrame = numSampsPerDopplerBlock * NUM_ANTENNAS;
numSampstoRead = numSampsPerFrame * FramesToRead;
status = fseek(fid, 0, 'eof'); %find end of file
samples_total = ftell(fid)/bytesPerSample;
framesToRead = floor((samples_total - samplesToThrowAway)/numSampsPerFrame);%remove last incomplete frame
samplesToRead = framesToRead*numSampsPerFrame;
status = fseek(fid, samplesToThrowAway*bytesPerSample, 'bof'); %skip incomplete frame
[data2,numRead] = fread(fid,[numSampsPerPulse,  samplesToRead/numSampsPerPulse],'int16');
fclose(fid);
Num_Frames = framesToRead;

%remove last incomplete frame
t1 = NUM_SAMPS_IN_HEADER + 1;
t2 = NUM_SAMPS_IN_HEADER + NUM_UP_CHIRP_SAMPLES;
data=reshape(data2(t1:t2,:), NUM_UP_CHIRP_SAMPLES, NUM_DOP_CHIRPS, NUM_ANTENNAS, Num_Frames);
clear data2

windowRange = chebwin(NUM_UP_CHIRP_SAMPLES,70);
windowDoppler = chebwin(NUM_DOP_CHIRPS, 70).';

%Remove mean
for i = 1:NUM_ANTENNAS
    data(:,:,i,:) = data(:,:,i,:) - mean(data(:,:,i,:),[2,3,4]);
end
%data = data - mean(data,[2,3,4]);

%do fft

Data2 = fft(data.*windowRange,FFT_SIZE);

Data = Data2(1:(end/2+1),:,:,:);  %throwing out the symmetric part of the data
clear Data2

DataDoppler = fftshift(fft(Data.*windowDoppler,[],2),2);
DatadBDoppler=20*log10(abs(DataDoppler));

dopplerIndexs = (-NUM_DOP_CHIRPS/2:NUM_DOP_CHIRPS/2-1);
f_doppler = PRF*(dopplerIndexs/NUM_DOP_CHIRPS);

AntennaRangeBin = [24 24 24  20 20 21 21 21 21 22 23 24  24  25  27 28];
[maxBinsAcrossTime maxBinsAcrossTimeIdx] = max(abs(Data),[],[2 4],'linear');
maxBinInRange = 30;
[maxBinPerAnt maxBinPerAntIdx] = max(squeeze(maxBinsAcrossTime(1:maxBinInRange,:,:)), [], 1);
%% - find doppler detection threshold
dopplerDetectionThreshold =  20*log10(mean(abs(DataDoppler(:, :, :, [1:12 end-3:end])),[3, 4])) + 10^(9/10);





figure(1);clf;
rangePlot = 1;
dopplerPlot = 2;
subplot(1,2,rangePlot);
range_axis_handle = gca;
subplot(1,2,dopplerPlot);
doppler_axis_handle = gca;
axis_handle = gca;

%%
antNum = 9;
trainBin = 32;
dopplerBin = 1;

figure(2);clf
maxPerFrame = squeeze(max(20*log10(abs(Data)),[],[1,2,3]));
plot(maxPerFrame.')
title('Max Frame Return')
legend


figure(3);clf
maxAcrossTime = max(squeeze(20*log10(abs(Data(:,:,antNum,:)))),[],[2,3,4])
plot(maxAcrossTime)
title(sprintf('Max across time. Antenna %d', antNum))

figure(4);clf;hold on
plot(squeeze(20*log10(abs(Data(trainBin,dopplerBin,antNum,:)))))
title(sprintf('FFT Magnitude. Antenna %d, Range Bin %d, Doppler Bin %d', antNum, trainBin, dopplerBin))

figure(5);clf;hold on
d = squeeze(20*log10(abs(Data(trainBin,:,antNum,:))));
d1= reshape(d,[1, numel(d)]);
plot(d1,'b')
%plot((((1:size(Data,4))-1)*NUM_DOP_CHIRPS)+1,squeeze(20*log10(abs(Data(trainBin,1,antNum,:)))),'.r')
title(sprintf(['FFT Magnitude.  Antenna %d, Bin %d , All Doppler Bins. '], antNum, trainBin))

%%
for frame = 1:size(DatadBDoppler,4)
    if 1 %plot range-magnitude and range-DcDoppler
        [binPatches, CartesianLookupTable] = plotMatrixCells(range_axis_handle, 20*log10(abs(squeeze(Data(:,1,:,frame)))), 0);
        [maxDop, maxDopIdx] = max(DatadBDoppler(:,:,:,frame),[],2);
        [binPatches, CartesianLookupTable] = plotMatrixCells(doppler_axis_handle, squeeze(maxDop), 0);
        colorbar
        %[binPatches, CartesianLookupTable] = plotMatrixCells(doppler_axis_handle, squeeze(DatadBDop(:,1,:,frame)), 0);
    end
    if 0 %plot range-doppler
        figure(rd_figure)
        for row = 1:rd_column
            for col = 1:rd_row
                antenna = (row-1)*rd_column + col;
                subplot(rd_row,rd_column, antenna)
                mph = f_doppler*lambda_mile/(2*abs(cos(BeamAnglesLeftToRight(antenna))))*3600;
                %mesh(mph,1:70,squeeze(DatadBDop(1:70,:,antenna,frame)));
                s = surf(mph,1:70,squeeze(DatadBDoppler(1:70,:,antenna,frame)));
                s.EdgeColor = 'none';
                grid off;
                caxis([20 100])
                %colorbar
                view(0,90)
            end
        end
        sgtitle(sprintf('Range-Doppler - Frame: %d', frame))
    end
    if 0 %plot doppler
    figure(dp_figure)
        for row = 1:dp_row
            for col = 1:dp_column
                antennaNum = (row-1)*dp_column + col;
                subplot(dp_row,dp_column, antennaNum)
                plot(squeeze(DatadBDoppler(AntennaRangeBin(antennaNum),:,antennaNum,frame)))
                axis([-inf inf 40 100])
            end
        end
        
    end
    sgtitle(sprintf('Frame %d; Doppler Pulse %d', frame, frame*NUM_DOP_CHIRPS))
    drawnow
end
%%


 
