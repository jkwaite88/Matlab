function window_quantized = window_quantization(window, quantization_dB)
%Given an window as an input, convert it to a window quantized in steps of size db_quantization
%window is a scaler array that will multiply numbers used in the an array factor

    window_dBm = 10*log10(window.^2/2/50/0.001);
    max_dBm = max(window_dBm);
    window_quantized_dBm = floor(window_dBm/quantization_dB)*quantization_dB;
    
    adjust = max_dBm - max(window_quantized_dBm);
    window_quantized_dBm = round(window_quantized_dBm + adjust);
    window_quantized_w = 10.^(window_quantized_dBm/10)*0.001;
    window_quantized_vrms =  sqrt(window_quantized_w*50);
    window_quantized_v = window_quantized_vrms*sqrt(2);
    window_quantized = window_quantized_v;
end
