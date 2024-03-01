%Sensor Failures
clear
%%
%fileName = 'C:\Users\jwaite\Downloads\MatrixEnvChamberTests4-8-21ToNow.xlsx';
%fileName = 'C:\Users\jwaite\Downloads\MatrixEnvChamberTestsMarch21.xlsx';
%fileName = 'C:\Users\jwaite\Downloads\MatrixEnvChamberTestsMarch-April2021.xlsx';
fileName = 'C:\Users\jwaite\Downloads\Shadow_2021-03-01_2021-04-20.xlsx';

T = readtable(fileName, 'Sheet', 1);

Sensor.serialNumbers = unique(T.SerialNumber);

testResultStrings = T{:,4};
j = 0;
for i = 1:length(testResultStrings)
    a = testResultStrings{i};
    if strcmp(a(end-1), '#')
        if contains(testResultStrings(i),'Test #1')
            j = j + 1;
            firstTestResults(j) = i;
        end
    end
end


%firstTestResults = find(and(contains(testResultStrings,'Test #1'), testResultStrings(:,end-1));
%startOfTestTime = find();

sensors = unique(T.SerialNumber);
sensorNumber = str2double(cellfun(@(x) x(9:end),sensors,'un',0));
%find each sensor's first time of failure
for i = 1:length(sensors)
    sensor_index = find(strcmp(T.SerialNumber, sensors{i}));
    groups = find(strcmp(T.TestResultGroup, sensors{i}));
    d = datenum(T.TestResultDate(sensor_index));
    if isempty(d)
        sensorFirstTestTime(i) = NaN;
        sensorLastTestTime(i) = NaN;
    else
        [time, time_idx] = min(d);
        sensorFirstTestTime(i) = time;
        [time, time_idx] = max(d);
        sensorLastTestTime(i) = time;
    end

    
    idx = find(and(and(and(contains(T.TestResultString(sensor_index), 'Antenna 0 Failed'), contains(T.TestResultString(sensor_index), 'Antenna 4 Failed'))...
        , contains(T.TestResultString(sensor_index), 'Antenna 8 Failed')), contains(T.TestResultString(sensor_index), 'Antenna 12 Failed')));
    if isempty(idx)
        sensorFirstFailTime(i) = NaN;
    else
        [time, time_idx] = min(datenum(T.TestResultDate(sensor_index(idx))));
        sensorFirstFailTime(i) = time;
    end
end


%%
figure(1)
clf
hold on

j = 1;
for i = 1:length(sensorNumber)
    h(j) = plot([sensorFirstTestTime(i) sensorLastTestTime(i)], [sensorNumber(i) sensorNumber(i)],'g');
    j = j + 1;
    h(j) = plot(sensorFirstTestTime(i), sensorNumber(i),'c.');
    j = j + 1;
    h(j) = plot(sensorLastTestTime(i), sensorNumber(i),'r.');
    j = j + 1;
end
h(j) = plot(sensorFirstFailTime, sensorNumber,'b.');
j = j + 1;
datetick('x','HH')
set(gca, 'YGrid', 'off', 'XGrid','on');
ylabel('Sensor Serial Number')

xlabel('Days')
legend([h(1:3) h(end)], 'Active Test', 'Sensor First Test Time', 'Sensor Last Test Time', 'Failure Times', 'location', 'se')
