clear all;
DB.DIR_EIRP = '\\napster\data\AntChamber\data\2018-07-21 Matrix RF EIRP\';
DB.DB = {
    'C:\Users\jwaite\Wavetronix LLC\Engineering Department - Matrix\2018-08-22\20180822 Matrix RF 451 06018 GeorgiaUnit NoMods Eng DelayLine.daq';
    'C:\Users\jwaite\Wavetronix LLC\Engineering Department - Matrix\2018-08-22\20180823 Matrix RF 451 06018 GeorgiaUnit BaseBand IproveV2 8CH Eng DelayLine.daq';
    'C:\Users\jwaite\Wavetronix LLC\Engineering Department - Matrix\2018-08-22\20180823 Matrix RF 451 06018 GeorgiaUnit BaseBand IproveV2 AllCHs Eng DelayLine.daq';
};

DB.Index.File = 1;
DB.Index.EIRP = 2;
DB.Index.Legend = 2;  % jlw **** What are these?
numFiles = size(DB.DB,1);

colors = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 0.5 0.5 0.5;...
            0.5 0 0; 0 0.5 0; 0 0 0.5; 1 0.62 0.4; 0.49 1 0.83;...
            0.4 1 0.62; 0.62 0.4 1; 1 0.83 0.49;    0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0;];

FIG_NUM = 16;
FIG_PK = 1;
FIG_NO = 2;
FIG_MEAN = 3;
FIG_SNR = 4;

FIG_ROWS = 2;
FIG_COLS = 2;

LineWidth = 2.0;

figure(FIG_NUM);clf;
subplot(FIG_ROWS,FIG_COLS,FIG_PK);hold on;box on;grid on;ylabel('dB');xlabel('Antenna # & Mean'); title('PEAK');
subplot(FIG_ROWS,FIG_COLS,FIG_NO);hold on;box on;grid on;ylabel('dB');xlabel('Antenna # & Mean');title('MODE');
subplot(FIG_ROWS,FIG_COLS,FIG_MEAN);hold on;box on;grid on;ylabel('dB');xlabel('Antenna # & Mean');title('MEAN');
subplot(FIG_ROWS,FIG_COLS,FIG_SNR);hold on;box on;grid on;ylabel('dB');xlabel('Antenna # & Mean');title('MAX2MEAN');
ChannelLegend = cell(numFiles,1);
set(gcf,'DefaultAxesColorOrder',colors);


figure(29);clf;hold on;box on;grid on;ylabel('dB');xlabel('Bin (1 Based)');
for i = 1:numFiles
    figure(FIG_NUM);
    fprintf('Processing: %s\n',DB.DB{i,DB.Index.File});
    Daq = load_daq_data( DB.DB{i,DB.Index.File}, 'KeepDownChirp', true);
    Daq = process_daq_data(Daq,'DelayLineProdCham');
    
    subplot(FIG_ROWS,FIG_COLS,FIG_PK);
    plot( [Daq.pks_dB mean(Daq.pks_dB)], 'LineWidth', LineWidth,'color', colors(i,:));
    
    subplot(FIG_ROWS,FIG_COLS,FIG_NO);
    plot( [Daq.mode mean(Daq.mode)], 'LineWidth', LineWidth ,'color', colors(i,:));
    
    subplot(FIG_ROWS,FIG_COLS,FIG_MEAN);
    plot([Daq.meanAcrossTime_dB(Daq.targetResponseBin,:) mean(Daq.meanAcrossTime_dB(Daq.targetResponseBin,:))],'LineWidth',LineWidth, 'color',colors(i,:));
    
    subplot(FIG_ROWS,FIG_COLS,FIG_SNR);
    plot([Daq.mx2mn mean(Daq.mx2mn)],'LineWidth',LineWidth ,'color',colors(i,:));
    
    
    figure(29);
    plot(Daq.meanAcrossTime_dB -mean(Daq.meanAcrossTime_dB(80:100,:)),'color',colors(i,:));
    
    %     figure(20+i);clf;hold on;box on;grid on;axis([1 289 -2^15 2^15]);
    %     title(DB.DB{i,DB.Index.Legend});
    %     for j = 1:Daq.num_channels
    %         plot(squeeze(Daq.data(:,j,(Daq.channels_peak_indices(j)))),'LineWidth',LineWidth ,'color',colors(j,:));
    %     end
    
    % Plot Peaks
%     figure(30);
%     for k = 1:16
%         fprintf('Ant %i\t',k);
%         for j = -7:0
%             pk0 = 10*log10(mean(abs(Daq.DATA(Daq.targetResponseBin,k,-16+(0:7)+Daq.channels_peak_indices(k)+j)).^2));
%             pk1 = 10*log10(mean(abs(Daq.DATA(Daq.targetResponseBin,k,-8+(0:7)+Daq.channels_peak_indices(k)+j)).^2));
%             pk2 = 10*log10(mean(abs(Daq.DATA(Daq.targetResponseBin,k,(0:7)+Daq.channels_peak_indices(k)+j)).^2));
%             pk3 = 10*log10(mean(abs(Daq.DATA(Daq.targetResponseBin,k,+8+(0:7)+Daq.channels_peak_indices(k)+j)).^2));
%             pk4 = 10*log10(mean(abs(Daq.DATA(Daq.targetResponseBin,k,+16+(0:7)+Daq.channels_peak_indices(k)+j)).^2));
%             pk = max([pk0 pk1 pk2 pk3 pk4]);
%             fprintf('%0.2f\t',pk);
%             plot(k,pk,'og');
%         end
%         plot(k,Daq.DATA_dB(Daq.targetResponseBin,k,Daq.channels_peak_indices(k)),'or');
%         fprintf('\n');
%     end
    %%
    %Plot Noise
%     ed = (20:1.5:150)';
%     cen_dB = ed + 1.5/2;
%     cen = 10.^(cen_dB./10);
%     figure(32);
%     %for k = 1:16
%         indx0 = Daq.MeanAcrossTimeIndx0;
%         indx1 = Daq.MeanAcrossTimeIndx1;
%         pts = indx1-indx0 + 1;
%         pts = floor(pts/8) * 8;
%         noi_data_dB = abs(Daq.DATA(Daq.targetResponseBin,:,(0:(pts-1)) + indx0)).^2;
%         noi_data_dB = reshape(noi_data_dB,[1 16 pts/8 8]);
%         noi_data_dB = 10*log10(sum(noi_data_dB,4)./8);
%         n = histc(noi_data_dB,ed,3);
%         noi_pwr = bsxfun(@times,n,reshape(cen,[1 1 numel(cen)]));
%         noi_pwr = sum(sum(noi_pwr,3),1);
%         noi_pwr = noi_pwr./sum(sum(n,3),1);
%         noi_dB = 10*log10(noi_pwr);
%         plot(noi_dB,'-or','color',colors(i,:));
%     %end
    

end

% Add a Ledgend
figure(FIG_NUM);
subplot(FIG_ROWS,FIG_COLS,FIG_SNR);
l = legend(DB.DB{:,DB.Index.Legend});
%annotation('textbox','String','175-0050 Matrix DSP\nSNR vs PGA Gain','Interpreter','none');



