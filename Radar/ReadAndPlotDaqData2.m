clear;  % ReadDAQData
SAMPLE_RATE = 1e6;
NUM_HEADER_SAMPLES = 3;
FFT_SIZE = 256;
NUM_SAMPLES_PER_VEL_EST_FFT = 256;
VEL_EST_FFT_SIZE = 256;
DIST_BETWEEN_ANTS = 34.32765e-6; %in miles
HOURS_PER_PULSE	= 277.7778e-9;

%FILE_NAME = 'C:\Data\2019-11-12 - Havana and Smith Denver\HDTrain1-57mph_right.daq';
%FILE_NAME = 'C:\Data\2019-11-12 - Havana and Smith Denver\HD-NoTrain_pointing away.daq';
%FILE_NAME = 'C:\Data\2019-11-12 - Havana and Smith Denver\Matrix1.daq';
%FILE_NAME = "C:\Data\AntennaSwitchingTest\RegularSwitching2.daq";
%FILE_NAME = "C:\Data\AntennaSwitchingTest\RegularSwitching_fingerOnTop.daq";
FILE_NAME = "C:\Data\AntennaSwitchingTest\Antenna7Only.daq";

[NUM_UP_CHIRP_SAMPLES, NUM_DOWN_CHIRP_SAMPLES, NUM_ANTENNAS] = findChirpParametersFromDaqFile(FILE_NAME);
NUM_SAMPLES_PER_PERIOD = NUM_UP_CHIRP_SAMPLES + NUM_DOWN_CHIRP_SAMPLES + NUM_HEADER_SAMPLES;
fid = fopen(FILE_NAME,'r');
if (fid == -1)
   error('Unable to open file');
end

%== Read in the data
%[data,numRead] = fread(fid,inf,'int16');
[data,numRead] = fread(fid,50050000,'int16');  % 15015000 is 15 s 30030000 is 30 s  45045000 is 45 s 50050000 is 50s
fclose(fid)
%data = data/(2^15);
numReshapedChirps = floor(floor(size(data,1)/NUM_SAMPLES_PER_PERIOD)/NUM_ANTENNAS)*NUM_ANTENNAS; %limit to even number of full chirps
numReshapedSamples = numReshapedChirps * NUM_SAMPLES_PER_PERIOD;
temp = reshape(data(1:numReshapedSamples), NUM_SAMPLES_PER_PERIOD, []);
dataMatrix = reshape(temp((NUM_HEADER_SAMPLES+1):(NUM_UP_CHIRP_SAMPLES+NUM_HEADER_SAMPLES),1:end), NUM_UP_CHIRP_SAMPLES, NUM_ANTENNAS, numReshapedChirps/NUM_ANTENNAS );
numFrames = size(dataMatrix,3);

chebWinSideLobes = 80;
WindowMatrix = repmat(myDolphCheb(NUM_UP_CHIRP_SAMPLES,chebWinSideLobes), 1, NUM_ANTENNAS, numFrames);
DataMatrix = fft(WindowMatrix.*dataMatrix,FFT_SIZE);
DataMatrix = DataMatrix(1:(FFT_SIZE/2+1),:,:);

if NUM_ANTENNAS == 2
    ant1 = 1;
    ant2 = 2;
elseif NUM_ANTENNAS == 16
    ant1 = 7;
    ant2 = 8;
else
    ant1 = 1;
    ant2 = 2;
end

%find index for train
maxFft = max(abs(squeeze(DataMatrix(:,ant1,:))),[],2);
startBin = 5;
endBin = 60;
[mx, maxFftBin] = max(maxFft(startBin:endBin));
maxFftBin = maxFftBin + startBin - 1;


% %% calculate speed
% pulseStart = 1;
% %pulseStop = 50000;
% pulseStop = size(dataMatrix,3)
% speedFftSize = 512;
% speedCalcPulses = 256;
% idxs = pulseStart:speedCalcPulses:(pulseStop-speedFftSize);
% speedCor = zeros(speedFftSize, length(idxs));
% a=0;  
% corSecondPeakThresh = .90;
% for i = idxs
%     a = a+1;
%     speedCor(:,a)= speedCorrelation(DataMatrix(maxFftBin, 1, i:(i+speedFftSize-1)), DataMatrix(maxFftBin, 2, i:(i+speedFftSize-1)),0);
%     %find largest two peaks
%     p1 = 0;
%     p1idx = 0;
%     p2 = 0;
%     p2idx = 0;
%     for j = 2:(speedFftSize-1)
%         if (abs(speedCor(j-1,a)) < abs(speedCor(j,a))) && (abs(speedCor(j,a)) > abs(speedCor(j+1,a)))
%             %peak found
%             if abs(speedCor(j,a)) > p1
%                 p2 = p1;
%                 p2idx = p1idx;
%                 p1 = abs(speedCor(j,a));
%                 p1idx = j;
%             elseif abs(speedCor(j,a)) > p2
%                 p2 = abs(speedCor(j,a));
%                 p2idx = j;
%             end
%         end
%     end
%     corMaxMy1(a) = p1;
%     corMaxMy2(a) = p2;
%     if p2 < (corSecondPeakThresh*p1)
%         corMaxIdxMy(a) = p1idx;
%     else
%         corMaxIdxMy(a) = nan;
%     end
% end
% 
% [corMax, corMaxIdx] = max(abs(speedCor),[],1);
% DIST_BETWEEN_ANTS =(83.32855682e-6); %miles
% %hoursPerPrimaryPulse = 555.556e-9; %hours
% hoursPerPrimaryPulse = (279e-6)*2/3600; %hours
% for i = 1:length(corMaxIdxMy)
%     if corMaxIdxMy(i) < speedFftSize/2
%         speed(i) = DIST_BETWEEN_ANTS / ((corMaxIdxMy(i) +0.5) *hoursPerPrimaryPulse);
%     else
%         speed(i) = DIST_BETWEEN_ANTS / ((corMaxIdxMy(i)-speedFftSize +0.5) *hoursPerPrimaryPulse);
%     end
% end


%%
figure(1)
clf; hold on
% for i = 1:16
%     plot(squeeze(dataMatrix(:,i,1:100:end))+i*300)
% end

plot(squeeze(dataMatrix(:,1,1:100:550))+0)
% plot(squeeze(dataMatrix(:,8,1:100:550))+400)
% plot(squeeze(dataMatrix(:,16,1:100:550))+800)



figure(2)
clf
plot(20*log10(maxFft))


figure(3)
clf
hold on
plot(pulseStart:pulseStop, 20*log10(abs(squeeze(DataMatrix(maxFftBin,ant1,pulseStart:pulseStop)))), 'b')
plot(pulseStart:pulseStop, 20*log10(abs(squeeze(DataMatrix(maxFftBin,ant2,pulseStart:pulseStop)))),'g')
title(sprintf('Magnitude Response - Bin %d', maxFftBin))
xlabel('Pulses')
legend('Ch 1', 'Ch 2')

figure(4)
clf
hold on
bin = 10;
plot(pulseStart:pulseStop, 20*log10(abs(squeeze(DataMatrix(bin,ant1,pulseStart:pulseStop)))), 'b')
plot(pulseStart:pulseStop, 20*log10(abs(squeeze(DataMatrix(bin,ant2,pulseStart:pulseStop)))),'g')
title(sprintf('Magnitude Response - Bin %d', bin))
xlabel('Pulses')
legend('Ch 1', 'Ch 2')






figure(5)
clf
%plot(corMaxIdx,'b')
hold on
plot(corMaxIdxMy,'g')

figure(6)
clf
hold on
plot(corMaxMy1, 'b')
plot(corMaxMy2, 'g')
plot(corMaxMy1.*corSecondPeakThresh, 'c')

temp = find(isnan(corMaxIdxMy));
%plot(temp, (corMaxMy1(temp)+corMaxMy2(temp))/2,'r.')
plot(temp, corMaxMy2(temp),'r.')

figure(7)
plot(speed)
title('Speed')
ylabel('MPH')
axis([-inf inf -30 30])

figure(8);clf;
plot(abs(speedCor(:,5)))

figure(9);clf; hold on;
m = max(max(abs(DataMatrix(10:end,ant1,:))));
imagesc(20*log10(squeeze(abs(DataMatrix(:,ant1,:)))))
caxis([20*log10(m)-60 20*log10(m)])
colorbar
title(sprintf('Magntitude - Antenna %d', ant1))
