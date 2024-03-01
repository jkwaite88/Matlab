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
FILE_NAME =    'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\MatrixRain\2023-10-01\Miday_St_Rain5_20231001_113114.daq';

z = ReadProcessDaqDataFunction(FILE_NAME);

z.DataMatrix_dB = 20*log10(abs(z.DataMatrix));
clear DataMatrix
%%

figure(1)
clf
antennaNum = 7;

subplot(2,2,1)
plot(squeeze(z.dataMatrix(:,antennaNum,1:100:end)))
title('Time Data')

subplot(2,2,2)
plot(squeeze(z.DataMatrix_dB(:,antennaNum,1:100:end)))
title(sprintf('FFT Magnitude  - Antenna %d', antennaNum))

subplot(2,2,3)
rangeBins = [19 24 27];
dataDbBins = squeeze(z.DataMatrix_dB(rangeBins,antennaNum,:));
plot(squeeze(z.DataMatrix_dB(rangeBins,antennaNum,1:end)).')
title_str = sprintf('FFT Magnitude  - Antenna %d, range bin %d', antennaNum);
title_str = append(title_str, ': ', num2str(rangeBins));
title(title_str)
