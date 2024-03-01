%Mx Message
close all
F = findall(0,'type','figure','tag','TMWWaitbar');
delete(F);

%fileName = "C:\Users\jwaite\Downloads\East Bay Angled MX Msg 1.txt";
fileName = "C:\Users\jwaite\Downloads\East Bay Perpendicular MX Msg 1.txt";
%fileName = "\\napster\Temp\Jonathan\SPI Capture_mosi.txt";
%fileName = "\\napster\Temp\Jonathan\SPI Capture 2_mosi.txt";
%fileName = "\\napster\Temp\Jonathan\SPI Capture_mosi_altered.txt";
%fileName = "\\napster\Temp\Scott\CDAnalyserFromRandy\RDQdata0.bin";

fid = fopen(fileName);
bytesToRead = inf;
data = fread(fid, bytesToRead, 'uint8');
fclose(fid);
dataLength = length(data);

msg = mx_message_format();
msg.RstMsg();
heatmapData = [];
frameNumber = [];
pointCloud = [];
NumDetections = [];
incrementingData = [];

incrementingDataCfg = 0;

i = 0;
frame = 0;
w = waitbar(i/dataLength, 'Percent Done');
while (i+1) < dataLength
    i = i + 1;
    if char(data(i)) == 'M'    
        breakhere = 1;
    end
    msg.RxMsg(data(i));
    if msg.error == msg.SUCCESS
        if msg.state == msg.MX_COMPLETE
            frame = frame + 1;
            if incrementingDataCfg
                m = mx_message_parser_incrementing_data(msg);
                incrementingData(1:length(m.msgParsed.bdy.data),frame) = m.msgParsed.bdy.data';
              
            else
                m = mx_message_parser(msg);
                heatmapData(:,:,frame) = m.msgParsed.heatmap;
                frameNumber(frame) = m.msgParsed.hdr2.frameNumber;
                NumDetections(frame) = m.msgParsed.hdr2.numDetectedObjects;
                pointCloud(frame).data = m.msgParsed.pointCloudSpherical;
            end
            if mod(frame,10) == 0
                waitbar(i/dataLength, w, sprintf('Percent Done: %3.1f %%', (i/dataLength)*100));
            end
            msg.RstMsg();
        end
    else
        switch msg.error
            case msg.FAIL
            
            case msg.CRC_HDR_FAILURE
                disp('CRC Error in message header')
                %break;
            case msg.CRC_BDY_FAILURE
                disp('CRC Error in message body')
                %break;
            otherwise
        
        end
    end
end
waitbar(1, w, sprintf('Percent Done: %3.1f %%', 100));
close(w)

%%  plot heatmap
fig1 = figure(1)
clf;
ax = axes;


if incrementingDataCfg == 1
    numFrames = size(incrementingData,2);
    plot(incrementingData)
  %   hold on
%   for i = 1:numFrames
%     plot(incrementingData(:,i))
%     drawnow;
%   end
else
    
    numFrames = size(heatmapData,3);
    for i = 1:numFrames
        image(ax, squeeze(heatmapData(:,:,i)));
        colorbar
        view(0,-90)  
        title(sprintf('FrameNumber: %d; NumDetection: %d',frameNumber(i), NumDetections(i)))
        drawnow;
        pause(0.001)  
    end
end