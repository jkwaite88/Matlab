%% DataLogger Report
clear
%% Read in data
C = initConstants;

%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\Logs\Log_2021-01-07.txt';
%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\Logs\Log_2021-01-07_withXRandIR.txt';
%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\Logs\Log_2021-01-22-Part1.txt';
%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\Logs\Log_2021-01-22-Part2.txt';
%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\Logs\Log_2021-01-25.txt';
%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\Logs\Log_2021-01-25_withXRbeforeSnow.txt';
%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\2021-01-27\Log_2021-01-27.txt';
%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\2021-01-28\Log_2021-01-28_after1400.txt';
%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\2021-01-30\Log_2021-01-30.txt';
%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\2021-01-30\Log_2021-01-30_with_XR_IR.txt';
%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\2021-01-31\Log_2021-01-31.txt';
%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\2021-01-31\Log_2021-01-31_with_XR_IR.txt';
%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\2021-02-15\Log_2021-02-15.txt';
%dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\2021-02-26\Log_2021-02-26.txt';
dataFile = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\2021-04-08\Log_2021-04-08.txt';

[filepath,fileName,fileExt] = fileparts(dataFile);
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
%data.XR = ~data.XR;
%data.IR = ~data.IR;

%temp = data;
data = zeroDataDuringXr(data);

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
detectionData.radarFalseCount = zeros(numZones,numRadars);  
detectionData.radarFalseTime = duration(0, 0, 0, 0) * ones(1, numZones, numRadars);
detectionData.radarFalseTime.Format = 'hh:mm:ss.SSS';
detectionData.allRadarsFalseCount = zeros(1, numZones);
detectionData.allRadarsFalseTime = duration(0, 0, 0, 0)* ones(1, numZones);
detectionData.allRadarsFalseTime.Format = 'hh:mm:ss.SSS';
detectionData.loopCount = zeros(1,numZones); 
%
detectionData.radarMissed_eventTime = duration(0, 0, 0, 0) * ones(1, numZones, numRadars);
detectionData.radarMissed_eventTime.Format = 'hh:mm:ss.SSS';

combinedData = combineData(data, numZones);

gapLimitSeconds = 0.20;
cleanedData = cleanEvents(combinedData, gapLimitSeconds);

detectionData = findMissedCalls(cleanedData, detectionData);
detectionData = findFalseCalls(cleanedData, detectionData, C);

makeIdividualDataTables = true;
%%
if makeIdividualDataTables
    eventsFile =  strcat(filepath,'\events-', fileName,'.xlsx');
    xr_index = 15;
    
    radarNum = 1;
    zoneNum = 1;
    loopNum = 1;
    createEventsFile(eventsFile, 'radar', cleanedData, radarNum, zoneNum, loopNum);
    radarNum = 1;
    zoneNum = 2;
    loopNum = 1;
    createEventsFile(eventsFile, 'radar', cleanedData, radarNum, zoneNum, loopNum);
    radarNum = 2;
    zoneNum = 1;
    loopNum = 1;
    createEventsFile(eventsFile, 'radar', cleanedData, radarNum, zoneNum, loopNum);
    radarNum = 2;
    zoneNum = 2;
    loopNum = 1;
    createEventsFile(eventsFile, 'radar', cleanedData, radarNum, zoneNum, loopNum);
    radarNum = 1;
    zoneNum = 1;
    loopNum = 1;
    createEventsFile(eventsFile, 'loop', cleanedData, radarNum, zoneNum, loopNum);
    radarNum = 1;
    zoneNum = 1;
    loopNum = 2;
    createEventsFile(eventsFile, 'loop', cleanedData, radarNum, zoneNum, loopNum);
    
%     %R1Z1
%     column_index = 3;
%     idx = find(xor(table2array(data(2:end,column_index)), table2array(data(1:(end-1),column_index))));
%     r1z1_table = data(idx+1, [1 2 column_index]);
%     event_r1z1 = dataTable2EventTable(r1z1_table);
%     writetable(event_r1z1, eventsFile, 'Sheet', 'R1Z1', 'WriteMode', 'overwritesheet')
%     %R1Z2
%     column_index = 4;
%     idx = find(xor(table2array(data(2:end,column_index)), table2array(data(1:(end-1),column_index))));
%     r1z2_table = data(idx+1, [1 2 column_index]);
%     event_r1z2 = dataTable2EventTable(r1z2_table);
%     writetable(event_r1z2, eventsFile, 'Sheet', 'R1Z2', 'WriteMode', 'overwritesheet')
%     %R2Z1
%     column_index = 7;
%     idx = find(xor(table2array(data(2:end,column_index)), table2array(data(1:(end-1),column_index))));
%     r2z1_table = data(idx+1, [1 2 column_index]);
%     event_r2z1 = dataTable2EventTable(r2z1_table);
%     writetable(event_r2z1,eventsFile, 'Sheet', 'R2Z1', 'WriteMode', 'overwritesheet')
%     %R2Z2
%     column_index = 8;
%     idx = find(xor(table2array(data(2:end,column_index)), table2array(data(1:(end-1),column_index))));
%     r2z2_table = data(idx+1, [1 2 column_index]);
%     event_r2z2 = dataTable2EventTable(r2z2_table);
%     writetable(event_r2z2, eventsFile, 'Sheet', 'R2Z2', 'WriteMode', 'overwritesheet')
%     %LOOP1
%     column_index = 11;
%     idx = find(xor(table2array(data(2:end,column_index)), table2array(data(1:(end-1),column_index))));
%     loop1_table = data(idx+1, [1 2 column_index]);
%     event_loop1 = dataTable2EventTable(loop1_table);
%     writetable(event_loop1, eventsFile, 'Sheet', 'LOOP1', 'WriteMode', 'overwritesheet')
%     %LOOP2
%     column_index = 12;
%     idx = find(xor(table2array(data(2:end,column_index)), table2array(data(1:(end-1),column_index))));
%     loop2_table = data(idx+1, [1 2 column_index]);
%     event_loop2 = dataTable2EventTable(loop2_table);
%     writetable(event_loop2, eventsFile, 'Sheet', 'LOOP2', 'WriteMode', 'overwritesheet')
end
%%


figureNum = 1;
plotData(data, figureNum);

figureNum = 2;
plotCombinedData(combinedData, figureNum);

figureNum = 3;
plotCleanedData(cleanedData, detectionData, figureNum);


%%
writeReport(detectionData, cleanedData, dataFile);
if(0)
    radarMissed = array2table([squeeze(detectionData.radarMissedTime(:,1,1)) squeeze(detectionData.radarMissedTime(:,1,2)) squeeze(detectionData.radarMissedTime(:,2,1)) squeeze(detectionData.radarMissedTime(:,2,2)) ],'VariableNames', {'R1Z1miss', 'R1Z2miss', 'R2Z1miss', 'R2Z2miss'});
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
stairs(ax1, data.Time, data.XR, 'c', 'linewidth', 0.5)
ylim([0 1.1])
legend('Loop1', 'R1Z1', 'R2Z1', 'XR', 'location', 'northeast')
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
        xrAx(i) = stairs(fig.ax(i), data.time, data.xr, 'c', 'linewidth', 2.0);
        loopAx(i) = stairs(fig.ax(i), data.time, data.loop(i).data, 'b', 'linewidth', 1.5);
        r1Ax(i)   = stairs(fig.ax(i), data.time, data.radar(1).zone(i).data, 'g', 'linewidth', 1.0);
        r2Ax(i)   = stairs(fig.ax(i), data.time, data.radar(2).zone(i).data, 'r', 'linewidth', 0.5);

        ylim([0 1.1])
        if i == 1
            title(datestr(date))
            %legend([loopAx(i) r1Ax(i) r2Ax(i)], sprintf('Loop%d',i), sprintf('R1Z%d',i), sprintf('R2Z%d', i), 'location', 'northeast')
            legend([loopAx(i) r1Ax(i) r2Ax(i)], sprintf('Loop'), sprintf('R1'), sprintf('R2'), 'location', 'northeast')
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
    
%     radarPlotMissedSymbols = ['o'; 'x'];
%     radarPlotFalseSymbols = ['h'; 'p'];
    radarPlotMissedSymbols = ['+'; 'x'];
    radarPlotFalseSymbols = ['d'; 'p'];
    radarPlotColors = ['g'; 'r'];
    radarPlotFalseColors = ['g'; 'r'];
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
        xrAx(i) = stairs(fig.ax(i), data.time, data.xr, 'c', 'linewidth', 3.5);  
        irAx(i) = stairs(fig.ax(i), data.time, data.ir, 'm', 'linewidth', 3);  
        loopAx(i) = stairs(fig.ax(i), data.time, data.loop(i).data, 'b', 'linewidth', 1.5);
        for radarNum = 1:2
            rdrAx(i, radarNum)   = stairs(fig.ax(i), data.time, data.radar(radarNum).zone(i).data, 'color', radarPlotColors(radarNum), 'linewidth', radarPlotLineWidth(radarNum));
            %plot miss detects
            ind = find(detectionData.radarMissedTime(:,i,radarNum) ~= duration(0, 0, 0, 0));
            numToPlot = length(ind);
            if numToPlot > 0
                missedAx(i, radarNum) = plot(detectionData.radarMissedTime(1:numToPlot,i,radarNum), 1.02*ones(numToPlot,1), 'color', radarPlotColors(radarNum), 'linestyle', 'none', 'marker', radarPlotMissedSymbols(radarNum));
            else
                missedAx(i, radarNum) = plot(duration(0, 0, 0, 0), -0.2, 'color', radarPlotColors(radarNum), 'linestyle', 'none', 'marker', radarPlotMissedSymbols(radarNum));
            end
            
            %plot false detects
            ind = find(detectionData.radarFalseTime(:,i,radarNum) ~= duration(0, 0, 0, 0));
            numToPlot = length(ind);
            if numToPlot > 0
                falseAx(i, radarNum) = plot(detectionData.radarFalseTime(1:numToPlot,i,radarNum), 1.02*ones(numToPlot,1), 'color', radarPlotFalseColors(radarNum), 'linestyle', 'none', 'marker', radarPlotFalseSymbols(radarNum));
            else
                falseAx(i, radarNum) = plot(duration(0, 0, 0, 0), -0.2, 'color', radarPlotFalseColors(radarNum), 'linestyle', 'none', 'marker', radarPlotFalseSymbols(radarNum));
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
            %legend([loopAx(i) rdrAx(i,1) rdrAx(i,2) missedAx(i,1) missedAx(i,2), allRadarMisedAx(1), falseAx(i,1), falseAx(i,2), xrAx(i), irAx(i)], sprintf('Loop%d',i), sprintf('R1Z%d',i), sprintf('R2Z%d', i), sprintf('R1 miss'), sprintf('R2 miss'), sprintf('All miss'), sprintf('R1 false'), sprintf('R2 false'), sprintf('XR'), sprintf('IR'), 'location', 'northeast')
            legend([loopAx(i) rdrAx(i,1) rdrAx(i,2) missedAx(i,1) missedAx(i,2), allRadarMisedAx(1), falseAx(i,1), falseAx(i,2), xrAx(i), irAx(i)], sprintf('Loop'), sprintf('R1'), sprintf('R2'), sprintf('R1 miss'), sprintf('R2 miss'), sprintf('All miss'), sprintf('R1 false'), sprintf('R2 false'), sprintf('XR'), sprintf('IR'), 'location', 'northeast')
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
    
    dt = data.Date(1);
    dt.Format = 'yyyy-MM-dd HH:mm:ss.SSS';
    dur = data.Time(1);
    dt = dt + dur;
    
    %after the time below we ch
    if dt <  datetime(2021,01,28,12,55,00,00)
        %before this date the radar was configured with four zones, two for
        %each direction of travel
        radarConfiguredWithTwoZones = false;
    else
        radarConfiguredWithTwoZones = true;
    end
    
    if numZones == 1
        combinedData.loop(1).data = data.LOOP1 | data.LOOP2 | data.LOOP3 | data.LOOP4;
        combinedData.radar(1).zone(1).data = data.R1Z1 | data.R1Z2 | data.R1Z3 | data.R1Z4;
        combinedData.radar(2).zone(1).data = data.R2Z1 | data.R2Z2 | data.R2Z3 | data.R2Z4;
    elseif numZones == 2 
            combinedData.loop(1).data = data.LOOP1 | data.LOOP2;
            combinedData.loop(2).data = data.LOOP3 | data.LOOP4;
        if radarConfiguredWithTwoZones == true
            combinedData.radar(1).zone(1).data = data.R1Z1;
            combinedData.radar(1).zone(2).data = data.R1Z2;
            combinedData.radar(2).zone(1).data = data.R2Z1;
            combinedData.radar(2).zone(2).data = data.R2Z2;
        else
            combinedData.radar(1).zone(1).data = data.R1Z1 | data.R1Z2;
            combinedData.radar(1).zone(2).data = data.R1Z3 | data.R1Z4;
            combinedData.radar(2).zone(1).data = data.R2Z1 | data.R2Z2;
            combinedData.radar(2).zone(2).data = data.R2Z3 | data.R2Z4;
        end
    elseif numZones == 4
        combinedData.loop(1).data = data.LOOP1;
        combinedData.loop(2).data = data.LOOP2;
        combinedData.loop(3).data = data.LOOP3;
        combinedData.loop(4).data = data.LOOP4;
        if radarConfiguredWithTwoZones == true
            f = msgbox('This data only has two radar zones per sensor.');
            return; % stop progarm execution
        else
            combinedData.radar(1).zone(1).data = data.R1Z1;
            combinedData.radar(1).zone(2).data = data.R1Z2;
            combinedData.radar(1).zone(3).data = data.R1Z3;
            combinedData.radar(1).zone(4).data = data.R1Z4;
            combinedData.radar(2).zone(1).data = data.R2Z1;
            combinedData.radar(2).zone(2).data = data.R2Z2;
            combinedData.radar(2).zone(3).data = data.R2Z3;
            combinedData.radar(2).zone(4).data = data.R2Z4;
        end
    end

    %find duplicate lines
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

function cleanedData = cleanEvents(combinedData, gapLimit)
	%fill in short gaps in active detections
    %combinedData_array = zeros(size(combinedData));
    
    cleanedData = combinedData; %initialize
    radarNum = 0;
	zoneNum = 0;
    for loopNum = 1:length(combinedData.loop)
		cleanedData = fillInGaps(cleanedData, 'loop', loopNum, radarNum, zoneNum, gapLimit);
    end
    
    temp = combinedData.radar.zone;
	for radarNum = 1:size(combinedData.radar, 2)
		for zoneNum = 1:size(temp,2)
			cleanedData = fillInGaps(cleanedData, 'radar', loopNum, radarNum, zoneNum, gapLimit);
		end
    end
    clear temp
end

function cleanedData = fillInGaps(cleanedData, sensorType, loopNum, radarNum, zoneNum, gapLimit)
		rows = size(cleanedData.loop(1).data,1);
        inactive = false;
        active = true;
        lastVehicleState = inactive;
        lastActiveTime = duration([-1000 0 0]);
        lastActiveTimeRow = 0;
        gapsFilledIn = 0;
        for i = 1:rows
            if cleanedData.time(i) == duration(0, 7, 5, 075) %debug line
                breakhere = 1;
            end
			if strcmp(sensorType, 'loop')
				vehicleState = cleanedData.loop(loopNum).data(i);
			elseif strcmp(sensorType, 'radar')
				vehicleState = cleanedData.radar(radarNum).zone(zoneNum).data(i);
			end
            if ( (vehicleState == active) && (lastVehicleState == inactive) )
                timeGap = cleanedData.time(i) - lastActiveTime;
                if (timeGap < seconds(gapLimit))
                    %change previous inactive state(s) to active
                    for j = (lastActiveTimeRow):(i-1)

						if strcmp(sensorType, 'loop')
							cleanedData.loop(loopNum).data(j) = active;
						elseif strcmp(sensorType, 'radar')
							cleanedData.radar(radarNum).zone(zoneNum).data(j) = active;
						end
                    end
                    gapsFilledIn = gapsFilledIn + 1;
                end
                lastVehicleState = active;
                lastActiveTime = cleanedData.time(i);
                lastActiveTimeRow = i;
            elseif (vehicleState == active)
                lastVehicleState = active;
                lastActiveTime = cleanedData.time(i);
                lastActiveTimeRow = i;
            elseif ( (vehicleState == inactive) && (lastVehicleState == active) ) 
                lastVehicleState = inactive;  
                lastActiveTime = cleanedData.time(i);% the vehicle is active until the moment it goes inactive
                lastActiveTimeRow = i;
            else %newVehicleState == inactive
                 lastVehicleState = inactive;  

            end

        end

end

%This function will change to inactive states that inactive state durations less than
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
                if data.time(loopDetctionStopRow) == duration(13,45,39,492)
                    breakhere = 1;
                end
                
                radarMissed = false(2,1);
                for radarNum = 1:2
                    %find row corresonding to the callDurationBuffer before
                    %the loopStart
                    searchStartRow = 1;
                    j = loopDetctionStartRow;
                    while j>0
                        timeBeforeStart = data.time(loopDetctionStartRow) - data.time(j);
                        if timeBeforeStart > callDuratonBuffer
                            searchStartRow = j+1; %start searching on the row that is within the callDuration buffer not greater than it
                            break;
                        end
                        j = j - 1;
                    end
                    searchStopRow = rows;
                    j = loopDetctionStopRow;
                    while j < rows
                        timeAfterStop = data.time(j) - data.time(loopDetctionStopRow);
                        if timeAfterStop > callDuratonBuffer
                            searchStopRow = j-1; %start searching on the row that is within the callDuration buffer not greater than it
                            break;
                        end
                        j = j + 1;
                    end
                    
                    %see if radar is active anytime during the loop
                    %activation plus buffer
                    overlap = false;
                    XR = inactive;
                    for j = searchStartRow:searchStopRow
                        radarState = data.radar(radarNum).zone(zone).data(j);
                        if data.xr(j) == active
                            XR = active;
                            break;
                        end
                        if radarState == active
                            overlap = true;
                            break;
                        elseif (j == searchStartRow) && (j>1) && (data.radar(radarNum).zone(zone).data(j-1) == active) % this takes into account the the detect transitions to inactive on searchStartRow
                            overlap = true;
                            break;
                        end
                    end
                    if (overlap == false && XR == inactive)
                        radarMissed(radarNum) = true;
                        detectionData.radarMissedCount(zone,radarNum) = detectionData.radarMissedCount(zone,radarNum) + 1;
                        detectionData.radarMissedTime(detectionData.radarMissedCount(zone,radarNum), zone, radarNum) = (data.time(loopDetctionStartRow) + data.time(loopDetctionStopRow))/2;
                        detectionData.radarMissed_eventTime(detectionData.radarMissedCount(zone,radarNum), zone, radarNum) = (data.time(loopDetctionStopRow) - data.time(loopDetctionStartRow));
                    end                    
                end
                if isempty(find(radarMissed == false)) % if both radar missed detection
                    detectionData.allRadarsMissedCount(zone) = detectionData.allRadarsMissedCount(zone) + 1;
                    detectionData.allRadarsMissedTime(detectionData.allRadarsMissedCount(zone),zone) = (data.time(loopDetctionStartRow) + data.time(loopDetctionStopRow))/2;
                end
                loopDetectionState  = idle;
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
    
    
   
   
    detector = [];
    detector = resetDetection(detector, C);
    
    for radar = 1:numRadars
        detector = resetDetectorDetection(detector, C);
        for zone = 1:numZones
    
            for row = 1:rows
                newDetectorData = data.radar(radar).zone(zone).data(row);
                detector = updateDetectorState(detector, newDetectorData, radar, zone, row, C);
                if detector.detectionState == C.STOP
                    detectionData = dectectOverlap(detector,data, radar, zone, detectionData, C);
      
                    detector.detectionState = C.IDLE;
                end
            end
        end
    end
end

%this function finds overalp. Detector contains the data of the primary
%sensor's current detection. It is determined if the secondary sensor
%overlaps the primary sensors detection.
function detectionData = dectectOverlap(detector, data, primarySensorNum, secondarySensorNum, detectionData, C)
    rows = size(data.loop(1).data,1);

    %debug if statement
    if data.time(detector.detectionStartRow) == duration(02,53,44,348)
        breakhere = 1;
    end
    
    %find row corresonding to callDurationBuffer before
    %the radarStart
    searchStartRow = 1;
    j = detector.detectionStartRow;
    while j>0
        timeBeforeStart = data.time(detector.detectionStartRow) - data.time(j);
        if timeBeforeStart > detector.callDuratonWindow
            searchStartRow = j+1; %start searching on the row that is within the callDuration buffer not greater than it
            break;
        end
        j = j - 1;
    end
    searchStopRow = rows;
    j = detector.detectionStopRow;
    while j < rows
        timeAfterStop = data.time(j) - data.time(detector.detectionStopRow);
        if timeAfterStop > detector.callDuratonWindow
            searchStopRow = j-1; %start searching on the row that is within the callDuration buffer not greater than it
            break;
        end
        j = j + 1;
    end
    
    %see if loop is active anytime during the radar
    %activation plus buffer
    overlap = false;
    XR = C.INACTIVE;
    for j = searchStartRow:searchStopRow
        %radarState = data.radar(primarySensorNum).zone(secondarySensorNum).data(j);
        loopState = data.loop(secondarySensorNum).data(j);
        if data.xr(j) == C.ACTIVE
            XR = C.ACTIVE;
            break;
        end
        if loopState == C.ACTIVE
            overlap = true;
            break;
        elseif (j == searchStartRow) && (j>1) && (data.loop(secondarySensorNum).data(j-1) == C.ACTIVE) % this takes into account the the detect transitions to inactive on searchStartRow
            overlap = true;
            break;
        end
    end
    if (overlap == false && XR == C.INACTIVE)
        detector.radarFalse(primarySensorNum) = true;
        detectionData.radarFalseCount(secondarySensorNum,primarySensorNum) = detectionData.radarFalseCount(secondarySensorNum,primarySensorNum) + 1;
        detectionData.radarFalseTime(detectionData.radarFalseCount(secondarySensorNum,primarySensorNum), secondarySensorNum, primarySensorNum) = (data.time(detector.detectionStartRow) + data.time(detector.detectionStopRow))/2;
    end                    

    
end
function detector = updateDetectorState(detector, newDetectorData, radar, zone, row, C)
    %debug if statement
    if(newDetectorData == C.ACTIVE)
        stophere = 1;
    end
    
    detector.currentState = newDetectorData;
    if ((detector.currentState == C.ACTIVE) && (detector.detectionState == C.IDLE))
        detector.detectionState = C.START;
        detector.detectionStartRow = row;
    elseif((detector.currentState == C.ACTIVE) && (detector.detectionState == C.START))
        detector.detectionState = C.CONTINUING;
    elseif ((detector.currentState == C.INACTIVE) && ((detector.detectionState == C.START)||(detector.detectionState == C.CONTINUING)) )
        detector.detectionState = C.STOP;
        detector.detectionStopRow = row;
        %detector.detectionCount(zone) = detectionData.loopCount(zone) + 1;
    end
    %detector.detectionLastState = detector.detectionState;
end

function detector = resetDetectorDetection(detector, C)
    detector.detectionStartRow = 0;
    detector.detectionStopRow = 0;
    detector.currentState = C.INACTIVE;
    detector.detectionState = C.IDLE;
    %detector.detectionLastState = C.IDLE;
end

function detector = resetDetection(detector, C)
    detector = resetDetectorDetection(detector, C);
    detector.detectionCount = 0;
    detector.callDuratonWindow = duration(0, 0, 1, 0);
    detector.callDuratonWindow.Format = 'hh:mm:ss.SSS';
    detector.radarFalse = false(2,1);
        
end

function writeReport(detectionData, cleanedData, dataFileName)
    [filepath,fileName,fileExt] = fileparts(dataFileName);

    numZones = length(cleanedData.loop);
    numRadars = length(cleanedData.radar);
    
    reportFileName = strcat(filepath, '\', fileName, '_Report', fileExt);
    reportFileId = fopen(reportFileName, 'w');
    date = cleanedData.date(1);
    
    fprintf(reportFileId, 'Filename: %s\n', strcat(fileName, fileExt));
    fprintf(reportFileId, 'Date: %10s\n\n', date);
    for i = 1:numZones
        fprintf(reportFileId, 'Loop%d Events: %4d\n', i, detectionData.loopCount(i) );
    end
    fprintf(reportFileId, '\n' );
    
    %Missed detects
    fprintf(reportFileId, 'Radar miss detect counts compared to Loops\n');
    
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
    fprintf(reportFileId, '\n');

    %False Detects
    fprintf(reportFileId, 'Radar False counts compared to Loops\n');
    
    fprintf(reportFileId, '     ');
    for radar = 1:numRadars
        fprintf(reportFileId, '   Radar%d', radar);
    end
    fprintf(reportFileId, '\n');
    
    for zone = 1:numZones
        fprintf(reportFileId, 'Loop%d', zone);
        for radar = 1:numRadars
            fprintf(reportFileId, '      %3d', detectionData.radarFalseCount(zone,radar));
        end
        fprintf(reportFileId, '\n');
    end
    fprintf(reportFileId, '\n');
    fprintf(reportFileId, '\n');

    
    
    fclose(reportFileId);
    
end

function event = dataTable2EventTable(table)
    %remove falses at the beginging of table
    i = 1;
    while table.(3)(i) == false
        table(i,3) = [];
        i = i + 1;
    end
    %remove trues at the end of table
    i = size(table,1);
    while table.(3)(i) == true
        table(i,3) = [];
        i = i - 1;
    end
    ind = find(table2array(table(:,3)) == true);
    event = table(ind, 1:2); %start time 
    event(:,3) = table(ind + 1, 2); %stop time
    dur = table2array(event(:,3)) - table2array(event(:,2));
    event = addvars(event, dur); 
    
    event.Properties.VariableNames(2) = {'StartTime'};
    event.Properties.VariableNames(3) = {'StopTime'};
    event.Properties.VariableNames(4) = {'Duration'};
    event.Duration = seconds(event.Duration);
    
end

function data = zeroDataDuringXr(data)
    xr_ind = find(data.XR == 0);
    %zero radar and loop data
    for i = 1:size(data,2)
        if or(~isempty(regexp(data.Properties.VariableNames{i}, regexptranslate('wildcard','R*Z'))), contains(data.Properties.VariableNames{i}, 'LOOP'))
            data(xr_ind,i) = {0};
        end
    end
end

%function createEventsFile(sensorType, cleanedData, radarNum, zoneNum, loopNum)
%This function creates the event file. sensorType is 'loop' or 'radar'.
function createEventsFile(fileName, sensorType, cleanedData, radarNum, zoneNum, loopNum)
	sheetName = '';
	if strcmp(sensorType, 'loop')
		idx = find(xor(cleanedData.loop(loopNum).data(2:end), cleanedData.loop(loopNum).data(1:(end-1))));
        idx = idx + 1;
        zone_data = cleanedData.loop(loopNum).data(idx);
        sheetName = strcat('LOOP', num2str(loopNum));
	elseif strcmp(sensorType, 'radar')
		idx = find(xor(cleanedData.radar(radarNum).zone(zoneNum).data(2:end), cleanedData.radar(radarNum).zone(zoneNum).data(1:(end-1))));
        idx = idx + 1;
        zone_data = cleanedData.radar(radarNum).zone(zoneNum).data(idx);
        sheetName = strcat('R', num2str(radarNum), 'Z', num2str(zoneNum));
	else
		f = msgbox('Wrong sensorType input in createEventsFile function call');
        quit
    end
    
    zone_table = array2table(cleanedData.date(idx));
    zone_table = addvars(zone_table, cleanedData.time(idx), zone_data);
    
    %remove falses at the beginging of table
    j = size(zone_table,1);
    i = 1;
    while zone_table.(3)(1) == false  && i <= j
        zone_table(i,:) = [];
        i = i + 1;
    end
    %remove trues at the end of table
    
    j = size(zone_table,1);
    i = 1;
    while zone_table.(3)(end) == true && i <= j
        zone_table(end,:) = [];
        i = i + 1;
    end
    
    ind = find(table2array(zone_table(:,3)) == true);
    event = zone_table(ind, 1:2); %date and start time 
    event(:,3) = zone_table(ind + 1, 2); %stop time
    dur = table2array(event(:,3)) - table2array(event(:,2));
    event = addvars(event, dur); 
    
    event.Properties.VariableNames(1) = {'Date'};
    event.Properties.VariableNames(2) = {'StartTime'};
    event.Properties.VariableNames(3) = {'StopTime'};
    event.Properties.VariableNames(4) = {'Duration'};
    event.Duration = seconds(event.Duration);
    
    writetable(event, fileName, 'Sheet', sheetName, 'WriteMode', 'overwritesheet')
    
end