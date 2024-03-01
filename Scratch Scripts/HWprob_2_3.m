
load receivedPulses
% This contains variables:
% numRangeGates
% numPulses
% rangeRes
% prf
% fc (RF center frequency)
% receivedPulses (complex matrix with dimensions numRangeGates x numPulses)

% Use all of these variables to answer Homework problems 2 and 3


% Two-pulse canceller example code
filteredPulses = zeros(numRangeGates,numPulses-1);
for idx=1:numPulses-1
    filteredPulses(:,idx) = receivedPulses(:,idx+1)-receivedPulses(:,idx);
end

%% -- Homework Problem #2 -- Implement a three-pulse canceller ----------------
   
%put the result in filteredPulses


% Plot Results

%Before MTI processing
figure;
imagesc(20*log10(abs(receivedPulses)));
xlabel('Pulse Index');
ylabel('Range Gate');
colorbar;
axis xy;
grid on;

%After MTI processing
figure;
imagesc(20*log10(abs(filteredPulses)));
xlabel('Pulse Index');
ylabel('Range Gate');
colorbar;
axis xy;
grid on;




%% -- Homework Problem #3 -- Implement Pulse Doppler Processing (one-line of code)

%filteredPulses = ?

%Before PD processing
figure;
imagesc(20*log10(abs(receivedPulses)));
xlabel('Pulse Index');
ylabel('Range Gate');
colorbar;
axis xy;
grid on;

%After PD processing
figure;
imagesc(20*log10(abs(filteredPulses)));
xlabel('Doppler Bin');
ylabel('Range Gate');
colorbar;
axis xy;
grid on;
