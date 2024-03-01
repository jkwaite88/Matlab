function [w] = dolph(N, R)
% w = dolph(N, R)
%
% Generate Dolph-Chebyshev array weight coefficients
%
% Inputs:
%	N = Number of array elements
%   R = side lobe level (dB)
%
% Outputs:
%   w = vector of array weights

N1 = N-1;
Ra = 10^(R/20);
x0 = cosh(acosh(Ra)/N1);

i = 1:N1;
xi = cos(pi*(i-0.5)/N1);
psi = 2*acos(xi/x0);
zi = exp(1i*psi);

w = (real(poly(zi))).';

end