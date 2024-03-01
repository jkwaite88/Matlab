%Negative Frequencies

N = 2^12;
Fs = 1000;
T = 1/Fs;
t = (0:(N-1))*T;

f1 = 250;
c = exp(j*2*pi*f1*t);
C = fft(c)
f = Fs.*(-(N/2):(N/2-1))/N;

f2 = f1;
r = real(exp(j*2*pi*f2*t));
R = fft(r)

figure(1)
clf;
hold on
plot(r, 'g')
plot(c, 'b')
axis square

figure(2)
clf;
hold on
plot(f, abs(fftshift(C)),'b.-')
plot(f, abs(fftshift(R)),'g.-')
axis square