%RadarSimulatorFMCW_simple
c = 3e8;
B = 250e6;
T = 11.4e-6;
fs = 22.5e6;
fo = 60.5e9;
ts = 1/fs;
N = 256;
Range_target_m = 10;
tau = 2*Range_target_m/c;

t = (1:N)*ts;
f = (1:N)/N*fs;
a = B/T;


vout = exp(-1j*2*pi*(fo*tau + (a*tau^2)/2 - a*tau*t));
Vout = fft(vout);

fh1 = figure(1);
plot(t,real(vout))

fh2 = figure(2);
plot(f,20*log10(abs(Vout)))
