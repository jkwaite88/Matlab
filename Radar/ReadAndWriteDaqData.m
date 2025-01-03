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
% FILE_NAME = "C:\Data\MatrixBrreathingRate\Zubair_3m._2daq";
%FILE_NAME = "C:\Data\AntennaSwitchingTest\AllAtnennas1.daq";
FILE_NAME = "E:\RadarData\Matrix\Matrix Rail Rain Data\MatrixRainSeattleData\Seattle_12072023\Dataset 2\20231207SeattleTestSite2Test1_fixed.daq";

[filepath,name,ext] = fileparts(FILE_NAME);
write_file_name = strcat(filepath, '\', name, '_extended', ext);

[NUM_UP_CHIRP_SAMPLES, NUM_DOWN_CHIRP_SAMPLES, NUM_ANTENNAS] = findChirpParametersFromDaqFile(FILE_NAME);
NUM_SAMPLES_PER_PERIOD = NUM_UP_CHIRP_SAMPLES + NUM_DOWN_CHIRP_SAMPLES + NUM_HEADER_SAMPLES;
fid = fopen(FILE_NAME,'r');
if (fid == -1)
   error('Unable to open file');
end

%== Read in the data
fprintf(1,'Reading file.\n');
[data,numRead] = fread(fid, inf,'int16=>int16');
%[data,numRead] = fread(fid,50050000,'int16');  % 15015000 is 15 s 30030000 is 30 s  45045000 is 45 s 50050000 is 50s
fclose(fid);
%data = data/(2^15);
fprintf(1,'Processing data.\n');

numChirps = floor(size(data,1)/NUM_SAMPLES_PER_PERIOD);
numFrames = floor(numChirps/NUM_ANTENNAS);
numSamplesInFrames = numFrames*NUM_ANTENNAS*NUM_SAMPLES_PER_PERIOD;
dataMatrix = reshape(data(1:numSamplesInFrames), NUM_SAMPLES_PER_PERIOD, []);
samples_thrown_away = size(data,1) - numSamplesInFrames;
clear data


%%
%concatenate data at beginning or end
% make sure the data to concatenate starts on antenna 1 and ends on antenna 16
fprintf(1,'Duplicating partial data set.\n');
frames_to_copy_and_add = 96000;
indexVal = floor(frames_to_copy_and_add/16)*16 ;
dataToConcatenate = dataMatrix(:,1:indexVal);

%initialize dataMatrix2
dataMatrix2 = cat(2, dataToConcatenate, dataToConcatenate, dataToConcatenate, dataToConcatenate, dataToConcatenate, dataToConcatenate, dataToConcatenate, dataToConcatenate, dataToConcatenate, dataToConcatenate, dataMatrix);

%% plot
% chebWinSideLobes = 80;
% chebWindow = myDolphCheb(NUM_UP_CHIRP_SAMPLES,chebWinSideLobes);
% 
% startIdx = NUM_HEADER_SAMPLES + 1;
% endIdx = startIdx + NUM_UP_CHIRP_SAMPLES -1;
% temp = double(dataMatrix((startIdx:endIdx),9:16:end));
% 
% DataMatrix = fft(chebWindow .* temp);
% DataMatrix = DataMatrix(1:(FFT_SIZE/2+1),:);
% DataMatrix = reshape(DataMatrix, (FFT_SIZE/2+1), []);
% 
% temp = double(dataMatrix2((startIdx:endIdx),9:16:end));
% DataMatrix2 = fft(chebWindow .* temp);
% DataMatrix2 = DataMatrix2(1:(FFT_SIZE/2+1),:,:);
% DataMatrix2 = reshape(DataMatrix2, (FFT_SIZE/2+1), []);
% clear temp
% 
% figure(1); clf; hold on;
% ant = 8;
% range = 22;
% plot(20*log10(abs(DataMatrix(23,:))), color='r', DisplayName="DatatMatrix1")
% plot(20*log10(abs(DataMatrix2(23,:)))-2, color='b', DisplayName="DatatMatrix2")
% axis([0 inf -inf inf])
% grid on
% legend




%%
clear dataToConcatenate
fprintf(1,'Writing data to file.\n');

%dataMatrix2 = squeeze(reshape(dataMatrix2, 1, 1, numel(dataMatrix2)));
fid_w = fopen(write_file_name,'w');
if (fid_w == -1)
   error('Unable to open file');
end

fwrite(fid_w, dataMatrix2, 'int16');
fclose(fid_w);
fprintf(1,'Process complete.\n');

%%
