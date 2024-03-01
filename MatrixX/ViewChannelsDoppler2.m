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
% FILE_NAME =  'C:\Data\Rail\RubyRiver6-12-19-32pt-2.daq';
% FILE_NAME =  'C:\Data\Rail\2022-06-01\FrontRunner_900W_1147_Doppler.daq';
%FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\2019-06-12  - Doppler\RubyRiver6-12-19-64pt-2.daq';
FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\2022-06-02\Provo_900W_Doppler_uptrack_20220602_143032.daq'; %Train coming in
%FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\2022-06-02\Provo_900W_Doppler_uptrack_20220602_155133.daq'; %Train going out
FILE_NAME =  'C:\Data\Data_20220616_103903.daq'; %
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
% indxDop=find(data1(3,:) == 1,1);
% indxDop2=find(data1(3,indxDop:end) == 0, 1);
% NUM_DOP_CHIRPS=find(data1(3,(indxDop+indxDop2-1):end)==1,1)-1;
% samplesToThrowAway = (indxDop+indxDop2-2)*numSampsPerPulse;

indxFirstZero=find(data1(3,:) == 0,1);
if indxFirstZero == 1 % first sample may not be the start of a full doppler frame look for next 0 index
    indxOneAfterFirstZero=indxFirstZero + find(data1(3,indxFirstZero:end) == 1,1)-1;
    indxFirstZero=indxOneAfterFirstZero + find(data1(3,indxOneAfterFirstZero:end) == 0, 1) -1;
end
indxOne = indxFirstZero + find(data1(3,indxFirstZero:end) == 1, 1) -1;
NUM_DOP_CHIRPS = indxOne -indxFirstZero;
samplesToThrowAway = (indxFirstZero - 1) * numSampsPerPulse;
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
DataNonCoherentAverage = 20*log10(mean(abs(Data),2));
clear Data2
%%

DataDoppler = fftshift(fft(Data.*windowDoppler,[],2),2);
DatadBDoppler=20*log10(abs(DataDoppler));
[MaxDop, MaxDopIdx] = max(DatadBDoppler,[],2);
MaxDop=squeeze(MaxDop);
MaxDopIdx=squeeze(MaxDopIdx);
dopplerIndexs = (-NUM_DOP_CHIRPS/2:NUM_DOP_CHIRPS/2-1);
f_doppler = PRF*(dopplerIndexs/NUM_DOP_CHIRPS);

AntennaRangeBin = [24 24 24  20 20 21 21 21 21 22 23 24  24  25  27 28];
[maxBinsAcrossTime, maxBinsAcrossTimeIdx] = max(abs(Data),[],[2 4],'linear');
maxBinInRange = 30;
[maxBinPerAnt, maxBinPerAntIdx] = max(squeeze(maxBinsAcrossTime(1:maxBinInRange,:,:)), [], 1);

velocity_mpersec = (MaxDopIdx - NUM_DOP_CHIRPS/2 - 1)./(NUM_DOP_CHIRPS/2) *lambda_m/(4*PRT);
velocity_miles_per_hour = velocity_mpersec * 2.23694;


%% - find doppler detection threshold
%dopplerDetectionThreshold =  20*log10(mean(abs(DataDoppler(:, :, :, [1:12 end-3:end])),[3, 4])) + 10^(9/10);
dopplerDetectionThreshold2 =  20*log10(median(abs(DataDoppler(:,:,:,1:50)), 4)) + 10^(10/10);


floordB=zeros(129,16);
DetectDop=0*MaxDop;
for frame = 2:size(DatadBDoppler,4)
    xtemp=squeeze(DatadBDoppler(:,:,:,frame));
    ytemp=squeeze(max((xtemp-dopplerDetectionThreshold2),[],2));  
    DetectDop(:,:,frame)=max(ytemp, floordB);  
end

DetectDopB = DetectDop > 0;

%% Background - Doppler

NumAntennas = size(DatadBDoppler,3);
NumRangeBins = size(DatadBDoppler,1);
NumDopplerBins = size(DatadBDoppler,2);
NumHistogramBins = 60;
histogramBinEdgesMin = 30;
histogramBinEdgesMax = 90;
histogramBinEdges = linspace(histogramBinEdgesMin, histogramBinEdgesMax, NumHistogramBins+1);
histogramBinCenters = (histogramBinEdges(2:end) + histogramBinEdges(1:(end-1)))/2;
backgroundHistogramDoppler = zeros(NumHistogramBins,NumDopplerBins,NumRangeBins,NumAntennas);
% Make histograms
for frame = 1:70
    frame
    for antennaNum = 1:NumAntennas
        for rangeBin = 1:NumRangeBins
            for dopplerBin = 1:NumDopplerBins
                [temp, edges] = histcounts(squeeze(DatadBDoppler(rangeBin,dopplerBin,antennaNum,frame)), histogramBinEdges);
                backgroundHistogramDoppler(:,dopplerBin,rangeBin,antennaNum)  = backgroundHistogramDoppler(:,dopplerBin,rangeBin,antennaNum) + temp.';
            end
        end
    end
end

%find background (max)
[mxVal, maxInd] = max(backgroundHistogramDoppler,[], 1);
backgroundValues = histogramBinCenters(squeeze(maxInd));
%% plot background
figure(106);clf
rows = 4;
cols = 4;
for row = 1:rows
    for col = 1:cols
        subplotNum = (row-1)*4 + col;
        antNum = subplotNum;
        subplot(rows,cols,subplotNum)
        plot(squeeze(backgroundValues(:,:,antNum)).')
        grid on
    end
end
figure(107);clf
rows = 4;
cols = 4;
for row = 1:rows
    for col = 1:cols
        subplotNum = (row-1)*4 + col;
        antNum = subplotNum;
        subplot(rows,cols,subplotNum)
        mesh(squeeze(backgroundValues(:,:,antNum)))
        view(-10,50)
    end
end
sgtitle('Range vs. Doppler vs. Background Level') 


%%
figure(111);clf;
colorbar
range_axis_handle = gca;
for frame = 1:10:size(DatadBDoppler,4)
    figure(111)
    %[binPatches, CartesianLookupTable] = plotMatrixCells(range_axis_handle,MaxDop(:,:,frame),0);
    %[binPatches, CartesianLookupTable] = plotMatrixCells(range_axis_handle,DetectDop(:,:,frame),0);
    [binPatches, CartesianLookupTable] = plotMatrixCells(range_axis_handle,DetectDopB(:,:,frame).*velocity_miles_per_hour(:,:,frame),0);
    %[binPatches, CartesianLookupTable] = plotMatrixCells(range_axis_handle,DetectDopB(:,:,frame).*DataNonCoherentAverage(:,:,frame),0);
    title(sprintf('Frame %d', frame))
    
    figure(112);clf
    %frameToPlot = 441;
    antToPlot = 2;
    dopChirpsToPlot = 1:32;
    plot(20*log10(abs(Data(:,dopChirpsToPlot,antToPlot,frame))))
    title(sprintf("FFT Magnitude. Frame %d, Antenna %d, Range Bin Min %d, Range Bin Max ", frameToPlot, antToPlot, min(dopChirpsToPlot), max(dopChirpsToPlot)))
    axis([-inf inf 10 100])
    
    figure(113); clf;
    rangeBinsToPlot = 1:129;
    plot(squeeze(DatadBDoppler(rangeBinsToPlot,dopChirpsToPlot,antToPlot,frame)).')
    title(sprintf("Doppler FFT Magnitude. Frame %d, Antenna %d, Range Bin Min %d, Range Bin Max %d", frame, antToPlot, min(rangeBinsToPlot), max(rangeBinsToPlot)))

    if 0
        figure(114); clf;
        plot(data(:,dopChirpsToPlot,antToPlot,frame))
        title(sprintf("Time Data. Frame %d, Antenna %d, Range Bin Min %d, Range Bin Max ", frame, antToPlot, min(dopChirpsToPlot), max(dopChirpsToPlot)))
    end

    drawnow
    pause(0.1);
    
end
 
%%
figure(112);clf
frameToPlot = 441;
antToPlot = 4;
dopChirpsToPlot = 1:32;
plot(20*log10(abs(Data(:,dopChirpsToPlot,antToPlot,frameToPlot))))
title(sprintf("FFT Magnitude. Frame %d, Antenna %d, Range Bin Min %d, Range Bin Max ", frameToPlot, antToPlot, min(dopChirpsToPlot), max(dopChirpsToPlot)))
axis([-inf inf 10 80])

%%
figure(115);clf
antToPlot = 2;
rangeBinToPlot = 90;
mesh(squeeze(DatadBDoppler(rangeBinToPlot, :, antToPlot,:)))
title(sprintf("Doppler vs Time. Antenna %d, Range Bin %d,x ", antToPlot, rangeBinToPlot))
view(0,90)