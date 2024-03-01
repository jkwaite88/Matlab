%mx_message_format

classdef mx_message_format < handle
    properties (Constant)
        %constants 
        SUCCESS             = 0;
        FAIL                = 1;
        CRC_HDR_FAILURE     = 4;
        CRC_BDY_FAILURE     = 5;

        MX_MIN_MESSAGE_SIZE = 25;
        MX_MAX_MESSAGE_SIZE = 65559;
        MX_MIN_BODY_SIZE    = 9;
        MX_MAX_BODY_SIZE    = 65534;
        MX_MIN_DATA_SIZE    = 0;
        MX_MAX_DATA_SIZE    = 65525;

        MX_MSG_VER_M      = 0;
        MX_MSG_VER_X      = 1;
        MX_INTERFACE_TYPE = 2;
        MX_SECTOR_ID      = 3;
        MX_SEQ_NUM        = 4;
        MX_STATUS         = 5;
        MX_BDY_SIZE       = 6;
        MX_HDR_CRC        = 7;
        MX_MSG_ID         = 8;
        MX_DATA           = 9;
        MX_BDY_CRC        = 10;
        MX_COMPLETE       = 11;
    end
    properties
        error
        state
        cnt
        bdyDataSize
        crc
        msgVer = {'0' '0'};%This should be in the hdr structure but I cannot figure out how to do it because it is and array.
        hdr = struct('interfaceType', 0, 'sectorId', 0, 'seqNum', 0, 'status', 0, 'bdySize', 0, 'hdrCrc', 0);
        bdy = struct('msgId', 0, 'data', zeros(65525,1), 'bdyCrc', 0);
        crc1 = crc();
    end
    methods (Access = private)
        function RxMsgVerM(obj, c)
            if(c == 'M')
                obj.msgVer{1} = c;
                obj.state = obj.MX_MSG_VER_X;
            else
                obj.msgVer{1} = 0;
            end
        
        end

        function RxMsgVerX(obj, c)
            if(c == 'M')
                obj.msgVer{1} = c;
                obj.msgVer{2} = '0';
                obj.state = obj.MX_MSG_VER_X;
            elseif(c == 'X')
                obj.msgVer{2} = c;
                obj.state = obj.MX_INTERFACE_TYPE;
                obj.cnt = 0;
                temp = [obj.msgVer{1} obj.msgVer{2}];
                obj.crc = obj.crc1.Crc64(0, temp, 2);
            else
                obj.state = obj.MX_MSG_VER_M;
                obj.msgVer{1} = '0';
                obj.msgVer{2} = '0';
            end
        end

        function RxInterfaceType(obj, c)
            obj.hdr.interfaceType = c;
            obj.crc = obj.crc1.Crc64(obj.crc, uint8(obj.hdr.interfaceType), 1);
            obj.state = obj.MX_SECTOR_ID;
            obj.cnt = 0;
        end
        
        function RxSectorId(obj, c)
            obj.hdr.sectorId = uint8(c);
            obj.crc = obj.crc1.Crc64(obj.crc, c, 1);
            obj.state = obj.MX_SEQ_NUM;
        end
        
        function RxSeqNum(obj, c)
            obj.hdr.seqNum = uint8(c);
            obj.crc = obj.crc1.Crc64(obj.crc, obj.hdr.seqNum, 1);
            obj.state = obj.MX_STATUS;
        end

        function RxStatus(obj, c)
            obj.hdr.status = uint8(c);
        
            obj.crc = obj.crc1.Crc64(obj.crc, obj.hdr.status, 1);
            obj.state = obj.MX_BDY_SIZE;
            obj.cnt = 0;
        end
        
        function RxBdySize(obj, c)
            obj.hdr.bdySize = bitshift(bitand(obj.hdr.bdySize, 0x00FF), 8);
            obj.hdr.bdySize = bitor(obj.hdr.bdySize, uint16(c));
        
            obj.crc = obj.crc1.Crc64(obj.crc, c, 1);
            obj.cnt = obj.cnt + 1;
        
            if(obj.cnt == 2)
                if((obj.hdr.bdySize >= obj.MX_MIN_BODY_SIZE)&& (obj.hdr.bdySize <= obj.MX_MAX_BODY_SIZE))
                    obj.state = obj.MX_HDR_CRC;
                    obj.bdyDataSize = (obj.hdr.bdySize - obj.MX_MIN_BODY_SIZE);
                    obj.hdr.crc = 0;
                else
                    obj.state = obj.MX_MSG_VER_M;
                    obj.bdyDataSize = 0;
                end
                obj.cnt = 0;
            end
        end

        function RxHdrCrc(obj, c)
            obj.hdr.crc = bitshift(bitand(obj.hdr.crc, 0x00FFFFFFFFFFFFFF), 8);
            obj.hdr.crc = bitor(obj.hdr.crc, c);
        
            obj.cnt = obj.cnt + 1;
        
            if(obj.cnt == 8)
                if(obj.hdr.crc == obj.crc)
                    obj.crc = 0;
                    obj.bdy.crc = 0;
                    obj.state = obj.MX_MSG_ID;
                else
                    obj.error = obj.CRC_HDR_FAILURE;
                    obj.state = obj.MX_MSG_VER_M;
                end    
            end
        end

        function RxMsgId(obj, c)
            obj.bdy.msgId = uint8(c);
        
            obj.crc = obj.crc1.Crc64(obj.crc, c, 1);
        
            if(obj.hdr.bdySize > obj.MX_MIN_BODY_SIZE)
                obj.state = obj.MX_DATA;
            else
                obj.state = obj.MX_BDY_CRC;
            end
            obj.cnt = 0;
        end

        function RxData(obj, c)
            obj.cnt = obj.cnt + 1;
            obj.bdy.data(obj.cnt) = c;
        
            if(((obj.cnt + obj.MX_MIN_BODY_SIZE) >= obj.hdr.bdySize) || (obj.cnt >= obj.MX_MAX_DATA_SIZE))
                obj.crc = obj.crc1.Crc64(obj.crc, obj.bdy.data, obj.cnt);
                obj.state = obj.MX_BDY_CRC;
                obj.bdy.crc = 0;
                obj.cnt = 0;
            end
        end

        function RxBdyCrc(obj, c)
            obj.bdy.crc = bitshift(bitand(obj.bdy.crc, 0x00FFFFFFFFFFFFFF), 8);
            obj.bdy.crc = bitor(obj.bdy.crc, uint64(c));
        
            obj.cnt = obj.cnt + 1;
        
            if(obj.cnt == 8)
                if(obj.bdy.crc == obj.crc)
                    obj.state = obj.MX_COMPLETE;
                else
                    obj.error = obj.CRC_BDY_FAILURE;
                    obj.state = obj.MX_MSG_VER_M;
                end
                obj.cnt = 0;
                obj.crc = 0;
            end
        end
        
        %tansmit message not implemented at this time
        %STATIC void TxMsgVerR(MXMsg_t* msg, uint8_t* c)

    end %methods
    methods (Access = public)
        function RstMsg(obj)
            obj.state = obj.MX_MSG_VER_M;
            obj.error = obj.SUCCESS;
            obj.crc = uint64(0);
            obj.hdr.msgVer(1) = 0;
            obj.hdr.msgVer(2) = 0;
            obj.cnt = 0;
            obj.hdr.crc = uint64(0);
            obj.bdy.crc = uint64(0);
        end

        function obj = r1_message_format()
            obj.error = obj.SUCCESS;
            %message structure    
            obj.state = uint8(obj.MX_MSG_VER_M);
            obj.cnt = uint16(0);
            obj.bdyDataSize = uint16(0);
            obj.crc = uint64(0);
            obj.msgVer = {'0' '0'};
            obj.hdr.dstDevType = uint8(0);
            obj.hdr.dstId = uint32(0);
            obj.hdr.srcDevType = uint8(0);
            obj.hdr.srcId = uint32(0);
            obj.hdr.seqNum = uint8(0);
            obj.hdr.status = uint8(0);
            obj.hdr.bdySize = uint16(0);
            obj.hdr.crc = uint64(0);
            obj.bdy.msgId = uint16(0);
            obj.bdy.data = uint8(zeros(480,1));
            obj.bdy.crc = uint64(0);

            if  nargin > 0
            else
            end
        end
        function obj = RxMsg(obj, c)
            
            if(obj.error == obj.SUCCESS)
                switch(obj.state)
                    
                    case obj.MX_MSG_VER_M
                        RxMsgVerM(obj, c);
                        
            
                    case obj.MX_MSG_VER_X
                        RxMsgVerX(obj, c);
                        
            
                    case obj.MX_INTERFACE_TYPE
                        RxInterfaceType(obj, c);
                        
            
                    case obj.MX_SECTOR_ID
                        RxSectorId(obj, c);
                        
            
                    case obj.MX_SEQ_NUM
                        RxSeqNum(obj, c);
                        
            
                    case obj.MX_STATUS
                        RxStatus(obj, c);
                        
            
                    case obj.MX_BDY_SIZE
                        RxBdySize(obj, c);
                        
            
                    case obj.MX_HDR_CRC
                        RxHdrCrc(obj, c);
                        
            
                    case obj.MX_MSG_ID
                        RxMsgId(obj, c);
                        
            
                    case obj.MX_DATA
                        RxData(obj, c);
                        
            
                    case obj.MX_BDY_CRC
                        RxBdyCrc(obj, c);
                        
            
                    case obj.MX_COMPLETE
                        %Wait until processed
            
                    otherwise
                        obj.state = obj.MX_MSG_VER_M;
                end
            else
                    RstMsg(obj);
            end

        end
        
    end %methods

end