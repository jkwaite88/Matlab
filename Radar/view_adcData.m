% view_adcData

%The files 'adcData_allFrames.mat' and 'radar_data_Rxchain_allFrames.mat' were manually made by inserting a few lines of code in 'cascade_MIMO_signalProcessing.m'  and '4chip_cascade_MIMO_example\modules\calibration\@calibrationCascade\datapath.m'
%The varialbes collected are 'adcData' and 'radar_data_Rxchain_allFrames', respectively.
%radar_data_Rxchain_allFrames is the uncalibrated date and adcData is the calibrated data

%In cascade_MIMO_signalProcessing.m the following lines were inserted startin on line 125:
%            jlw = 0;
%            if jlw == 1
%                adcData_allFrames(frameIdx,:,:,:,:) = adcData;
%                if frameIdx == numValidFrames
%                    save(strcat(dataFolder_test, "adcData_allFrames.mat"), "adcData_allFrames")
%                end
%            end

%In cascade_MIMO_signalProcessing.m the following lines were inserted startin on line 92:
%    jlw = 0;
%    if jlw == 1
%        fileName = strcat(obj.binfilePath.dataFolderName, "radar_data_Rxchain_allFrames.mat");
%        if frameIdx == 2
%           if exist(fileName, "file") == 2
%                delete(fileName)
%           end
%           radar_data_Rxchain_allFrames = [];
%       else
%            load(fileName, "radar_data_Rxchain_allFrames")
%       end
%        
%        radar_data_Rxchain_allFrames(frameIdx,:,:,:,:) = radar_data_Rxchain;
%        
%        save(fileName, "radar_data_Rxchain_allFrames")
%        
%    end


load('C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector\adcData_allFrames.mat', 'adcData_allFrames')
load('C:\ti\mmwave_studio_03_00_00_14\mmWaveStudio\PostProc\Data_5m_cornerRelector\radar_data_Rxchain_allFrames.mat', 'radar_data_Rxchain_allFrames')

adcData_allFrames = reshape(adcData_allFrames, size(adcData_allFrames,1), size(adcData_allFrames,2), size(adcData_allFrames,3), size(adcData_allFrames,4) * size(adcData_allFrames,5) );
radar_data_Rxchain_allFrames = reshape(radar_data_Rxchain_allFrames, size(radar_data_Rxchain_allFrames,1), size(radar_data_Rxchain_allFrames,2), size(radar_data_Rxchain_allFrames,3), size(radar_data_Rxchain_allFrames,4) * size(radar_data_Rxchain_allFrames,5) );

ch1 = 50;
frame1 = 7;
frame2 = 8;
frames = [5 6 7 8 9];


myColors = colorC;
figure(11);clf;
subplot(2,1,1)
hold("on")
for i = 1:length(frames)
    data1 =adcData_allFrames(frames(i),:,1, ch1);
    data2 = radar_data_Rxchain_allFrames(frames(i),:,1, ch1);
    plot(abs(data1), color=myColors.color01(frames(i),:))
    plot(abs(data2), color=[ 0 0 0])

end

subplot(2,1,2)
hold("on")
for i = 1:length(frames)
    data1 =adcData_allFrames(frames(i),:,1, ch1);;
    data2 = radar_data_Rxchain_allFrames(frames(i),:,1, ch1);
    plot(angle(data1), color=myColors.color01(frames(i),:))
    plot(angle(data2), color=[ 0 0 0])
end

