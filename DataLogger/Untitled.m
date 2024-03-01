test plot

xHrMin =   0;
xMinMin = 1;
xSecMin = 40;
xHrMax = 0;
xMinMax = 1;
xSecMax = 50;


% xHrMin =22;
% xMinMin = 36;
% xSecMin = 50;
% xHrMax = 22;
% xMinMax = 37;
% xSecMax = 50;


figure(8);
clf;
hold on;
%stairs(data.Time, data.LOOP1,'b','linewidth', 2);
%stairs(data.Time, data.R1Z1,'g');
stairs(data.Time, data.R2Z1,'r');
xlim([duration(xHrMin,xMinMin,xSecMin) duration(xHrMax,xMinMax,xSecMax)]);
ylim([0 1.1]);



figure(10);
clf;
hold on;
%stairs(combinedData.time, combinedData.loop(1).data,'b','linewidth', 2);
%stairs(combinedData.time, combinedData.radar(1).zone(1).data,'g');
stairs(combinedData.time, combinedData.radar(2).zone(1).data,'r');
xlim([duration(xHrMin,xMinMin,xSecMin) duration(xHrMax,xMinMax,xSecMax)]);
ylim([0 1.1]);

figure(12);
clf;
hold on;
stairs(cleanedData.time, cleanedData.loop(1).data,'b','linewidth', 2);
stairs(cleanedData.time, cleanedData.radar(2).zone(1).data);
xlim([duration(xHrMin,xMinMin,xSecMin) duration(xHrMax,xMinMax,xSecMax)]);
ylim([0 1.1]);
