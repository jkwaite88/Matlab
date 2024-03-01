function [ArrayPhase, BeamPeakAngle] = get_phase_vector(x, BeamAngle, QuantizeFlag)

% [E] = get_pattern(x, alpha)
%
% Generate field pattern, normalized to a peak of 1, evaluated at the
% azimuth angles contained in the vector alpha.
%
% Inputs:
%	x = vector of x position of array antenna elements (wavelengths)
%   BeamAngle = angle of main beam (degrees)
%	QuantizeFlag = 0: Give exact phase to achieve BeamAngle
%                  1: Round phase to nearest discrete angle
%                  2: Adjust BeamAngle to what is achievable
%
% Outputs:
%   ArrayPhase = vector of element phase values

% Discrete phase increment (degrees)
DeltaPhase = 5.625;
DP = DeltaPhase*pi/180;

% Wavenumber
k = 2*pi;

% Beam steering angle in radians
bsa = BeamAngle*pi/180;

% Exact phase vector
AP = -k*x*sin(bsa);
NP = length(AP);

if QuantizeFlag == 0
    ArrayPhase = AP;
    BeamPeakAngle = BeamAngle;
elseif QuantizeFlag == 1
    ArrayPhase = zeros(size(AP));
    for n = 1:NP
        ArrayPhase(n) = round(AP(n)/DP)*DP;
    end

    % Find beam peak angle
    alpha = linspace(BeamAngle-10, BeamAngle+10, 301);
    E = get_pattern(x, ArrayPhase, alpha*pi/180);
    [~, peakIndex] = max(abs(E));
    BeamPeakAngle = alpha(peakIndex);

elseif QuantizeFlag == 2
    % Assume first element is at x = 0
    DelP = round((AP(2) - AP(1))/DP)*DP;
    bsa_p = -asin(DelP/(k*x(2)));
    ArrayPhase = -k*x*sin(bsa_p);
    BeamPeakAngle = 180*bsa_p/pi;
end

