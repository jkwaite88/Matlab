function [pos_tx, pos_rx] = arrays(d, NTx, NRx, ArrayType)

% [pos_tx, pos_rx] = arrays(d, NTx, NRx, ArrayType)
%
% Generate radar linear arrays
%
% Inputs:
%	d = desired actual or virtual array spacing (wavelengths)
%	NTx = total number of transmit array elements (must be even for ArrayType = 3)
%   NRx = total number of receive array elements
%   ArrayType = type of array configuration
%               1: d-spaced Rx and Tx arrays (traditional)
%               2: d-spaced Rx array, NRx*d-spaced Tx array
%               3: 2*d-spaced Rx array, Tx array in d-spaced pairs
%               4: groups of d-spaced Rx array, NRx*d spaced Tx arrays
%               5: groups of d-spaced Rx array, linear Tx arrays
% Outputs:
%   pos_tx = NTx x 1 matrix of transmit element x positions
%   pos_rx = NRx x 1 matrix of receive element x positions

% For grouped (TI cascade) solutions, number of Rx and Tx elements per
% group
NR = 4;
NT = 3;

% Traditional linear arrays
if ArrayType == 1
    pos_tx = lin_array(d, NTx, 0);
    pos_rx = lin_array(d, NRx, 0);
    
% d-spaced Rx array, NRx*d-spaced Tx array
elseif ArrayType == 2
    pos_rx = lin_array(d, NRx, 0);
    pos_tx = lin_array(NRx*d, NTx, 0);

% 2*d-spaced Rx array, Tx array in d-spaced pairs
elseif ArrayType == 3

    % Rx array
    dRx = 2*d;
    pos_rx = lin_array(dRx, NRx, 0);

    % Tx array spacing and number of segments
    dTx = d;
    Nseg = NTx/2;
    
    % Tx array
    pos_tx = zeros(NTx, 1);
    for n = 1:Nseg
        pos_tx((2*(n-1)+1):(2*n)) = lin_array(dTx, 2, (n-1)*NRx*dRx);
    end


elseif ArrayType == 4

    % Number of groups (assumes groups of NT-Tx antennas, NR-Rx antennas)
    NGroup = NRx/NR;
    pos_rx = zeros(NRx, 1);
    pos_tx = zeros(NTx, 1);

    ROffset = NT*NR*d;
    TOffset = NGroup*ROffset;

    for n = 1:NGroup
        % Rx array
        pos_rx((NR*(n-1)+1):(NR*n)) = lin_array(d, NR, (n-1)*ROffset);

        % Tx array
        pos_tx((NT*(n-1)+1):(NT*n)) = lin_array(NR*d, NT, (n-1)*TOffset);
    end
    
elseif ArrayType == 5

    % Number of groups (assumes groups of NT-Tx antennas, NR-Rx antennas)
    NGroup = NRx/NR;
    pos_rx = zeros(NRx, 1);

    ROffset = NTx*NR*d;

    for n = 1:NGroup
        % Rx array
        pos_rx((NR*(n-1)+1):(NR*n)) = lin_array(d, NR, (n-1)*ROffset);
    end

    % Tx array
    pos_tx = lin_array(NR*d, NTx, 0);

end


function [pos] = lin_array(d, n, offset)

% [pos] = lin_array(d, n, offset);
%
% Generate positions for a linear array.
%
% Inputs:
%	d = spacing (wavelengths)
%	n = number of antennas
%   offset = offset from zero of first element (wavelengths)
%
% Output:
%   pos = n x 1 vector containing x position of each antenna

pos = (offset + (0:n-1)*d).';