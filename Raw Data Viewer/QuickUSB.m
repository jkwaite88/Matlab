classdef QuickUSB < handle
    %QuickUSB Module Class
    %   This class is the the Matlab translation of the QuickUSB module
    properties
        hDevice = NaN;
        isOpened = false;
        isOpenedPolitely = false;
        openCount = 0;
        ModuleName = '';
    end
    
    
    methods (Static = true) 
        function LoadLib()
            if not(libisloaded('quickusb'))
               [~, ~] = loadlibrary('quickusb', 'QuickUSB.h');
            end
        end
        
        function UnloadLib()
            if libisloaded('quickusb')
               unloadlibrary('quickusb');
            end
        end
        
        function delete()
            QuickUSB.UnloadLib();
        end
 
        function obj = FindModules()
            QuickUSB.LoadLib();

            % Allocate a buffer for the module names
            buffer = blanks(1024);
            len = length(buffer);
            
            [result, namelist] = calllib('quickusb', 'QuickUsbFindModules', buffer, len);
            if result == 1
                obj = textscan(namelist, '%s', 'delimiter', char(0));
            end
        end
    end
    
    
    methods (Access = private)
        function Open(obj, name)
            % If the user supplies a name, use that name instead
            if (nargin == 2)
                obj.ModuleName = name;
            end
            
            % Load the library if it hasn't been already loaded
            QuickUSB.LoadLib();
            
            % Call the library function
            qhnd = -1;
            [r, obj.hDevice] = calllib('quickusb', 'QuickUsbOpen', qhnd, obj.ModuleName);
            obj.isOpened = true;
            obj.openCount = obj.openCount + 1;
        end
        
        function Close(obj)
            calllib('quickusb', 'QuickUsbClose', obj.hDevice);
            if obj.isOpenedPolitely
                obj.isOpenedPolitely = false;
            else                
                obj.openCount = obj.openCount - 1;
            end
            obj.hDevice = NaN;
            obj.isOpened = false;
        end
                
        function OpenPolitely(obj)
            if obj.isOpened 
                return;
            end            
            obj.isOpenedPolitely = true;
            obj.Open(obj);
        end
        
        function ClosePolitely(obj)
            if obj.isOpened
                obj.Close();
            end
        end
    end
    
    
    methods
        function set.ModuleName(obj, name)
            % Handle different name classes
            switch class(name)
                case 'char'
                    obj.ModuleName = name;
                case 'cell'
                    obj.ModuleName = name{1,1};
            end
        end
        
        function obj = QuickUSB(name)
            if (nargin == 1)
                obj.ModuleName = name;
            end
        end
        
        function WriteSpiBytes(obj, portnum, data)
            obj.OpenPolitely();
            len = min(length(data), 64);
            calllib('quickusb', 'QuickUsbWriteSpi', obj.hDevice, portnum, data, len);
            obj.ClosePolitely();
        end
        
        function obj = ReadSpiBytes(obj, portnum, length)
            obj.OpenPolitely();
            data = ones(1, min(length, 64), 'uint8');
            len = length(data);
            [~, ~, values] = calllib('quickusb', 'QuickUsbReadSpi', obj.hDevice, portnum, data, len);     
            obj.ClosePolitely();
            obj = values;
        end
        
        function obj = WriteReadSpiBytes(obj, portnum, data)
            obj.OpenPolitely();
            len = min(length(data), 64);
            [~, ~, values] = calllib('quickusb', 'QuickUsbWriteReadSpi', obj.hDevice, portnum, data, len);     
            obj.ClosePolitely();
            obj = values;
        end
        
        function values = ReadPort(obj, addr, length)
            obj.OpenPolitely();
            data = ones(1, min(length, 64), 'uint8');
            len = length(data);
            [~, ~, values] = calllib('quickusb', 'QuickUsbReadPort', obj.hDevice, addr, data, len);     
            obj.ClosePolitely();
            
        end
        function obj = WritePort(obj, addr, data)
            obj.OpenPolitely();
            len = min(length(data), 64);,l
            calllib('quickusb', 'QuickUSBWritePort',...
                obj.hDevice, addr, data, len);     
            obj.ClosePolitely();
        end
        function values = ReadUsbData(obj, len)
            obj.OpenPolitely();
            % try to capture one scan
            data = zeros(1, len);
            [~, ~, values] = calllib('quickusb', 'QuickUsbReadData', obj.hDevice, data, len);
            obj.ClosePolitely();
        end
        
        function WriteSettings(obj)
            obj.OpenPolitely();
            
            settings(1) = uint16(hex2dec('1'));
            settings(2) = uint16(hex2dec('c000'));
            settings(3) = uint16(hex2dec('00fa'));
            settings(4) = uint16(hex2dec('0001'));
            settings(5) = uint16(hex2dec('8016'));
                        
            for ind = 1:length(settings)
                calllib('quickusb','QuickUsbWriteSetting',obj.hDevice,ind,settings(ind));
            end
            
            portVal = uint8(3);
            addr = 0;
            calllib('quickusb','QuickUsbWritePortDir',obj.hDevice,addr,portVal);
            
            data = uint8(2*ones(1,1));
            calllib('quickusb','QuickUsbWritePort',obj.hDevice, addr, data, length(data));
            
            % toggle reset line
            data = uint8(zeros(1,1));
            [~, ~, values] = calllib('quickusb', 'QuickUsbReadPort',...
                obj.hDevice, addr, data, length(data));
            values = bitor(values,uint8(1));
            calllib('quickusb', 'QuickUsbWritePort',...
                obj.hDevice, addr, values, length(values));
            
            [~, ~, values] = calllib('quickusb', 'QuickUsbReadPort',...
                obj.hDevice, addr, data, length(data));
            values = bitand(values,bitcmp(uint8(1)));
            calllib('quickusb', 'QuickUsbWritePort',...
                obj.hDevice, addr, values, length(values));  
            
            obj.ClosePolitely();
        end
    end
    
end

