%RadarSimulatorFMCW
c = 3e8;
B = 250e6;
T = 11.4e-6;
fs = 22.5e6;
fo = 60.5e9;
ts = 1/fs;
N_t = 256;
t = ((1:N_t)*ts)';
f = (1:N_t)/N_t*fs;
f_dot = B/T;
lambda = c/fo;
crt = 17.54-6; %chirp repition time
N_chirps = 192;



%antenna positions
dRx = 0.5;
NRx = 8;
dTx = 0;
NTx = 6;
ArrayType = 2;
[pos_tx_lambda, pos_rx_lambda] = get_array_element_positions(dTx, NTx, dRx, NRx,  ArrayType);
rx_offset_m = [0.00 0.1];


pos_tx_m = [pos_tx_lambda*lambda zeros(NTx, 1)];
pos_rx_m = [pos_rx_lambda*lambda zeros(NRx, 1)] + rx_offset_m;


vehicle_start_pos_m = [0 20];
velocity_m_s = [0 -10];

vehicle_pos_m = vehicle_start_pos_m + t*velocity_m_s;
%vehicle_range_Rt_m = (pos_tx_m(:,1) - vehicle_pos_m())
vehicle_range_Rt_m = (repmat(pos_tx_m, 1, 1, N_t) - vehicle_pos_m)
tau = 2*vehicle_pos_m/c;

si = exp(1j*2*pi*(fo*tau + f_dot*tau.*t - (f_dot*tau.^2)./2));
Si = fft(si);

fh1 = figure(1);
plot(t,real(si))

fh2 = figure(2);
plot(f,20*log10(abs(Si)))

fh3 = figure(3);clf;
hold("on")
plot(pos_tx_m(:,1)',pos_tx_m(:,2)', color='b', LineStyle='none', Marker='.')
plot(pos_rx_m(:,1)',pos_rx_m(:,2)', color='r', LineStyle='none', Marker='o')


function range = calcVehicleRange(pos_tx, pos_rx, pos_veh)
    
end
