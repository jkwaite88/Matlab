clear all
%close all
clc
% Number of Rows in spreadsheet
numSensors = 28;

fid = fopen('ManfTestChamber Combined - 2018-09-06.csv','r');
idx = 1;
Noise = zeros(2,16);
SNR = zeros(2,16);
Peaks = zeros(2,16);
% line = fgets(fid); % Skip first line



idx_Nan = 1;
for kk = 1:numSensors

  line = fgets(fid);
% keyboard
  a=strfind(line,'Matrix Data Histogram');

  if isempty(a)
      
  if isempty(strfind(line,'|')) == true;
    disp('ERROR: wrong format')
    keyboard
    idx=idx+1;
    continue
  end
  row = strsplit(line,'|');
%     keyboard
  if isempty(strfind(row{1},'U1000')) == false;
%       keyboard
    cDelimNum = strsplit(row{1},'U1000');
    second_half = cDelimNum{2};
    sensorSN = str2num(second_half(1:5));
  end
            %% FOR NOISE PLOT ##
  if isempty(strfind(row{2},'Raw Bin Ave Noise')) == false;
%       keyboard
    cDelimNum = strtok(row{2},'"');
    cDelimNum = strsplit(cDelimNum,':');
    newLine=strsplit(cDelimNum{2},',');
    newLine = cellfun(@str2num,newLine);
    Noise=newLine;
  end
  
  
  clear cDelimNum;
  clear newLine
 
              %% FOR SNR PLOT ##
  if isempty(strfind(row{3},'Raw Peak SNR')) == false;
    cDelimNum = strtok(row{3},'"');
    cDelimNum = strsplit(cDelimNum,':');
    newLine=strsplit(cDelimNum{2},',');
    newLine = cellfun(@str2num,newLine);
    SNR=newLine;
  end
  clear cDelimNum;
  clear newLine
  
            %% FOR MAGNITUDE PLOT ##
 if isempty(strfind(row{4},'Raw Peak Mag')) == false;

   cDelimNum = strtok(row{4},'"');
   cDelimNum = strsplit(cDelimNum,':');
   newLine=strsplit(cDelimNum{2},',');
   newLine = cellfun(@str2num,newLine);
   Peaks= newLine;
 end
             %% FOR Antenna Coefficients ##
 if isempty(strfind(row{9},'Normalized Calculated Antenna Coefficients')) == false;
     
   cDelimNum = strtok(row{9},'"');
   cDelimNum = strsplit(cDelimNum,':');
   newLine=strsplit(cDelimNum{2},',');
   newLine = cellfun(@str2num,newLine);
   Ant_coeff= newLine;
 end
%  keyboard
 
 
 Sensor_No = sensorSN;
 
    if idx==1
                Noise_Save(idx,:) = Noise;
                SNR_Save(idx,:) = SNR;
                Peaks_Save(idx,:) = Peaks;
                Sensor_No_Save(idx) = Sensor_No;
                Ant_Coeff_Save(idx,:) = Ant_coeff;
        idx=idx+1;
        
        else
%      idx_rep = find(Sensor_No_Save==Sensor_No);
%             if (isempty(idx_rep))
                
                Noise_Save(idx,:) = Noise;
                SNR_Save(idx,:) = SNR;
                Peaks_Save(idx,:) = Peaks;
                Sensor_No_Save(idx) = Sensor_No;
                Ant_Coeff_Save(idx,:) = Ant_coeff;
                idx=idx+1;
                
                
%             else
%                 [idx_rep idx]
%                 fprintf('\n')
% 
%                 Noise_Save(idx_rep,:) = Noise;
%                 SNR_Save(idx_rep,:) = SNR;
%                 Peaks_Save(idx_rep,:) = Peaks;
%                 Sensor_No_Save(idx_rep) = Sensor_No;
%                 
 %            end
 end
 
clear line
clear row
clear cDelimNum;
clear newLine
clear SNR
clear Sensor_No
clear Peaks
clear Noise
clear idx_rep
clear Ant_coeff
  else


 clear line
  end
end

fclose all
clear a
clear ans
clear fid
clear idx
clear idx_Nan
clear kk
clear line
clear numSensors
clear sensorSN


% for kk = 1:length(Sensor_No_Save)
%  current_no = Sensor_No_Save(kk);
%  
%  if (find(current_no==Sensor_No_Save)==kk)
%  else
%      others = find(current_no==Sensor_No);
%      [kk; others(2:end)]
%      keyboard
% 
%  end
%  clear current_no
%  clear others
% end
Noise = Noise_Save;
Peaks = Peaks_Save;
Sensor_No = Sensor_No_Save;
SNR = SNR_Save;
Ant_coeff=Ant_Coeff_Save;
% colors={'-*r','-*g','-*b','-*k','-*m','-or','-og','-ob','-ok','-om'};
% figure(1)
% hold on
% for kk = 1:10
% plot(Noise(kk,:),colors{kk})
% end
% figure(2)
% hold on
% for kk = 1:10
% plot(Peaks(kk,:),colors{kk})
% end
%plot(Peaks.','o')
save('Jonathan_test','Noise','SNR','Peaks','Sensor_No','Ant_coeff')

%Sensor_plot = 39256;
%Sensor_plot = 39257;
Sensor_plot = 39259;


idx_plot = find(Sensor_No==Sensor_plot);
figure(1);
plot(0:15,Noise(idx_plot,:).')
grid on
xlabel('Antenna Number')
ylabel('Noise (dB)')
title(strcat('Sensor SN: ', num2str(Sensor_plot)))
% legend
figure(2)
plot(0:15,Peaks(idx_plot,:).');
xlabel('Antenna Number')
ylabel('Power (dB)')
title(strcat('Sensor SN: ', num2str(Sensor_plot)))
grid on 
figure(3)
plot(0:15,SNR(idx_plot,:).');
xlabel('Antenna Number')
ylabel('SNR (dB)')
title(strcat('Sensor SN: ', num2str(Sensor_plot)))
grid on 


straightBar5004 = [1 2 3];
straightBar = [4 5 6];
stratightBarUpsideDown = [7 8 9];
curvedBar = [10 12 13];
curvedBarUpsideDown = [14 17 18];
curvedBarOffsetRight = [19 22 25];
curvedBarOffsetLeft = [26 27 28];

xlimits =[0 15];
ylimits = [40 55];
ylimits2 = [-4 2];
ylimits3 = [30 50];
ylimits4 = [-5 20];

figure(4)
clf;
subplot(2,1,1)
hold on
a1 = plot(0:15,SNR(straightBar5004,:).');
set(gca,'ColorOrderIndex',1)
a2 = plot(0:15,SNR(straightBar,:).','--');
xlabel('Antenna Number')
ylabel('SNR (dB)')
title(strcat('Sensor SNR In Different Chambers'))
legend([a1(1); a2(1)], {'Chamber with Horns'; 'Chamber with HD Antennas'}, 'location', 'best')
ylim(ylimits)

subplot(2,1,2)
hold on
plot(0:15,(SNR(straightBar5004,:)-SNR(straightBar,:)).');
xlabel('Antenna Number')
ylabel('SNR (dB)')
title(strcat('Sensor SNR Difference Between Chambers'))
legend('39256', '39257', '39259', 'location', 'best')

figure(5)
clf
subplot(2,1,1)
hold on
a1 = plot(0:15,SNR(straightBar,:).');
set(gca,'ColorOrderIndex',1)
a2 = plot(0:15,SNR(stratightBarUpsideDown,:).','--');
xlabel('Antenna Number')
ylabel('SNR (dB)')
title(strcat('Sensor SNR - Straight Bar'))
legend([a1(1); a2(1)], {'Right Side Up'; 'Upside Down'}, 'location', 'best')
ylim(ylimits)

subplot(2,1,2)
hold on
plot(0:15,(SNR(straightBar,:)-SNR(stratightBarUpsideDown,:)).');
xlabel('Antenna Number')
ylabel('SNR (dB)')
title(strcat('Sensor SNR Difference Between Orientations'))
legend('39256', '39257', '39259', 'location', 'best')
ylim(ylimits2)

figure(6)
clf
subplot(2,1,1)
hold on
a1 = plot(0:15,SNR(curvedBar,:).');
set(gca,'ColorOrderIndex',1)
a2 = plot(0:15,SNR(curvedBarUpsideDown,:).','--');
xlabel('Antenna Number')
ylabel('SNR (dB)')
title(strcat('Sensor SNR - Curved Bar'))
legend([a1(1); a2(1)], {'Right Side Up'; 'Upside Down'}, 'location', 'best')
ylim(ylimits)

subplot(2,1,2)
hold on
plot(0:15,(SNR(curvedBar,:)-SNR(curvedBarUpsideDown,:)).');
xlabel('Antenna Number')
ylabel('SNR (dB)')
title(strcat('Sensor SNR Difference Between Orientations'))
legend('39256', '39257', '39259', 'location', 'best')
ylim(ylimits2)

figure(7)
clf
subplot(2,1,1)
hold on
a1 = plot(0:15,SNR(curvedBar,:).');
set(gca,'ColorOrderIndex',1)
a2 = plot(0:15,SNR(curvedBarOffsetRight,:).','--');
xlabel('Antenna Number')
ylabel('SNR (dB)')
title(strcat('Sensor SNR - Curved Bar'))
legend([a1(1); a2(1)], {'Pointed Straight'; 'Right Offset'}, 'location', 'best')
ylim(ylimits3)

subplot(2,1,2)
hold on
plot(0:15,(SNR(curvedBar,:)-SNR(curvedBarOffsetRight,:)).');
xlabel('Antenna Number')
ylabel('SNR (dB)')
title(strcat('Sensor SNR Difference Between Orientations'))
legend('39256', '39257', '39259', 'location', 'best')
ylim(ylimits4)
xlim(xlimits)

figure(8)
clf
subplot(2,1,1)
hold on
a1 = plot(0:15,SNR(curvedBar,:).');
set(gca,'ColorOrderIndex',1)
a2 = plot(0:15,SNR(curvedBarOffsetLeft,:).','--');
xlabel('Antenna Number')
ylabel('SNR (dB)')
title(strcat('Sensor SNR - Curved Bar'))
legend([a1(1); a2(1)], {'Pointed Straight'; 'Left Offset'}, 'location', 'best')
ylim(ylimits3)

subplot(2,1,2)
hold on
plot(0:15,(SNR(curvedBar,:)-SNR(curvedBarOffsetLeft,:)).');
xlabel('Antenna Number')
ylabel('SNR (dB)')
title(strcat('Sensor SNR Difference Between Orientations'))
legend('39256', '39257', '39259', 'location', 'best')
ylim(ylimits4)
xlim(xlimits)

