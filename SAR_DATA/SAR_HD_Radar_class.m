clear all;  % ReadDAQData
HD=0;
SAMPLE_RATE = 1e6;
FFT_SIZE = 256;
PRI=2*279e-6; % seconds
FFT_SIZE_SAR = 16384; %2048; 8192
HoursPerPrimaryPulse = PRI/3600;
NUM_SAMPLES_PER_FFT = 255;
NUM_SAMPLES_IN_HDR = 3;
BEAM_WIDTH_D = 8;
if HD ==1
    NUM_DOWN_CHIRP_SAMPLES = 26;%23%25
else
    NUM_DOWN_CHIRP_SAMPLES = 24;
end

PULSES_PER_SECOND_ON_SAME_CHANNEL = (SAMPLE_RATE /(2*(NUM_SAMPLES_PER_FFT + NUM_DOWN_CHIRP_SAMPLES))); 
NUM_SAMPLES_PER_PERIOD = NUM_SAMPLES_PER_FFT+NUM_SAMPLES_IN_HDR+NUM_DOWN_CHIRP_SAMPLES;
AntennaWidthDegrees = 13.5;
HalfAntennaWidth = AntennaWidthDegrees/2;
AntennaWidth_Radians=AntennaWidthDegrees*3.1415926/180;  %6.5
HalfAntennaWidth_Radians=AntennaWidth_Radians/2;
NUM_SAMPLES_PER_VEL_EST_FFT = 512;%originally 256
VEL_EST_FFT_SIZE = 512;%originally 256
HoursPerPrimaryPulse = 2*279e-6/3600;
PrimarySamplesPerSecond=1/(2*279e-6);
HOURS_PER_PULSE	= 277.7778e-9;
Mph2mps=5280*0.12*2.54/3600;
Lambda=3e8/24.125e9;
MAX_NUM_EVENTS = 50;
MIN_DURATION = 250;
MIN_DURATION_F = 135;
NUM_PULSES_FOR_EVENT = 100;
FT_PER_RANGE_BIN = 2;
MPH_TO_FPS = 5280/3600;
FT_TO_M=12*2.54/100;
M_PER_RANGE_BIN = FT_PER_RANGE_BIN * FT_TO_M;
wmg=2*3.1415926*24.125e9;%
KN=wmg/3e8; %2pi/lambda
Rad2Deg=180/3.1415926;

%FILE_NAME = 'c:\Data\HD\SAR\train1-30mph.daq';xcvr=1;
FILE_NAME = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Documents\Matlab\SAR_DATA\EB-Cows-30mph.daq';xcvr=1;
%FILE_NAME = 'c:\Data\HD\SAR\SB-Cows-30mph.daq';xcvr=1;
startBin=1;
endBin=FFT_SIZE/2;

fid = fopen(FILE_NAME,'r');
if (fid == -1)
   error('Unable to open file');
end


%==========================================================================
% Data file has the following format:
% <header><Ch1Data><header><Ch2Data><header><Ch1Data>...
%
%   Where the header is:
%     header(1) = 0x7FFF
%     header(2) = 0x8000
%     header(3) = 0x0000 (zero-based Channel Number)
%
%   And the 16-bit signed data is: <channel 1 up chirp & down chirp>
%                                       OR
%                                  <channel 2 up chirp & down chirp>
%
%   Note: the data may end on channel 1, which means that there is more 
%         channel 1 data than for channel 2.  In other words,
%         the final pair of pulses may not be complete.
%==========================================================================

%== Read in the data
%[data,numRead] = fread(fid,inf,'int16');

% 15015000 is 15 s 30030000 is 30 s  45045000 is 45 s 50050000 is 50s
numSeconds = 30;

%QUESTION: why isn't this 1000000? 
%ANSWER: because EACH CHIRP has a header...
numSamplesPerSecond = 1010753;  
% [data,numRead] = fread(fid,numSeconds*numSamplesPerSecond ,'int16');  
% [data,numRead] = fread(fid,numSeconds*numSamplesPerSecond ,'int16');  
% [data,numRead] = fread(fid,numSeconds*numSamplesPerSecond ,'int16');  
[data,numRead] = fread(fid,numSeconds*numSamplesPerSecond ,'int16');  
%[data,numRead] = fread(fid,'int16');  
%data = data/(2^15); %normalize 16-bit data (15 bits of magnitude, 1 bit for sign)

%get number of complete sample periods
numReshapedSamples = floor(max(size(data))/NUM_SAMPLES_PER_PERIOD) * NUM_SAMPLES_PER_PERIOD;  %number of complete pulses

%reshape the data such that all the samples from a given sample period are in the
%same COLUMN: leave out the last samples that do not make a complete sample period
dataMatrix = reshape(data(1:numReshapedSamples), NUM_SAMPLES_PER_PERIOD, []); %shape data into matirx

clear data; %memory management: clear out file data

%get the number of sample periods (pulses) in the data set
numPulses = size(dataMatrix,2);

%==========================================================================
% For Channel 1 and Channel 2:
% 1. Create a Chebychev window
% 2. apply the window to the time data by multiplying data by the window
% 3. take the FFT of the resulting windowed time data
%==========================================================================
% channel1 data comes first, so there may be one more channel 1 piece of data
% that channel 2 data
%==========================================================================

%create cheb window data (in a column) and replicate it across columns
%WindowMatrix = repmat(blackman(NUM_SAMPLES_PER_FFT),1,ceil(numPulses/2));
WindowMatrix = repmat(chebwin(NUM_SAMPLES_PER_FFT,70),1,ceil(numPulses/2));

%data is interleaved channel1, channel2, ...
DataMatrixCh1_FFT_raw = fft(WindowMatrix.*dataMatrix(NUM_SAMPLES_IN_HDR+1:...
    NUM_SAMPLES_PER_FFT+NUM_SAMPLES_IN_HDR,1:2:end),FFT_SIZE);    %FFT of windowed channel 1 data, after header
%DataMatrixCh1_FFT_raw = DataMatrixCh1_FFT_raw .* conj(DataMatrixCh1_FFT_raw);
%create cheb window data (in a column) and replicate it across columns
% WindowMatrix = repmat(blackman(NUM_SAMPLES_PER_FFT),1,floor(numPulses/2));   %why floor?
WindowMatrix = repmat(chebwin(NUM_SAMPLES_PER_FFT,70),1,floor(numPulses/2));   %why floor?
%data is interleaved channel1, channel2, ...
DataMatrixCh2_FFT_raw = fft(WindowMatrix.*dataMatrix(NUM_SAMPLES_IN_HDR+1:...
    NUM_SAMPLES_PER_FFT+NUM_SAMPLES_IN_HDR,2:2:end),FFT_SIZE);  %FFT of windowed channel 2 data, after header
%DataMatrixCh2_FFT_raw = DataMatrixCh2_FFT_raw .* conj(DataMatrixCh2_FFT_raw);
 
%QUESTION: why not do this before the FFT?  
%ANSWER: you could do it that way

%truncate channel 1 data matrix if it exceeds the size of channel 2 data
%matrix
if length(DataMatrixCh1_FFT_raw)>length(DataMatrixCh2_FFT_raw)
    DataMatrixCh1_FFT_raw=DataMatrixCh1_FFT_raw(:,1:length(DataMatrixCh2_FFT_raw));
end

clear dataMatrix; %memory management: clear out time waveform


%convert raw data to dB
figure(1);mesh(abs(DataMatrixCh1_FFT_raw(1:128,:)));view(0,90);



focusedDataMatrix_raw=DataMatrixCh1_FFT_raw;  %copy channel 1 data (raw data, not dB)
plotFlag = 1;
for rangeBin=startBin:endBin
%    indx=find(RangeBinDetectionList(rangeBin,:)==1); %get index for detections
    
    % process the entire range bin based on an average speed and no angle
    Speed_AVG_mph = 30;
    Speed_AVG_mps = Speed_AVG_mph*5280*12*.0254/3600;  
    %Offset = 9/55*rangeBin;  %for rail cars
    %Offset = 2.5/55*rangeBin;  %for rail cars
    Offset = 3.5/55*rangeBin;  %for rail cars
    %% This is where you need to create the chirp...
    BmWEdge_m = M_PER_RANGE_BIN*rangeBin*tand(HalfAntennaWidth);
    step_m = abs(Speed_AVG_mps)*PRI;
    indxM = (-BmWEdge_m:step_m:BmWEdge_m) - Offset;
    chirpbw=exp(1i*KN*((M_PER_RANGE_BIN*rangeBin)^2+indxM.^2).^.5);
    
    
    chirpLength=length(chirpbw);
    CLB2 = floor(chirpLength/2);
    winchirp=blackman(chirpLength); %create a window
    chirptemp=chirpbw.*winchirp'; %window the chirp
    chirp=chirptemp/sqrt(FFT_SIZE_SAR/2);
    length_of_data = length(DataMatrixCh1_FFT_raw);
    %focus all data when no events are present to create a consistent
    %background and improved SNR
    for idxstrt2 = 1:FFT_SIZE_SAR/2:length_of_data
        idxstrt1 = idxstrt2
        idxstp1= idxstrt2 + FFT_SIZE_SAR - 1;
        if idxstp1 > length_of_data
            idxstp1 = length_of_data;
            idxstrt1 = idxstp1 - FFT_SIZE_SAR + 1;
        end
        eventCh1Fft_raw = DataMatrixCh1_FFT_raw(rangeBin, idxstrt1:idxstp1);
        if length(eventCh1Fft_raw)>length(chirp)
            fftEventCh1Fft_raw=fft((eventCh1Fft_raw-mean(eventCh1Fft_raw)),length(eventCh1Fft_raw));%/sqrt(length(eventCh1Fft_raw)); %not padded FFT_SIZE_SAR
            ChirpFFT=fft(chirp,length(eventCh1Fft_raw));%/sqrt(length(eventCh1Fft_raw)); %not padded
        else
            ChirpFFT=fft(chirp,length(chirp)); %not padded
            fftEventCh1Fft_raw=fft(eventCh1Fft_raw,length(chirp));%/sqrt(length(chirp)); %not padded
        end
        
        if ( (plotFlag ==1) && (rangeBin >= 48) &&(idxstp1>=37000))
            plotFlag = 0;
            figure(13);clf;
            subplot(2,1,1); plot(((1:length(fftEventCh1Fft_raw))+idxstrt1-1),abs(fftEventCh1Fft_raw));title(sprintf('rangeBin = %d; idxstart1 = %d; idxstp1 = %d', rangeBin, idxstrt1, idxstp1));
            subplot(2,1,2);plot(((1:length(fftEventCh1Fft_raw))+idxstrt1-1),abs(ChirpFFT))
        end
        
        %% THis is where you process the image data
        focusedEventCh1_rawb = conj(fftEventCh1Fft_raw .* conj(ChirpFFT));
        fftFocusedEventCh1_rawb=fft(focusedEventCh1_rawb);
                      
        fftFocusedEventCh1_raw = fftFocusedEventCh1_rawb; %fftFocusedEventCh1_rawb(2:(length(fftFocusedEventCh1_rawb)-2));
        if idxstrt2 == 1
            focusedDataMatrix_raw(rangeBin,(idxstrt1):(idxstp1))=(fftFocusedEventCh1_raw(1:FFT_SIZE_SAR));  %0 Hz shifted to center of data
        else
            focusedDataMatrix_raw(rangeBin,(idxstrt1+FFT_SIZE_SAR/4):(idxstp1))=(fftFocusedEventCh1_raw((1+FFT_SIZE_SAR/4):FFT_SIZE_SAR));  %0 Hz shifted to center of data
        end
    end
end
figure(23);mesh(abs(focusedDataMatrix_raw(1:128,:)));view(0,90);
% the following line will plot out the chirps. It needs to be plotted for
% and index that has a bright targe of interest
%figure(13);clf; subplot(2,1,1); plot(abs(fftEventCh1Fft_raw));title(idxstrt1); subplot(2,1,2);plot(abs(ChirpFFT))
