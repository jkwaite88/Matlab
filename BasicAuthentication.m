%basic Authentication

% userName = 'test';
% password = '123#';
% userName = 'root';
% password = 'Asdf1234';
userName = 'root';
password = 'Asdf1234';

alphabet = {65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,48,49,50,51,52,53,54,55,56,57,43,47};

s = strcat(userName, ':', password);
 
s_ascii = double(s);
s_bin = dec2bin(s_ascii, 8);
 
s_bin_cat = '';

for i = 1:size(s_bin,1)
   s_bin_cat = strcat(s_bin_cat, s_bin(i,:));
end


%input is done in sets of 3 8-bit characters, or 24 bits
s_length = length(s_bin_cat);
num_sets = ceil(s_length/24);
ba_num_characters = num_sets*24/6;
s_length = length(s_bin_cat); 

%take six bits at a time
i = 1;
basicAuthorizationStr = '';
pad = 0;
for i = 1:ba_num_characters
    ind_start = (i-1)*6 + 1;
    ind_stop = ind_start + 5;
    if ind_stop <= s_length
        a = s_bin_cat(ind_start:ind_stop);
        aa = bin2dec(a);
        basicAuthorizationStr = strcat(basicAuthorizationStr, char(alphabet{aa+1}) );
    elseif ind_start < s_length
        a = s_bin_cat(ind_start:s_length);
        if length(a) == 2
            a_pad = strcat(a, '0000');
        elseif length(a) == 4
            a_pad = strcat(a, '00');
        end
       aa = bin2dec(a_pad);
       basicAuthorizationStr = strcat(basicAuthorizationStr, char(alphabet{aa+1}) );
    else
       basicAuthorizationStr = strcat(basicAuthorizationStr, '=' );
   end
end
    

basicAuthorizationStr
