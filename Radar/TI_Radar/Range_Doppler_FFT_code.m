clear all
close all
fclose all
clc



% Profile parameters
N_range = 256; % ADC Samples per chirp
N_frame =1083;      % Number of frames
N_dopp = 4;       % Number of chirps in each frame
n_adc_bits = 16;     % Number of ADC bits 
n_rx = 4;            % Number of Recieve antennas
n_tx = 3;            % Number of Transmit antennas
n_txrx = n_rx*n_tx;  % Number of combined transmit and recieve antennas 
N_fft = 256;

sample_rate_khz = 12499;
chirp_slope_mhz_us = 20.314;  
df = [0:N_range-1]/N_range*sample_rate_khz*1000;
rng = 3e8*df/(2*chirp_slope_mhz_us*1e12);
norm_factor = (sqrt(2)/(2^(n_adc_bits-1)-1)); % nomalization factor 
samples_req = N_range*N_dopp*N_frame*n_rx*n_tx*2;   

for idx_f = 1:1

  fname_load = 'adc_data_Raw_Outside4.bin';
    fid = fopen(fname_load,'r');                       % Opening data file 
    

    for jj = 1:1
        jj
        dat = [];
        dat = fread(fid,samples_req,'int16'); % Reading a certain number of bytes from data file

        if length(dat)~=samples_req
           keyboard
        end
        
       Ch_All = reshape(dat,4,[]);         % Reshape data
 
       Ch_R = reshape(Ch_All(1:2,:),1,[]); % Real part of data (Complex data due to I/Q sampling)  
       Ch_I = reshape(Ch_All(3:4,:),1,[]); % Imaginary part of data (Complex data due to I/Q sampling)
 
       Ch = Ch_R + i*Ch_I;                 % Complex data
       
        clear Ch_R;clear Ch_I
        Ch = reshape(Ch,N_range,n_tx*n_rx*N_dopp*N_frame); % Rearranging data
        compute_range_doppler_FFT(Ch,idx_f,N_range,N_dopp,n_txrx,N_frame,norm_factor);
        clear Ch
    end

    clear fname_load;clear dat;clear Ch_All;clear Ch;
    

end

load Range_FFT_1

for idx_f = 1:1

    [max_rng] = max(20*log10(abs(Ch_11_fft(30:50,:).')));
    [~,idx_rng(1)] = max(max_rng); clear max_rng
 
    idx_rng(idx_f) = idx_rng(idx_f) + 29;

    
    Ch(idx_f,1,:) =  Ch_11_fft(idx_rng(idx_f),:);
    Ch(idx_f,2,:) =  Ch_21_fft(idx_rng(idx_f),:);
    Ch(idx_f,3,:) =  Ch_31_fft(idx_rng(idx_f),:);
    Ch(idx_f,4,:) =  Ch_41_fft(idx_rng(idx_f),:);
    Ch(idx_f,5,:) =  Ch_12_fft(idx_rng(idx_f),:);
    Ch(idx_f,6,:) =  Ch_22_fft(idx_rng(idx_f),:);
    Ch(idx_f,7,:) =  Ch_32_fft(idx_rng(idx_f),:);
    Ch(idx_f,8,:) =  Ch_42_fft(idx_rng(idx_f),:);
    Ch(idx_f,9,:) =  Ch_13_fft(idx_rng(idx_f),:);
    Ch(idx_f,10,:) = Ch_23_fft(idx_rng(idx_f),:);
    Ch(idx_f,11,:) = Ch_33_fft(idx_rng(idx_f),:);
    Ch(idx_f,12,:) = Ch_43_fft(idx_rng(idx_f),:);
    
    clear max_rng;
    
end

save('Ch_Calibration.mat','Ch')


