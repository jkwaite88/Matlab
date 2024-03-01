function [pos_tx, pos_rx] = get_array_element_positions(dTx, NTx, dRx, NRx,  ArrayType)

    % [pos_tx, pos_rx] = arrays(dRx, NRx, dTx, NTx, ArrayType)
    %
    % Generate radar linear arrays
    %
    % Inputs:
    %	dRx = desired actual or virtual Rx array spacing (wavelengths)
    %	dTx = desired actual or virtual Tx array spacing (wavelengths)
    %	NTx = total number of transmit array elements (must be even for ArrayType = 3)
    %   NRx = total number of receive array elements
    %   ArrayType = type of array configuration
    %               1: dRx-spaced Rx and dTx-spaced Tx arrays (traditional)
    %               2: d-spaced Rx array, NRx*d-spaced Tx array (set dTx to 0)
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
        pos_tx = lin_array(dTx, NTx, 0);
        pos_rx = lin_array(dRx, NRx, 0);
        
    % d-spaced Rx array, NRx*d-spaced Tx array
    elseif ArrayType == 2
        if dRx <= dTx || (dTx == 0)
            pos_rx = lin_array(dRx, NRx, 0);
            pos_tx = lin_array(NRx*dRx, NTx, 0);
        else
            pos_tx = lin_array(dTx, NTx, 0);
            pos_rx = lin_array(NTx*dTx, NRx, 0);
        end
    
    % 2*d-spaced Rx array, Tx array in d-spaced pairs
    elseif ArrayType == 3
    
        % Rx array
        dRx = 2*dRx;
        pos_rx = lin_array(dRx, NRx, 0);
    
        % Tx array spacing and number of segments
        dTx = dRx;
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
    
        ROffset = NT*NR*dRx;
        TOffset = NGroup*ROffset;
    
        for n = 1:NGroup
            % Rx array
            pos_rx((NR*(n-1)+1):(NR*n)) = lin_array(dRx, NR, (n-1)*ROffset);
    
            % Tx array
            pos_tx((NT*(n-1)+1):(NT*n)) = lin_array(NR*dRx, NT, (n-1)*TOffset);
        end
        
    elseif ArrayType == 5
    
        % Number of groups (assumes groups of NT-Tx antennas, NR-Rx antennas)
        NGroup = NRx/NR;
        pos_rx = zeros(NRx, 1);
    
        ROffset = NTx*NR*dRx;
    
        for n = 1:NGroup
            % Rx array
            pos_rx((NR*(n-1)+1):(NR*n)) = lin_array(dRx, NR, (n-1)*ROffset);
        end
    
        % Tx array
        pos_tx = lin_array(NR*dRx, NTx, 0);
    
    end
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
end