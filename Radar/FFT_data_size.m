f_sample_Hz = 1000;
time_max_sec = 0.001;
N = 1000;

f1_Hz = 41.;
f2_Hz = 64;

t_sample = 1/f_sample_Hz;
%t = double(t_sample:t_sample:time_max_sec);
t = (0:(N-1))*t_sample;
L = length(t);
f =  f_sample_Hz * (0:(L-1))/L;

y_32 = int32((2^11-1)*(sin(2*pi*f1_Hz*t) + 0*sin(2*pi*f2_Hz*t)));
y_16 = int16(y_32);
y_complex = exp(1j*2*pi*f1_Hz*t);

Y_32 = fft(y_32);
Y_16 = fft(y_16);
Y_diff = abs(Y_32) - abs(Y_16);
Y_complex = fft(y_complex);

figure(1);clf;hold on;
plot(t,y_32, 'Color','b')
plot(t,y_16, 'Color','r' ,'LineStyle','--')

figure(2);clf;hold on;
%subplot(2,1,1)
plot(f, 20*log10(abs(Y_32)+1),'Color', 'b')
plot(f, 20*log10(abs(Y_16)+1),'Color', 'r','LineStyle','--')

% subplot(2,1,2)
% plot(f, (Y_diff),'Color', 'b')


figure(3);clf;hold on
plot((Y_32))

figure(4);clf;
plot(y_complex, color='b', LineStyle="-", marker='.')

figure(5);clf;hold on;
plot(Y_complex)