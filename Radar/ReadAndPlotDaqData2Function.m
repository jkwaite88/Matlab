function z = ReadAndPlotDaqData2Function(FILE_NAME)
% clear;  % ReadDAQData
SAMPLE_RATE = 1e6;
NUM_HEADER_SAMPLES = 3;
FFT_SIZE = 256;
NUM_SAMPLES_PER_VEL_EST_FFT = 256;
VEL_EST_FFT_SIZE = 256;
DIST_BETWEEN_ANTS = 34.32765e-6; %in miles
HOURS_PER_PULSE	= 277.7778e-9;



%FILE_NAME = 'C:\Data\24GHzIts\2004_10_08\TwelfthNorth1546G10PRF2K.daq';
%FILE_NAME = 'C:\Users\jwaite\Wavetronix LLC\Rail Division - Data\2018-06-20\ProvoFR_2018-06-20-15-14.daq';
[NUM_UP_CHIRP_SAMPLES, NUM_DOWN_CHIRP_SAMPLES, NUM_ANTENNAS] = findChirpParametersFromDaqFile(FILE_NAME);
NUM_SAMPLES_PER_PERIOD = NUM_UP_CHIRP_SAMPLES + NUM_DOWN_CHIRP_SAMPLES + NUM_HEADER_SAMPLES;
fid = fopen(FILE_NAME,'r');
if (fid == -1)
   error('Unable to open file');
end

%== Read in the data
%[data,numRead] = fread(fid,inf,'int16');
[data,numRead] = fread(fid,50050000,'int16');  % 15015000 is 15 s 30030000 is 30 s  45045000 is 45 s 50050000 is 50s
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
z.dataMatrix = dataMatrix;
z.DataMatrix = DataMatrix;

%find index for train
maxFft = max(abs(squeeze(DataMatrix(:,1,:))),[],2);
starBin = 5;
[mx, maxFftBin] = max(maxFft(starBin:end));
maxFftBin = maxFftBin + starBin - 1;

%% calculate speed
pulseStart = 1;
pulseStop = size(DataMatrix,3);
speedFftSize = 512;
speedCalcPulses = 512;
idxs = pulseStart:speedCalcPulses:(pulseStop-speedFftSize);
speedCor = zeros(speedFftSize, length(idxs));
a=0;  
corSecondPeakThresh = .90;
for i = idxs
    a = a+1;
    speedCor(:,a)= speedCorrelation(DataMatrix(maxFftBin, 1, i:(i+speedFftSize-1)), DataMatrix(maxFftBin, 2, i:(i+speedFftSize-1)));
    %find largest two peaks
    p1 = 0;
    p1idx = 0;
    p2 = 0;
    p2idx = 0;
    for j = 2:(speedFftSize-1)
        if (abs(speedCor(j-1,a)) < abs(speedCor(j,a))) && (abs(speedCor(j,a)) > abs(speedCor(j+1,a)))
            %peak found
            if abs(speedCor(j,a)) > p1
                p2 = p1;
                p2idx = p1idx;
                p1 = abs(speedCor(j,a));
                p1idx = j;
            elseif abs(speedCor(j,a)) > p2
                p2 = abs(speedCor(j,a));
                p2idx = j;
            end
        end
    end
    corMaxMy1(a) = p1;
    corMaxMy2(a) = p2;
    if p2 < (corSecondPeakThresh*p1)
        corMaxIdxMy(a) = p1idx;
    else
        corMaxIdxMy(a) = nan;
    end
end
z.speedCor = speedCor;
z.corMax1 = corMaxMy1;
z.corMax2 = corMaxMy2;
z.corMaxIdx = corMaxIdxMy;

[corMax, corMaxIdx] = max(abs(speedCor),[],1);
DIST_BETWEEN_ANTS =(83.32855682e-6); %miles
%hoursPerPrimaryPulse = 555.556e-9; %hours
hoursPerPrimaryPulse = (279e-6)*2/3600; %hours
for i = 1:length(corMaxIdxMy)
    if corMaxIdxMy(i) < speedFftSize/2
        speed(i) = DIST_BETWEEN_ANTS / ((corMaxIdxMy(i) +0.5) *hoursPerPrimaryPulse);
    else
        speed(i) = DIST_BETWEEN_ANTS / ((corMaxIdxMy(i)-speedFftSize +0.5) *hoursPerPrimaryPulse);
    end
end
z.speed = speed;

%%
% figure(1)
% clf
% plot(squeeze(dataMatrix(:,1,1:100)))
% 
% figure(2)
% clf
% plot(20*log10(maxFft))
% 
% figure(3)
% clf
% hold on
% plot(pulseStart:pulseStop, 20*log10(abs(squeeze(DataMatrix(maxFftBin,1,pulseStart:pulseStop)))), 'b')
% plot(pulseStart:pulseStop, 20*log10(abs(squeeze(DataMatrix(maxFftBin,2,pulseStart:pulseStop)))),'g')
% title('Magnitude Response')
% xlabel('Pulses')
% legend('Ch 1', 'Ch 2')
% 
% 
% 
% 
% 
% 
% 
% figure(5)
% clf
% %plot(corMaxIdx,'b')
% hold on
% plot(corMaxIdxMy,'g')
% 
% figure(6)
% clf
% hold on
% plot(corMaxMy1, 'b')
% plot(corMaxMy2, 'g')
% plot(corMaxMy1.*corSecondPeakThresh, 'c')
% 
% temp = find(isnan(corMaxIdxMy));
% %plot(temp, (corMaxMy1(temp)+corMaxMy2(temp))/2,'r.')
% plot(temp, corMaxMy2(temp),'r.')
% 
% figure(7)
% plot(speed)
% title('Speed')
% ylabel('MPH')
% axis([-inf inf -30 30])
% 
% figure(8);clf;
% plot(abs(speedCor(:,32)))