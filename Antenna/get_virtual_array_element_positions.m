function [pos_v] = get_virtual_array_element_positions(pos_tx, pos_rx)

% [pos_v] = virtual_array(pos_tx, pos_rx);
%
% Generate positions for the virtual array sorted by increasing position
%
% Input:
%	pos_tx = NTx x 1 vector of transmit array element x positions (wavelengths)
%	pos_rx = NRx x 1 vector of receive  array element x position (wavelengths)
%
% Outputs:
%   pos_v = NRx*NTx x 1 vector of virtual array element x positions (wavelengths)

NTx = length(pos_tx);
NRx = length(pos_rx);

% Use kronecker products to create matrices that can be added
p_rx = kron(pos_rx, ones(1,NTx));
p_tx = kron(ones(NRx,1), pos_tx.');
p = p_rx + p_tx;

pv = reshape(p, NRx*NTx, 1);
pos_v = sort(pv);

