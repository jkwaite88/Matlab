function z = ReadProcessDaqDataFunction(FILE_NAME)
% clear;  % ReadDAQData
z.NUM_HEADER_SAMPLES = 3;
z.FFT_SIZE = 256;

[z.NUM_UP_CHIRP_SAMPLES, z.NUM_DOWN_CHIRP_SAMPLES, z.NUM_ANTENNAS] = findChirpParametersFromDaqFile(FILE_NAME);
z.NUM_SAMPLES_PER_PERIOD = z.NUM_UP_CHIRP_SAMPLES + z.NUM_DOWN_CHIRP_SAMPLES + z.NUM_HEADER_SAMPLES;
fid = fopen(FILE_NAME,'r');
if (fid == -1)
   error('Unable to open file');
end

%== Read in the data
[data,numRead] = fread(fid,inf,'int16');
fclose(fid);
%[data,numRead] = fread(fid,50050000,'int16');  % 15015000 is 15 s 30030000 is 30 s  45045000 is 45 s 50050000 is 50s
%data = data/(2^15);
numReshapedChirps = floor(floor(size(data,1)/z.NUM_SAMPLES_PER_PERIOD)/z.NUM_ANTENNAS)*z.NUM_ANTENNAS; %limit to even number of full chirps
numReshapedSamples = numReshapedChirps * z.NUM_SAMPLES_PER_PERIOD;
temp = reshape(data(1:numReshapedSamples), z.NUM_SAMPLES_PER_PERIOD, []);
z.dataMatrix = reshape(temp((z.NUM_HEADER_SAMPLES+1):(z.NUM_UP_CHIRP_SAMPLES+z.NUM_HEADER_SAMPLES),1:end), z.NUM_UP_CHIRP_SAMPLES, z.NUM_ANTENNAS, numReshapedChirps/z.NUM_ANTENNAS );
z.numFrames = size(z.dataMatrix,3);
clear temp data

chebWinSideLobes = 60;
%window = myDolphCheb(z.NUM_UP_CHIRP_SAMPLES,chebWinSideLobes);
window = blackman(z.NUM_UP_CHIRP_SAMPLES);
DataMatrix = fft(z.dataMatrix .* window,z.FFT_SIZE);
z.DataMatrix = DataMatrix(1:(z.FFT_SIZE/2+1),:,:);

