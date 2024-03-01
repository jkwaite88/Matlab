N = 256;
k = (0:1:(N-1))-N/2;

theta = asin(2*k/N);

figure(1);clf
plot(k,theta*180/pi,'.')