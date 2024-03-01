figure(10);clf;
hold on; 
n = 100;
plot(data.LOOP1(1:n), color ='b', linewidth=3);
plot(data.LOOP2(1:n), color ='r', linewidth=2);
plot(combinedData.loop(1).data(1:n), color ='g', linewidth=1)