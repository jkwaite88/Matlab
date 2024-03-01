% AntennaVirutalElementPosition

%All positions in wavelengths
transmit_y_print_offset = 1;
receive_y_print_offset = 2;
receive2_y_print_offset = 5;


%in units of wavelength from left to right
transmit_order = [12 11 10 3 2 1 9 8 7 6 5 4];
transmit_x = [0.0 2.0 4.0 4.5 5.0 5.5 6.0 8.0 10.0 12.0 14.0 16.0];
transmit_y = [0.0 0.0 0.0 0.5 2.0 3.0 0.0 0.0 0.0 0.0 0.0 0.0];

transmit_order = [13 14 15 16 1 2 3 4 9 10 11 12 5 6 7 8];
receive_array_offset_x = 0;%-7.759;
receive_array_offset_y = 0; %19.072;
receive_x = receive_array_offset_x + [0.0 0.5 1.0 1.5 5.5 6.0 6.5 7.0 23.0 23.5 24.0 24.5 25.0 25.5 26.0 26.5];
receive_y = receive_array_offset_y +[0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0];

numTx = length(transmit_x);
numRx = length(receive_x);

% Use kronecker products to create matrices that can be added
p_rx = kron(receive_x.', ones(1,numTx));
p_tx = kron(ones(numRx,1), transmit_x);
p_vx = p_rx + p_tx;
p_vx = reshape(p_vx, numRx*numTx, 1);
[p_vx, sort_i] = sort(p_vx);

p_ry = kron(receive_y.', ones(1,numTx));
p_ty = kron(ones(numRx,1), transmit_y);
p_vy = p_ry + p_ty;
p_vy = reshape(p_vy, numRx*numTx, 1);
p_vy = p_vy(sort_i);

numVirtual = length(p_vx);
unique_virtual = unique(p_vx);
numUniqueVirtElements = length(unique_virtual);

tx_symbol = '.';
rx_symbol = 'o';
color = {'b', 'g', 'r', 'm', 'k', 'c', 'y', [.5 .6 .7],[.8 .2 .6], [0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560], [0.4660, 0.6740, 0.1880], [0.3010, 0.7450, 0.9330], [0.6350, 0.0780, 0.1840] };
txMarkerSize = 14;
rxMarkerSize = 10;
rxLineWidth = 2.0;

virtual_offset_x = 0;
virtual_offset_y = 0 ; %0:0.1:2;
figure(1)
clf
hold on

for i = 1:numTx
    plot(transmit_x(i), transmit_y(i), 'color', color{i}, 'Marker', tx_symbol, 'MarkerSize', txMarkerSize, DisplayName = sprintf('tx %d' , i))
end

for i = 1:numRx
    plot(receive_x(i), receive_y(i),  'color', color{i}, 'Marker', rx_symbol, 'MarkerSize', rxMarkerSize, 'LineWidth', rxLineWidth, DisplayName = sprintf('rx %d' , i))
end
xlabel("Wavelengths")
ylabel("Wavelengths")
title("Element position (\lambda)")
legend

figure(2)
clf
hold on

for t = 1:numTx
    for r = 1:numRx
        i = (t-1)*numRx + r;
        virtual_x(i) = transmit_x(t) + receive_x(r) + virtual_offset_x;
        virtual_y(i) = transmit_y(t) + receive_y(r) + virtual_offset_y;
        
        plot(virtual_x(i), virtual_y(i), 'color', color{t}, 'Marker', tx_symbol, 'MarkerSize', txMarkerSize)
        plot(virtual_x(i), virtual_y(i), 'color', color{r}, 'Marker', rx_symbol, 'MarkerSize', rxMarkerSize, 'LineWidth', rxLineWidth)
        stophere = 1;    
    end
end
xlabel("Wavelengths")
ylabel("Wavelengths")
title("Virtual Element position (\lambda)")

virtual_position = [virtual_x.' virtual_y.'];
[unique_virtual, ia, ic] = unique(virtual_position, 'rows', 'stable');
numUniqueVirtElements = length(unique_virtual);
%not_unique_virutal = 
figure(3)
clf
hold on

plot(p_vx, p_vy, Marker=".", LineStyle="none")
plot(p_vx, p_vy, Marker=".", LineStyle="none")
grid on
title("Virtual Element Positions")
xlabel("Wavelengths")
ylabel("Wavelengths")
