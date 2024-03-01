%r1_message_format

classdef r1_message_format < handle
    properties (Constant)
        %constants 
        SUCCESS         = 0;
        FAIL            = 1;

        R1_MIN_MESSAGE_SIZE = 28;
        R1_MAX_MESSAGE_SIZE = 512;
        R1_MIN_BODY_SIZE    = 10;
        R1_MAX_BODY_SIZE    = 490;
        R1_MIN_DATA_SIZE    = 0;
        R1_MAX_DATA_SIZE    = 480;

        R1_MSG_VER_R    = 0;
        R1_MSG_VER_1    = 1;
        R1_DST_DEV_TYPE = 2;
        R1_DST_ID       = 3;
        R1_SRC_DEV_TYPE = 4;
        R1_SRC_ID       = 5;
        R1_SEQ_NUM      = 6;
        R1_STATUS       = 7;
        R1_BDY_SIZE     = 8;
        R1_HDR_CRC      = 9;
        R1_MSG_ID       = 10;
        R1_DATA         = 11;
        R1_BDY_CRC      = 12;
        R1_COMPLETE     = 13;
    end
    properties
        error
        state
        cnt
        bdyDataSize
        crc
        msgVer = {'0' '0'};%This should be in the hdr structure but I cannot figure out how to do it because it is and array.
        hdr = struct('dstDevType', 0, 'dstId', 0, 'srcDevTyp', 0, 'srcId', 0, 'seqNum', 0, 'status', 0, 'bdySize', 0, 'crc', 0);
        bdy = struct('msgId', 0, 'data', zeros(480,1), 'crc', 0);
        crc1 = crc();
    end
    methods (Access = private)
        function RxMsgVerR(obj, c)
            if(c == 'R')
                obj.msgVer{1} = c;
                obj.state = obj.R1_MSG_VER_1;
            else
                obj.msgVer{1} = 0;
            end
        
        end

        function RxMsgVer1(obj, c)
            if(c == 'R')
                obj.msgVer{1} = c;
                obj.msgVer{2} = '0';
                obj.state = obj.R1_MSG_VER_1;
            elseif(c == '1')
                obj.msgVer{2} = c;
                obj.state = obj.R1_DST_DEV_TYPE;
                obj.hdr.dstId = '0';
                obj.cnt = 0;
                %obj.crc = Crc64(0UL, obj.hdr.msgVer, 2);
            else
                obj.state = obj.R1_MSG_VER_R;
                obj.msgVer{1} = '0';
                obj.msgVer{2} = '0';
            end
        end

        function RxDstDevType(obj, c)
            obj.hdr.dstDevType = c;
            obj.crc = obj.crc1.Crc64(obj.crc, uint8(obj.hdr.dstDevType), 1);
            obj.state = obj.R1_DST_ID;
            obj.cnt = 0;
        end
        
        function RxDstId(obj, c)
            obj.hdr.dstId = bitshift(bitand(obj.hdr.dstId, 0x0000FFFF), 8);
            obj.hdr.dstId = bitor(obj.hdr.dstId, uint32_t(c));
        
            obj.crc = obj.crc1.Crc64(obj.crc, c, 1);
            obj.cnt = obj.cnt + 1;
        
            if(obj.cnt == 3)
                obj.state = obj.R1_SRC_DEV_TYPE;
                obj.hdr.srcId = 0;
                obj.cnt = 0;
            end
        end
        
        function RxSrcDevType(obj, c)
            obj.hdr.srcDevType = c;
            obj.crc = obj.crc1.Crc64(obj.crc, obj.hdr.srcDevType, 1);
            obj.state = obj.R1_SRC_ID;
            obj.cnt = 0;
        end

        function RxSrcId(obj, c)
            obj.hdr.srcId = bitshift(bitand(obj.hdr.srcId, 0x0000FFFF), 8);
            obj.hdr.srcId = bitor(obj.hdr.srcId, uint32(c));
        
            obj.crc = obj.crc1.Crc64(obj.crc, c, 1);
            obj.cnt = obj.cnt + 1;
        
            if(obj.cnt == 3)
                obj.state = obj.R1_SEQ_NUM;
                obj.cnt = 0;
            end
        end
        
        function RxSeqNum(obj, c)
            obj.hdr.seqNum = c;
            obj.crc = obj.crc1.Crc64(obj.crc, obj.hdr.seqNum, 1);
            obj.state = obj.R1_STATUS;
        end

        function RxStatus(obj, c)
            obj.hdr.status = c;
            obj.crc = Crc64(obj.crc,obj.hdr.status, 1);
            obj.hdr.bdySize = 0;
            obj.state = obj.R1_BDY_SIZE;
            obj.cnt = 0;
        end

        function RxBdySize(obj, c)
            obj.hdr.bdySize = bitshift(bitand(obj.hdr.bdySize, 0x00FF), 8);
            obj.hdr.bdySize = bitor(obj.hdr.bdySize, uint16_t(c));
        
            obj.crc = obj.crc1.Crc64(obj.crc, c, 1);
            obj.cnt = obj.cnt + 1;
        
            if(obj.cnt == 2)
                if((obj.hdr.bdySize >= obj.R1_MIN_BODY_SIZE)&& (obj.hdr.bdySize <= obj.R1_MAX_BODY_SIZE))
                    obj.state = obj.R1_HDR_CRC;
                    obj.bdyDataSize = (obj.hdr.bdySize - obj.R1_MIN_BODY_SIZE);
                else
                    obj.state = obj.R1_MSG_VER_R;
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
                    obj.state = obj.R1_MSG_ID;
                    obj.cnt = 0;
                else
                    obj.state = obj.R1_MSG_VER_R;
                end    
            end
        end

        function RxMsgId(obj, c)
            obj.bdy.msgId = bitshift(bitand(obj.bdy.msgId, 0x00FF), 8);
            obj.bdy.msgId = bitor(obj.bdy.msgId, uint16(c));
        
            obj.crc = Crc64(obj.crc, c, 1);
            obj.cnt = obj.cnt+ 1;
        
            if(obj.cnt == 2)
                if(obj.hdr.bdySize > obj.R1_MIN_BODY_SIZE)
                    obj.state = obj.R1_DATA;
                else
                    obj.state = obj.R1_BDY_CRC;
                end
                obj.cnt = 0;
            end
        end

        function RxData(obj, c)
            obj.cnt = obj.cnt + 1;
            obj.bdy.data(obj.cnt) = c;
        
            if(((obj.cnt + obj.R1_MIN_BODY_SIZE) >= obj.hdr.bdySize) || (obj.cnt >= obj.R1_MAX_DATA_SIZE))
                obj.crc = Crc64(obj.crc, obj.bdy.data, obj.cnt);
                obj.state = obj.R1_BDY_CRC;
                obj.cnt = 0;
            end
        end

        function RxBdyCrc(obj, c)
            obj.bdy.crc = bitshift(bitand(obj.bdy.crc, 0x00FFFFFFFFFFFFFF), 8);
            obj.bdy.crc = bitor(obj.bdy.crc, uint32(c));
        
            obj.cnt =obj.cnt + 1;
        
            if(obj.cnt == 8)
                if(obj.bdy.crc == obj.crc)
                    obj.state = obj.R1_COMPLETE;
                else
                    obj.state = obj.R1_MSG_VER_R;
                end
                obj.cnt = 0;
                obj.crc = 0;
            end
        end
        
        %tansmit message not implemented at this time
        %STATIC void TxMsgVerR(R1Msg_t* msg, uint8_t* c)

    end %methods
    methods (Access = public)
        function RstMsg(obj)
            obj.state = obj.R1_MSG_VER_R;
            obj.hdr.msgVer(1) = 0;
            obj.hdr.msgVer(2) = 0;
            obj.cnt = 0;
        end

        function obj = r1_message_format()
            obj.error = obj.SUCCESS;
            %message structure    
            obj.state = uint8(obj.R1_MSG_VER_R);
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
                    
                    case obj.R1_MSG_VER_R
                        %obj = RxMsgVerR(obj, c);
                        RxMsgVerR(obj, c);
                        
            
                    case obj.R1_MSG_VER_1
                        RxMsgVer1(obj, c);
                        
            
                    case obj.R1_DST_DEV_TYPE
                        RxDstDevType(obj, c);
                        
            
                    case obj.R1_DST_ID
                        RxDstId(msg, c);
                        
            
                    case obj.R1_SRC_DEV_TYPE
                        RxSrcDevType(obj, c);
                        
            
                    case obj.R1_SRC_ID
                        RxSrcId(obj, c);
                        
            
                    case obj.R1_SEQ_NUM
                        RxSeqNum(obj, c);
                        
            
                    case obj.R1_STATUS
                        RxStatus(obj, c);
                        
            
                    case obj.R1_BDY_SIZE
                        RxBdySize(obj, c);
                        
            
                    case obj.R1_HDR_CRC
                        RxHdrCrc(obj, c);
                        
            
                    case obj.R1_MSG_ID
                        RxMsgId(msg, c);
                        
            
                    case obj.R1_DATA
                        RxData(msg, c);
                        
            
                    case obj.R1_BDY_CRC
                        RxBdyCrc(msg, c);
                        
            
                    case obj.R1_COMPLETE
                        %Wait until processed
            
                    otherwise
                        obj.state = obj.R1_MSG_VER_R;
                end
            else
                    RstMsg(msg);
            end

        end
        
    end %methods

end