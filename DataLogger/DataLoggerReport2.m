%% DataLogger Report
clear
%% Read in data
C = initConstants;

dataFile = 'C:\Data\DataLogger\Logs\Log_2021-01-07.txt';
data = readtable(dataFile);
%profile on

% %invert some of the data
data.R1Z1 = ~data.R1Z1;
data.R1Z2 = ~data.R1Z2;
data.R1Z3 = ~data.R1Z3;
data.R1Z4 = ~data.R1Z4;
data.R2Z1 = ~data.R2Z1;
data.R2Z2 = ~data.R2Z2;
data.R2Z3 = ~data.R2Z3;
data.R2Z4 = ~data.R2Z4;
data.LOOP1 = ~data.LOOP1;
data.LOOP2 = ~data.LOOP2;
data.LOOP3 = ~data.LOOP3;
data.LOOP4 = ~data.LOOP4;
data.XR = ~data.XR;
data.IR = ~data.IR;

%script settings
numZones = 2; % 1= all loops combined into one zone, all zones from each radar combined into 1 zone; 2=all loops and each radar combined into one zone for each direction of travel 

numRadars = 2;

%create detectionData structure to hold detection data
detectionData.creationTime = now;
detectionData.radarMissedCount = zeros(numZones,numRadars);  
detectionData.radarMissedTime = duration(0, 0, 0, 0) * ones(1, numZones, numRadars);
detectionData.radarMissedTime.Format = 'hh:mm:ss.SSS';
detectionData.allRadarsMissedCount = zeros(1, numZones);
detectionData.allRadarsMissedTime = duration(0, 0, 0, 0)* ones(1, numZones);
detectionData.allRadarsMissedTime.Format = 'hh:mm:ss.SSS';
detectionData.loopCount = zeros(1,numZones); 

combinedData = combineData(data, numZones);

gapLimitSeconds = 1;
cleanedLoopData = cleanLoopEvents(combinedData, gapLimitSeconds);

detectionData = findMissedCalls(cleanedLoopData, detectionData);
%detectionData = findFalseCalls(cleanedLoopData, detectionData, C);


figureNum = 1;
plotData(data, figureNum);

figureNum = 2;
plotCombinedData(combinedData, figureNum);

figureNum = 3;
plotCleanedData(cleanedLoopData, detectionData, figureNum);


%%
writeReport(detectionData, cleanedLoopData, dataFile);
if(0)
    radarMissed = array2table([squeeze(detectionData.radarMissedTime(:,1,1)) squeeze(detectionData.radarMissedTime(:,1,2)) squeeze(detectionData.radarMissedTime(:,2,1)) squeeze(detectionData.radarMissedTime(:,2,2)) ],'VariableNames', {'R1Z1missed', 'R1Z2missed', 'R2Z1missed', 'R2Z2missed'});
    writetable(radarMissed, 'radarMissed.xlsx')
end
%%
function C = initConstants
        C.IDLE = 4;
        C.START = 5;
        C.CONTINUING = 6;
        C.STOP = 7;

        C.INACTIVE = 0;
        C.ACTIVE = 1;
end


%This function will plot a subplot of data from each radar and loop zone
%group
function plotData(data, figureNum)

date = data.Date(1);

figure(figureNum)
clf
rows = 4;
cols = 1;

tlt = tiledlayout(rows,cols);
ax1 = nexttile;
hold on
%plot data
stairs(ax1, data.Time, data.LOOP1, 'b', 'linewidth', 1.5)
stairs(ax1, data.Time, data.R1Z1, 'g', 'linewidth', 1.0)
stairs(ax1, data.Time, data.R2Z1, 'r', 'linewidth', 0.5)
ylim([0 1.1])
legend('Loop1', 'R1Z1', 'R2Z1', 'location', 'northeast')
title(datestr(date))

ax2 = nexttile;
hold on
%invert data and plot
stairs(ax2, data.Time, data.LOOP2, 'b', 'linewidth', 1.5)
stairs(ax2, data.Time, data.R1Z2, 'g', 'linewidth', 1.0)
stairs(ax2, data.Time, data.R2Z2, 'r', 'linewidth', 0.5)
ylim([0 1.1])

ax3 = nexttile;
hold on
%invert data and plot
stairs(ax3, data.Time, data.LOOP3, 'b', 'linewidth', 1.5)
stairs(ax3, data.Time, data.R1Z3, 'g', 'linewidth', 1.0)
stairs(ax3, data.Time, data.R2Z3, 'r', 'linewidth', 0.5)
ylim([0 1.1])

ax4 = nexttile;
hold on
%invert data and plot
stairs(ax4, data.Time, data.LOOP4, 'b', 'linewidth', 1.5)
stairs(ax4, data.Time, data.R1Z4, 'g', 'linewidth', 1.0)
stairs(ax4, data.Time, data.R2Z4, 'r', 'linewidth', 0.5)
ylim([0 1.1])


tlt.Padding = "none";
tlt.TileSpacing = "none";
% Link the axes. Add title and labels.
linkaxes([ax1,ax2,ax3,ax4],'x');
end


%This function will plot a subplot of data from each radar and loop zone
%group
function fig = plotCombinedData(data, figureNum)

    date = data.date(1);
    numZones = length(data.loop);

    figure(figureNum)
    clf
    cols = 1;
    axList = [];
    tlt = tiledlayout(numZones,1);
    for i = 1:numZones

        fig.ax(i) = nexttile;
        axList = [axList fig.ax(i)];
        hold on
        %plot data
        loopAx(i) = stairs(fig.ax(i), data.time, data.loop(i).data, 'b', 'linewidth', 1.5);
        r1Ax(i)   = stairs(fig.ax(i), data.time, data.radar(1).zone(i).data, 'g', 'linewidth', 1.0);
        r2Ax(i)   = stairs(fig.ax(i), data.time, data.radar(2).zone(i).data, 'r', 'linewidth', 0.5);

        ylim([0 1.1])
        if i == 1
            title(datestr(date))
            legend([loopAx(i) r1Ax(i) r2Ax(i)], sprintf('Loop%d',i), sprintf('R1Z%d',i), sprintf('R2Z%d', i), 'location', 'northeast')
        end

    end

tlt.Padding = "none";
tlt.TileSpacing = "none";
% Link the axes. Add title and labels.

linkaxes(axList,'x');
end

function plotCleanedData(data, detectionData, figureNum)
    date = data.date(1);
    numZones = length(data.loop);
    
    radarPlotSymbols = ['o'; 'x'];
    radarPlotColors = ['g'; 'r'];
    radarPlotLineWidth = [1.0; 0.5];
    
    figure(figureNum)
    clf
    rows = numZones;
    cols = 1;
    axList = [];
    tlt = tiledlayout(numZones,1);
    for i = 1:numZones

        fig.ax(i) = nexttile;
        axList = [axList fig.ax(i)];
        hold on
        %plot data
        loopAx(i) = stairs(fig.ax(i), data.time, data.loop(i).data, 'b', 'linewidth', 1.5);
        for radarNum = 1:2
            rdrAx(i, radarNum)   = stairs(fig.ax(i), data.time, data.radar(radarNum).zone(i).data, 'color', radarPlotColors(radarNum), 'linewidth', radarPlotLineWidth(radarNum));
            ind = find(detectionData.radarMissedTime(:,i,radarNum) ~= duration(0, 0, 0, 0));
            numToPlot = length(ind);
            if numToPlot > 0
                missedAx(i, radarNum) = plot(detectionData.radarMissedTime(1:numToPlot,i,radarNum), 1.02*ones(numToPlot,1), 'color', radarPlotColors(radarNum), 'linestyle', 'none', 'marker', radarPlotSymbols(radarNum));
            else
                missedAx(i, radarNum) = plot(duration(0, 0, 0, 0), -0.2, 'color', radarPlotColors(radarNum), 'linestyle', 'none', 'marker', radarPlotSymbols(radarNum));
            end
        end
        ind = find(detectionData.allRadarsMissedTime(:,i) ~= duration(0, 0, 0, 0));
        numToPlot = length(ind);
        if numToPlot > 0
            allRadarMisedAx(i) = plot(detectionData.allRadarsMissedTime(ind,i), 1.09*ones(numToPlot,1), 'color', 'black', 'linestyle', 'none', 'marker', 'd');
        else
            allRadarMisedAx(i) = plot(duration(0, 0, 0, 0), -0.2, 'color', 'black', 'linestyle', 'none', 'marker', 'd'); % plot one junk marker so we can still have a value for the legend
        end
        
        ylim([0 1.1])
        if i == 1
            title(datestr(date))
            legend([loopAx(i) rdrAx(i,1) rdrAx(i,2) missedAx(i,1) missedAx(i,2), allRadarMisedAx(1)], sprintf('Loop%d',i), sprintf('R1Z%d',i), sprintf('R2Z%d', i), sprintf('R1 missed'), sprintf('R2 missed'), sprintf('All missed'), 'location', 'northeast')
        end
        
    end
    
    

    tlt.Padding = "none";
    tlt.TileSpacing = "none";
    % Link the axes. Add title and labels.

    linkaxes(axList,'x');
    
end

function combinedData = combineData(data, numZones)
    
    combinedData.date = data.Date;
    combinedData.time = data.Time;
    combinedData.xr = data.XR;
    combinedData.ir = data.IR;
    
    if numZones == 1
        combinedData.loop(1).data = data.LOOP1 | data.LOOP2 | data.LOOP3 | data.LOOP4;
        combinedData.radar(1).zone(1).data = data.R1Z1 | data.R1Z2 | data.R1Z3 | data.R1Z4;
        combinedData.radar(2).zone(1).data = data.R2Z1 | data.R2Z2 | data.R2Z3 | data.R2Z4;
    elseif numZones == 2    
        combinedData.loop(1).data = data.LOOP1 | data.LOOP2;
        combinedData.loop(2).data = data.LOOP3 | data.LOOP4;
        combinedData.radar(1).zone(1).data = data.R1Z1 | data.R1Z2;
        combinedData.radar(1).zone(2).data = data.R1Z3 | data.R1Z4;
        combinedData.radar(2).zone(1).data = data.R2Z1 | data.R2Z2;
        combinedData.radar(2).zone(2).data = data.R2Z3 | data.R2Z4;
    elseif numZones == 4
        combinedData.loop(1).data = data.LOOP1;
        combinedData.loop(2).data = data.LOOP2;
        combinedData.loop(3).data = data.LOOP3;
        combinedData.loop(4).data = data.LOOP4;
        combinedData.radar(1).zone(1).data = data.R1Z1;
        combinedData.radar(1).zone(2).data = data.R1Z2;
        combinedData.radar(1).zone(3).data = data.R1Z3;
        combinedData.radar(1).zone(4).data = data.R1Z4;
        combinedData.radar(2).zone(1).data = data.R2Z1;
        combinedData.radar(2).zone(2).data = data.R2Z2;
        combinedData.radar(2).zone(3).data = data.R2Z3;
        combinedData.radar(2).zone(4).data = data.R2Z4;
        
    end
    
    if numZones == 1
        ind = find(combinedData.loop(1).data(1:(end-1)) == combinedData.loop(1).data(2:end,1) & ...
                   combinedData.radar(1).zone(1).data(1:(end-1)) == combinedData.radar(1).zone(1).data(2:end) & ...
                   combinedData.radar(2).zone(1).data(1:(end-1)) == combinedData.radar(2).zone(1).data(2:end));
    elseif numZones == 2
        ind = find(combinedData.loop(1).data(1:(end-1)) == combinedData.loop(1).data(2:end,1) & ...
                   combinedData.loop(2).data(1:(end-1)) == combinedData.loop(2).data(2:end,1) & ...
                   combinedData.radar(1).zone(1).data(1:(end-1)) == combinedData.radar(1).zone(1).data(2:end) & ...
                   combinedData.radar(1).zone(2).data(1:(end-1)) == combinedData.radar(1).zone(2).data(2:end) & ...
                   combinedData.radar(2).zone(1).data(1:(end-1)) == combinedData.radar(2).zone(1).data(2:end) & ...
                   combinedData.radar(2).zone(2).data(1:(end-1)) == combinedData.radar(2).zone(2).data(2:end));
    elseif numZones == 4
        ind = find(combinedData.loop(1).data(1:(end-1)) == combinedData.loop(1).data(2:end,1) & ...
                   combinedData.loop(2).data(1:(end-1)) == combinedData.loop(2).data(2:end,1) & ...
                   combinedData.loop(3).data(1:(end-1)) == combinedData.loop(3).data(2:end,1) & ...
                   combinedData.loop(4).data(1:(end-1)) == combinedData.loop(4).data(2:end,1) & ...
                   combinedData.radar(1).zone(1).data(1:(end-1)) == combinedData.radar(1).zone(1).data(2:end) & ...
                   combinedData.radar(1).zone(2).data(1:(end-1)) == combinedData.radar(1).zone(2).data(2:end) & ...
                   combinedData.radar(1).zone(3).data(1:(end-1)) == combinedData.radar(1).zone(3).data(2:end) & ...
                   combinedData.radar(1).zone(4).data(1:(end-1)) == combinedData.radar(1).zone(4).data(2:end) & ...
                   combinedData.radar(2).zone(1).data(1:(end-1)) == combinedData.radar(2).zone(1).data(2:end) & ...
                   combinedData.radar(2).zone(2).data(1:(end-1)) == combinedData.radar(2).zone(2).data(2:end) & ...
                   combinedData.radar(2).zone(3).data(1:(end-1)) == combinedData.radar(2).zone(3).data(2:end) & ...
                   combinedData.radar(2).zone(4).data(1:(end-1)) == combinedData.radar(2).zone(4).data(2:end));
    end
    %delete duplicate lines

    if length(ind)>0
        combinedData.date(ind+1) = [];
        combinedData.time(ind+1) = [];
        combinedData.xr(ind+1) = [];
        combinedData.ir(ind+1) = [];
        if numZones == 1
            combinedData.loop(1).data(ind+1) = [];
            combinedData.radar(1).zone(1).data(ind+1) = [];
            combinedData.radar(2).zone(1).data(ind+1) = [];
        elseif numZones == 2
            combinedData.loop(1).data(ind+1) = [];
            combinedData.loop(2).data(ind+1) = [];
            combinedData.radar(1).zone(1).data(ind+1) = [];
            combinedData.radar(1).zone(2).data(ind+1) = [];
            combinedData.radar(2).zone(1).data(ind+1) = [];
            combinedData.radar(2).zone(2).data(ind+1) = [];
        end
    end
    breakhere = 1;
end

%This function will change to inactive states that have durations less than
%the gapLimit to an active state
function cleanedLoopData = cleanLoopEvents(combinedData, gapLimt)
    combinedData_array = zeros(size(combinedData));
    
    cleanedLoopData = combinedData; %initialize
    rows = size(combinedData.loop(1).data,1);
    
    for loopNum = 1:length(combinedData.loop)
        inactive = false;
        active = true;
        lastVehicleState = inactive;
        lastActiveTime = -1000;
        lastActiveTimeRow = 0;
        for i = 1:rows
            if combinedData.time(i) == duration(0, 7, 5, 075)
                breakhere = 1;
            end
            vehicleState = combinedData.loop(loopNum).data(i);
            if ( (vehicleState == active) && (lastVehicleState == inactive) )
                timeGap = combinedData.time(i) - lastActiveTime;
                if (timeGap < seconds(gapLimt))
                    %change previous inactive state(s) to active
                    for j = (lastActiveTimeRow):(i-1)
                        cleanedLoopData.loop(loopNum).data(j) = active;
                    end
                end
                lastVehicleState = active;
                lastActiveTime = combinedData.time(i);
                lastActiveTimeRow = i;
            elseif (vehicleState == active)
                lastVehicleState = active;
                lastActiveTime = combinedData.time(i);
                lastActiveTimeRow = i;
            elseif ( (vehicleState == inactive) && (lastVehicleState == active) ) 
                lastVehicleState = inactive;  
                lastActiveTime = combinedData.time(i);% the vehicle is active until the moment it goes inactive
                lastActiveTimeRow = i;
            else %newVehicleState == inactive
                 lastVehicleState = inactive;  

            end

        end
    end
    
end

%This function will change to inactive states that durations are less than
%the gapLimit to and active state
function detectionData = findMissedCalls(data, detectionData)
    rows = size(data.loop(1).data,1);
    numZones = length(data.loop);
    
    callDuratonBuffer = duration(0, 0, 2, 0);
    
    idle = 4;
    start = 5;
    stop = 6;
    
    inactive = 0;
    active = 1;
    
    for zone = 1:numZones
        
        loopDetctionStartRow = 0;
        loopDetctionStopRow = 0;
        loopDetectionState  = idle;
        for i = 1:rows
            loopState = data.loop(zone).data(i);
            if ((loopState == active) && (loopDetectionState == idle))
                loopDetectionState = start;
                loopDetctionStartRow = i;
            elseif ((loopState == inactive) && (loopDetectionState == start))
                loopDetectionState = stop;
                loopDetctionStopRow = i;
                detectionData.loopCount(zone) = detectionData.loopCount(zone) + 1;
            end
            if loopDetectionState == stop
                %debug if statement
                if data.time(loopDetctionStopRow) == duration(10,47,51,504)
                    breakhere = 1;
                end
                
                radarMissed = false(2,1);
                for radarNum = 1:2
                    %compare loop detection to radar for overlap
                    %From the loop stop time search backward in time for the next previous radar detection start time
                    j = loopDetctionStopRow;
                    lastRadarState = idle;
                    radarDetectStartRow = 0;
                    radarDetectStopRow = 0;
                    while j>0
                        radarState = data.radar(radarNum).zone(zone).data(j);
                        if (radarState == active) && (lastRadarState == idle)
                            lastRadarState = active;
                            radarDetectStartRow = j;
                        elseif(radarState == active) && (lastRadarState == active)
                            radarDetectStartRow = j;
                        elseif(radarState == inactive) && (lastRadarState == active)
                            break;
                        end
                        j = j - 1;
                    end
                    lastRadarState = start;
                    if j == 0
                        radarDetectStartRow = 1; % the detection start high
                    end
                    
                    %find radar start time, search forward to find stop time
                    j = radarDetectStartRow;
                    while j <= rows
                        radarState = data.radar(radarNum).zone(zone).data(j);
                        if (radarState == active) && (lastRadarState == start)
                            lastRadarState = active;
                        elseif (radarState == active) && (lastRadarState == active)
                            %stay active
                        elseif (radarState == inactive) && (lastRadarState == active)
                            lastRadarState = stop;
                            radarDetectStopRow = j;
                            break;
                        end
                       j = j + 1; 
                    end

                    %determineif loop detection and radar detection overlap
                    if (data.time(radarDetectStartRow) <= (data.time(loopDetctionStopRow)+callDuratonBuffer)) && ((data.time(loopDetctionStartRow)-callDuratonBuffer) <= data.time(radarDetectStopRow))
                        %overlap - verified detection
                        previousDetectionOverlap = true;
                    else
                        %no overlap - missed radar detection
                        previousDetectionOverlap = false;
                    end
                    
                    %%%%%%
                    %compare loop detection to radar for overlap
                    %From the loop start time search forward in time for the next radar detection stop time
                    j = loopDetctionStartRow;
                    lastRadarState = idle;
                    radarDetectStartRow = 0;
                    radarDetectStopRow = 0;
                    while j <= rows
                        radarState = data.radar(radarNum).zone(zone).data(j);
                        if (radarState == active) && (lastRadarState == idle)
                            lastRadarState = active;
                            %radarDetectStopRow = j;
                        elseif(radarState == active) && (lastRadarState == active)
                        elseif(radarState == inactive) && (lastRadarState == active)
                            radarDetectStopRow = j;
                            break;
                        end
                        j = j + 1;
                    end
                    lastRadarState = stop;

                    %find radar start time
                    j = radarDetectStopRow;
                    while j >0 
                        radarState = data.radar(radarNum).zone(zone).data(j);
                        if (radarState == active) && (lastRadarState == stop)
                            lastRadarState = active;
                            radarDetectStartRow = j;
                        elseif (radarState == active) && (lastRadarState == active)
                            %stay active
                            radarDetectStartRow = j;
                        elseif (radarState == inactive) && (lastRadarState == active)
                            lastRadarState = start;
                            break;
                        end
                       j = j - 1; 
                    end

                    %determineif loop detection and radar detection overlap
                    if (data.time(radarDetectStartRow) <= (data.time(loopDetctionStopRow)+callDuratonBuffer)) && ((data.time(loopDetctionStartRow)-callDuratonBuffer) <= data.time(radarDetectStopRow))
                        %overlap - verified detection
                        nextDetectionOverlap = true;
                    else
                        %no overlap - missed radar detection
                        nextDetectionOverlap = false;
                    end
                    if (nextDetectionOverlap == false) && (previousDetectionOverlap == false)
%                    if (previousDetectionOverlap == false)
                        radarMissed(radarNum) = true;
                        detectionData.radarMissedCount(zone,radarNum) = detectionData.radarMissedCount(zone,radarNum) + 1;
                        detectionData.radarMissedTime(detectionData.radarMissedCount(zone,radarNum), zone, radarNum) = (data.time(loopDetctionStartRow) + data.time(loopDetctionStopRow))/2;
                    end                    
                    
                    loopDetectionState  = idle;
                end
                if isempty(find(radarMissed == false)) % if both radar missed detection
                    detectionData.allRadarsMissedCount(zone) = detectionData.allRadarsMissedCount(zone) + 1;
                    detectionData.allRadarsMissedTime(detectionData.allRadarsMissedCount(zone),zone) = (data.time(loopDetctionStartRow) + data.time(loopDetctionStopRow))/2;
                end
            end
        end


    end

end

%This function will cycle through all radar events and check to see if
%there is an overlapping loop event. Radar events with no overlapping loop
%event will create a false event call.
function detectionData = findFalseCalls(data, detectionData, C)
    rows = size(data.loop(1).data,1);
    numZones = length(data.loop);
    numRadars = 2;
    
    callDuratonWindow = duration(0, 0, 1, 0);
    callDuratonWindow.Format = 'hh:mm:ss.SSS';
    
   
   
    detector = [];
    detector = resetDetection(detector, C);
    
    for radar = 1:numRadars
        detector = resetDetectorDetection(detector, C);
    
        for row = 1:rows
             newDetectorData = data.radar(zone).data(row);
             detector = updateDetectorState(detector, newDetectorData, row);
             if detecor.detectionState == C.STOP
                 for zone = 1:numZones
                 
                 end
                 
                 detecor.detectionState = C.IDLE;
             end
        end
        
    end

end

function detector = updateDetectorState(detector, newDetectorData, row)
    detector.detectionState = newDetectorData;
    if ((detector.detectionState == C.ACTIVE) && (detector.detectionLastState == C.IDLE))
        detector.detectionState = C.START;
        detector.detectionStartRow = row;
    elseif((detector.detectionState == C.ACTIVE) && (detector.detectionLastState == C.START))
        detector.detectionState = C.CONTINUING;
    elseif ((loopState == C.INACTIVE) && ((detector.detectionLastState == C.START)||(detector.detectionLastState == C.CONTINUING)) )
        detector.detectionState = C.STOP;
        detector.detectionStopRow = row;
        detector.detectionCount(zone) = detectionData.loopCount(zone) + 1;
    end
    detector.detectionLastState = detector.detectionState;
end

function detector = resetDetectorDetection(detector, C)
    detector.detectionStartRow = 0;
    detector.detectionStopRow = 0;
    detector.detectionState = C.IDLE;
    detector.detectionLastState = C.IDLE;
end

function detector = resetDetection(detector, C)
    detector = resetDetectorDetection(detector, C);
    detector.detectionCount = 0;
end

function writeReport(detectionData, cleanedLoopData, dataFileName)
    [filepath,fileName,fileExt] = fileparts(dataFileName);

    numZones = length(cleanedLoopData.loop);
    numRadars = length(cleanedLoopData.radar);
    
    reportFileName = strcat(filepath, '\', fileName, '_Report', fileExt);
    reportFileId = fopen(reportFileName, 'w');
    date = cleanedLoopData.date(1);
    fprintf(reportFileId, 'Date: %10s\n\n', date);
    for i = 1:numZones
        fprintf(reportFileId, 'Loop%d Events: %4d\n', i, detectionData.loopCount(i) );
    end
    fprintf(reportFileId, '\n' );
    
    fprintf(reportFileId, 'Radar Missed counts compared to Loops\n');
    
    fprintf(reportFileId, '     ');
    for radar = 1:numRadars
        fprintf(reportFileId, '   Radar%d', radar);
    end
    fprintf(reportFileId, '   AllRadars');
    fprintf(reportFileId, '\n');
    
    for zone = 1:numZones
        fprintf(reportFileId, 'Loop%d', zone);
        for radar = 1:numRadars
            fprintf(reportFileId, '      %3d', detectionData.radarMissedCount(zone,radar));
        end
        fprintf(reportFileId, '         %3d', detectionData.allRadarsMissedCount(zone));
        fprintf(reportFileId, '\n');
    end
    fprintf(reportFileId, '\n');
    
    
    
    fclose(reportFileId);
    
    
    
end