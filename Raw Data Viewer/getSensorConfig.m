function [sensorInfo, varargout] = getSensorConfig(fileName)
% sensorInfo = getSensorConfig(fileName);
%
% This function reads the sensor configuration from the dump debug ssd
% file.
%
% Written by Steven Reeves



sensorInfo = MatrixSensor;
fid = fopen(fileName);
if fid == -1
    error(['Error opening file: ' fileName]);
end
file_info    = dir(fileName);
sensorInfo.fileDate = file_info.datenum;

% first line is the file version, for now we ignore it, since we only have
% one version of the file
% ignore the start time of the file
fgetl(fid);
fgetl(fid);

% firmware version
str = fgetl(fid);
versionArray =...
    sscanf(str,'FirmwareVersion=V%1d.%1d.%1d');
sensorInfo.major = versionArray(1);
sensorInfo.minor = versionArray(2);
sensorInfo.build = versionArray(3);

% dsp version
str = fgetl(fid);
temp = sscanf(str,'DspVersion=%d-%d-%d');
sensorInfo.dspVersion = datenum(temp(1), temp(2), temp(3));

% algorithm version
str = fgetl(fid);
temp = sscanf(str,'AlgorithmVersion=%d-%d-%d');
sensorInfo.algorithmVersion = datenum(temp(1), temp(2), temp(3));

% fpga version
str = fgetl(fid);
temp = sscanf(str,'FpgaVersion=%d-%d-%d');
sensorInfo.fpgaVersion = datenum(temp(1), temp(2), temp(3));

% fpaa version
str = fgetl(fid);
temp = sscanf(str,'FpaaVersion=%d-%d-%d');
sensorInfo.fpaaVersion = datenum(temp(1), temp(2), temp(3));

% serial number
str = fgetl(fid);
sensorInfo.serialNumber = sscanf(str,'SerialNumber=%16c');

% rf hardware
sensorInfo.rfHardware = HardwareVersion();
str = fgetl(fid);
temp = sscanf(str,'RfBuildDate=%d-%d-%d');
sensorInfo.rfHardware.buildDate = datenum(temp(1), temp(2), temp(3));
str = fgetl(fid);
sensorInfo.rfHardware.serialNumber = sscanf(str,'RfSerialNumber=%30c');
str = fgetl(fid);
sensorInfo.rfHardware.expansion1 = sscanf(str,'RfExpansion1=%30c');
% dsp hardware
sensorInfo.dspHardware = HardwareVersion();
str = fgetl(fid);
temp = sscanf(str,'DspBuildDate=%d-%d-%d');
sensorInfo.dspHardware.buildDate = datenum(temp(1), temp(2), temp(3));
str = fgetl(fid);
sensorInfo.dspHardware.serialNumber = sscanf(str,'DspSerialNumber=%30c');
str = fgetl(fid);
sensorInfo.dspHardware.expansion1 = sscanf(str,'DspExpansion1=%30c');

% sensor settings
sensorInfo.antennaCoefficients = fread(fid,sensorInfo.numBeams,'float32');
sensorInfo.orientation = fread(fid,1,'uint8');


strLength = fread(fid,1,'uint8');
sensorInfo.approach = fread(fid,strLength,'*char')';



strLength = fread(fid,1,'uint8');
sensorInfo.location = fread(fid,strLength,'*char')';



strLength = fread(fid,1,'uint8');
sensorInfo.description = fread(fid,strLength,'*char')';


sensorInfo.rfChannel = fread(fid,1,'uint32');

sensorInfo.port(1).responseDelay = fread(fid,1,'uint16');
sensorInfo.port(2).responseDelay = fread(fid,1,'uint16');

sensorInfo.dataPush = fread(fid,1,'uint8');
sensorInfo.source = fread(fid,1,'uint8');

dataArray = fread(fid,2,'uint8');
sensorInfo.sensorHeight = CreateFloatFrom10Dot6(dataArray);

sensorInfo.minChannelWidth = fread(fid,1,'uint8')/10;
sensorInfo.minPulseWidth = fread(fid,1,'uint8')/10;

sensorInfo.units = fread(fid,1,'uint8');
sensorInfo.washoutTime = fread(fid,1,'uint8');
sensorInfo.snowAlgorithms = logical(fread(fid,1,'uint8'));
sensorInfo.blindSensorCheck = logical(fread(fid,1,'uint8'));
if sensorInfo.IsRailSensor()
    sensorInfo.unconstrainedDimensions = logical(fread(fid,1,'uint8'));
end
sensorInfo.thresholds = fread(fid,...
    [sensorInfo.numBeams sensorInfo.numRangeBins],'int8');

% lanes
numLanes = fread(fid,1,'uint8');
for ind = 1:numLanes
    index = fread(fid,1,'uint8') + 1;
    sensorInfo.lanes(index).state = fread(fid,1,'uint8');
    sensorInfo.lanes(index).stopbarDefined = logical(fread(fid,1,'uint8'));
    dataArray = fread(fid,2,'uint8');
    sensorInfo.lanes(index).stopbarDistance = CreateFloatFrom10Dot6(dataArray);
    numNodes = fread(fid,1,'uint8');
    sensorInfo.lanes(index).numNodes = numNodes;
    sensorInfo.lanes(index).nodes(numNodes) = struct('x',0,'y',0,'width',0);
    for ind2 = 1:numNodes
        sensorInfo.lanes(index).nodes(ind2).x =...
            CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
        sensorInfo.lanes(index).nodes(ind2).y =...
            CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
        sensorInfo.lanes(index).nodes(ind2).width =...
            CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
    end
    x1 = [sensorInfo.lanes(index).nodes(1:end-1).x];
    x2 = [sensorInfo.lanes(index).nodes(2:end).x];
    y1 = [sensorInfo.lanes(index).nodes(1:end-1).y];
    y2 = [sensorInfo.lanes(index).nodes(2:end).y];
    sensorInfo.lanes(index).segLength = sqrt((x2-x1).^2+(y2-y1).^2);
end

% channels
numChannels = fread(fid,1,'uint8');
for ind = 1:numChannels
    index = fread(fid,1,'uint8') + 1;
    mappedZones = fread(fid,2,'uint8');
    bitMask = bitshift(1,7);
    bitIndex = 0;
    byteIdx = 1;
    for zoneNum = 16:-1:1
        if bitand(mappedZones(byteIdx),bitMask) > 0
            sensorInfo.channels(index).mappedZones(zoneNum) = true;
        end
        bitIndex = bitIndex + 1;
        bitMask = bitshift(bitMask,-1);
        if bitIndex >= 8
            bitIndex = 0;
            bitMask = bitshift(1,7);
            byteIdx = byteIdx + 1;
        end
    end
    
    sensorInfo.channels(index).logic = fread(fid,1,'uint8');
    sensorInfo.channels(index).inverted = logical(fread(fid,1,'uint8'));
    sensorInfo.channels(index).detectorInput = fread(fid,1,'uint8');
    sensorInfo.channels(index).phase = fread(fid,1,'uint8');
    sensorInfo.channels(index).delay = fread(fid,1,'uint8')/10;
    sensorInfo.channels(index).extend = fread(fid,1,'uint8')/10;
    sensorInfo.channels(index).state = fread(fid,1,'uint8');
end

% zones
numZones = fread(fid,1,'uint8');
for ind = 1:numZones
    index = fread(fid,1,'uint8') + 1;
    for ind2 = 1:4
        sensorInfo.zones(index).polygon(ind2).x =...
            CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
        sensorInfo.zones(index).polygon(ind2).y =...
            CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
    end
    sensorInfo.zones(index).delay =...
        CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
    sensorInfo.zones(index).extend =...
        CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
    sensorInfo.zones(index).enabled = true;
end




if nargout > 1
    % the next bytes are the track, zones, and channel info
    varargout{1} = ftell(fid);
end




fclose(fid);

