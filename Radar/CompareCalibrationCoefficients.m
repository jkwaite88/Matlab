%Compare calibration coefficients
dataset = 1;
switch(dataset)
    case 1
        dataFileList = [
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector";
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector_2";
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector_3";
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector_4";
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector_5";
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector_6";
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector_7";
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector_8";
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector_9";
            %%"C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_10m_cornerRelector_center"
           ];
    case 2
        dataFileList = [
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector";
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector_left";
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector_right2";
           ];
    case 3
        dataFileList = [
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector";
            "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_10m_cornerRelector_center";
           ];
        
    otherwise
    end
calibFileDir = "C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\MatlabExamples\4chip_cascade_MIMO_example\main\cascade\input";

fh1 = figure(1);
clf(fh1)
subplot(2,1,1)
fh1_ax1 = gca;
hold(fh1_ax1,"on")
subplot(2,1,2)
fh1_ax2 = gca;
hold(fh1_ax2,"on")

fh2 = figure(2);
clf(fh2)
subplot(2,1,1)
fh2_ax1 = gca;
hold(fh1_ax1,"on")
subplot(2,1,2)
fh2_ax2 = gca;
hold(fh2_ax2,"on")

col = colorC;

for file_i = 1:length(dataFileList)
    temp = split(dataFileList(file_i),'\');
    if isempty(temp{end})
        dataFile_name = temp{end-1};
    else
        dataFile_name = temp{end};
    end
   
    calibFileStr = strcat(calibFileDir, "\calibrateResults_high_", dataFile_name, ".mat");
    if exist(calibFileStr) == 2
        calibData = load(calibFileStr);
    else
        text('File does not exist')
    end
    
    peakVal = calibData.calibResult.PeakValMat;
    peakVal = reshape(peakVal, size(peakVal,1)*size(peakVal,2),1);
    if file_i ==1
        peakVal_1 = peakVal;
    end
    peakValMag = abs(peakVal) - abs(peakVal_1);
    peakValAngle = (angle(peakVal) - angle(peakVal_1));
    
    plot(fh1_ax1, abs(peakVal), Color=col.color01(file_i,:))
    plot(fh1_ax2, (angle(peakVal))*180/pi, Color=col.color01(file_i,:))
    
    plot(fh2_ax1, peakValMag, Color=col.color01(file_i,:))
    plot(fh2_ax2, peakValAngle*180/pi, Color=col.color01(file_i,:))
    
    a =1;
    legendsStrings{file_i} = dataFile_name;
end
figure(fh1)
sgtitle("PeakVal")
ylabel(fh1_ax1, 'Magnitude')
ylabel(fh1_ax2, 'Angle')
xlabel(fh1_ax2, "Channel Number")
legend(fh1_ax1, legendsStrings, 'Interpreter', 'none')

figure(fh2)
sgtitle("PeakVal - relative to first dataset")
ylabel(fh2_ax1, 'Magnitude')
ylabel(fh2_ax2, 'Angle')
xlabel(fh2_ax2, "Channel Number")
