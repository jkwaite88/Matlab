Fs = 1000;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = 4;             % Length of signal
t = (0:L-1)*T;        % Time vector

% S = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);
S = 0*exp(1i*2*pi*50.*t )+ exp(1i*2*pi*1000.*t );
X = S + 0*randn(size(t));

figure(1)
clf
hold on
if L<50
    m = L;
else
    m = 50;
end
plot(1000*t(1:m),real(X(1:m)),'b')
plot(1000*t(1:m),imag(X(1:m)),'g')
title('Signal Corrupted with Zero-Mean Random Noise')
xlabel('t (milliseconds)')
ylabel('X(t)')

Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
fcomplex = Fs*(0:(L-1))/L;

figure(2)
plot(fcomplex,P2) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
axis([0 Fs 0 inf])

