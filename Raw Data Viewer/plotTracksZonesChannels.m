function [pulseCount, unconstrainedHandles,...
    constrainedHandles, ghostHandles, channelOutputs] = plotTracksZonesChannels(haxis,...
    offset, fileName, sensorInfo, zoneHandles,...
    unconstrainedHandles, constrainedHandles, ghostHandles, unconstrainedDetections)
% [zoneHandles, channelHandles, unconstrainedHandles,...
%    constrainedHandles, ghostHandles] = ...
%    plotTracksZonesChannels(haxis, offset, fileName, sensorInfo, zoneHandles, channelHandles);
%
% This matlab function plots the zones, channels, and tracks for the given
% offset. No error checking is performed to verify the offset is good.
%
% Written by Steven Reeves
% September 16, 2014

convertToMph = sensorInfo.findPulsesPerSecond * 3600 / 5280 / 1e4;
trackZonesChannelsSupport = sensorInfo.supports.TrackZonesChannels;

fid = fopen(fileName, 'r');
pulseCount = 0;

if fid == -1
    return;
end
fseek(fid,offset,'bof');

% first read the pulse count
if trackZonesChannelsSupport
    pulseCount = fread(fid,1,'uint32',0,'b');
else
    pulseCount = 1;
end

prevConstrainedHandles = constrainedHandles;
if isempty(prevConstrainedHandles)
    prevConstrainedHandles = [];
else
    prevConstrainedStructs = get(prevConstrainedHandles,'UserData');
    prevConstrainedIds = zeros(1,length(prevConstrainedStructs));
    if length(prevConstrainedStructs) > 1
        for ind = 1:length(prevConstrainedStructs)
            prevConstrainedIds(ind) = prevConstrainedStructs{ind}.id;
        end
    else
        prevConstrainedIds = prevConstrainedStructs.id;
    end
end
constr_colors = {'b','m','k','c'};

prevUnconstrainedHandles = unconstrainedHandles;
if isempty(prevUnconstrainedHandles)
    prevUnconstrainedHandles = [];
else
    prevUnconstrainedStructs = get(prevUnconstrainedHandles,'UserData');
    prevUnconstrainedIds = zeros(1,length(prevUnconstrainedStructs));
    if length(prevUnconstrainedStructs) > 1
        for ind = 1:length(prevUnconstrainedStructs)
            prevUnconstrainedIds(ind) = prevUnconstrainedStructs{ind}.id;
        end
    else
        prevUnconstrainedIds = prevUnconstrainedStructs.id;
    end
end

prevGhostHandles = ghostHandles;
if isempty(prevGhostHandles)
    prevGhostHandles = [];
else
    prevGhostStructs = get(prevGhostHandles,'UserData');
    prevGhostIds = zeros(1,length(prevGhostStructs));
    if length(prevGhostStructs) > 1
        for ind = 1:length(prevGhostStructs)
            prevGhostIds(ind) = prevGhostStructs{ind}.ghostIndex;
        end
    else
        prevGhostIds = prevGhostStructs.ghostIndex;
    end
end

numChannels = 16;
% next is the channel outputs
if trackZonesChannelsSupport
    dataArray = fread(fid,2,'uint8');
    index = numChannels;
    byteIdx = 1;
    channelOutputs = false(1,numChannels);
    while index > 0
        for ind = 7:-1:0
            if bitand(dataArray(byteIdx),bitshift(1,ind)) ~= 0
                channelOutputs(index) = true;

            end
            index = index - 1;
        end
        byteIdx = byteIdx + 1;
    end


    % now get the zone handles
    dataArray = fread(fid,2,'uint8');
    index = length(zoneHandles);
    byteIdx = 1;
    while index > 0
        for ind = 7:-1:0
            if ishandle(zoneHandles{index})
                if bitand(dataArray(byteIdx),bitshift(1,ind)) ~= 0

                    set(zoneHandles{index},'FaceColor','r','FaceAlpha',0.25)

                else
                    set(zoneHandles{index},'FaceColor','w','FaceAlpha',0)
                end
            end
            index = index - 1;
        end
        byteIdx = byteIdx + 1;
    end
    
    numConstrainedTracks = fread(fid,1,'uint8');
    
    ctracks(1:numConstrainedTracks) = struct('center',0,'length',0,'lane',0,...
        'id',0,'state',0,'occluded',false,'speed',0,'lastPulseCount',0,'dataFront',...
        0,'dataBack',0);
    match_indices = zeros(1,numConstrainedTracks);
    constrainedHandles = zeros(1,numConstrainedTracks);
    for ind = 1:numConstrainedTracks
        ctracks(ind).center = CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
        ctracks(ind).length = CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
        ctracks(ind).lane = fread(fid,1,'uint8') + 1;
        ctracks(ind).id = fread(fid,1,'uint16',0,'b');
        dataArray = fread(fid,1,'uint8');
        ctracks(ind).state = bitand(dataArray,15);
        if bitand(dataArray,240) ~= 0
            ctracks(ind).occluded = true;
        end

        ctracks(ind).speed = CreateFloatFrom10Dot6(fread(fid,2,'uint8')) * convertToMph;
        ctracks(ind).lastPulseCount = fread(fid,1,'uint32',0,'b');
        ctracks(ind).dataFront = CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
        ctracks(ind).dataBack = CreateFloatFrom10Dot6(fread(fid,2,'uint8'));



    end

    track_ids = [ctracks.id];
    for ind = 1:length(prevConstrainedHandles)
        index = find(prevConstrainedIds(ind) == track_ids);
        if ~isempty(index)
            match_indices(index) = 1;
            constrainedHandles(index(end)) = prevConstrainedHandles(ind);
        else
            if ishandle(prevConstrainedHandles(ind))
                delete(prevConstrainedHandles(ind));
            end
        end
    end

    
    for ind = 1:numConstrainedTracks

        % convert the distance along the path to a cartesian point so we can 
        % plot it
        lane_num = bitand(ctracks(ind).lane,hex2dec('f'));
        [x, y] = sensorInfo.lanes(lane_num).DistAlongPathToCartesian(...
            [ctracks(ind).center-ctracks(ind).length/2,...
             ctracks(ind).center+ctracks(ind).length/2]);

        if match_indices(ind) == 1
            set(constrainedHandles(ind),'XData',x,'YData',y);
        else
            constrainedHandles(ind) = plot(haxis,x,y,'Color',constr_colors{...
                mod(ctracks(ind).id,4)+1},'LineWidth',4);
        end
        set(constrainedHandles(ind),'UserData',ctracks(ind));
    end


    numUnconstrainedTracks = fread(fid,1,'uint8');
    
    utracks(1:numUnconstrainedTracks) = struct('x',0,'y',0,'lane',0,...
        'id',0,'laneState',0,'multipath',false,'lastConstrTrackId',...
        0,'startPulseCountInLane',0,'minPeaksClaimed',false);
    match_indices = zeros(1,numUnconstrainedTracks);
    unconstrainedHandles = zeros(1,numUnconstrainedTracks);
    for ind = 1:numUnconstrainedTracks
        utracks(ind).x = CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
        utracks(ind).y = CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
        utracks(ind).id = fread(fid,1,'uint16',0,'b');
        dataArray = fread(fid,1,'uint8');
        utracks(ind).lane = bitand(dataArray,15) + 1;
        utracks(ind).laneState = bitshift(bitand(dataArray,48),-4);
        utracks(ind).multipath = logical(bitshift(bitand(dataArray,64),-6));
        utracks(ind).minPeaksClaimed = logical(bitshift(bitand(dataArray,128),-7));
        dataArray = fread(fid,2,'uint8');
        utracks(ind).lastConstrTrackId = dataArray(1)*256 + dataArray(2);
        utracks(ind).startPulseCountInLane = fread(fid,1,'uint32',0,'b');
    end

    track_ids = [utracks.id];
    for ind = 1:length(prevUnconstrainedHandles)
        index = find(prevUnconstrainedIds(ind) == track_ids);
        if ~isempty(index)
            match_indices(index(end)) = 1;
            unconstrainedHandles(index(end)) = prevUnconstrainedHandles(ind);
        else
            if ishandle(prevUnconstrainedHandles(ind))
                delete(prevUnconstrainedHandles(ind));
            end
        end
    end

    for ind = 1:numUnconstrainedTracks
        if(utracks(ind).multipath)
            plotColor = [.8,.2,.2];
        else
            plotColor = [.75,.75,.75];
        end

        if match_indices(ind) == 1
            set(unconstrainedHandles(ind),'XData',utracks(ind).x,'YData',...
                utracks(ind).y,'MarkerEdgeColor',plotColor);
        else
            unconstrainedHandles(ind) = plot(haxis,utracks(ind).x,utracks(ind).y,...
                'Marker','o','MarkerEdgeColor',plotColor,'LineStyle','none',...
                'LineWidth',1.5);
        end
        set(unconstrainedHandles(ind),'UserData',utracks(ind));
    end

    % now do the ghost tracks
    

    % plot the new ghost tracks
    x_offset = 6*[-1 -1  1  1 -1];
    y_offset = 6*[-1  1  1 -1 -1];

    numGhostTracks = fread(fid,1,'uint8');
    ghostTracks(1:numGhostTracks) = struct('creationReason',0,'x',0,'y',0,...
        'windowImageCounter',0,'numWindowImagesStalePeaks',0,...
        'numWindowImagesClaimedFreshPeaks',0,'numWindowImagesFreshPeaks',0,...
        'ghostIndex',0);
    %ghostHandles = zeros(1,numGhostTracks);
    for ind = 1:numGhostTracks
        ghostTracks(ind).creationReason = fread(fid,1,'uint8');
        ghostTracks(ind).x = CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
        ghostTracks(ind).y = CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
        ghostTracks(ind).windowImageCounter = fread(fid,1,'uint16');
        ghostTracks(ind).numWindowImagesStalePeaks = fread(fid,1,'uint16');
        ghostTracks(ind).numWindowImagesClaimedFreshPeaks = fread(fid,1,'uint16');
        ghostTracks(ind).numWindowImagesFreshPeaks = fread(fid,1,'uint16');
        if sensorInfo.fileDate >= datenum(2015,1,2)
            ghostTracks(ind).ghostIndex = fread(fid,1,'uint8');
        end
    end
    
    match_indices = zeros(1,numGhostTracks);
    
    % find all of the matching ghost tracks, if the file is new enough,
    % otherwise just delete all of the ghost handles
    if sensorInfo.fileDate >= datenum(2015,1,2)
        track_ids = [ghostTracks.ghostIndex];
        ghostHandles = zeros(1,numGhostTracks);
        for ind = 1:length(prevGhostHandles)
            index = find(prevGhostIds(ind) == track_ids);
            if ~isempty(index)
                match_indices(index) = 1;
                ghostHandles(index(end)) = prevGhostHandles(ind);
            else
                if ishandle(prevGhostHandles(ind))
                    delete(prevGhostHandles(ind));
                end
            end
        end
    else
        for ind = 1:length(ghostHandles)
            if ishandle(ghostHandles(ind))
                delete(ghostHandles(ind));
            end
        end
        ghostHandles = zeros(1,numGhostTracks);
    end
    
    
    for ind = 1:numGhostTracks
        plotColor = [0.9 0.9 0.2];
        
        
        
        if match_indices(ind) == 1
            prevGhostStruct = get(ghostHandles(ind),'UserData');
            prevPeaksClaimed = prevGhostStruct.numWindowImagesStalePeaks +...
                prevGhostStruct.numWindowImagesClaimedFreshPeaks;
            currentPeaksClaimed = ghostTracks(ind).numWindowImagesStalePeaks +...
                ghostTracks(ind).numWindowImagesClaimedFreshPeaks;
            if currentPeaksClaimed > prevPeaksClaimed
                plotColor = [0.9 0.9 0.2];
            else
                plotColor = [0.4 0.4 0.1];
            end
            set(ghostHandles(ind),'XData',ghostTracks(ind).x + x_offset,...
                'YData',ghostTracks(ind).y + y_offset,'Color',plotColor);
        else
            ghostHandles(ind) = plot(haxis,ghostTracks(ind).x + x_offset,...
                ghostTracks(ind).y + y_offset,'Color',plotColor,'LineWidth',2);
        end
        set(ghostHandles(ind),'UserData',ghostTracks(ind));
    end
else
    numPackets = fread(fid,1,'uint8');
    
    % this is the number of channels (should always be 16)
    numChannels = fread(fid,1,'uint8');
    channelOutputs = false(1,numChannels);
    for ind = 1:numChannels
        channelOutputs(ind) = logical(fread(fid,1,'uint8'));
    end
    
    numZones = fread(fid,1,'uint8');
    for ind = 1:numZones
        zoneOutput = logical(fread(fid,1,'uint8'));
        if ishandle(zoneHandles{ind})
            
            if zoneOutput
                set(zoneHandles{ind},'FaceColor','r','FaceAlpha',0.25);
            else
                set(zoneHandles{ind},'FaceColor','w','FaceAlpha',0);
            end
        end
    end
    
    
    ctracks = cell(numPackets-1,1);
    for packetIndex = 1:numPackets - 1
        % we just read over the number of packets here
        fread(fid,1,'uint8');
        numTracks = fread(fid,1,'uint8');
        ctracks{packetIndex}(1:numTracks) = struct('numTrackerPoints',0,...
            'laneId',20,'id',0,'x',zeros(1,6),'y',zeros(1,6));
        for trackerIndex = 1:numTracks
            numTrackerPoints = fread(fid,1,'uint8');
            for pointIndex = 1:numTrackerPoints
                ctracks{packetIndex}(trackerIndex).x(pointIndex) = ...
                    CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
                ctracks{packetIndex}(trackerIndex).y(pointIndex) = ...
                    CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
            end
            ctracks{packetIndex}(trackerIndex).numTrackerPoints = ...
                numTrackerPoints;
            ctracks{packetIndex}(trackerIndex).id = fread(fid,1,'uint16','b');
            ctracks{packetIndex}(trackerIndex).laneId = fread(fid,1,'uint8');
        end
    end
    
    ctracks = cell2mat(ctracks);
    ctracks = ctracks(:);
    numConstrainedTracks = length(ctracks);
    match_indices = zeros(1,numConstrainedTracks);
    constrainedHandles = zeros(1,numConstrainedTracks);
    track_ids = [ctracks.id];
    for ind = 1:length(prevConstrainedHandles)
        index = find(prevConstrainedIds(ind) == track_ids);
        if ~isempty(index)
            match_indices(index) = 1;
            constrainedHandles(index(end)) = prevConstrainedHandles(ind);
        else
            if ishandle(prevConstrainedHandles(ind))
                delete(prevConstrainedHandles(ind));
            end
        end
    end

    
    for ind = 1:numConstrainedTracks

        x = ctracks(ind).x(1:ctracks(ind).numTrackerPoints);
        y = ctracks(ind).y(1:ctracks(ind).numTrackerPoints);
        if match_indices(ind) == 1
            set(constrainedHandles(ind),'XData',x,'YData',y);
        else
            constrainedHandles(ind) = plot(haxis,x,y,'Color',constr_colors{...
                mod(ctracks(ind).id,4)+1},'LineWidth',4);
        end
        set(constrainedHandles(ind),'UserData',ctracks(ind));
    end
    
    
    numUnconstrainedPackets = fread(fid,1,'uint8');
    utracks = cell(numUnconstrainedPackets-1,1);
    for packetIndex = 1:numUnconstrainedPackets
        
        numTracks = fread(fid,1,'uint8');
        utracks{packetIndex}(1:numTracks) = struct('id',0,...
            'x',0,'y',0,'laneId',0,'multipath',0);
        for trackerIndex = 1:numTracks
            utracks{packetIndex}(trackerIndex).x = CreateFloatFrom10Dot6(...
                fread(fid,2,'uint8'));
            utracks{packetIndex}(trackerIndex).y = CreateFloatFrom10Dot6(...
                fread(fid,2,'uint8'));
            utracks{packetIndex}(trackerIndex).id = fread(fid,1,'uint16','b');
            utracks{packetIndex}(trackerIndex).laneId = fread(fid,1,'uint8');
            if unconstrainedDetections
                width = CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
                len = CreateFloatFrom10Dot6(fread(fid,2,'uint8'));
                fread(fid,4,'uint8');
            end
        end
        
        
        
        if packetIndex < numUnconstrainedPackets
            fread(fid,1,'uint8');
        end
    end
    
    utracks = cell2mat(utracks);
    utracks = utracks(:);
    numUnconstrainedTracks = length(utracks);
    
    match_indices = zeros(1,numUnconstrainedTracks);
    unconstrainedHandles = zeros(1,numUnconstrainedTracks);
    

    track_ids = [utracks.id];
    for ind = 1:length(prevUnconstrainedHandles)
        index = find(prevUnconstrainedIds(ind) == track_ids);
        if ~isempty(index)
            match_indices(index(end)) = 1;
            unconstrainedHandles(index(end)) = prevUnconstrainedHandles(ind);
        else
            if ishandle(prevUnconstrainedHandles(ind))
                delete(prevUnconstrainedHandles(ind));
            end
        end
    end

    for ind = 1:numUnconstrainedTracks
        if(utracks(ind).multipath)
            plotColor = [.8,.2,.2];
        else
            plotColor = [.75,.75,.75];
        end

        if match_indices(ind) == 1
            set(unconstrainedHandles(ind),'XData',utracks(ind).x,'YData',...
                utracks(ind).y,'MarkerEdgeColor',plotColor);
        else
            unconstrainedHandles(ind) = plot(haxis,utracks(ind).x,utracks(ind).y,...
                'Marker','o','MarkerEdgeColor',plotColor,'LineStyle','none',...
                'LineWidth',1.5);
        end
        set(unconstrainedHandles(ind),'UserData',utracks(ind));
    end
    
end



fclose(fid);