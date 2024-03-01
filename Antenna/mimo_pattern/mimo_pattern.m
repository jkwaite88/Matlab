function [] = mimo_pattern(ArrayType, BeamAngle, QuantizePhase)

% [] = mimo_pattern(TypeFlag, BeamAngle, QuantizePhase)
%
% Compute and plot MIMO radar and traditional beamforming patterns
%
% INPUTS:
% ArrayType = 1: Traditional arrays
%             2: MIMO arrays (lambda/2 Rx, Tx evenly spaced)
%             3: MIMO arrays (lambda Rx, pairs of Tx)
%             4: MIMO arrays (groups of lambda/2 Rx, Tx)
%             5: MIMO arrays (groups of lambda/2 Rx, linear Tx)
%
% BeamAngle = Angle of main beam (degrees). Optional (default = 0)
%
% QuantizePhase = Flag to determine phase quantization. Optional. However,
%                 you must set BeamAngle if you set QuantizePhase
%                 0: Tx beamformer has continuous phase (default)
%                 1: Tx beamformer phase snaps to closest quantized value
%                 2: Tx beam angle adjusted to value that can be achieved
%                    using quantized phase


% Set beam_angle if not set
if ~exist('BeamAngle', 'var')
    BeamAngle = 0;
end

% Set phase quantization if not set
if ~exist('QuantizePhase', 'var')
    QuantizePhase = 0;
end

% Hard-coded parameters
% Number of angle points from -90 to 90
Nalpha = 361;
alpha = linspace(-90, 90, Nalpha)*pi/180;

% Number of transmit and receive elements
NTx = 6;
NRx = 8;

% Virtual array spacing
d = 0.5;

% ---------------------------------------------------------------------------
% Construct Tx and Rx arrays
[pos_tx, pos_rx] = arrays(d, NTx, NRx, ArrayType);

% Get virtual array
[pos_v] = virtual_array(pos_tx, pos_rx);

% Display array geometries
plot_array(pos_tx, pos_rx, pos_v, 1, 0.2, 'Arrays');

% Array Weights
% Virtual array weights in column vector first ordered in Rx, then in Tx
VWeight = dolph(NTx*NRx, 30);
VW = reshape(VWeight, NRx, NTx)
[U, S, V] = svd(VW);
RxWeight = -sqrt(S(1,1))*U(:,1)
TxWeight = -conj(sqrt(S(1,1))*V(:,1))

VWp = RxWeight*TxWeight.'



% Tx and Rx array radiation patterns
% Only Tx beamformer has quantized phase
[TxPhase, TxPeak] = get_phase_vector(pos_tx(:,1), BeamAngle, QuantizePhase);
%TxWeight = ones(NTx,1);
TxWeight = dolph(NTx,30);
E_tx = get_pattern(pos_tx(:,1), TxPhase, TxWeight, alpha);
%TxTitle = sprintf('Tx Array: Peak = %0.2f degrees', TxPeak);
%plot_pattern(alpha, E_tx, 2, 'b', TxTitle);
RxPhase = get_phase_vector(pos_rx(:,1), BeamAngle, 0);
RxWeight = ones(NRx,1);
%RxWeight = dolph(NRx,10);
E_rx = get_pattern(pos_rx(:,1), RxPhase, RxWeight, alpha);
%RxTitle = sprintf('Rx Array: Peak = %0.2f degrees', BeamAngle);
%plot_pattern(alpha, E_rx, 3, 'r', RxTitle);
TRTitle = sprintf('Tx, Rx Array: Peak = %0.2f degrees', BeamAngle);
plot_pattern(alpha, [E_tx; E_rx], 2, ['r','b'], TRTitle);

% Multiplication of patterns
EM = E_tx.*E_rx;
plot_pattern(alpha, EM, 4, 'k', 'Multiplied Patterns');

% Pattern for virtual array
% Note that TI chip does not have discrete phase limitation for MIMO
VPhase = get_phase_vector(pos_v, BeamAngle, 0);
EV = get_pattern(pos_v, VPhase, VWeight, alpha);
EV2 = get_pattern(pos_v, VPhase, reshape(VWp,numel(VWp),1), alpha);
plot_pattern(alpha, [EV; EV2], 5, ['k', 'g'], 'Virtual Array');

return;


% Plot the array geometries for visualization
function [] = plot_array(pos_tx, pos_rx, pos_v, fig_num, p_xtext, p_title)

figure(fig_num);
NTx = size(pos_tx,1);
NRx = size(pos_rx,1);
Nv = length(pos_v);
plot(pos_tx(:,1),  2*ones(NTx,1), 'bs', 'MarkerFaceColor', 'b');
hold on;
plot(pos_rx(:,1), zeros(NRx,1), 'rs', 'MarkerFaceColor', 'r');
plot(pos_v(:,1), -2*ones(Nv,1), 'ks', 'MarkerFaceColor', 'k');
hold off;
set(gca, 'YLim', [-5 5]);
text(p_xtext, 2.5, 'Tx Array', 'Color', 'b');
text(p_xtext, 0.5, 'Rx Array', 'Color', 'r');
text(p_xtext, -1.5, 'Virtual Array', 'Color', 'k');
xlabel('Element Position (lambda)');
title(p_title);


% Routine to plot the pattern E as a function of alpha in dB
function [] = plot_pattern(alpha, E, fig_num, LColor, p_title)

NP = size(E, 1);
alpha_d = alpha*180/pi;
figure(fig_num);
for n = 1:NP
    if n == 2
        hold on;
    end
    plot(alpha_d, 20*log10(abs(E(n, :))), LColor(n), 'LineWidth', 2);
end
hold off;
title(p_title);

% Plot from -90 to 90, -40 to 0 dB
set(gca, 'XLim', [-90 90], 'YLim', [-40 0]);
xlabel('Angle (degrees)');
ylabel('dB');
title(p_title);


