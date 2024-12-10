%This script will find corrupt data

%These definitions will help understand this script
%Valid Pulse - This pulse has propper header and next header is the correct number of samples away - it will be copied
%Invalid pulse - headers are not correct or not the right number of samples apart from each other - pulse will not be copied
%In sequence - for Valid data, antenna number is in order
%Out of sequence - for Valid data, antenna number is out of propper order

%Script: check a pulse for validity. If valid, check sequence. If out of order, add pulses contiaining zero data. If in order, copy pulse

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
FILE_NAME = "C:\Users\jwaite\Wavetronix LLC\Matrix Test and Raw Data - General\Matrix Rail Rain Data\2024-12-09_400South\Data4.daq";
%FILE_NAME = "C:\Data\2024-11-05\Test_Matrix2.daq";


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

corruptCount = 0;
removedLastOrFirstPulseBecauseOfAntennaNumber = false;
NUM_SAMPS_IN_CHIRP = NUM_UP_CHIRP_SAMPLES + NUM_DOWN_CHIRP_SAMPLES;
NUM_SAMPLES_PER_PULSE = NUM_SAMPS_IN_CHIRP + NUM_SAMPS_IN_HEADER;
%==find out how large the file is
fseek(fid_origFile, 0, 'eof');
endOfFilePointer = ftell(fid_origFile);
totalNumSamples = (endOfFilePointer/2); 
%== Reset file point to beginning of first pulse
fseek(fid_origFile, 0, 'bof');


[data,numRead] = fread(fid_origFile,inf,'int16');
fclose(fid_origFile);

%%

pulseStartKey = [POSITIVE_FULL_SCALE NEGATIVE_FULL_SCALE];
idxPulseStart = strfind(data.', pulseStartKey);
samplesInPulse = idxPulseStart(2:end) - idxPulseStart(1:(end-1));
pulseNum_IncorrectNumberOfSamples = find(samplesInPulse ~= NUM_SAMPLES_PER_PULSE);

%initialize variable;
data2 = zeros(size(data));
numPulses = length(idxPulseStart);
numPulsesToFix = length(pulseNum_IncorrectNumberOfSamples);
lastAntennaNum = data(idxPulseStart(1)+(NUM_SAMPS_IN_HEADER-1)) - 1;
if lastAntennaNum < 0
    lastAntennaNum = lastAntennaNum + NUM_ANTENNAS;
end
pulsesInserted = 0;
pulsesRemoved = 0;
data2PulseNum = 1;
data2SampleNumber = 1;
dataPulseNum = 1;
begining_of_file = true;
lastFullFrameSample = 0;
pulsesRemovedAtBeginning = 0;
pulsesRemovedAtEnd = 0;
numInvalidAntennaNumberPulses = 0;
fprintFlag = 0;
whileLoopCounter = 0;
while dataPulseNum <= numPulses
    if whileLoopCounter > (10*numPulses)
        error('In infinite loop.')
    end
    
    pulseValid = false;
    correctAntennaSequence = false;
    validAntennaNum = false;
    % check for pulse validity
    currentAntennaNum = data(idxPulseStart(dataPulseNum)+(NUM_SAMPS_IN_HEADER-1));
    if currentAntennaNum >= 0 && currentAntennaNum <= 15
        validAntennaNum = true;
    else
        numInvalidAntennaNumberPulses = numInvalidAntennaNumberPulses +1;
    end
    if dataPulseNum < numPulses
        samplesInPulse = idxPulseStart(dataPulseNum+1) - idxPulseStart(dataPulseNum);
    else
        samplesInPulse = length(data) -idxPulseStart(dataPulseNum) + 1;
    end
    if (samplesInPulse == NUM_SAMPLES_PER_PULSE) && validAntennaNum
        pulseValid = true;
        
        %Check pulse sequence
        antennaSequenceDifference = currentAntennaNum - lastAntennaNum;
        if antennaSequenceDifference < 0
            antennaSequenceDifference = antennaSequenceDifference + NUM_ANTENNAS;
        end
        if antennaSequenceDifference == 1
            correctAntennaSequence = true;
            pulsesToInsert = 0;
        else
            %
            pulsesToInsert = antennaSequenceDifference - 1;
            if pulsesToInsert < 0
                pulsesToInsert = pulsesToInsert + NUM_ANTENNAS;
            end
            if pulsesToInsert >= NUM_ANTENNAS || pulsesToInsert < 0
                error('Invalid pulsesToInsert variable value')
            end
        end
    else
        %pulse not valid
        breakhere = 1;
    end

    if pulseValid && begining_of_file && correctAntennaSequence
        %skip pulses at beginning of file until current antenna is 0
        if currentAntennaNum == 0
            begining_of_file = false;
            pulsesToInsert = 0;
        end
    end
    if begining_of_file
        pulsesRemovedAtBeginning = pulsesRemovedAtBeginning + 1;
    end

    if pulseValid && not(begining_of_file)
        if correctAntennaSequence
            %copy data
            dataSampleNumber = idxPulseStart(dataPulseNum);
            dataToInsert = data(dataSampleNumber:(dataSampleNumber+NUM_SAMPLES_PER_PULSE-1));
            %put data to insert into data2
            endLastSampleIdx = (data2SampleNumber+NUM_SAMPLES_PER_PULSE-1);
            data2(data2SampleNumber:endLastSampleIdx) = dataToInsert;
            data2PulseNum = data2PulseNum + 1;
            data2SampleNumber = data2SampleNumber + length(dataToInsert);
            %update values
            dataPulseNum = dataPulseNum + 1;
            if currentAntennaNum == (NUM_ANTENNAS -1)
                %record last sample of last full frame 
                lastFullFrameSample = endLastSampleIdx;
            end
            lastAntennaNum = currentAntennaNum;
        else
            insert_zero_pulses = true; % do not set to false until the code has been completed for this feature
            if insert_zero_pulses
                %insert zero pulses
                pulsesToInsertCountDown = pulsesToInsert;
                while pulsesToInsertCountDown > 0
                    %create data full of zeroes
                    currentAntennaNum = incrementAntenna(lastAntennaNum, NUM_ANTENNAS);
                    dataToInsert = oneFullPulseOfZeros(NUM_SAMPS_IN_CHIRP, currentAntennaNum);
                    %put data to insert into data2
                    data2(data2SampleNumber:(data2SampleNumber+NUM_SAMPLES_PER_PULSE-1)) = dataToInsert;
                    data2PulseNum = data2PulseNum + 1;
                    data2SampleNumber = data2SampleNumber + length(dataToInsert);
                    %update values
                    pulsesInserted = pulsesInserted + 1;
                    pulsesToInsertCountDown = pulsesToInsertCountDown - 1;
                    lastAntennaNum = currentAntennaNum;
                end
            else
                %do not insert pulse - do not copy pulse until it is the correct antenna number
                %############this code has not been been tested yet
                pulsesRemoved = pulsesRemoved + 1;
                dataPulseNum = dataPulseNum + 1;
                lastAntennaNum = currentAntennaNum;
            end
        end
    else
        %invalid pulse - skip currnet pulse in data
        dataPulseNum = dataPulseNum + 1;
        if begining_of_file
             lastAntennaNum = currentAntennaNum;
        end
    end
    
    whileLoopCounter = whileLoopCounter + 1;
end
fprintf(1,'\n');
%throw away partial frame at end of data
if data2SampleNumber ~= lastFullFrameSample
    data2 = data2(1:lastFullFrameSample);
    pulsesRemovedAtEnd = floor((data2SampleNumber - lastFullFrameSample)/NUM_SAMPS_IN_CHIRP);
end


%%
fid_fixedFile = fopen(NEW_FIXED_FILE_NAME,'w');
if (fid_fixedFile == -1)
   error('Unable to open file');
end
fwrite(fid_fixedFile, data2, 'int16');
fclose(fid_fixedFile);

if isequal(size(data), size(data2)) && (pulsesRemovedAtBeginning == 0) && (pulsesRemovedAtEnd == 0) && (pulsesInserted == 0)
    %no changes made to file
	delete(NEW_FIXED_FILE_NAME);
	fprintf(1,'The file is good!\nNo corruptions were found or corrections made in the file:\n%s\n',FILE_NAME);
else
    fprintf(1, 'To start file at begining of a frame, %d pulses removed at begging of file.\n',pulsesRemovedAtBeginning);
    fprintf(1, 'To finish file with complete frame, %d pulses removed at end of file.\n',pulsesRemovedAtEnd);
    fprintf(1, 'To fix currupt or missing data:\n');
    fprintf(1, '\t%d pulses inserted with ''zero'' data.\n',pulsesInserted);
    fprintf(1, '\t%d pulses removed.\n', pulsesRemoved);
    fprintf(1, 'The number of invalid antenna numbers, %d.\n',numInvalidAntennaNumberPulses);

    if false
        %append "_orig" to orignal file
        NEW_ORIG_FILE_NAME = getOrigFileName(FILE_NAME);      
        movefile(FILE_NAME,NEW_ORIG_FILE_NAME);
        movefile(NEW_FIXED_FILE_NAME,FILE_NAME);
	    fprintf(1,'The corrected file was SAVED as:\n%s\n',FILE_NAME);
	    fprintf(1,'The original file was SAVED as:\n%s\n',NEW_ORIG_FILE_NAME);
	    fprintf(1,'Total number of times corrupt data found: %d\n', corruptCount);
    else
        %apppend "_fixed to fixed file
        fprintf(1,'The corrected file was SAVED as:\n%s\n',NEW_FIXED_FILE_NAME);
	    fprintf(1,'The original file is unchanged:\n%s\n',FILE_NAME);
	    fprintf(1,'Total number of times corrupt data found: %d\n', corruptCount);
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


