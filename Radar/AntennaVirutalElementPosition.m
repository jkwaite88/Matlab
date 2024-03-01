% AntennaVirutalElementPosition

%All positions in wavelengths
transmit_y_offset = 1;
receive_y_offset = 2;
receive2_y_offset = 5;

transmit_x = [0.0 2.0 4.0 6.0 8.0 10.0 12.0 14.0 16.0];
transmit_y = [0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0] + transmit_y_offset;

receive_x = [0.0 0.5 1.0 1.5 5.5 6.0 6.5 7.0 23.0 23.5 24.0 24.5 25.0 25.5 26.0 26.5];
receive_y = [0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0] + receive_y_offset;
receive2_y = [0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0] + receive2_y_offset;

transmit2_y_offset = 1;
receive2_y_offset = 2;

transmit2_x = [0.0 0.5 1.0 1.5];
transmit2_y = [0.0 0.5 2.0 3.0] + transmit_y_offset;


virtual_offset_x = 0;
virtual_offset_y = 0:0.1:2;

virtual_offset2_x = 0;
virtual_offset2_y = (0:0.1:2) +1;

numTx = length(transmit_x);
numTx2 = length(transmit2_x);
numRx = length(receive_x);
numVirtual = numTx * numRx;
numVirtual2 = numTx2 * numRx;

virtual_x = zeros(1,numVirtual);
virtual_y = zeros(1,numVirtual);
virtual2_x = zeros(1,numVirtual2);
virtual2_y = zeros(1,numVirtual2);

tx_symbol = '.';
rx_symbol = 'o';
color = {'b', 'g', 'r', 'm', 'k', 'c', 'y', [.5 .6 .7],[.8 .2 .6], [0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560], [0.4660, 0.6740, 0.1880], [0.3010, 0.7450, 0.9330], [0.6350, 0.0780, 0.1840] };
txMarkerSize = 14;
rxMarkerSize = 10;
rxLineWidth = 2.0;

figure(1)
clf
hold on

for i = 1:numTx
    plot(transmit_x(i), transmit_y(i), 'color', color{i}, 'Marker', tx_symbol, 'MarkerSize', txMarkerSize)
end

for i = 1:numRx
    plot(receive_x(i), receive_y(i),  'color', color{i}, 'Marker', rx_symbol, 'MarkerSize', rxMarkerSize, 'LineWidth', rxLineWidth)
end

for t = 1:numTx
    for r = 1:numRx
        i = (t-1)*numRx + r;
        virtual_x(i) = transmit_x(t) + receive_x(r) + virtual_offset_x;
        virtual_y(i) = transmit_y(t) + receive_y(r) + virtual_offset_y(t);
        
        plot(virtual_x(i), virtual_y(i), 'color', color{t}, 'Marker', tx_symbol, 'MarkerSize', txMarkerSize)
        plot(virtual_x(i), virtual_y(i), 'color', color{r}, 'Marker', rx_symbol, 'MarkerSize', rxMarkerSize, 'LineWidth', rxLineWidth)
        stophere = 1;    
    end
end

unique_x = unique(virtual_x);
numUniqueElements = length(unique_x);

title(sprintf('%d Transmit, %d Recieve, %d x %d = %d, Unique element positions: %d ', numTx, numRx, numTx, numRx, numVirtual, numUniqueElements))
text(0.2, transmit_y_offset-0.1, 'Transmit antennas are dots')
text(0.2, receive_y_offset-0.1, 'Receive antennas are circles')
text(0.2, virtual_y(1)-0.1, 'Virtual elements are combinations of colored dots and circles. Virtual elements are separated vertically to be able to see them all.')
axis([-inf inf 0 (max(virtual_y)+1)])


figure(2)
clf
hold on

for i = 1:numTx2
    plot(transmit2_x(i), transmit2_y(i), 'color', color{i}, 'Marker', tx_symbol, 'MarkerSize', txMarkerSize)
end

for i = 1:numRx
    plot(receive_x(i), receive2_y(i),  'color', color{i}, 'Marker', rx_symbol, 'MarkerSize', rxMarkerSize, 'LineWidth', rxLineWidth)
end

for t = 1:numTx2
    for r = 1:numRx
        i = (t-1)*numRx + r;
        virtual2_x(i) = transmit2_x(t) + receive_x(r) + virtual_offset2_x;
        virtual2_y(i) = transmit2_y(t) + receive2_y(r) + virtual_offset2_y(t);
        
        plot(virtual2_x(i), virtual2_y(i), 'color', color{t}, 'Marker', tx_symbol, 'MarkerSize', txMarkerSize)
        plot(virtual2_x(i), virtual2_y(i), 'color', color{r}, 'Marker', rx_symbol, 'MarkerSize', rxMarkerSize, 'LineWidth', rxLineWidth)
        stophere = 1;    
    end
end

unique2_x = unique(virtual2_x);
numUniqueElements2 = length(unique2_x);

title(sprintf('%d Transmit, %d Recieve, %d x %d = %d, Unique element positions: %d ', numTx2, numRx, numTx2, numRx, numVirtual2, numUniqueElements2))
% text(0.2, transmit_y_offset-0.1, 'Transmit antennas are dots')
% text(0.2, receive_y_offset-0.1, 'Receive antennas are circles')
% text(0.2, virtual_y(1)-0.1, 'Virtual elements are combinations of colored dots and circles. Virtual elements are separated vertically to be able to see them all.')
axis([-inf inf 0 (max(virtual2_y)+1)])
