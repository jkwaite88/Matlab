%% DataLogger Report
clear
%% Read in data
dataFile = 'C:\Data\DataLogger\Logs\Log_2021-01-07.txt';

data = readtable(dataFile);
%profile on

%invert some of the data
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

%create detectionData structure to hold detection data
detectionData.creationTime = now;
detectionData.radarMissedCount = zeros(2,2);    
detectionData.loopCount = zeros(1,2); 

plotData(data);

combinedData = combineData(data);
figureNum = 2;
plotCombinedData(combinedData, figureNum);

columns = [3 4];
gapLimitSeconds = 1;
cleanedLoopData = cleanLoopEvents(combinedData, columns, gapLimitSeconds);
figureNum = 3;
fig3 = plotCombinedData(cleanedLoopData, figureNum);

detectionData = findMissedCalls(cleanedLoopData, detectionData);

plotDetectionData(detectionData, figureNum, fig3);
%%
writeReport(detectionData, cleanedLoopData, dataFile);


%%

%This function will plot a subplot of data from each radar and loop zone
%group
function plotData(data)

date = data.Date(1);

figure(1)
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

date = data.Date(1);

figure(figureNum)
clf
rows = 2;
cols = 1;

tlt = tiledlayout(rows,cols);
fig.ax(1) = nexttile;
hold on
%plot data
L1P1 = stairs(fig.ax(1), data.Time, data.LOOP1, 'b', 'linewidth', 1.5);
L1P2 = stairs(fig.ax(1), data.Time, data.R1Z1, 'g', 'linewidth', 1.0);
L1P3 = stairs(fig.ax(1), data.Time, data.R2Z1, 'r', 'linewidth', 0.5);
ylim([0 1.1])
%legend([L1P1 L1P2 L1P3], 'Loop1', 'R1Z1', 'R2Z1', 'location', 'northeast')
title(datestr(date))

fig.ax(2) = nexttile;
hold on
%invert data and plot
L2P1 = stairs(fig.ax(2), data.Time, data.LOOP2, 'b', 'linewidth', 1.5);
L2P2 = stairs(fig.ax(2), data.Time, data.R1Z2, 'g', 'linewidth', 1.0);
L2P3 = stairs(fig.ax(2), data.Time, data.R2Z2, 'r', 'linewidth', 0.5);
ylim([0 1.1])
%legend([L2P1 L2P2 L2P3], 'Loop2', 'R1Z2', 'R2Z2', 'location', 'northeast')

tlt.Padding = "none";
tlt.TileSpacing = "none";
% Link the axes. Add title and labels.
linkaxes([fig.ax(1), fig.ax(2)],'x');
end



function combinedData = combineData(data)
    
    LOOP1 = data.LOOP1 | data.LOOP2;
    LOOP2 = data.LOOP3 | data.LOOP4;
    R1Z1 = data.R1Z1 | data.R1Z2;
    R1Z2 = data.R1Z3 | data.R1Z4;
    R2Z1 = data.R2Z1 | data.R2Z2;
    R2Z2 = data.R2Z3 | data.R2Z4;
    Date = data.Date;
    Time = data.Time;
    
    ind = find(LOOP1(1:(end-1)) == LOOP1(2:end) & LOOP2(1:(end-1)) == LOOP2(2:end) & ...
        R1Z1(1:(end-1)) == R1Z1(2:end) & R1Z2(1:(end-1)) == R1Z2(2:end) & ...
        R2Z1(1:(end-1)) == R2Z1(2:end) & R2Z2(1:(end-1)) == R2Z2(2:end));
    
    combinedData = table(Date,Time,LOOP1,LOOP2,R1Z1,R1Z2,R2Z1,R2Z2);
    %delete duplicate lines
    combinedData((ind+1),:) = [];
    breakhere = 1;
end

%This function will change to inactive states that have durations less than
%the gapLimit to an active state
function cleanedLoopData = cleanLoopEvents(combinedData, columns, gapLimt)
    combinedData_array = zeros(size(combinedData));
    combinedData_array(:,3:end) = table2array(combinedData(:,3:end));
    
    cleanedLoopData = combinedData; %initialize
    rows = size(combinedData,1);
    
    for column = columns
        inactive = false;
        active = true;
        lastVehicleState = inactive;
        lastActiveTime = -1000;
        for i = 1:rows
            %newVehicleState = combinedData.LOOP1(i);
            %newVehicleState = combinedData{i,column};
            %newVehicleState = combinedData.(column)(i);
            newVehicleState = combinedData_array(i,column);
            if ( (newVehicleState == active) && (lastVehicleState == inactive) )
                timeGap = combinedData.Time(i) - lastActiveTime;
                if (timeGap < seconds(gapLimt))
                    %change previous inactive state(s) to active
                    for j = (lastActiveTimeRow + 1):(i-1)
                        %cleanedLoopData{j,column} = active;
                        cleanedLoopData.(column)(j) = active;
                    end
                end
                lastVehicleState = active;
                lastActiveTime = combinedData.Time(i);
                lastActiveTimeRow = i;
            elseif (newVehicleState == active)
                lastVehicleState = active;
                lastActiveTime = combinedData.Time(i);
                lastActiveTimeRow = i;
            else %newVehicleState == inactive
                 lastVehicleState = inactive;  

            end

        end
    end
    
end

%This function will change to inactive states that durations are less than
%the gapLimit to and active state


%This function will find when the loops indicated a call and the radar did
%not.
%Loops 1 and 2 will be combined for west bound traffic
%Loops 3 and 4 will be combined for east bound traffic
%Radar zones 1 and 2 will be combined for west bound traffic
%Radar zones 3 and 4 will be combined for east bound traffic
function detectionData = findMissedCalls(data, detectionData)
    rows = size(data,1);
    callDuratonBuffer = duration([ 0 0 2]);
    detect = table2array(data(:,3:end)); %indexing into the table was slow so this is used to speed things up
    
    idle = 4;
    start = 5;
    stop = 6;
    inactive = 0;
    active = 1;
    
    loop = [1 2];%columns for loops
    %radar1 = [3 4];    
    %radar2 = [5 6];
    radar = [[3 4]; [5 6]];%columns for radar1 and radar2
    
    for zone = 1:2
        
        loopDetctionStartRow = 0;
        loopDetctionStopRow = 0;
        loopDetectionState  = idle;
        for i = 1:rows
            if ((detect(i,loop(zone)) == active) && (loopDetectionState == idle))
                loopDetectionState = start;
                loopDetctionStartRow = i;
            elseif ((detect(i,loop(zone)) == inactive) && (loopDetectionState == start))
                loopDetectionState = stop;
                loopDetctionStopRow = i;
                detectionData.loopCount(zone) = detectionData.loopCount(zone)  + 1;
            end
            if loopDetectionState == stop
                %debug if statement
                if data.Time(loopDetctionStopRow) == duration(10,47,51,504)
                    breakhere = 1;
                end
                
                for radarNum = 1:2
                    %compare loop detection to radar for overlap
                    %From the loop stop time search backward in time for the next previous radar detection start time
                    j = loopDetctionStopRow;
                    radarState = idle;
                    radarDetectStartRow = 0;
                    radarDetectStopRow = 0;
                    while j>0
                        if (detect(j,radar(radarNum, zone)) == active) && (radarState == idle)
                            radarState = active;
                            radarDetectStartRow = j;
                        elseif(detect(j,radar(radarNum, zone)) == active) && (radarState == active)
                            radarDetectStartRow = j;
                        elseif(detect(j,radar(radarNum, zone)) == inactive) && (radarState == active)
                            break;
                        end
                        j = j - 1;
                    end
                    radarState = start;

                    %find radar stop time
                    j = radarDetectStartRow;
                    while j <= rows
                        if (detect(j,radar(radarNum, zone)) == active) && (radarState == start)
                            radarState = active;
                        elseif (detect(j,radar(radarNum, zone)) == active) && (radarState == active)
                            %stay active
                        elseif (detect(j,radar(radarNum, zone)) == inactive) && (radarState == active)
                            radarState = stop;
                            radarDetectStopRow = j;
                            break;
                        end
                       j = j + 1; 
                    end

                    %determineif loop detection and radar detection overlap
                    if (data.Time(radarDetectStartRow) <= (data.Time(loopDetctionStopRow)+callDuratonBuffer)) && ((data.Time(loopDetctionStartRow)-callDuratonBuffer) <= data.Time(radarDetectStopRow))
                        %overlap - verified detection
                        previousDetectionOverlap = true;
                    else
                        %no overlap - missed radar detection
                        previousDetectionOverlap = false;
                        %detectionData.radarMissedCount(zone,radarNum) = detectionData.radarMissedCount(zone,radarNum) + 1;
                        %detectionData.radarMissedTime(detectionData.radarMissedCount(zone,radarNum), zone, radarNum) = (data.Time(loopDetctionStartRow) + data.Time(loopDetctionStopRow))/2;
                    end
                    
                    %%%%%%
                    %compare loop detection to radar for overlap
                    %From the loop start time search forward in time for the next radar detection stop time
                    j = loopDetctionStartRow;
                    radarState = idle;
                    radarDetectStartRow = 0;
                    radarDetectStopRow = 0;
                    while j <= rows
                        if (detect(j,radar(radarNum, zone)) == active) && (radarState == idle)
                            radarState = active;
                            %radarDetectStopRow = j;
                        elseif(detect(j,radar(radarNum, zone)) == active) && (radarState == active)
                        elseif(detect(j,radar(radarNum, zone)) == inactive) && (radarState == active)
                            radarDetectStopRow = j;
                            break;
                        end
                        j = j + 1;
                    end
                    radarState = stop;

                    %find radar start time
                    j = radarDetectStopRow;
                    while j >0 
                        if (detect(j,radar(radarNum, zone)) == active) && (radarState == stop)
                            radarState = active;
                            radarDetectStartRow = j;
                        elseif (detect(j,radar(radarNum, zone)) == active) && (radarState == active)
                            %stay active
                            radarDetectStartRow = j;
                        elseif (detect(j,radar(radarNum, zone)) == inactive) && (radarState == active)
                            radarState = start;
                            break;
                        end
                       j = j - 1; 
                    end

                    %determineif loop detection and radar detection overlap
                    if (data.Time(radarDetectStartRow) <= (data.Time(loopDetctionStopRow)+callDuratonBuffer)) && ((data.Time(loopDetctionStartRow)-callDuratonBuffer) <= data.Time(radarDetectStopRow))
                        %overlap - verified detection
                        nextDetectionOverlap = true;
                    else
                        %no overlap - missed radar detection
                        nextDetectionOverlap = false;
                    end
                    if (nextDetectionOverlap == false) && (previousDetectionOverlap == false)
                        detectionData.radarMissedCount(zone,radarNum) = detectionData.radarMissedCount(zone,radarNum) + 1;
                        detectionData.radarMissedTime(detectionData.radarMissedCount(zone,radarNum), zone, radarNum) = (data.Time(loopDetctionStartRow) + data.Time(loopDetctionStopRow))/2;
                    end                    
                    
                    loopDetectionState  = idle;
                end
            end
        end


    end

end

function plotDetectionData(detectionData, figureNum, figAxesHandles)
    radarPlotSymbols = ['o'; 'x'];
    radarPlotColors = ['g'; 'r'];
    
    figure(figureNum)
    
    for lane = 1:2
        %axes(figAxesHandles.ax(lane));
        for radarNum = 1:2
            ind = find(detectionData.radarMissedTime(:,lane,radarNum) ~= duration([ 0 0 0]));
            numToPlot = length(ind);
            plot(figAxesHandles.ax(lane),detectionData.radarMissedTime(1:numToPlot,lane,radarNum), 1.02*ones(numToPlot), 'color', radarPlotColors(radarNum), 'linestyle', 'none', 'marker', radarPlotSymbols(radarNum))
        end
        if lane == 1
            legend(figAxesHandles.ax(lane),'Loop1', 'R1Z1', 'R2Z1', 'location', 'northeast')
        elseif lane ==2
            legend(figAxesHandles.ax(lane),'Loop2', 'R1Z2', 'R2Z2', 'location', 'northeast')
        end
    end
end


function writeReport(detectionData, cleanedLoopData, dataFileName)
    [filepath,fileName,fileExt] = fileparts(dataFileName);
    
    reportFileName = strcat(filepath, '\', fileName, '_Report', fileExt);
    reportFileId = fopen(reportFileName, 'w');
    date = cleanedLoopData.Date(1);
    fprintf(reportFileId, 'Date: %10s\n\n', date);
    fprintf(reportFileId, 'Loop1 Events: %4d\n', detectionData.loopCount(1) );
    fprintf(reportFileId, 'Loop2 Events: %4d\n\n', detectionData.loopCount(2) );
    
    fprintf(reportFileId, 'Radar Missed counts compared to Loops\n');
    fprintf(reportFileId, '       Radar1     Radar2\n');
    zone = 1;
    fprintf(reportFileId, 'Loop1     %3d        %3d\n', detectionData.radarMissedCount(zone,1), detectionData.radarMissedCount(zone,2));
    zone = 2;
    fprintf(reportFileId, 'Loop2     %3d        %3d\n', detectionData.radarMissedCount(zone,1), detectionData.radarMissedCount(zone,2));
    
    
    
    fclose(reportFileId);
    
    
    
end