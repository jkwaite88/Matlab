function w = quantize_window_dB(window, quantizaiton_level_db)
%function w = quantize_window_dB(window, quantizaiton_level_db)
%
% Quantize a window in steps measured in dB
% INPUTS:
%   window: an array in linear (not dB)
%   quantizaiton_level_db: the amount in dB that the window will be quantized to
    if quantizaiton_level_db == 0 
        w = window;
    else
        window_dB = 20*log10(window);
        window_dB_q = round(window_dB/quantizaiton_level_db)*quantizaiton_level_db;
        w = 10.^(window_dB_q/20);
    end
end