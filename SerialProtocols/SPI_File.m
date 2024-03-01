%T = readtable("\\napster\Temp\Jonathan\SPI Capture.txt",'NumHeaderLines',3);  % skips the first three rows of data
fileName = "\\napster\Temp\Jonathan\SPI Capture 2.txt";

[filepath,name,ext] = fileparts(fileName);

T = readtable(fileName);
exportFileName = strcat(filepath,'\',name,'_mosi',ext);
fid = fopen(exportFileName, 'w');
fwrite(fid, T.MOSI, 'uint8');
fclose(fid);

