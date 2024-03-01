clear

logoRows = 64;
logoCols = 256;
numLogoCharacters = 1;
maxRGB = 255;

%%
%fileName = 'C:\Users\jwaite\Downloads\IR BLack.bmp';
fileName = 'C:\Users\jwaite\Wavetronix LLC\Rail Division - Documents\VDR\Engineering Docs\IR Images and Logos for the Display\Logo 237X65.BMP';
A = double(imread(fileName));

%%
%adjust size of A
if size(A,1) > logoRows
    A = A((end-logoRows+1):end,:,:); %limit size to the last logoRows rows
end
if size(A,1) < logoRows             %add rows below and above to center image
    rowsToAdd = logoRows - size(A,1);
    rowsBelow = ceil(rowsToAdd/2);
    rowsAbove = rowsToAdd - rowsBelow;
    A = [maxRGB.*ones(rowsAbove,size(A,2),size(A,3)); A; maxRGB.*ones(rowsBelow,size(A,2), size(A,3))];
end
if size(A,2) > logoCols
    A = A(:,1:logoCols,:); %limit size to the first logoCols rows
end

if size(A,2) < logoCols             %add cols left and right to center image
    colsToAdd = logoCols - size(A,2);
    colsLeft = floor(colsToAdd/2);
    colsRight = colsToAdd - colsLeft;
    A = [maxRGB.*ones(size(A,1), colsLeft, size(A,3)), A, maxRGB.*ones(size(A,1), colsRight, size(A,3))];
end

%%

image(A)

B = squeeze(A(:,:,1));
C = (B<=35); 

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


%% create bit map image
[filepath,name,ext] = fileparts(fileName);
saveFileName = strcat(filepath, '\',name,'.c')
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

%% create grayscale image - these bytes get written directly to the display
[filepath,name,ext] = fileparts(fileName);
saveFileNameGray = strcat(filepath, '\',name,'_grayscale.c');
fileIDgs = fopen(saveFileNameGray,'w');
if fileIDgs < 0 
    f = msgbox('Could not open file.');
else
    fprintf(fileIDgs, 'const uint8_t IR_Logo_Grayscale[%d][%d] =\n', logoRows, logoCols/8*4);
    fprintf(fileIDgs, '{\n');
    fprintf(fileIDgs,'    /***  Logo 0x00  ***/\n');
    E = (zeros(logoRows,logoCols/8*4));
    minA = min(A,[],'all');
    maxA = max(A,[],'all');
    max_gs = 0;
    for row = 1:logoRows
        fprintf(fileIDgs, '    {' );
        nibble = 0;
        byte = 1;
        for col = 1:size(A,2)
            gs = 15 - floor(((sum([0.3 0.59 .11]' .* squeeze(A(row,col,:)))-minA)/(maxA-minA))*15);
            if gs > max_gs
                max_gs = gs;
            end
            if (gs>=0) && (gs<16)
                if nibble ==0
                    E(row,byte) =  gs*(2^4);
                    nibble = 1;
                else
                    E(row,byte) =  E(row,byte) + gs;
                    fprintf(fileIDgs, ' 0x%02X', E(row,byte)); 
                    if byte ~= size(E,2)
                        fprintf(fileIDgs, ','); 
                    end
                    nibble = 0;
                    byte = byte + 1;
                end                
            else
                %error
                breakhere = 1;
            end
        end
        fprintf(fileIDgs, '}');
        if row ~= logoRows
           fprintf(fileIDgs, ',');
        else
           fprintf(fileIDgs, ' ');
        end
        %print logo picture
        fprintf(fileIDgs, '    /*  '); 
        for byte = 1:size(E,2)
            for nibble = 1:2
                if nibble == 1
                    v = E(row,byte)/(2^4);
                else
                    b = bitget(E(row,byte),4:-1:1);
                    v = sum(b .* [8 4 2 1]);
                end
                if v > 8
                    fprintf(fileIDgs, '#'); 
                else
                    fprintf(fileIDgs, '.'); 
                end
                
            end
        end
        fprintf(fileIDgs, '*/\n'); 
    end

    fprintf(fileIDgs, '};\n' );
    fclose(fileIDgs);
end


