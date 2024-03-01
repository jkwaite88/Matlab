secondsPerPulse = 279e-6;
hoursPerPrimaryPulse = secondsPerPulse/3600*2;
mph2fps = 5280/3600;
hours2seconds = 3600;
pulseCount= uint32(1:100:(2^32-1));
currentSpeed = 30; %MPH

t = double(pulseCount) * hoursPerPrimaryPulse * 0.5 * hours2seconds;
t_single = single(pulseCount) * single(hoursPerPrimaryPulse) * single(0.5) * single(hours2seconds);

trainLength =  mph2fps*currentSpeed * t;
trainLength_single =  single(mph2fps)*single(currentSpeed) * t_single;

figure(1)
clf

plot(trainLength_single - trainLength)


figure(2)
clf
hold on
plot(trainLength, 'b')
plot(trainLength_single, 'r--')