% view allRadarData

%The file radarData.mat is a 5-D variable. The dimesions represent the frame, adc sample, doppler chirp, rx channel, tx channel
% this file was created be setting a break point in the datapath function on line 84, when called by the 'cascade_MIMO_antennaCalib.m' script.
% when at this breakpoint the file was manuall created by entering the following commands at the command promt.
%After the save command, the debugger was stopped, the frame number in 'cascade_MIMO_antennaCalib.m' was incremented, then the script was run
%again. The three commands were then run again and the process repeated for the desired number of frames..


%        load('C:\temp\radarData.mat', 'allRadarData')
%        allRadarData(frameIdx,:,:,:,:) = radar_data_Rxchain;
%        save('C:\temp\radarData.mat', 'allRadarData')
%        


load('C:\temp\radarData.mat', 'allRadarData')

average_doppler = false;
if average_doppler == true
    data = squeeze(mean(allRadarData, 3));
    data = reshape(data, [size(data,1), size(data,2), size(data,3) * size(data,4)]);
    
    %%
    
    ch1 = 50;
    frame1 = 7;
    frame2 = 8;
    frames = [5 6 7 8];
    
    myColors = colorC;
    figure(10);clf;
    subplot(2,1,1)
    hold("on")
    for i = 1:length(frames)
        data1 =data(frames(i),:, ch1);
        plot(real(data1), color=myColors.color01(frames(i),:))
    end
    
    subplot(2,1,2)
    hold("on")
    for i = 1:length(frames)
        data1 =data(frames(i),:, ch1);
        plot(imag(data1), color=myColors.color01(frames(i),:))
    end

    win = hann()


else
    data = allRadarData;
    data = reshape(data, [size(data,1), size(data,2), size(data,3), size(data,4)*size(data,5)]);
    
    %%
    
    ch1 = 50;
    frame1 = 7;
    frame2 = 8;
    frames = [5 6 7 8];
    
    
    myColors = colorC;
    figure(10);clf;
    subplot(2,1,1)
    hold("on")
    for i = 1:length(frames)
        data1 =squeeze(data(frames(i),:,:, ch1));
        plot(real(data1), color=myColors.color01(frames(i),:))
    end
    
    subplot(2,1,2)
    hold("on")
    for i = 1:length(frames)
        data1 =squeeze(data(frames(i),:,:, ch1));
        plot(imag(data1), color=myColors.color01(frames(i),:))
    end
    
    

end