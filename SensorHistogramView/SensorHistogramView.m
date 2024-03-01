%%Load DataDirectoryName = "C:\Users\jwaite\OneDrive - Wavetronix LLC\Documents\Matlab\SensorHistogramView\2019-09-16_12-20-34";cd(DirectoryName)dataFiles = dir('*.mat');%%create data matrixData = [];for i = 1:size(dataFiles,1)    d = load(dataFiles(i).name);    Data.numDataSets = i;    Data.backgroundHist(i,:,:,:) = d.backgroundHist;     Data.daily_hist(i,:,:,:) = d.daily_hist;    Data.clutter(i,:,:) = d.clutter;    Data.hist_mode(i,:,:) = d.hist_mode;    Data.pga(i,:) = d.pga;    Data.sensor_id(i,:) = d.sensor_id;    Data.pulse_count(i,:) = d.pulse_count;    Data.seconds_on(i,:) = d.seconds_on;    Data.year(i,:) = d.year;    Data.month(i,:) = d.month;    Data.day(i,:) = d.day;    Data.hour(i,:) = d.hour;    Data.minute(i,:) = d.minute;    Data.second(i,:) = d.second;    stopHere = 1;end%%Veiw Backgroundfigure(2);clf;for i =1:Data.numDataSets    plot(squeeze(Data.hist_mode(i,:,:)))    pause(0.5)endPlot Histogramsfigure(2);clf;antennas = 7; % 1:16rangeBin = 50; for i =1:Data.numDataSets    plot(squeeze(Data.backgroundHist(i,antennas,rangeBin,:))')    axis([-inf inf 0 5e5])    drawnow    pause(0.5)end