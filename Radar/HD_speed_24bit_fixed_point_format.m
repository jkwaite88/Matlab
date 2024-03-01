h = 0x80375E;
h = 0xfffe3c;

valid = bitshift(bitand(uint32(h),uint32(0x800000)),-23)
signedIntegerPart = bitshift(bitand(uint32(h),uint32(0x7FFF00)),-8);
decimalPart =bitand(uint32(h),uint32(0x0000FF));

integerPart =  twosComp2dec_15bit(signedIntegerPart);

Nfloat = double(integerPart) + (double(sign(integerPart))*double(decimalPart)/256)

test = twosComp2dec_15bit(-55);
test =  twosComp2dec_15bit(0x07FED)

function a = twosComp2dec_15bit(d)
    b = bitand(uint32(d),uint32(0x7FFF));

    if (bitand(uint32(b),uint32(0x00004000)) == 0x4000)
        %negative number - twos compliment
        %alternate method - ignoring the MSB the number could have been
        %interpreted as and integer, then subtract 2^numBits
        c = bitcmp(uint32(b));
        c = bitand(c, uint32(0x7FFF));
        a = -(int32(c) + int32(1));
    else
        %positive number
        a = b;
    end
    
end