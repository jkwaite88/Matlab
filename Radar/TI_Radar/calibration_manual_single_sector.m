clear all
close all
clc


load Ch_Calibration.mat % Ch format is Number of Sectors x Number of Virtual Elements x Number of Chirp Samples
% Note that every Frame has 60 chrips with a frame time of 33.33 ms 

ang = 0:180/size(Ch,3):180-180/size(Ch,3); % Compute angle based on per frame. Note that this computation is not very accurate
% as we are mapping to angle domain uniformily. However, in reality we chirp for about 5.5ms and don't chirp for remaining 27.8 ms. 

N_chirp = 4;  % Total number of chirps used for calibration 
sector = 1;

% Plot the Power for all virtual elements for first sector 
figure(1)
plot(20*log10(abs(squeeze((Ch(sector,:,:))).')))
xlabel('Chirp Number ')
%plot(ang,20*log10(abs(squeeze((Ch(sector,:,:))).')))
%xlabel('Spin Angle (deg)')
ylabel('Relative Power (dB)')
grid on

% Compute the average max chirp number 
[~,idx_max] = max((squeeze(Ch(sector,:,1:2500)).')); % Look at the chirp number when sensor is infront of the target
idx_chirp = round(mean(idx_max));     
frame_idx = round(idx_chirp/N_chirp);


freq = 61.25e9;  % Middle Freq
dx_mil = 260;    % Antenna Spacing
lam = 3e8/freq;
dx = dx_mil/1000*2.54/100;
dx_lam = dx/lam;          % Sparse array 1.348 lam spacing 
n_tx = 3;
n_rx = 4;

% Element Locations 
x = [0:n_rx*n_tx-1].'*dx_lam;% - (n_rx*n_tx-1)/2*dx_lam; % Location of array elements 

% Compute calibration vector 
Cal   = squeeze(Ch(sector,:,frame_idx*N_chirp+1:(frame_idx+1)*N_chirp));
Cal   = Cal./Cal(1,:);

figure(2)
plot(abs(Cal))
xlabel('Virtual Elements')
ylabel('Calibration - Magnitude')
grid on

figure(3)
plot(angle(Cal).*180/pi)
xlabel('Virtual Elements')
ylabel('Calibration - Phase (deg)')
grid on


% Observe calibration impact on beamforming for the chirp at which
% calibration is computed 

N_ang = 180;
ang0 = -15; % FOV limits 
ang1 = 15;  
ang = ([0:N_ang-1]+0.5)/N_ang*(ang1 - ang0) + ang0;
sll = 40; % Side lobe level of window 
for ii = 1:N_ang
    w = exp(j*2*pi*x*sind(ang(ii))).*chebwin(n_rx*n_tx, sll);
    Ch_cal = Ch(sector,:,frame_idx*N_chirp+1)./mean(Cal.');
    P(ii) = abs(sum(w'.*Ch_cal)).^2;  
    clear w;
end
figure
plot(ang,10*log10(P))
xlabel('Angle(deg)')
ylabel('Relative Power (dB)')
% Look at figure 1 to compute start / end frame when we see a target
st_frame = round(1175/N_chirp);
end_frame = round(1988/N_chirp);


figure
% Look at overall calibration across the span of target 
N_ang = 180;
ang0 = -15; % FOV limits 
ang1 = 15;  
ang = ([0:N_ang-1]+0.5)/N_ang*(ang1 - ang0) + ang0;
sll = 40; % Side lobe level of window 
idx_s = 1;
for jj = st_frame:end_frame 
    for ii = 1:N_ang
        w = exp(j*2*pi*x*sind(ang(ii))).*chebwin(n_rx*n_tx, sll);
        Ch_cal = Ch(sector,:,jj*N_chirp+1)./mean(Cal.');
        P(idx_s,ii) = abs(sum(w'.*Ch_cal)).^2;  
        clear w;
    end
    plot(ang,10*log10(P(idx_s,:)))
    xlabel('Angle(deg)')
    ylabel('Relative Power (dB)')
    ylim([-90 -10])
    grid on
    pause 
    idx_s = idx_s+1;
end



    



    