function [ArrayPhase, BeamPeakAngle] = get_array_steering_phase(x_lambda, BeamSteerAngleDegrees, QuantizationValueDegrees)

% [E] = get_pattern(x, alpha)
%
% Generate array steering vector, 
%
% Inputs:
%	x_lambda = vector of x position of array antenna elements (wavelengths)
%   BeamAngle = angle of main beam (degrees)
%	QuantizeFlag = 0: Give exact phase to achieve BeamAngle
%                  non-zero value: Round phase to nearest discrete angle value
%
% Outputs:
%   ArrayPhase = vector of element phase values

% Discrete phase increment (degrees)
QuantizationValueRadinas = QuantizationValueDegrees*pi/180;

% Wavenumber
k = 2*pi;

% Beam steering angle in radians
beamSteeringAngleRadians = BeamSteerAngleDegrees*pi/180;

% Exact phase vector
AP = k*x_lambda*sind(BeamSteerAngleDegrees);

if QuantizationValueDegrees == 0
    ArrayPhase = AP;
    BeamPeakAngle = BeamSteerAngleDegrees;
elseif QuantizationValueDegrees ~= 0
    ArrayPhase = round(AP./QuantizationValueRadinas).*QuantizationValueRadinas;
    
    % Find beam peak angle
    alpha_degrees = linspace(BeamSteerAngleDegrees-10, BeamSteerAngleDegrees+10, 301);
    weigths = ones(size(x_lambda));
    E = get_array_factor_pattern(x_lambda, ArrayPhase, weigths, alpha_degrees);
    [~, peakIndex] = max(abs(E));
    BeamPeakAngle = alpha_degrees(peakIndex);

end

