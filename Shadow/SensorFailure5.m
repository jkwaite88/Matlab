%Sensor Failures
%This script was developed when U34 amplifier was failing on MatrixRF
%boards. This script shows start and stop times of group tests and when the
%sensor failures occrured.
%This script reads in a data file output from Shadow. In Shadow's "Search"
%menu, select "Search for Tests". Enter Sensor Type (SS225 U). Enter date
%range. Select "Use Date Range".
%export an
%excel file

clear
%%
%fileName = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\Shadow\\MatrixEnvChamberTests4-8-21ToNow.xlsx';
%fileName = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\Shadow\\MatrixEnvChamberTestsMarch21.xlsx';
%fileName = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\Shadow\\MatrixEnvChamberTestsMarch-April2021.xlsx';
fileName = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\Shadow\\Shadow_2021-03-01_2021-04-20.xlsx';
%fileName = 'C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\Shadow\Shadow Data - 2021-01-01 to 2021-05-03.xlsx';

T = readtable(fileName, 'Sheet', 1);



sn =unique(T.SerialNumber);
for i = 1:length(sn)
    data.sensor(i).serialNumberStr = sn{i};
    s = sn{i};
    data.sensor(i).serialNumber = str2double(s(9:end));    

    sensor_index = find(strcmp(T.SerialNumber, data.sensor(i).serialNumberStr));
    groupNumbers = unique(T.TestResultGroup(sensor_index));

    %find each sensor's first time of failure
    idx = find(and(and(and(contains(T.TestResultString(sensor_index), 'Antenna 0 Failed'), contains(T.TestResultString(sensor_index), 'Antenna 4 Failed'))...
        , contains(T.TestResultString(sensor_index), 'Antenna 8 Failed')), contains(T.TestResultString(sensor_index), 'Antenna 12 Failed')));
    if isempty(idx)
        data.sensor(i).sensorFirstFailTime = NaN;
    else
        [time, time_idx] = min(datenum(T.TestResultDate(sensor_index(idx))));
        data.sensor(i).sensorFirstFailTime = time;
    end
    %initialize sensorRunTimeUntilFail
    if ~isempty(data.sensor(i).sensorFirstFailTime)
        data.sensor(i).sensorRunTimeUntilFail = 0;
    else
        data.sensor(i).sensorRunTimeUntilFail = NaN;
    end

    %find start and stop time of each test group
    for g = 1:length(groupNumbers)
        data.sensor(i).group(g).groupNumber = groupNumbers{g};
        group_idx = find(strcmp(T.TestResultGroup(sensor_index), groupNumbers{g}));
        d = datenum(T.TestResultDate(sensor_index(group_idx)));
        if isempty(d)
            data.sensor(i).group(g).sensorFirstTestTime = NaN;
            data.sensor(i).group(g).sensorLastTestTime = NaN;
        else
            [time, time_idx] = min(d);
            data.sensor(i).group(g).sensorFirstTestTime = time;
            [time, time_idx] = max(d);
            data.sensor(i).group(g).sensorLastTestTime = time;
        end
        
        %Determine sensor run-time until fail
        if ~isempty(data.sensor(i).sensorFirstFailTime)
            if data.sensor(i).group(g).sensorLastTestTime < data.sensor(i).sensorFirstFailTime
                %add entire group time to failtime
                groupTime = data.sensor(i).group(g).sensorLastTestTime - data.sensor(i).group(g).sensorFirstTestTime;
                data.sensor(i).sensorRunTimeUntilFail = data.sensor(i).sensorRunTimeUntilFail + groupTime;
            elseif data.sensor(i).group(g).sensorFirstTestTime < data.sensor(i).sensorFirstFailTime
                %add partial grouop time to fail-time
                groupTime =  data.sensor(i).sensorFirstFailTime - data.sensor(i).group(g).sensorFirstTestTime;
                data.sensor(i).sensorRunTimeUntilFail = data.sensor(i).sensorRunTimeUntilFail + groupTime;
            else
                %grout time is not before failure
            end
        end
    end    
end

data.minTime = min(datenum(T.TestResultDate));
data.maxTime = max(datenum(T.TestResultDate));


%%
figure(1)
clf
hold on

j = 1;
for i = 1:length(data.sensor)
    for g = 1:length(data.sensor(i).group)
        h(j) = plot([data.sensor(i).group(g).sensorFirstTestTime data.sensor(i).group(g).sensorLastTestTime], [data.sensor(i).serialNumber data.sensor(i).serialNumber],'g');
        j = j + 1;
        h(j) = plot(data.sensor(i).group(g).sensorFirstTestTime, data.sensor(i).serialNumber,'c.', 'MarkerSize',10);
        j = j + 1;
        h(j) = plot(data.sensor(i).group(g).sensorLastTestTime, data.sensor(i).serialNumber,'r.', 'MarkerSize',8);
        j = j + 1;
    end
    h(j) = plot(data.sensor(i).sensorFirstFailTime, data.sensor(i).serialNumber,'b.', 'MarkerSize',10);
    j = j + 1;
end
ax = gca;
datetick('x','mm/dd')
%xx = floor(data.minTime):1:ceil(data.maxTime);
%xticks(xx')
set(ax, 'YGrid', 'off', 'XGrid','on');
ax.XMinorTick = 'on'

ylabel('Sensor Serial Number')
ax.YAxis.Exponent = 0;
ytickformat('%.0f')

xlabel('Days')
legend([h(1:3) h(end)], 'Active Test', 'Start Test', 'End Test', 'All Channels Fail', 'location', 'se')

%% plot table
figure(2)
clf
%get data to print
idx = find(~isnan([data.sensor.sensorFirstFailTime]));
failed_sensors = {data.sensor(idx).serialNumberStr}';
time_to_fail = [data.sensor(idx).sensorRunTimeUntilFail]';
hours_to_fail = time_to_fail.*24;
T_fail = table(hours_to_fail, 'RowNames', failed_sensors);
uitable('Data',T_fail{:,:},'ColumnName',T_fail.Properties.VariableNames,'RowName',T_fail.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);

%% plot Histogram
figure(3)
clf
edges = 0:1:100;
hist = histogram(hours_to_fail, edges);
average_hours_to_fail = mean(hours_to_fail);
[hist_max hist_max_idx] = max(hist.Values);
common_fail_duration = mean(hist.BinEdges(hist_max_idx:(hist_max_idx+1)));

xlabel('Hours')
ylabel('Count')
title(sprintf('Failed Sensors\n Average Fail: %3.1f hours    Common Failure: %3.1f hours', average_hours_to_fail, common_fail_duration ))
