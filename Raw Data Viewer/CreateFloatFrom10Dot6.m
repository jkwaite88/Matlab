function floatVal = CreateFloatFrom10Dot6(dataArray)
% floatVal = CreateFloatFrom10Dot6(dataArray);
%
% This function converts a 2 byte data array that is in the 10.6 fixed
% format to a floating point number
%
% Written by Steven Reeves
% September 15, 2014

iValue = 0;
count = length(dataArray) - 1;

for x = 1:length(dataArray)
    iValue = bitor(iValue, bitshift(dataArray(x),count*8));
    count = count - 1;
end

floatVal = iValue / 64;