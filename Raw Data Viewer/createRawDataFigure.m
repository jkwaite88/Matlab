function [] = createRawDataFigure(sensorInfo)
% createRawDataFigure(sensorInfo)
%
% This matlab function creates the gui figure that allows the user to
% visualize the raw data.
%
% Written by Steven Reeves
% March 24, 2015

delay = 0.2;
% framesPerSec = 3.5;
c = 3e8;
m_to_ft = 3.28084;
NUM_UP_SAMPLES = 256;
NUM_SWEEPS = 8;
NUM_ANTENNAS = 16;
FFT_SIZE       = 256;
BW             = 250e6;
FT_PER_BIN     = c*NUM_UP_SAMPLES/(2*BW*FFT_SIZE)*m_to_ft;
max_range       = 140;
stop_range_bin  = floor(max_range/FT_PER_BIN);
maxRangeBin     = 80;
if stop_range_bin > maxRangeBin
    stop_range_bin = maxRangeBin;
end
fig = figure('Position',[20, 178, 550, 550],'CloseRequestFcn',{@closeGui},...
    'MenuBar','none');

haxis_image = axes('Parent',fig,'NextPlot','add',...
                            'XLim',[0 max_range],'YLim',...
                            [0 max_range],'Units','Normalized',...
                            'Visible','on',...
                            'DataAspectRatio',[1 1 1],'Color','none',...
                            'DrawMode','fast','Position',[0.05 0.08 0.91 0.91],...
                            'XTick',[],'YTick',[]);
% Draw the Matrix beams on the image axis
[himage, AnglesLeftToRight, ~, ~] = createMatrixBeams(FT_PER_BIN,stop_range_bin,...
          sensorInfo.sensorHeight,haxis_image, true);
delete(himage);
% Draw the Matrix beams on the image axis
[himage, ~, ~, ~] = createMatrixBeams(FT_PER_BIN,stop_range_bin,...
          sensorInfo.sensorHeight,haxis_image, false);
            
% Edit dB panel (used to set min/max dB to plot on image axis)
min_db = 40;
max_db = 75;
edit_dB = uipanel('Title','Set min/max dB to plot','Parent',...
    fig,'Units','Normalized','Position',...
    [0.01 0.3 0.15 0.1],'Visible','off');
hedit_mindB = uicontrol('Parent',edit_dB,'Style','edit',...
    'String',num2str(min_db),'Units',...
    'Normalized','Position',[0.5 0.0 0.5 0.5],...
    'Callback',{@editdB_Callback});
hedit_maxdB = uicontrol('Parent',edit_dB,'Style','edit',...
    'String',num2str(max_db),'Units',...
    'Normalized','Position',[0.5 0.5 0.5 0.5],...
    'Callback',{@editdB_Callback});
uicontrol('Parent',edit_dB,'Style','text',...
    'String','min dB','Units','Normalized',...
    'Position',[0.0 0.0 0.5 0.5]);
uicontrol('Parent',edit_dB,'Style','text',...
    'String','max dB','Units','Normalized',...
    'Position',[0.0 0.5 0.5 0.5]);
                   


uicontrol('Parent',fig,'Units','Normalized','Position',...
    [6/16 0.005 1/8 1/16],'Style','pushbutton','String','Play','Callback',...
    {@playbutton_Callback});


htime = uicontrol(fig,'Units','Normalized','Style','text','String',...
    ['Time: ' datestr(0,'HH:MM:SS.FFF') ', PulseCount: 0'],'Position',...
    [0.0 0.97 0.25 0.02], 'Visible','off');

% create a matrix of blackman windows to quickly process all of the sweeps
% at once
window = repmat(blackman(NUM_UP_SAMPLES),[1, NUM_ANTENNAS NUM_SWEEPS]);

lane_handles = cell(1,length(sensorInfo.lanes));
for ind = 1:length(sensorInfo.lanes)
    lane_handles{ind} = sensorInfo.lanes(ind).plotLanes(haxis_image);
end

zone_handles = cell(1,length(sensorInfo.zones));
for ind = 1:length(sensorInfo.zones)
    zone_handles{ind} = sensorInfo.zones(ind).plotZones(haxis_image,true);
end


hbar = [];




quickUsb = QuickUSB('QUSB-0');
set(haxis_image,'CLimMode','manual','CLim',...
    [min_db max_db]);

axis off


% Set the data cursor update function
dcm_obj = datacursormode(fig);
set(dcm_obj,'UpdateFcn',@DataCursorUpdate,...
    'SnapToDataVertex','off');
camroll(haxis_image,90*sensorInfo.orientation);
    

    function playbutton_Callback(hObject, eventdata)
        str = get(hObject,'String');
        Strings = {'Play','Pause'};
        state = find(strcmp(str,Strings));
        
        set(hObject,'String',Strings{3-state});
        
        if state == 1
            InitDaq();
%             ResetUsb();
            numBytes = 8*16*(279*2+6) + 279*2+6;
            numConsecutiveErrors = 0;
            while ishandle(haxis_image)
                % if button label changed since last iteration, stop now
                if find(strcmp(get(hObject,'String'),Strings)) == 1
                    break
                end
                
                % collect raw data as long as the we are playing
                
                
                raw_data = quickUsb.ReadUsbData(numBytes);
%                 if result ~= 0

                    numConsecutiveErrors = 0;
                    % convert to 16 bit signed integers
                    raw_data = typecast(raw_data,'int16');

                    fft_mag = parseRawAdcData(raw_data);

                    % set the image to the latest raw data
                    updatePlot(10*log10(fft_mag'));

                    drawnow;
%                 else
%                     disp('USB error');
%                     numConsecutiveErrors = numConsecutiveErrors + 1;
%                     if numConsecutiveErrors > 10
%                         disp('Pausing gui');
%                         set(hObject,'String',Strings{1});
%                     end
%                 end                
            end
        end
    end

    function InitDaq()
        quickUsb.WriteSettings();
    end
    function ResetUsb()
        data = quickUsb.ReadPort(0,1);
        data = bitor(data,uint8(1));
        quickUsb.WritePort(0,data);
        data = quickUsb.ReadPort(0,1);
        data = bitand(data,bitcmp(uint8(1)));
        quickUsb.WritePort(0,data);
    end

    function fft_mag = CalcMagSqd(chirp)
        fftData = fft(chirp.*window,[],1);
        
        % only need the top half of the fft
        fftData = fftData(1:size(chirp,1)/2,:,:);
        fft_mag = abs(fftData).^2;
        fft_mag = squeeze(mean(fft_mag,3));
    end
    
    function fft_mag = parseRawAdcData(data)
        maxVal = 32767;
        minVal = -32768;
        indices = strfind(data,[maxVal, minVal]);
        
        upChirpData = zeros(NUM_UP_SAMPLES,NUM_ANTENNAS,NUM_SWEEPS);
        
        % discard the last chirp, since in general it will not be a full
        % one
        sweepNum = 1;
        for index = 1:length(indices)-1
            antNum = data(indices(index)+2) + 1;
            
                upChirpData(:,antNum,sweepNum) = double(data(indices(index)+3:indices(index)+3+NUM_UP_SAMPLES-1));
            
            
            if mod(index,NUM_ANTENNAS) == 0
                sweepNum = sweepNum + 1;
            end
            if sweepNum > NUM_SWEEPS
                break;
            end
        end
        
        fft_mag = CalcMagSqd(upChirpData);
        
    end

    function editdB_Callback(hObject, event)
        
        temp_min = str2double(get(hedit_mindB,'String'));
        temp_max = str2double(get(hedit_maxdB,'String'));
        
        if isnumeric(temp_min) && isnumeric(temp_max) && temp_min<temp_max
            min_db = temp_min;
            max_db = temp_max;
                        
            set(haxis_image,'CLimMode','manual','CLim',[min_db max_db]);

            if ishandle(hbar)
                delete(hbar);
                temp_pos = get(haxis_image,'Position');
                hbar = colorbar('peer',haxis_image,'location','EastOutSide');
                xlabel(hbar,'dB')
                set(haxis_image,'Position',temp_pos);
            end
           
        else % reset to what it was before
            set(hedit_mindB,'String',num2str(min_db));
            set(hedit_maxdB,'String',num2str(max_db));
        end
            
    end

    
    function output_text = DataCursorUpdate(~,event_obj)
        info_struct = getCursorInfo(dcm_obj);
        x = info_struct.Position(1);
        y = info_struct.Position(2);
        
       [range, beam] = CartesianToBeamAndRange(x,y,...
           sensorInfo.sensorHeight,...
           AnglesLeftToRight,FT_PER_BIN);
        value = get(himage,'CData');
        value = value(sub2ind([stop_range_bin,16],range,beam));
        output_text = {['X: ' num2str(x,'%0.1f')],...
                       ['Y: ' num2str(y,'%0.1f')],...
                       ['Range: ' num2str(range)],...
                       ['Beam: ' num2str(beam)],...
                       ['Val: ' num2str(value)]};
        
    end

    function updatePlot(img)
        assignin('base','img',img);
        if ~isempty(img)
            set(himage,'CData',img(:,1:stop_range_bin)');
        end
    end

    function closeGui(src, event)
       clear('sensorInfo');
       clear('MatrixSensor');
       if ishandle(fig)
           delete(fig);
       end
    end

    
end
