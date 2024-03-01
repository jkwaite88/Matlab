clear
fileName = 'C:\Users\jwaite\Downloads\IR BLack.bmp';
A = imread(fileName);
image(A)

B = squeeze(A(:,:,1));
C = (B==0); 

D = zeros(size(C,1),ceil(size(C,2)/8));
for row = 1:size(D,1)
    col = 0;
    for byteNum = 1:size(D,2)
        for bit = 8:-1:1
            col = col + 1;
            D(row,byteNum) = bitset(D(row,byteNum),bit,C(row,col));
        end
    end
end




logoRows = 64;
logoCols = 256;
numLogoCharacters = 1;

[filepath,name,ext] = fileparts(fileName);
saveFileName = strcat(filepath,'\IR_Black.c')
fileID = fopen(saveFileName,'w');
if fileID < 0 
    f = msgbox('Could not open file.');
else
    fprintf(fileID, 'const uint8_t IR_Logo[%d][%d] =\n', logoRows, logoCols/8);
    fprintf(fileID, '{\n');
    fprintf(fileID,'    /***  Logo 0x00  ***/\n');
    for row = 1:logoRows
        fprintf(fileID, '    {' );
        for byte = 1:size(D,2)
             fprintf(fileID, ' 0x%02X', D(row, byte)); 
             if byte ~= size(D,2)
                fprintf(fileID, ',', D(row, byte)); 
             end
        end
        fprintf(fileID, '}');
        if row ~= logoRows
           fprintf(fileID, ',', D(row, byte));
        else
           fprintf(fileID, ' ', D(row, byte));
        end
        %print logo picture
        fprintf(fileID, '    /*  '); 
        for byte = 1:size(D,2)
            for bit = 8:-1:1
                if bitget(D(row,byte),bit) == 1
                    fprintf(fileID, '#'); 
                else
                    fprintf(fileID, '.'); 
                end
            end
        end
        fprintf(fileID, '*/\n'); 
    end

    fprintf(fileID, '};\n' );
    fclose(fileID);
end



