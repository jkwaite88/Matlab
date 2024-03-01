%findChirpParametersFromDaqFile - Given a daq file name this functions
%returns the number of upchirp samples and down chirp samples.
%function [NUM_UP_CHIRP_SAMPLES, NUM_DOWN_CHIRP_SAMPLES] = findChirpParametersFromDaqFile(daqFileaName);
%
function [NUM_UP_CHIRP_SAMPLES, NUM_DOWN_CHIRP_SAMPLES, NUM_ANTENNAS] = findChirpParametersFromDaqFile(daqFileaName)
%daqFileaName = 'G:\Data\Wasp\2007_03_19\State_Center_SW_1130.daq';

HD_file = 0;

iii = strfind(daqFileaName,'\');
if ~isempty(iii)
    filename = lower(daqFileaName((iii(end)+1):end));
    iii = strfind(filename,'hd');
    if isempty(iii)
        iii = strfind(filename,'125');
    end
    if ~isempty(iii) %file must be and HD file
        HD_file = 1;
    end
end
    
samplesToProcess = 10000000;

POSITIVE_FULL_SCALE = 32767;
NEGATIVE_FULL_SCALE = -32768;
NUM_HEADER_SAMPLES = 3;

fid = fopen(daqFileaName,'r');
if (fid == -1)
   error('Unable to open file');
end
fseek(fid, 0,"eof");
samplesInFile = floor(ftell(fid)/2);
fseek(fid, 0,"bof");

if samplesInFile < samplesToProcess
    samplesToProcess = samplesInFile;
end
[data, numRead] = fread(fid, samplesToProcess, 'int16');
fclose(fid);

consecutivePulsesSameLengthToFind = 2; %should be 2 or greater 
pulsesSameLength = 0;
chirpStart  = zeros(1,consecutivePulsesSameLengthToFind+1); %find one more start the number of pulses
chirpLength = zeros(1,consecutivePulsesSameLengthToFind);
n = 1;
for sample = 1:samplesToProcess
   if( (data(sample) == POSITIVE_FULL_SCALE)...
        &&...
       (data(sample + 1) == NEGATIVE_FULL_SCALE)...
        &&...
       (data(sample + 2) >= 0)...
        &&...
       (data(sample + 2) <= 63) )
      %update start array
      for i = 1:consecutivePulsesSameLengthToFind
          chirpStart(i) = chirpStart(i+1);
      end
      chirpStart(consecutivePulsesSameLengthToFind+1) = sample + 3;
      %find length of chirps
      for i =1:consecutivePulsesSameLengthToFind
        chirpLength(i) = chirpStart(i+1) - chirpStart(i);
      end
      %see if chirps are same length
      sameLength = 1;
      for i =1:(consecutivePulsesSameLengthToFind-1)
        if chirpLength(i+1) ~= chirpLength(i);
            sameLength = 0;
            break;
        end
      end
      if sameLength
          break;
      end
   end
end
    

if sameLength
    %find the number of antennas
    indxmx=find(data==POSITIVE_FULL_SCALE);
    ii=find(indxmx<=(length(data)-2));
    indxmx=indxmx(ii);
    indxHalfgood=find(data(indxmx+1)==NEGATIVE_FULL_SCALE);
    indxGood=find((data(indxmx(indxHalfgood)+2)>-1) & (data(indxmx(indxHalfgood)+2)<17));
    mn=min(data(indxmx(indxHalfgood(indxGood))+2));
    mx=max(data(indxmx(indxHalfgood(indxGood))+2));
    %mn = min(data(3:NUM_SAMPLES_PER_PRF:end));
    %mx = max(data(3:NUM_SAMPLES_PER_PRF:end));
    NUM_ANTENNAS = mx - mn + 1;
    if NUM_ANTENNAS == 2
        HD_file = 1;
    end

    NUM_SAMPLES_PER_PERIOD = chirpStart(2) - chirpStart(1) - NUM_HEADER_SAMPLES;
    if NUM_SAMPLES_PER_PERIOD == 2048
        NUM_UP_CHIRP_SAMPLES = 1024;
    elseif NUM_SAMPLES_PER_PERIOD >= 2000
        NUM_UP_CHIRP_SAMPLES = 2048;
    elseif NUM_SAMPLES_PER_PERIOD > 1000
        NUM_UP_CHIRP_SAMPLES = 1024;
    elseif NUM_SAMPLES_PER_PERIOD > 500
        NUM_UP_CHIRP_SAMPLES = 512;
    else
        NUM_UP_CHIRP_SAMPLES = 256;
    end
    if HD_file == 1
        NUM_UP_CHIRP_SAMPLES = 255;
    end

    NUM_DOWN_CHIRP_SAMPLES = NUM_SAMPLES_PER_PERIOD - NUM_UP_CHIRP_SAMPLES;

    NUM_SAMPLES_PER_PRF = NUM_SAMPLES_PER_PERIOD + NUM_HEADER_SAMPLES;

else
    NUM_UP_CHIRP_SAMPLES = 0;
    NUM_DOWN_CHIRP_SAMPLES = 0;
    NUM_ANTENNAS = 0;
    assert(1, 'Valid pulse not found');
end


