figure(1);clf;
x = linspace(-90,90,length(data));
hold on
plot(x, data(1:end),'b')

[mn, start] = min(abs(x+60));
[mn, stop] = min(abs(x-60));


plot(x(start:stop), data(start:stop), 'r')

figure(2);clf;
plot(x(start:stop), data(start:stop), 'r')