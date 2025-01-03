%This script will find corrupt data

%These definitions will help understand this script
%Valid Pulse - This pulse has propper header and next header is the correct number of samples away - it will be copied
%Invalid pulse - headers are not correct or not the right number of samples apart from each other - pulse will not be copied
%In sequence - for Valid data, antenna number is in order
%Out of sequence - for Valid data, antenna number is out of propper order

%Script: check a pulse for validity. If valid, check sequence. If out of order, add pulses contiaining zero data. If in order, copy pulse
clear all
tic;
SAMPLE_RATE = 1e6;
POSITIVE_FULL_SCALE = 32767;
NEGATIVE_FULL_SCALE = -32768;
NUM_SAMPS_IN_HEADER = 3;


%Enter the file name to be fixed here.  The new fixed file will
% have "_fixed" appended to it. 

%FILE_NAME = 'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\HD\Data\Zara\hd_raw_data_07_22_2022_10_26_38.daq';
%FILE_NAME = 'C:\Users\jwaite\Downloads\data\data\hd_raw_data_07_28_2022_15_02_17.daq';
%FILE_NAME = 'C:\Data\MatrixRailRain\AtDeskSensorMoving1.daq';
%FILE_NAME =    'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\MatrixRain\Miday_St_Rain5_20231001_113114.daq';
%FILE_NAME = 'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\MatrixRain\2023-09-30\RCA_Blvd_NoRain2_20230930_083337.daq';
%FILE_NAME =  'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\MatrixRain\2023-09-30\RCA_Blvd_NoRain1.daq';
%FILE_NAME = 'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\Matrix Rail\Data\MatrixRain\2023-09-30\RCA_Blvd_NoRain4_20230930_105120.daq';
%FILE_NAME = 'C:\Data\MatrixRain\2023-10-13\MatrixRailCornerReflector_43feet_moving_20231013_113416.daq';
%FILE_NAME = "E:\Data\Matrix\Matrix Rail Rain Data\2024_02_27_Wavetronix\Firehose1.daq";
%FILE_NAME = "E:\Data\Matrix\Matrix Rail Rain Data\delete me\20231207SeattleTestSite1Test1.daq";
%FILE_NAME = "E:\Data\Matrix\Matrix Rail Rain Data\delete me\Firehose1.daq";
%FILE_NAME = "E:\Data\Matrix\Matrix Rail Rain Data\delete me\20231207SeattleTestSite1Test1.daq";
%FILE_NAME = "E:\Data\Matrix\Matrix Rail Rain Data\delete me\Firehose1.daq";
%FILE_NAME = "E:\Data\Matrix\Matrix Rail Rain Data\MatrixRainFloridaData\2023-10-09_Florida_Crossing\MatrixRain_Midway_RD_9\MatrixRainMidwayRD9_extended.daq";
%FILE_NAME = "C:\Data\AntennaSwitchingTest\Antenna7Only.daq";
%FILE_NAME = "C:\Data\AntennaSwitchingTest\RegularSwitching.daq";
%FILE_NAME = "E:\RadarData\Matrix\Matrix Rail Rain Data\MatrixRainSeattleData\Seattle_12072023\Dataset 2\20231207SeattleTestSite2Test1_fixed_extended.daq";
FILE_NAME = "E:\RadarData\Matrix\Matrix Rail Rain Data\MatrixRainSeattleData\Seattle_12072023\Dataset 2\20231207SeattleTestSite2Test1_fixed.daq";


[NUM_UP_CHIRP_SAMPLES, NUM_DOWN_CHIRP_SAMPLES, NUM_ANTENNAS] = findChirpParametersFromDaqFile(FILE_NAME);

fprintf(1,'\n\nFindAndFixCorruptedFile\nCurrent File: %s\n', FILE_NAME);
daqCharNum = strfind(FILE_NAME,'.daq');
% NEW_FIXED_FILE_NAME = [FILE_NAME(1:(daqCharNum-1)) '_fixed.daq'];
% NEW_ORIG_FILE_NAME = [FILE_NAME(1:(daqCharNum-1)) '_orig.daq'];
path_strings = split(FILE_NAME, '.');
NEW_FIXED_FILE_NAME = strcat(path_strings(1), "_fixed.daq");
NEW_ORIG_FILE_NAME = strcat(path_strings(1), "_orig.daq");

fid_origFile = fopen(FILE_NAME,'r');
if (fid_origFile == -1)
   error('Unable to open file');
end

removedLastOrFirstPulseBecauseOfAntennaNumber = false;
NUM_SAMPS_IN_CHIRP = NUM_UP_CHIRP_SAMPLES + NUM_DOWN_CHIRP_SAMPLES;
NUM_SAMPLES_PER_PULSE = NUM_SAMPS_IN_CHIRP + NUM_SAMPS_IN_HEADER;
%==find out how large the file is
fseek(fid_origFile, 0, 'eof');
endOfFilePointer = ftell(fid_origFile);
totalNumSamples = (endOfFilePointer/2); 
%== Reset file point to beginning of first pulse
fseek(fid_origFile, 0, 'bof');


[data,numRead] = fread(fid_origFile,inf,'int16=>int16');
fclose(fid_origFile);

%%

pulseStartKey = [POSITIVE_FULL_SCALE NEGATIVE_FULL_SCALE];
idxPulseStart = strfind(data.', pulseStartKey);
samplesInPulse = idxPulseStart(2:end) - idxPulseStart(1:(end-1));
pulseNum_IncorrectNumberOfSamples = find(samplesInPulse ~= NUM_SAMPLES_PER_PULSE);

%initialize variable;
data2 = zeros(size(data), 'int16');
numPulses = length(idxPulseStart);
numPulsesToFix = length(pulseNum_IncorrectNumberOfSamples);
lastValidAntennaNum = data(idxPulseStart(1)+(NUM_SAMPS_IN_HEADER-1)) - 1;
if lastValidAntennaNum < 0
    lastValidAntennaNum = lastValidAntennaNum + NUM_ANTENNAS;
end
pulsesInserted = 0;
pulsesRemoved = 0;
data2_PulseNum = 0;
data2_StartSampleIdx = 1;
data_PulseNum = 1;
begining_of_file = true;
lastFullFrameSampleIdx = 0;
pulsesRemovedAtBeginning = 0;
pulsesRemovedAtEnd = 0;
numInvalidAntennaNumber = 0;
number_of_pulses_with_invalid_number_of_samples = 0;
number_of_invalid_antenna_sequence = 0;
fprintFlag = 0;
whileLoopCounter = 0;
while data_PulseNum <= numPulses
    if whileLoopCounter > (10*numPulses)
        error('In infinite loop.')
    end
    
    validAntennaNum = false;
    correctNumerOfSamples = false;
    correctAntennaSequence = false;
    pulseValid = false;
    % check for valid antenna number
    currentAntennaNum = data(idxPulseStart(data_PulseNum)+(NUM_SAMPS_IN_HEADER-1));
    if currentAntennaNum >= 0 && currentAntennaNum <= 15
        validAntennaNum = true;
    else
        numInvalidAntennaNumber = numInvalidAntennaNumber +1;
    end
    
    %check for correct number of samples in pulse
    if data_PulseNum < numPulses
        samplesInPulse = idxPulseStart(data_PulseNum+1) - idxPulseStart(data_PulseNum);
    else
        samplesInPulse = length(data) -idxPulseStart(data_PulseNum) + 1;
    end
    if (samplesInPulse == NUM_SAMPLES_PER_PULSE)
        correctNumerOfSamples = true;
    else
        number_of_pulses_with_invalid_number_of_samples = number_of_pulses_with_invalid_number_of_samples + 1;
    end
    
    %Check antenna sequence
    antennaSequenceDifference = currentAntennaNum - lastValidAntennaNum;
    if antennaSequenceDifference < 0
        antennaSequenceDifference = antennaSequenceDifference + NUM_ANTENNAS;
    end
    if antennaSequenceDifference == 1
        correctAntennaSequence = true;
    else
        number_of_invalid_antenna_sequence = number_of_invalid_antenna_sequence + 1;
    end

    % Begining of file. Do not copy until the first antenna 0 pulse
    if begining_of_file
        %skip pulses at beginning of file until current antenna is 0
        if currentAntennaNum == 0
            begining_of_file = false;
        else
            pulsesRemovedAtBeginning = pulsesRemovedAtBeginning + 1;
        end
    end
    
    %Determine if pulse is valid
    if correctNumerOfSamples && validAntennaNum && correctAntennaSequence && not(begining_of_file)
        pulseValid = true;
    else
        %pulse not valid
        breakhere = 1;
    end

    % Copy valid pulse data
    if pulseValid
        %copy data
        start_dataSampleNumber = idxPulseStart(data_PulseNum);
        end_dataSampleIdx = (start_dataSampleNumber+NUM_SAMPLES_PER_PULSE-1);
        dataToInsert = data(start_dataSampleNumber:end_dataSampleIdx);
        %put data to insert into data2
        data2_endSampleIdx = (data2_StartSampleIdx+NUM_SAMPLES_PER_PULSE-1);
        data2(data2_StartSampleIdx:data2_endSampleIdx) = dataToInsert;
        
        %update data2 values
        data2_PulseNum = data2_PulseNum + 1;
        data2_StartSampleIdx = data2_endSampleIdx + 1;
        if currentAntennaNum == (NUM_ANTENNAS -1)
            %record last sample of last full frame 
            lastFullFrameSampleIdx = data2_endSampleIdx;
        end
        lastValidAntennaNum = currentAntennaNum;
    else
        %invalid pulse - do not copy - skip currnet pulse in data
        if begining_of_file && correctNumerOfSamples && validAntennaNum
             lastValidAntennaNum = currentAntennaNum;
        end
    end
    data_PulseNum = data_PulseNum + 1;
    whileLoopCounter = whileLoopCounter + 1;
end

fprintf(1,'\n');
%throw away partial frame at end of data
if data2_endSampleIdx ~= lastFullFrameSampleIdx
    data2 = data2(1:lastFullFrameSampleIdx);
    pulsesRemovedAtEnd = floor((data2_endSampleIdx - lastFullFrameSampleIdx)/NUM_SAMPLES_PER_PULSE);
end


%%

if isequal(size(data), size(data2)) && (pulsesRemovedAtBeginning == 0) && (pulsesRemovedAtEnd == 0) && (pulsesInserted == 0)
    %file good - no changes made
	fprintf(1,'The file is good!\nNo corruptions were found or corrections made in the file:\n%s\n',FILE_NAME);
else
    %file fixed - write file
    fprintf(1, 'To start file with a full frame, %d pulses removed at the begging.\n',pulsesRemovedAtBeginning);
    fprintf(1, 'To finish file with complete frame, %d pulses removed at the end.\n',pulsesRemovedAtEnd);
    fprintf(1, 'To fix currupt or missing data:\n');
    
    fprintf(1, '\t%d pulses with invalid antenna number.\n',numInvalidAntennaNumber);
    fprintf(1, '\t%d pulses with invalid number of samples.\n',number_of_pulses_with_invalid_number_of_samples);
    fprintf(1, '\t%d pulses with invalid antenna sequence.\n', number_of_invalid_antenna_sequence);
    fprintf(1, 'Writing correceted file.\n');

    %file fixed - write file
    fid_fixedFile = fopen(NEW_FIXED_FILE_NAME,'w');
    if (fid_fixedFile == -1)
       error('Unable to open file');
    end
    fwrite(fid_fixedFile, data2, 'int16');
    fclose(fid_fixedFile);

    if false
        %append "_orig" to orignal file
        NEW_ORIG_FILE_NAME = getOrigFileName(FILE_NAME);      
        movefile(FILE_NAME,NEW_ORIG_FILE_NAME);
        movefile(NEW_FIXED_FILE_NAME,FILE_NAME);
	    fprintf(1,'The corrected file was SAVED as:\n%s\n',FILE_NAME);
	    fprintf(1,'The original file was SAVED as:\n%s\n',NEW_ORIG_FILE_NAME);
    else
        %apppend "_fixed to fixed file
        fprintf(1,'The corrected file was SAVED as:\n%s\n',NEW_FIXED_FILE_NAME);
	    fprintf(1,'The original file is unchanged:\n%s\n',FILE_NAME);
    end
end
elapsedTime = toc;
fprintf(1,'Elapsed time: %.0f seconds\n\n', elapsedTime);

function a = oneFullPulseOfZeros(numSamplesInChirp, antennaNumber)
    POSITIVE_FULL_SCALE = 32767;
    NEGATIVE_FULL_SCALE = -32768;
    a = [POSITIVE_FULL_SCALE; NEGATIVE_FULL_SCALE; antennaNumber; zeros(numSamplesInChirp,1)];
end

function a = incrementAntenna(antennaNumber, NUM_ANTENNAS)
     a = antennaNumber + 1;
     if a >= NUM_ANTENNAS
         a = 0;
     end
end

function file_name = getOrigFileName(f_in)
    [filepath,name,ext] = fileparts(f_in);
    file_name = [filepath '\' name '_orig' ext];
    fileNum = 0;
    while isfile(file_name) && fileNum < 100
        fileNum = fileNum + 1;
        file_name = [filepath '\' name '_orig' num2str(fileNum) ext];
    end

end


