indM = 50;

messageVersion = char(data((indM+0):(indM+1)))'
sequenceNumber =     (data((indM+4):(indM+4)))'
bodySize       =     data(indM+6)*2^8 + data(indM+7)
bodyDataSize   = bodySize - 9
crcHdr         = dec2hex(data((indM+9):(indM+15)))
crc1 = crc();
crcData = data(indM:(indM+7));
bodyCrcCalc = dec2hex(crc1.Crc64(0,crcData, length(crcData)))
msgID           = data(indM+16)
bodyData = data((indM+17):indM+17+bodyDataSize-1)
bodyCrc = dec2hex(data((indM+17+bodyDataSize):(indM+17+bodyDataSize+8-1)))
bdyCrcCalc = dec2hex(crc1.Crc64(0,[msgID bodyData'],length(bodyData)+1))