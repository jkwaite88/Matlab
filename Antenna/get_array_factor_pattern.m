function [E] = get_array_factor_pattern(x, ArrayPhase, ArrayWeight, alpha_degrees)

% [E] = get_pattern(x, alpha)
%
% Generate field pattern, normalized to a peak of 1, evaluated at the
% azimuth angles contained in the vector alpha.
%
% Inputs:
%	x = vector of x position of array antenna elements (wavelengths)
%   ArrayPhase = vector of element phase
%   ArrayWeight = vector of element weights
%	alpha = vector of azimuth angles
%
% Outputs:
%   E = complex vector of field pattern evaluated at alpha angles

% Wavenumber
k = 2*pi;

% Matrix with column array factor at each angle
A = ArrayWeight.*exp(1j*(k*x*sind(alpha_degrees) - ArrayPhase));

% Row vector by summing down each column
E = sum(A);
E = E/max(abs(E));


