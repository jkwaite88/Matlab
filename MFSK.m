%% MFSK

sample_frequency = 1e6;
number_samples = 256;
t = (1:number_samples)./sample_frequency; 

c = 3e8;
start_frequency = 24e9;
lambda = c/start_frequency;
number_of_steps = 10;
frequency_step = 25e6;
frequency_offset = 0.1e6; 
step_time = 10e-6;
samples_per_step = step_time * sample_frequency;

target_range = [40 50]; %meters
target_velocity = [0 0]; %m/s
number_targets = size(target_range,2);

s = zeros(1,number_samples);


start_step_time = t(1);
for sample = 1:num_samples
    time = t(sample);
    
    for target = 1:number_targets
        delay = (target_range(target) - target_velocity(target)*time) /c;
        s(sample) = s(sample) + exp(1i*2*pi*delay/lambda);
        
    end
end

signal = real(s);

figure(1)
plot(signal)


