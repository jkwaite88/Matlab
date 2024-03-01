TX = 0;
RX = 1;


%% tx parameters
numElements_tx = 6;
elementSpacingWavelengths_tx = 2.0;
steerAngle_tx = -12;
%elementWindow_tx = ones(1,numElements_tx);
%elementWindow_tx = hanning(numElements_tx);
elementWindow_tx = chebwin(numElements_tx,33);
window_quantization_tx_db = 3; % 0=no quantization
tx_phase_quantization_degrees = 5.625; % 0=no quantization

%% Rx Parameters
numElements_rx = 8;
elementSpacingWavelengths_rx = [0.6];
steerAngle_rx = -12;
%elementWindow_rx = ones(1,numElements_rx);
%elementWindow_rx = hanning(numElements_rx);
elementWindow_rx = chebwin(numElements_rx,33);

%% MIMO Parameters
numElements_tx_MIMO = 6;
numElements_rx_MIMO = 8;
elementSpacingWavelengths_rx_MIMO = [0.7];
steerAngle_virtual = steerAngle_rx;

numElements_virtual = numElements_tx_MIMO * numElements_rx_MIMO;
%elementWindow_virtual = ones(1,numElements_virtual);
%elementWindow_virtual = hanning(numElements_virtual);
elementWindow_virtual = chebwin(numElements_virtual,33);

%% Multiple MIMO Parameters
numElements_tx_mm = 6;
num_mm_tx_sub_arrays = 2; %must be factor of numElements_tx_mm
num_elements_tx_sub_array = numElements_tx_mm/num_mm_tx_sub_arrays;
steerAngle_tx_mm = -0;
window_quantization_tx_db_mm = 3;
tx_phase_quantization_degrees_mm = 5.625; % 0=no quantization

numElements_rx_mm = 8;
steerAngle_rx_mm = -0;
steerAngle_virtual_mm = steerAngle_rx_mm;
num_elements_virutal_sub_array = num_elements_tx_sub_array * numElements_rx_mm;

small_element_spacing = TX;

switch small_element_spacing
    case RX
        elementSpacingWavelengths_rx_mm = [0.5];    
        elementSpacingWavelengths_tx_mm = elementSpacingWavelengths_rx_mm * numElements_rx_mm;    
    case TX
        elementSpacingWavelengths_tx_mm = [0.5];    
        elementSpacingWavelengths_rx_mm = elementSpacingWavelengths_tx_mm * numElements_tx_mm;    
        elementSpacingWavelengths_mm = elementSpacingWavelengths_tx_mm;
    otherwise
        error('Incorrect parameter')
end

numElements_virtual_mm_sub = num_elements_tx_sub_array * numElements_rx_mm;
numElements_virtual_mm = numElements_tx_mm * numElements_rx_mm;
%elementWindow_virtual = ones(1,numElements_virtual);
%elementWindow_virtual = hanning(numElements_virtual);
elementWindow_virtual_mm = chebwin(numElements_virtual,33);
elementWindow_tx_mm_sub = chebwin(num_elements_tx_sub_array,33);
elementWindow_rx_mm = chebwin(numElements_rx_mm,33);
elementWindow_virtual_mm_sub = chebwin(num_elements_virutal_sub_array,33);


%% array factor
arrayAngleSpacingDegrees = 0.01;
azimuth_angles_degrees = -90: arrayAngleSpacingDegrees:90;

elementWindow_tx_quantized_dB = quantize_window_dB(elementWindow_tx, window_quantization_tx_db);

[tx_array_element_positions, rx_array_element_positions] = get_array_element_positions(elementSpacingWavelengths_tx, numElements_tx, elementSpacingWavelengths_rx, numElements_rx, 1);
[tx_array_element_positions_MIMO, rx_array_element_positions_MIMO] = get_array_element_positions(elementSpacingWavelengths_rx_MIMO, numElements_tx_MIMO, elementSpacingWavelengths_rx_MIMO, numElements_rx_MIMO,  2);
virtual_array_element_positions = get_virtual_array_element_positions(tx_array_element_positions_MIMO, rx_array_element_positions_MIMO);

[tx_ArrayPhase, tx_BeamPeakAngle] = get_array_steering_phase(tx_array_element_positions, steerAngle_tx, tx_phase_quantization_degrees);
[rx_ArrayPhase, rx_BeamPeakAngle] = get_array_steering_phase(rx_array_element_positions, steerAngle_rx, 0);
[virtual_ArrayPhase, virtual_BeamPeakAngle] = get_array_steering_phase(virtual_array_element_positions, steerAngle_virtual, 0);



af_tx = get_array_factor_pattern(tx_array_element_positions, tx_ArrayPhase, elementWindow_tx_quantized_dB, azimuth_angles_degrees);
af_rx = get_array_factor_pattern(rx_array_element_positions, rx_ArrayPhase, elementWindow_rx, azimuth_angles_degrees);
af = af_tx .* af_rx;
af_virtual = get_array_factor_pattern(virtual_array_element_positions, virtual_ArrayPhase, elementWindow_virtual, azimuth_angles_degrees);

[bw_tx, bwAngle_tx, peakIdx_tx] = beamwidth(20*log10(abs(af_tx)), 3, azimuth_angles_degrees, steerAngle_rx, 2);
[bw_rx, bwAngle_rx, peakIdx_rx] = beamwidth(20*log10(abs(af_rx)), 3, azimuth_angles_degrees, steerAngle_rx, 2);
[bw, bwAngle, peakIdx] = beamwidth(20*log10(abs(af)), 3, azimuth_angles_degrees, 0, 1);
[bw_virtual, bwAngle_virtual, peakIdx_virtual] = beamwidth(20*log10(abs(af_virtual)), 3, azimuth_angles_degrees, 0, 1);

%% array factor multiple MIMO (mm)
elementWindow_tx_quantized_dB_mm = quantize_window_dB(elementWindow_tx_mm_sub, window_quantization_tx_db_mm);

[tx_array_element_positions_mm, rx_array_element_positions_mm] = get_array_element_positions(elementSpacingWavelengths_tx_mm, numElements_tx_mm, elementSpacingWavelengths_rx_mm, numElements_rx_mm,  2);
virtual_array_element_positions_mm = get_virtual_array_element_positions(tx_array_element_positions_mm, rx_array_element_positions_mm);
tx_array_element_positions_mm_sub = reshape(tx_array_element_positions_mm, num_elements_tx_sub_array, num_mm_tx_sub_arrays);
virtual_array_element_positions_mm_sub = reshape(virtual_array_element_positions_mm, num_elements_virutal_sub_array, num_mm_tx_sub_arrays);

[tx_ArrayPhase_mm, tx_BeamPeakAngle_mm] = get_array_steering_phase(tx_array_element_positions_mm, steerAngle_tx_mm, tx_phase_quantization_degrees_mm);
[rx_ArrayPhase_mm, rx_BeamPeakAngle_mm] = get_array_steering_phase(rx_array_element_positions_mm, steerAngle_rx_mm, 0);
[virtual_ArrayPhase_mm, virtual_BeamPeakAngle_mm] = get_array_steering_phase(virtual_array_element_positions_mm, steerAngle_virtual_mm, 0);

tx_ArrayPhase_mm_sub = reshape(tx_ArrayPhase_mm, num_elements_tx_sub_array, num_mm_tx_sub_arrays);
virtual_ArrayPhase_mm_sub = reshape(virtual_ArrayPhase_mm, num_elements_virutal_sub_array, num_mm_tx_sub_arrays)

af_rx_mm = get_array_factor_pattern(rx_array_element_positions_mm, rx_ArrayPhase_mm, elementWindow_rx_mm, azimuth_angles_degrees);
af_virtual_mm = get_array_factor_pattern(virtual_array_element_positions_mm, virtual_ArrayPhase_mm, elementWindow_virtual_mm, azimuth_angles_degrees);
for i = 1:num_mm_tx_sub_arrays
    af_tx_mm_sub(:,i) = get_array_factor_pattern(tx_array_element_positions_mm_sub(:,i), tx_ArrayPhase_mm_sub(:,i), elementWindow_tx_quantized_dB_mm, azimuth_angles_degrees);
    af_mm_sub(i,:) = af_tx_mm_sub(:,i).' .* af_rx_mm;
end
%% plot
plot_array(tx_array_element_positions_MIMO, rx_array_element_positions_MIMO, [], 1, 1.2, 'Arrays')

figure(2);clf
h(1) = plot(azimuth_angles_degrees, 20*log10(abs(af_tx)), 'color', 'b');
legendStr{1} = 'Tx';
hold on
plot(bwAngle_tx,  20*log10(abs(af_tx(peakIdx_tx))), 'color', 'b', 'Marker', '.', 'MarkerSize', 15)
h(2) = plot(azimuth_angles_degrees, 20*log10(abs(af_rx)), 'color', 'g');
legendStr{2} = 'Rx';
plot(bwAngle_rx, 20*log10(abs(af_rx(peakIdx_rx))), 'color', 'g', 'Marker', '.', 'MarkerSize', 15)
h(3) = plot(azimuth_angles_degrees, 20*log10(abs(af)), 'color', 'r');
legendStr{3} = 'Combined';
plot(bwAngle, 20*log10(abs(af(peakIdx))), 'color', 'r', 'Marker', '.', 'MarkerSize', 15)
hold off
grid on
str1 = sprintf('Num Tx Elements: %d; Num Rx Elements: %d', numElements_tx,numElements_rx);
str2 = sprintf('\nElement Spacing: Tx %3.2f\\lambda; Rx %3.2f\\lambda', elementSpacingWavelengths_tx, elementSpacingWavelengths_rx);
str3 = sprintf('\nQuantization: Tx  %3.1f dB, %3.1f\\circ; Rx %3.1f dB, %3.1f\\circ', window_quantization_tx_db, tx_phase_quantization_degrees, 0, 0);
str4 = sprintf('\nSteer Angle: Tx %3.1f\\circ; Rx: %3.1f\\circ',  steerAngle_tx, steerAngle_rx);
str5 = sprintf('\nBeamwidth: Tx %3.1f\\circ; Rx %3.1f\\circ; Combined %3.1f\\circ',bw_tx, bw_rx, bw);
title(strcat(str1, str2, str3, str4, str5))
axis([-90 90 -50 3  ])
legend(h, legendStr)

plot_array(tx_array_element_positions_MIMO, rx_array_element_positions_MIMO, virtual_array_element_positions, 3, 1.2, 'MIMO Arrays')
figure(4);clf
plot(azimuth_angles_degrees, 20*log10(abs(af_virtual)), 'color', 'b')
grid on
str1 = sprintf('Num Virtual Elements: %d', numElements_virtual);
str2 = sprintf('\nElement Spacing: %3.2f\\lambda', elementSpacingWavelengths_rx_MIMO);
str3 = sprintf('\nBeamwidth: %3.1f\\circ',bw_virtual);
str4 = sprintf('\nSteer Angle: %3.1f\\circ',  steerAngle_virtual);
title(strcat(str1, str2, str3, str4))
axis([-90 90 -50 3  ])
legend('Virtual')
%% plot multiple mimo

figure(5);clf;
h(1) = plot(azimuth_angles_degrees, 20*log10(abs(sum(af_tx_mm_sub(:,1),2))), 'color', 'b');
legendStr{1} = 'Tx';
hold on
h(2) = plot(azimuth_angles_degrees, 20*log10(abs(af_rx_mm)), 'color', 'g');
legendStr{2} = 'Rx';
h(3) = plot(azimuth_angles_degrees, 20*log10(abs(af_mm_sub(1,:))), 'color', 'r');
legendStr{3} = 'Combined';
axis([-90 90 -50 3  ])
legend(h, legendStr)
title('Multiple MIMO - (Investigation not complete)')
%%
function [] = plot_array(pos_tx, pos_rx, pos_v, fig_num, p_xtext, p_title)

    figure(fig_num);
    NTx = size(pos_tx,1);
    NRx = size(pos_rx,1);
    Nv = length(pos_v);
    plot(pos_tx(:,1),  2*ones(NTx,1), 'bs', 'MarkerFaceColor', 'b');
    hold on;
    text(p_xtext, 2.5, 'Tx Array', 'Color', 'b');
    plot(pos_rx(:,1), zeros(NRx,1), 'rs', 'MarkerFaceColor', 'r');
    text(p_xtext, 0.5, 'Rx Array', 'Color', 'r');
    if ~isempty(pos_v)
        plot(pos_v(:,1), -2*ones(Nv,1), 'ks', 'MarkerFaceColor', 'k');
        text(p_xtext, -1.5, 'Virtual Array', 'Color', 'k');
    end
    hold off;
    set(gca, 'YLim', [-5 5]);
    xlabel('Element Position (lambda)');
    title(p_title);
    axis([-inf inf -4 4])
end
