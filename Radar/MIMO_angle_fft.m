%MIMO_angle_fft
%This script will identify the angle represented by each bin of the MIMO
%angle fft
%

fft_size = 32;

d =0.5; %spacing on antenna elements in wavelengths

N = fft_size;

%argument of fft exponential
%FFT bin 0 (k=0) corresponds to no phase change between antenna elements (boresight)
%FFT bin 1 (k=1)corresponds to 2*pi*k*1/N radians change per bin
n = 1;
k = 0:(N-1);
a = 2*pi*k*n/N;
%a = a *(d/0.5); %multiply a by the percenage of 1/2 lambda spacing

%phase chagne between adjacent elements
% delta_p = 2*pi*d*cos(theta)/lambda
% theta = acos(delta_p*lambda/(w*pi*d)
%simplify by make d be in wavelengths

idx_r = 1:N;
%idx_r = [N:-1:(N/2+2) 1:(N/2+1)];

%adjust a so results are not imaginary
b = a/(2*pi*d);
idx = find(b > 1);


b(idx) = -(b(idx)-1);

b = b(idx_r);
theta = asin(b);
theta_deg = theta*180/pi;

fft_bin_num = k(idx_r);
T = table(fft_bin_num', ...
    theta_deg','VariableNames',{'FFT Bin Num (k)','Angle (deg)'}); 
figure(1);clf
uit = uitable('Data', table2cell(T),'ColumnName',T.Properties.VariableNames,...
    'Units', 'Normalized', 'Position',[0.1,0.05,0.8,0.9]);

figure(2);clf;
polarplot(exp(1j*(theta)), 'LineStyle','none', Marker='o')
axis square
grid on
f = 1.1;
axis([-f f -f f])