% check that only one bit is set in a number

i = uint32(1);

while 1
   n = -i;
   a = bitand(i, n);
   
   s = 0;
   for j= 0:1:31
       s = s + bitget(a,j); 
   end
   if s ~= 1
       sprintf('Fail')
       break
   end
    if i > 2^31
        break;
    end
end

    