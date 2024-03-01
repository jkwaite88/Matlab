function c = speedCorrelation(antennaData1, antennaData2, removeMean)

if removeMean
    AntennaData1 = fft(antennaData1 - mean(antennaData1));
    AntennaData2 = fft(antennaData2 - mean(antennaData2));
else    
    AntennaData1 = fft(antennaData1);
    AntennaData2 = fft(antennaData2);
end
Data = AntennaData1 .* conj(AntennaData2);

c = fft(Data);
