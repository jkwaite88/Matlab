function [img, ghostTracks, totalSecs] = updateStateMessages(initialOffset,frame,fileName,...
    failsafeHandle,missedPulsesHandle,errorLogHandle,imageType,sensorInfo)
% img = updateStateMessages(initialOffset,frame,fileName,...
%    failsafeHandle,missedPulsesHandle,errorLogHandle,imageType,sensorInfo);
%
% This matlab function reads the state messages from the ssd file.
%
% Written by Steven Reeves
% September 17, 2014

img = [];
fid = fopen(fileName,'r');
if fid == -1
    return
end

fseek(fid,initialOffset,'bof');
if feof(fid)
    return
end

numStateFrames = fread(fid,1,'uint32',0,'b');
if frame > numStateFrames
    % just get the last frame
    frame = numStateFrames;
end

numBytesPerState = 1 + 5 + 240 + 2560 + 2560;
if sensorInfo.supports.ClutterMap
    % for the clutter map
    numBytesPerState = numBytesPerState + 2560;
    clutterMap = true;
else
    clutterMap = false;
end
if sensorInfo.supports.HistMode
    % for the histogram mode
    numBytesPerState = numBytesPerState + 2560;
    histMode = true;
else
    histMode = false;
end
if sensorInfo.supports.DominantActiveBin 
    % for the dominant active bin
    numBytesPerState = numBytesPerState + 1280;
    dominantActiveBin = true;
else
    dominantActiveBin = false;
end

timeStampBlindSensorDate = datenum(2015,1,6);


    

if sensorInfo.supports.RadarImage
    numBytesRadarImage = 2560;
else
    % the number of bytes is dependent on the rf channel
    numBytesRadarImage = (sensorInfo.NumSamplesPerChirp + 3)*2*MatrixSensor.numBeams;
end

% check the date of the file to see if it actually contains the radar image
if sensorInfo.fileDate < datenum(2014,12,18)
    numBytesRadarImage = 0;
end


ghostTracks = [];

radarImage = zeros(MatrixSensor.numBeams,MatrixSensor.numRangeBins);
timeStamp = struct('year',0,'month',0,'day',0,'hours',0,'minutes',0,'seconds',...
    0,'msecs',0,'pulseCount',0,'numSecs',0);
maxNumBrightClutterWindows = 5;
blindSensor = struct('range',zeros(1,maxNumBrightClutterWindows),'beam',...
    zeros(1,maxNumBrightClutterWindows),'numFailSafe',0,'numWindows',0);
if sensorInfo.supports.TrackZonesChannels == false && numBytesRadarImage > 0
    % then we also have to read over the ghost tracks
    
    dataArray = fread(fid,numBytesRadarImage/2,'int16');
    if imageType == ImageType.RadarImage
        radarImage = ConvertRawAdcData(dataArray, sensorInfo.NumSamplesPerChirp);
    end
    
    if sensorInfo.supports.SysTimeStamp && sensorInfo.fileDate >= timeStampBlindSensorDate
        yearBCD = fread(fid,1,'uint16','b');
        timeStamp.year = bitand(yearBCD,hex2dec('f000'))*10^3 +...
            bitand(yearBCD,hex2dec('0f00'))*10^2 +...
            bitand(yearBCD,hex2dec('00f0'))*10^1 +...
            bitand(yearBCD,hex2dec('000f'))*10^0;
        timeStamp.month = fread(fid,1,'uint8');
        timeStamp.day = fread(fid,1,'uint8');
        timeStamp.hours = fread(fid,1,'uint8');
        timeStamp.minutes = fread(fid,1,'uint8');
        timeStamp.seconds = fread(fid,1,'uint8');
        timeStamp.msecs = fread(fid,1,'uint16','b');
        timeStamp.pulseCount = fread(fid,1,'uint32','b');
        timeStamp.numSecs = fread(fid,1,'uint32','b');
    end
    
    if sensorInfo.supports.BlindSensor && sensorInfo.fileDate >= timeStampBlindSensorDate
        for ind = 1:maxNumBrightClutterWindows
            blindSensor.range(ind) = fread(fid,1,'uint8');
            blindSensor.beam(ind) = fread(fid,1,'uint8');
        end
        if sensorInfo.dspVersion >= datenum(2015,1,29)
            blindSensor.numWindows = fread(fid,1,'uint8');
        end
        blindSensor.numFailSafe = fread(fid,1,'uint8');
    end
    
    numGhostTracks = fread(fid,1,'uint8');
    % each ghost track is 21 bytes
    fread(fid,numGhostTracks*21,'uint8');
else
    if sensorInfo.supports.TrackZonesChannels==true && numBytesRadarImage > 0
        dataArray = fread(fid,numBytesRadarImage,'uint8');
        radarImage = ConvertByteArray(dataArray);
        if sensorInfo.supports.SysTimeStamp && sensorInfo.fileDate >= timeStampBlindSensorDate
            yearBCD = dec2hex(fread(fid,1,'uint16','b'));
            year = 0;
            digit = length(yearBCD)-1;
            for ind = 1:length(yearBCD)
                year = year + str2double(yearBCD(ind))*10^digit;
                digit = digit - 1;
            end
            timeStamp.year = year;
            
            timeStamp.month = fread(fid,1,'uint8');
            timeStamp.day = fread(fid,1,'uint8');
            timeStamp.hours = fread(fid,1,'uint8');
            timeStamp.minutes = fread(fid,1,'uint8');
            timeStamp.seconds = fread(fid,1,'uint8');
            timeStamp.msecs = fread(fid,1,'uint16','b');
            timeStamp.pulseCount = fread(fid,1,'uint32','b');
            timeStamp.numSecs = fread(fid,1,'uint32','b');
        end

        if sensorInfo.supports.BlindSensor && sensorInfo.fileDate >= timeStampBlindSensorDate
            for ind = 1:maxNumBrightClutterWindows
                blindSensor.range(ind) = fread(fid,1,'uint8');
                blindSensor.beam(ind) = fread(fid,1,'uint8');
            end
            if sensorInfo.dspVersion >= datenum(2015,1,29)
                blindSensor.numWindows = fread(fid,1,'uint8');
            end
            blindSensor.numFailSafe = fread(fid,1,'uint8');
        end
    else
        fseek(fid,(frame-1)*numBytesPerState+numBytesRadarImage,'cof');
    end
end

    
    


failsafe = fread(fid,1,'uint8');
failsafeStr = 'Failsafe:';
if bitand(failsafe,1) ~= 0
    failsafeStr = [failsafeStr '|All RF Channels Failing'];
end
if bitand(failsafe,2) ~= 0
    failsafeStr = [failsafeStr '|One or more RF channels failing'];
end
if bitand(failsafe,4) ~= 0
    failsafeStr = [failsafeStr '|No active output channels'];
end
if bitand(failsafe,8) ~= 0
    failsafeStr = [failsafeStr '|Configuration size change'];
end
if bitand(failsafe,16) ~= 0
    failsafeStr = [failsafeStr '|Corrupted flash'];
end
if bitand(failsafe,32) ~= 0
    failsafeStr = [failsafeStr '|ADC failure'];
end
if bitand(failsafe,64) ~= 0
    failsafeStr = [failsafeStr '|Blind sensor'];
end
set(failsafeHandle,'String',failsafeStr);

errorLog = fread(fid,120,'uint16',0,'b');
errors = dec2hex(errorLog,4);
errors(:,end+1) = ' ';
errors = errors';
errors = errors(:)';
errorStr = ['ErrorLog:                          ' errors];
set(errorLogHandle,'String',errorStr);

% read over the number of seconds elapsed for this frame. We only care
% about the next frame (if it exists)

t = fread(fid,1,'uint8');

numMissedPulses = fread(fid,1,'uint32',0,'b');
% TODO figure out how to get the last and next to last missed pulses
% when on the last frame
if numStateFrames > 1 && frame < numStateFrames
    % we only update the missed pulses handle when we have more than one
    % frame and we are not on the last frame
    
    position = ftell(fid);
    
    fseek(fid,numBytesPerState - 5,'cof');
    
    numSecsElapsed = fread(fid,1,'uint8');
    numMissedPulses2 = fread(fid,1,'uint32',0,'b');
    
    missedStr = ['Missed Pulses/Sec:' num2str(...
        (numMissedPulses2-numMissedPulses)/numSecsElapsed)];
    
    set(missedPulsesHandle,'String',missedStr);
    
    fseek(fid,position,'bof');
    
end

% do we need to get an image?
if imageType ~= ImageType.None
    dataArray = fread(fid,2560,'uint8');
    if imageType == ImageType.RawThreshold
        % then convert data array to an image
        img = ConvertByteArray(dataArray);
    end
    
    dataArray = fread(fid,2560,'uint8');
    if imageType == ImageType.SmoothThreshold
        % then convert data array to an image
        img = ConvertByteArray(dataArray);
    end
    
    if clutterMap
        dataArray = fread(fid,2560,'uint8');
        if imageType == ImageType.ClutterMap
            img = ConvertByteArray(dataArray);
        end
    end
    
    if histMode
        dataArray = fread(fid,2560,'uint8');
        if imageType == ImageType.HistMode
            img = ConvertByteArray(dataArray);
        end
    end
    
    if dominantActiveBin
        dataArray = fread(fid,1280,'uint8');
        if imageType == ImageType.DominantActiveBin
            img = ConvertHistBin(dataArray);
        end
    end
    
    if imageType == ImageType.RadarImage
        img = radarImage;
    end
end
    
if sensorInfo.fileDate >= datenum(2014,12,19)
    fseek(fid,-8,'eof');
    totalSecs = fread(fid,1,'float64','b');
else
    totalSecs = 0;
end
assignin('base','totalSecs',totalSecs);
fclose(fid);
end

function img = ConvertByteArray(dataArray)
    numRangeBins = 80;
    numBeams = 16;
    img = zeros(numBeams,numRangeBins);
    index = 1;
    for beam = 1:numBeams
        for range = 1:numRangeBins
            img(beam,range) = CreateFloatFrom10Dot6(dataArray(index:index+1));
            index = index + 2;
        end
    end
end

function img = ConvertHistBin(dataArray)
    numRangeBins = 80;
    numBeams = 16;
    img = zeros(numBeams,numRangeBins);
    index = 1;
    for beam = 1:numBeams
        for range = 1:numRangeBins
            img(beam,range) = 10*log10(2^((dataArray(index)+21)*0.5+0.5));
            index = index + 1;
        end
    end
end

function img = ConvertRawAdcData(dataArray, numSamplesPerChirp)
    
    max_val = 32767;
    min_val = -32768;
    numUpChirpSamples = 256;
    
    
    chirpIndex = numSamplesPerChirp + 1;
    headerCount = 0;
    antNum = 0;
    chirpArray = zeros(numUpChirpSamples, MatrixSensor.numBeams);
    for index = 1:length(dataArray)
        if chirpIndex == numSamplesPerChirp + 1
            headerCount = headerCount + 1;
            if headerCount == 1
                if dataArray(index) ~= max_val
                    error('Error in adc data');
                end
            elseif headerCount == 2
                if dataArray(index) ~= min_val
                    error('Error in adc data');
                end
            elseif headerCount == 3
                if dataArray(index) < 0 || dataArray(index) > MatrixSensor.numBeams
                    error('Error in adc data');
                end
                chirpIndex = 1;
                % add 1, since the dataArray is zero based indexing for the
                % antenna number
                antNum = dataArray(index) + 1;
                headerCount = 0;
            end
        else
            if chirpIndex < numUpChirpSamples
                chirpArray(chirpIndex, antNum) = dataArray(index);
            end
            chirpIndex = chirpIndex + 1;
        end
        
        
    end
    
    % take the fft
    window = blackman(numUpChirpSamples);
    chirpArray = chirpArray.*repmat(window,[1 MatrixSensor.numBeams]);
    img = fft(chirpArray,[],1);
    img = 10*log10(abs(img).^2);

    img = img(1:MatrixSensor.numRangeBins,:);
    img = img';

end
