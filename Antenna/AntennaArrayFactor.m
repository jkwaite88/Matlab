%%AntennaArrayFactor
N = 48;  %number of antenna elements
d = 2.5; %antenna elecment spacing, in lambda
steeringAngle = 10; %angle the main beam is steered
percentElementsWithPhaseErrors = 1/48;


[tx_position, rx_position] = get_array_element_positions(d, N, 0, 0, 1);

k = 2*pi;
angles = -90:0.1:90; % angles to calculate the beam pattern

%win = ones(N,1); %window to apply to atenna elements
%win = hann(N); %window to apply to atenna elements
win = chebwin(N,40);

%phase errors
N_errors = ceil(percentElementsWithPhaseErrors *N); % number of elements to apply a phase error to
error_idx = sort(randperm(N, N_errors));

% Element Phase Errors
error_option = 2;
switch(error_option)
    case 1
        %uniform distribution
        mean_angle = 0;
        max_error_degrees = 7; %maximum possible phase error in degrees
        error_angles = (rand(1, N_errors)*2-1)*max_error_degrees + mean_angle;  %unifrom distribution from (-1 to 1)*max_error_degrees
        optionString = sprintf('Uniform Distribution - Mean %3.1f, max \x00B1%3.1f', mean_angle, max_error_degrees);
    case 2
        %Gausion distrubtion
        mean_angle  = 0;
        std_angle = 15;
        error_angles = randn(1, N_errors) *std_angle + mean_angle;
        optionString = sprintf('Normal Distribution - Mean %3.1f, Std %3.1f - ', mean_angle, std_angle);
    otherwise
        error('Enter valid option')
end
%error_angles = (rand(1, N_errors))*max_error_degrees; %only positive errors
errorAngleDegrees =zeros(1,N);
errorAngleDegrees(error_idx) = error_angles;
errors = exp(1j*errorAngleDegrees*pi/180)';
weights = errors.*win;

[tx_ArrayPhase, tx_BeamPeakAngle] = get_array_steering_phase(tx_position, steeringAngle, 0);
af_tx = get_array_factor_pattern(tx_position, tx_ArrayPhase, win, angles);
af_tx_error = get_array_factor_pattern(tx_position, tx_ArrayPhase, weights, angles);


figure(3);clf;
subplot(2,1,1)
hold on;
plot(angles, 20*log10(abs(af_tx)),'Color', 'b', LineStyle='-')

plot(angles, 20*log10(abs(af_tx_error)),'Color', 'r', LineStyle='-')

axis([-90 90 -60 1])
grid
legend('No phase errors', 'With phase errors')
title('Beam Pattern')
xlabel('Degrees')
ylabel('dB')


subplot(2,1,2)
hold on;

plot(tx_position, errorAngleDegrees, 'Marker','.', 'Color', 'r', MarkerSize= 20')
grid on;
title(['Element Phase Error - ' optionString])
xlabel('Element Position - Wavelengths (\lambda)')
ylabel('Phase Error \circ')
axis([(min(tx_position)-1) (max(tx_position)+1) -20 20])
