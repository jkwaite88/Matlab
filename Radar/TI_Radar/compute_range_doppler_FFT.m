function [] = compute_range_doppler_FFT(Ch,idx_save,N_range,N_dopp,n_txrx,N_frame,norm_factor)


N_fft = N_range;
Ch_11 = Ch(:,1:n_txrx:end);  % Data for Rx 1 and Tx 1 (Spacing of 12 due to 3 Tx and 4 Rx antennas)
Ch_21 = Ch(:,2:n_txrx:end);  % Data for Rx 2 and Tx 1
Ch_31 = Ch(:,3:n_txrx:end);  % Data for Rx 3 and Tx 1
Ch_41 = Ch(:,4:n_txrx:end);  % Data for Rx 4 and Tx 1
Ch_12 = Ch(:,5:n_txrx:end);  % Data for Rx 1 and Tx 2
Ch_22 = Ch(:,6:n_txrx:end);  % Data for Rx 2 and Tx 2
Ch_32 = Ch(:,7:n_txrx:end);  % Data for Rx 3 and Tx 2
Ch_42 = Ch(:,8:n_txrx:end);  % Data for Rx 4 and Tx 2
Ch_13 = Ch(:,9:n_txrx:end);  % Data for Rx 1 and Tx 3
Ch_23 = Ch(:,10:n_txrx:end); % Data for Rx 2 and Tx 3
Ch_33 = Ch(:,11:n_txrx:end); % Data for Rx 3 and Tx 3
Ch_43 = Ch(:,12:n_txrx:end); % Data for Rx 4 and Tx 3

% save('Ch_Dir_Data','Ch_11','Ch_21','Ch_31','Ch_41','Ch_12','Ch_22','Ch_32','Ch_42','Ch_13','Ch_23','Ch_33','Ch_43','norm_factor');
% keyboard

black_win = repmat(blackman(N_range),1,N_dopp*N_frame);  % Blackman window

% Compute Range FFT for each chirp and each Tx/Rx antenna combination 
Ch_11_fft = (1/N_fft).*fft(Ch_11.*black_win.*norm_factor,N_fft,1);
Ch_21_fft = (1/N_fft).*fft(Ch_21.*black_win.*norm_factor,N_fft,1);
Ch_31_fft = (1/N_fft).*fft(Ch_31.*black_win.*norm_factor,N_fft,1);
Ch_41_fft = (1/N_fft).*fft(Ch_41.*black_win.*norm_factor,N_fft,1);

Ch_12_fft = (1/N_fft).*fft(Ch_12.*black_win.*norm_factor,N_fft,1);
Ch_22_fft = (1/N_fft).*fft(Ch_22.*black_win.*norm_factor,N_fft,1);
Ch_32_fft = (1/N_fft).*fft(Ch_32.*black_win.*norm_factor,N_fft,1);
Ch_42_fft = (1/N_fft).*fft(Ch_42.*black_win.*norm_factor,N_fft,1);

Ch_13_fft = (1/N_fft).*fft(Ch_13.*black_win.*norm_factor,N_fft,1);
Ch_23_fft = (1/N_fft).*fft(Ch_23.*black_win.*norm_factor,N_fft,1);
Ch_33_fft = (1/N_fft).*fft(Ch_33.*black_win.*norm_factor,N_fft,1);
Ch_43_fft = (1/N_fft).*fft(Ch_43.*black_win.*norm_factor,N_fft,1);

% Save Range FFT data 
fname_save = sprintf('Range_FFT_%d',idx_save);
save(fname_save,'Ch_11_fft','Ch_21_fft','Ch_31_fft','Ch_41_fft','Ch_12_fft','Ch_22_fft','Ch_32_fft','Ch_42_fft','Ch_13_fft','Ch_23_fft','Ch_33_fft','Ch_43_fft');

