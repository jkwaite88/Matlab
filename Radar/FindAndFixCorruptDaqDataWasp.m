%This script will find corrupt data
tic;
SAMPLE_RATE = 1e6;
POSITIVE_FULL_SCALE = 32767;
NEGATIVE_FULL_SCALE = -32768;
NUM_SAMPS_IN_HEADER = 3;
BLOCK_SIZE = 1000;

%Enter the file name to be fixed here.  The new fixed file will
% have "_fixed" appended to it. 

 FILE_NAME = 'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\HD\Data\Zara\hd_raw_data_07_22_2022_10_26_38.daq';
 %FILE_NAME = 'C:\Users\jwaite\Downloads\data\data\hd_raw_data_07_28_2022_15_02_17.daq';
%dmToWrite = [];
%[NUM_UP_CHIRP_SAMPLES, NUM_DOWN_CHIRP_SAMPLES, NUM_ANTENNAS] = findChirpParametersFromWaspDaqFile(FILE_NAME);
[NUM_UP_CHIRP_SAMPLES, NUM_DOWN_CHIRP_SAMPLES, NUM_ANTENNAS] = findChirpParametersFromDaqFile(FILE_NAME);

%NUM_UP_CHIRP_SAMPLES=1024;
fprintf(1,'\n\nFindAndFixCorruptedFile\nCurrent File: %s\n', FILE_NAME);
i = strfind(FILE_NAME,'.daq');
NEW_FILE_NAME = [FILE_NAME(1:(i-1)) '_fixed.daq'];
NEW_ORIG_FILE_NAME = [FILE_NAME(1:(i-1)) '_orig.daq'];

fid_origFile = fopen(FILE_NAME,'r');
if (fid_origFile == -1)
   error('Unable to open file');
end

fid_fixedFile = fopen(NEW_FILE_NAME,'w');
if (fid_fixedFile == -1)
   error('Unable to open file');
end

corruptCount = 0;
removedLastOrFirstPulseBecauseOfAntennaNumber = false;
numSampsInChirp = NUM_UP_CHIRP_SAMPLES + NUM_DOWN_CHIRP_SAMPLES;
numSampsPerPulse = numSampsInChirp + NUM_SAMPS_IN_HEADER;
numSampsPerBlock = numSampsPerPulse*BLOCK_SIZE;
%==find out how large the file is
fseek(fid_origFile, 0, 'eof');
endOfFilePointer = ftell(fid_origFile);
totalNumSamples = (endOfFilePointer/2); 
totalNumBlocks = ceil(totalNumSamples/numSampsPerBlock);


%== Reset file point to beginning of first pulse
%fseek(fid_origFile, (firstChirpStart-NUM_SAMPS_IN_HEADER-1)*2, 'bof');
fseek(fid_origFile, 0, 'bof');
[data,numRead] = fread(fid_origFile,numSampsPerBlock,'int16');
block = 0;
ii = repmat((0:(numSampsPerPulse-1)).',1,BLOCK_SIZE);

firstSampleToUse = numSampsPerBlock + 1;
lastAntennaInFile = -1;
lastAntennaInPreviousBlock = -1;
while numRead > 0
	block = block + 1;
	if mod(block,5) == 0 || block == 1 || block == totalNumBlocks
		fprintf(1,'Block %d of %d\n', block, totalNumBlocks);
	end

	%find positive full scale indexes
	I_FullScalePos = find(data(1:(end-(numSampsPerPulse+2))) == POSITIVE_FULL_SCALE);

% 	if (block == totalNumBlocks) && ( ((length(data)-I_FullScalePos(end))+1) == numSampsPerPulse )
%         %we are on the last block and there is a full pulse at the end of
%         %the block.
%         
% 		%use the last pulse on the last file if it looks reasonable
% 		lastToFind = length(I_FullScalePos);
% 		Igood_IFSP = find(data(I_FullScalePos(1:lastToFind)+1) == NEGATIVE_FULL_SCALE ...
% 			& data(I_FullScalePos(1:lastToFind)+2) >= 0 ...
% 			& data(I_FullScalePos(1:lastToFind)+2) <= (NUM_ANTENNAS-1));
% 	else
		lastToFind = length(I_FullScalePos)-1;
		Igood_IFSP = find(data(I_FullScalePos(1:lastToFind)+1) == NEGATIVE_FULL_SCALE ...
			& data(I_FullScalePos(1:lastToFind)+2) >= 0 ...
			& data(I_FullScalePos(1:lastToFind)+2) <= (NUM_ANTENNAS-1) ...
			& data(I_FullScalePos(1:lastToFind)+numSampsPerPulse) == POSITIVE_FULL_SCALE ...
			& data(I_FullScalePos(1:lastToFind)+(numSampsPerPulse+1)) == NEGATIVE_FULL_SCALE...
            & data(I_FullScalePos(1:lastToFind)+(numSampsPerPulse+2)) == mod((data(I_FullScalePos(1:lastToFind)+2) + 1),NUM_ANTENNAS));
% 	end

	%Igood_IFSP should now contain the valid pulse indexes into
	%I_FullScalePos
	
	Igood = I_FullScalePos(Igood_IFSP);
	if (1) %do we want to have the first chrip start with 0 and the last chirp to end with (NUM_ANTENNAS-1)
		if(block == 1)
			%lets start with antenna 0
			firstIgood = find(data(Igood+2)==0,1,'first');
			if(firstIgood ~=1)
				Igood = Igood(firstIgood:end);
				fprintf(1,'First %d pulses removed from file to make the beginning antenna number 0\n',firstIgood-1)
				corruptCount = corruptCount + 1;
			end
		end
		if(block == totalNumBlocks)
			%lets end with antenna (NUM_ANTENNAS-1)
			temp = length(Igood);
			lastIgood = find(data(Igood+2)==(NUM_ANTENNAS-1),1,'last');
			if(lastIgood ~=temp)
				Igood = Igood(1:lastIgood);
				fprintf(1,'Last %d pulses removed from file to make the last antenna number %d\n',temp-lastIgood,(NUM_ANTENNAS-1))
				corruptCount = corruptCount + 1;
			end
		end
	end
	
	%check for missing/bad data (look for sub-blocks of good data)
	samplesBetweenGoodPulses = Igood(2:end) - Igood(1:(end-1));
	i_corruptions = find(samplesBetweenGoodPulses ~= numSampsPerPulse);
	
	writeFirstIdx = Igood(1);
	for i = 1:length(i_corruptions)
		%write out good data up to next bad data
		writeLastIdx = Igood(i_corruptions(i)) + numSampsPerPulse - 1;
		idxsToWrite = (writeFirstIdx):(writeLastIdx);
		%dmToWrite = [dmToWrite; data(idxsToWrite)];
		fwrite(fid_fixedFile,data(idxsToWrite),'int16');
		
		%write out filler data so antenna sequence will be correct
		antFirst = data(Igood(i_corruptions(i))+2)+1;
		if antFirst > (NUM_ANTENNAS-1)
			antFirst = 0;
		end
		antLast = data(Igood(i_corruptions(i)+1)+2)-1;
		if antLast < 0
			antLast = (NUM_ANTENNAS-1);
		end
		if antFirst <= antLast
			antennaNumsToWriteOut = antFirst:antLast;
		else
			if (antFirst - antLast) == 1
				%Missing number of pulse just happens to be a multiple of
				%16
				antennaNumsToWriteOut = []; 
			else
				antennaNumsToWriteOut = [antFirst:(NUM_ANTENNAS-1) 0:antLast];
			end
		end
		%create data to write
		for j = 1:length(antennaNumsToWriteOut)
			pulseDataToWrite = [POSITIVE_FULL_SCALE; NEGATIVE_FULL_SCALE; antennaNumsToWriteOut(j); zeros(numSampsInChirp,1)];
			%dmToWrite = [dmToWrite; pulseDataToWrite];
			fwrite(fid_fixedFile, pulseDataToWrite, 'int16');
		end
		fprintf(1,'Bad pulse removed and %d pulses added to preserve proper antenna sequence\n',length(antennaNumsToWriteOut));
		corruptCount = corruptCount + 1;		
		%fwrite(fid_fixedFile,goodPulses(:,inOrderPulses),'int16');
		writeFirstIdx = Igood(i_corruptions(i)+1);
	end
	%write out the last of the data
	writeLastIdx = Igood(end) + numSampsPerPulse - 1;
	idxsToWrite = (writeFirstIdx):(writeLastIdx);
	%dmToWrite = [dmToWrite; data(idxsToWrite);];
	fwrite(fid_fixedFile, data(idxsToWrite), 'int16');

	
	%debug - begin
	if(length(idxsToWrite) >=283)
		tdata = data(idxsToWrite);
		i1 = floor(length(idxsToWrite)/283);
		tdata1 = reshape(tdata(1:i1*283),283,[]);
		stophere = 1;
	end
	%debug - end
	
	
	%take care of left over data not written out
	writeFirstIdx = Igood(end) + numSampsPerPulse;
	writeLastIdx = length(data);
	idxsToWrite = (writeFirstIdx):(writeLastIdx);
	b = length(idxsToWrite);
	%read in more data
	if block >= (totalNumBlocks-1)
		%last block
		data(1:b) = data(idxsToWrite);
		[dataTemp,numRead] = fread(fid_origFile, numSampsPerBlock-b, 'int16');
		data((b+1):(b+numRead)) = dataTemp;
		data = data(1:(b+numRead));
		clear dataTemp;
	else
		data(1:b) = data(idxsToWrite);
		[data((b+1):end),numRead] = fread(fid_origFile, numSampsPerBlock-b, 'int16');
	end
end

fclose(fid_origFile);
fclose(fid_fixedFile);
if(corruptCount == 0  && removedLastOrFirstPulseBecauseOfAntennaNumber == false)
	delete(NEW_FILE_NAME);
	fprintf(1,'The file is good!\nNo corruptions were found or corrections made in the file:\n%s\n',FILE_NAME);
else
    movefile(FILE_NAME,NEW_ORIG_FILE_NAME);
    movefile(NEW_FILE_NAME,FILE_NAME);
	fprintf(1,'The corrected file was SAVED as:\n%s\n',FILE_NAME);
	fprintf(1,'The original file was SAVED as:\n%s\n',NEW_ORIG_FILE_NAME);
	fprintf(1,'Total number of times corrupt data found: %d\n', corruptCount);
end
elapsedTime = toc;
fprintf(1,'Elapsed time: %.0f seconds\n\n', elapsedTime);

