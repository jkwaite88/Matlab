function offsets = findDebugOffsets(fileName, initialOffset, sensorInfo)
% offset = findDebugOffsets(fileName);
%
% This matlab function if necessary creates the offsets array for the
% specified debug file, otherwise it reads the offsets array. It is assumed
% that the offsets file name has the same name as the fileName with the
% file extension .mat instead of .ssd
%
% Written by Steven Reeves
% September 16, 2014

dspVersion = sensorInfo.dspVersion;
trackZonesChannelsSupport = dspVersion >= datenum(2014,9,12);
numBytesConstrainedTrack = 18;
numBytesUnconstrainedTrack = 13;
fileDate = sensorInfo.fileDate;

computeLongTracks = false;

if fileDate >= datenum(2015,1,2)
    numBytesGhostTrack = 14;
else
    numBytesGhostTrack = 13;
end

if sensorInfo.IsRailSensor() && sensorInfo.supports.UnconstrainedDetections
    unconstrainedTrackBytes = 15;
else
    unconstrainedTrackBytes = 7;
end
matchend = regexp(fileName,'\.');

load_offsets = false;
offsets_file = [fileName(1:matchend(end)-1) '.mat'];
if exist(offsets_file,'file')
    offsets_info = dir(offsets_file);
    file_info = dir(fileName);
    if offsets_info.datenum >= file_info.datenum
        load_offsets = true;
    end
end


if load_offsets
    offsets = load(offsets_file,'offsets');
    offsets = offsets.offsets;
else
    fid = fopen(fileName,'r');
    fseek(fid,initialOffset,'bof');
    numTrackFrames = fread(fid,1,'uint32');
    offsets = zeros(1,numTrackFrames+1);
    offset_sum = ftell(fid);
    frame = 1;
    longTrackFrame = zeros(1,numTrackFrames);
    numLongTrackFrames = 0;
    startFrames = -1*ones(1,40);
    prevTrackIds = -1*ones(1,40);
    numFramesIds = zeros(1,40);
    % numTrackFrames actually represents the number of messages received.
    % For v1.5.0 and newer, this is equivalent to the number of track
    % frames. Older versions it means the number of messages received
    % (including multiple packets), so we use this variable to keep track
    % of the message count
    msgFrame = 1;
    while msgFrame <= numTrackFrames
        offsets(frame) = offset_sum;
        matchIds = false(1,40);
        if trackZonesChannelsSupport
            % read off the first 8 bytes (pulsecount, channel and zone outputs)
            fread(fid,8,'uint8');

            % now get the number of constrained tracks
            numConstrainedTracks = fread(fid,1,'uint8');
            % each constrained track is 18 bytes
            fread(fid,numBytesConstrainedTrack*numConstrainedTracks,'uint8');

            % now get the number of unconstrained tracks
            numUnconstrainedTracks = fread(fid,1,'uint8');
            % each constrained track is 13 bytes
            fread(fid,numUnconstrainedTracks*numBytesUnconstrainedTrack,'uint8');

            % finally get the number of ghost tracks
            numGhostTracks = fread(fid,1,'uint8');
            % each ghost track is 14 bytes
            fread(fid,numBytesGhostTrack*numGhostTracks,'uint8');

            % add to the offset sum
            offset_sum = offset_sum + 8 +...
                1 + numBytesConstrainedTrack*numConstrainedTracks +...
                1 + numBytesUnconstrainedTrack*numUnconstrainedTracks +...
                1 + numBytesGhostTrack*numGhostTracks;
            
            msgFrame = msgFrame + 1;
        else
            
            
            
            numPackets = fread(fid,1,'uint8');
            
            % read over the channel/zone outputs
            fread(fid,34,'uint8');
           
            
            offset_sum = offset_sum + 1 + 34;
            for packetIndex = 1:numPackets-1
                % get the num packets
                t = fread(fid,1,'uint8');
                numTracks = fread(fid,1,'uint8');
                offset_sum = offset_sum + 2;
                for ind = 1:numTracks
                    numTrackerPoints = fread(fid,1,'uint8');
                    % each tracker point uses 4 bytes plus 4 more
                    fread(fid,numTrackerPoints*4);
                    id = fread(fid,1,'uint16',0,'b');
                    if computeLongTracks
                        indices = find(id==prevTrackIds);
                        if ~isempty(indices)
                            % we have a match,
                            % so increment the number of frames
                            numFramesIds(indices(end)) = numFramesIds(indices(end)) + 1;

                            % mark it as a match
                            matchIds(indices(end)) = true;
                        else
                            % we have a new track id
                            indices = find(prevTrackIds==-1);
                            if ~isempty(indices)
                                prevTrackIds(indices(1)) = id;
                                matchIds(indices(1)) = true;
                                numFramesIds(indices(1)) = 1;
                                startFrames(indices(1)) = frame;
                            else
                                disp('Overflow error');
                            end
                        end
                    end
                    fread(fid,1,'uint8');
                    offset_sum = offset_sum + numTrackerPoints*4 + 3 + 1;
                end
            end
            
            numUnconstrPackets = fread(fid,1,'uint8');
            for packetIndex = 1:numUnconstrPackets
                numTracks = fread(fid,1,'uint8');
                offset_sum = offset_sum + 2;
                for ind = 1:numTracks
                    % x,y data
                    fread(fid,4,'uint8');
                    
                    % tracker id
                    id = fread(fid,1,'uint16',0,'b');
                    
                    
                    
                    fread(fid,unconstrainedTrackBytes-6,'uint8');
                    offset_sum = offset_sum + unconstrainedTrackBytes;
                end
                if packetIndex < numUnconstrPackets
                    fread(fid,1,'uint8');
                end
            end
            msgFrame = msgFrame + numUnconstrPackets + numPackets;
        end
        
        if computeLongTracks
            longFrame = 100;
            if any(numFramesIds(matchIds==false) > longFrame)
                numLongTrackFrames = numLongTrackFrames + 1;
                longTrackFrame(numLongTrackFrames) = startFrames(matchIds==false...
                    & numFramesIds > longFrame);
            end
            prevTrackIds(matchIds==false) = -1;
            numFramesIds(matchIds==false) = 0;
        end
        frame = frame + 1;
    end
    % add the last frame in, so we can know where the thresholds, etc.
    % start
    offsets(frame) = offset_sum;
%     offsets(frame) = hex2dec('e2e0') - 4;
% offsets(frame) = hex2dec('c260') - 4;
    offsets(frame+1:end) = [];
    fclose(fid);
    save(offsets_file,'offsets');
    if computeLongTracks
        longTrackFrame(numLongTrackFrames+1:end) = [];
        assignin('base','longTrackFrame',longTrackFrame);
    end
end

