function LoadHistogramData(Directory)

%%create data matrix
cd(Directory)
dataFiles = dir('*.mat');
Data = [];
for i = 1:size(dataFiles,1)
    d = load(dataFiles(i).name);
    Data.numDataSets = i;
    Data.backgroundHist(i,:,:,:) = d.backgroundHist; 
    Data.daily_hist(i,:,:,:) = d.daily_hist;
    Data.clutter(i,:,:) = d.clutter;
    Data.hist_mode(i,:,:) = d.hist_mode;
    Data.pga(i,:) = d.pga;
    Data.sensor_id(i,:) = d.sensor_id;
    Data.pulse_count(i,:) = d.pulse_count;
    Data.seconds_on(i,:) = d.seconds_on;
    Data.year(i,:) = d.year;
    Data.month(i,:) = d.month;
    Data.day(i,:) = d.day;
    Data.hour(i,:) = d.hour;
    Data.minute(i,:) = d.minute;
    Data.second(i,:) = d.second;
    stopHere = 1;
end

