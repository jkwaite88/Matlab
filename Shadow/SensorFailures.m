%Sensor Failures
clear
%%
%fileName = 'C:\Users\jwaite\Downloads\MatrixEnvChamberTests4-8-21ToNow.xlsx';
%fileName = 'C:\Users\jwaite\Downloads\MatrixEnvChamberTestsMarch21.xlsx';
fileName = 'C:\Users\jwaite\Downloads\MatrixEnvChamberTestsMarch-April2021.xlsx';
%fileName = 'C:\Users\jwaite\Downloads\Shadow_2021-03-01_2021-04-20.xlsx';

T = readtable(fileName, 'Sheet', 3);
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
%find each sensor's first time of failure
sensorFirstFailTime = NaT(1,length(sensors));
for i = 1:length(sensors)
    sensor_index = find(strcmp(T.SerialNumber, sensors{i}));
   
    [time, time_idx] = min(T.TestDate(sensor_index));
    sensorFirstFailTime(i) = time;
end

figure(1)
clf
plot(sensorFirstFailTime, ones(size(sensorFirstFailTime)),'.')
hold on
%tick24 = datenum(min(sensorFirstFailTime):max(sensorFirstFailTime);
datetick('x','HH')
set(gca, 'YGrid', 'off', 'XGrid','on');

xline(T.TestDate(firstTestResults),'g.')
ylim([0 1.2])