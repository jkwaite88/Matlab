clear all;
DB.DIR_EIRP = '\\napster\data\AntChamber\data\2018-07-21 Matrix RF EIRP\';
DB.DB = {
    %'C:\Data\20180723 Matrix DSP Prod\20180723 Matrix RF 451 09721 & DSP 438 01843 EngDelayLine.daq', 'DSP 438 01834 Run1 No Mods';
    %'C:\Data\20180723 Matrix DSP Prod\20180723 Matrix RF 451 09721 & DSP 438 01843 EngDelayLine Run2.daq', 'DSP 438 01834 Run2 No Mods';
    %'C:\Data\20180723 Matrix DSP Prod\20180723 Matrix RF 451 09721 & DSP 438 01843 EngDelayLine DSP BBGainEqaulToOldDSP Run1.daq', 'DSP 438 01834 GainToOldDSP';
    %'C:\Data\20180723 Matrix DSP Prod\20180724 Matrix RF 451 09721 & DSP 438 01843 EngDelayLine DSP BBGainEqaulToOldDSP Run2.daq', 'DSP 438 01834 GainToOldDSP Run2';
%     '20180725 Matrix 451 09721 & 050 0A5594 ChamberDelayLine.daq', 'Matrix 451 09721 & 050 0A5594';
%     '20180725 Matrix 451 09721 & 438 01843 BBGto050PCBA ChamberDelayLine.daq', 'Matrix 451 09721 & 438 001843 BBG=050PCA';
%     %'20180725 Matrix 451 09721 & 438 01843 BBGto050PCBA WallAdapter ChamberDelayLine.daq', 'Matrix 451 09721 & 438 001843 WallAdapter';
%     %'20180725 Matrix 451 09721 & 438 01843 BBGto050PCBA LapSupply ChamberDelayLine.daq', 'Matrix 451 09721 & 438 001843 LabSupply';
%     '20180725 Matrix 451 09721 & 050 02796 ChamberDelayLine.daq', 'Matrix 451 09721 & 050 02796';
%     '20180725 Matrix 451 09721 & 050 02796 PGA0.11 ChamberDelayLine.daq', 'Matrix 451 09721 & 050 02796 PGA=0.11';
%     '20180725 Matrix 451 09721 & 050 02796 PGA5.0 ChamberDelayLine.daq', 'Matrix 451 09721 & 050 02796 PGA=5.0';

%     '20180725 Matrix 451 09721 & 438 01843 PGA-20dB ChamberDelayLine.daq','PGA -20dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA-18dB ChamberDelayLine.daq', 'PGA -18dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA-16dB ChamberDelayLine.daq', 'PGA - 16dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA-14dB ChamberDelayLine.daq', 'PGA -14dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA-12dB ChamberDelayLine.daq', 'PGA -12dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA-10dB ChamberDelayLine.daq', 'PGA -10dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA-8dB ChamberDelayLine.daq', 'PGA -8dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA-6dB ChamberDelayLine.daq', 'PGA -6dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA-4dB ChamberDelayLine.daq', 'PGA -4dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA-2dB ChamberDelayLine.daq', 'PGA -2dB';
%    '20180725 Matrix 451 09721 & 438 01843 PGA 0dB ChamberDelayLine.daq', 'PGA  0dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA +2dB ChamberDelayLine.daq', 'PGA +2dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA +4dB ChamberDelayLine.daq', 'PGA +4dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA +6dB ChamberDelayLine.daq', 'PGA +6dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA +8dB ChamberDelayLine.daq', 'PGA +8dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA +10dB ChamberDelayLine.daq', 'PGA +10dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA +12dB ChamberDelayLine.daq', 'PGA +12dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA +14dB ChamberDelayLine.daq', 'PGA +14dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA +16dB ChamberDelayLine.daq', 'PGA +16dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA +18dB ChamberDelayLine.daq', 'PGA +18dB';
%     '20180725 Matrix 451 09721 & 438 01843 PGA +20dB ChamberDelayLine.daq', 'PGA +20dB';
    
%     '20180727 Matrix 451 09721 & 050 A5594 PGA-20dB ChamberDelayLine.daq', 'PGA -20dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA-18dB ChamberDelayLine.daq', 'PGA -18dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA-16dB ChamberDelayLine.daq', 'PGA -16dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA-14dB ChamberDelayLine.daq', 'PGA -14dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA-12dB ChamberDelayLine.daq', 'PGA -12dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA-10dB ChamberDelayLine.daq', 'PGA -10dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA-8dB ChamberDelayLine.daq', 'PGA -8dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA-6dB ChamberDelayLine.daq', 'PGA -6dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA-4dB ChamberDelayLine.daq', 'PGA -4dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA-2dB ChamberDelayLine.daq', 'PGA -2dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA 0dB ChamberDelayLine.daq', 'PGA  0dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA+2dB ChamberDelayLine.daq', 'PGA +2dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA+4dB ChamberDelayLine.daq', 'PGA +4dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA+6dB ChamberDelayLine.daq', 'PGA +6dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA+8dB ChamberDelayLine.daq', 'PGA +8dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA+10dB ChamberDelayLine.daq', 'PGA +10dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA+12dB ChamberDelayLine.daq', 'PGA +12dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA+14dB ChamberDelayLine.daq', 'PGA +14dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA+16dB ChamberDelayLine.daq', 'PGA +16dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA+18dB ChamberDelayLine.daq', 'PGA +18dB';
%     '20180727 Matrix 451 09721 & 050 A5594 PGA+20dB ChamberDelayLine.daq', 'PGA +20dB';
%     
%     "C:\Data\20180721 Matrix RF Prod Cham\20180721 Matrix RF 175-0451 R6.0 SN 05834 w175-0410dsp Prod Cham5011.daq",
%     "C:\Data\20180721 Matrix RF Prod Cham\20180721 Matrix RF 175-0451 R6.0 SN 06018 w175-0410dsp Prod Cham5011.daq",
%     "C:\Data\20180721 Matrix RF Prod Cham\20180721 Matrix RF 175-0451 R6.0 SN 09411 w175-0410dsp Prod Cham5011.daq",
%     "C:\Data\20180721 Matrix RF Prod Cham\20180721 Matrix RF 175-0451 R6.0 SN 09416 w175-0410dsp Prod Cham5011.daq",
%     "C:\Data\20180721 Matrix RF Prod Cham\20180721 Matrix RF 175-0451 R6.0 SN 09700 w175-0410dsp Prod Cham5011.daq",
%     "C:\Data\20180721 Matrix RF Prod Cham\20180721 Matrix RF 175-0451 R6.0 SN 09716 w175-0410dsp Prod Cham5011.daq",
    
% %     '20180723 Matrix DSP Prod\20180727 Matrix 451 09721 & 438 01843 FPAABypassed ChamberDelayLine.daq', 'Newer DSP FPAA Bypassed';
% %     '20180727 Matrix 451 09721 & 438 01843 FPAABypassed & FPAAPreAmpVgain4 ChamberDelayLine.daq', 'Newer DSP FPAA Bypassed & FPAA PreAmpVGain=4';
% %     '20180727 Matrix 451 09721 & 438 01843 FPAABypassed & FPAAPreAmpVgain1over8 ChamberDelayLineOff.daq', 'Newer DSP FPAA Bypassed & FPAA PreAmpVGain=^{1}/_{8}';
% %     '20180728 Matrix 451 09721 & 438 01843 FPAABypassed & FPAAPreAmpVgain2 ChamberDelayLineOff.daq', 'Newer DSP FPAA Bypassed & PFAA PreAmpVGain=2'
    
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine Run01.daq', '438 01843 FPAA Bypassed Run  1';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine Run02.daq', '438 01843 FPAA Bypassed Run  2';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine Run03.daq', '438 01843 FPAA Bypassed Run  3';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine Run04.daq', '438 01843 FPAA Bypassed Run  4';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine Run05.daq', '438 01843 FPAA Bypassed Run  5';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine Run06.daq', '438 01843 FPAA Bypassed Run  6';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine Run07.daq', '438 01843 FPAA Bypassed Run  7';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine Run08.daq', '438 01843 FPAA Bypassed Run  8';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine Run09.daq', '438 01843 FPAA Bypassed Run  9';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine Run10.daq', '438 01843 FPAA Bypassed Run 10';
    
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine 50sec Run01.daq', '438 01843 FPAA Bypassed 50Sec Spin Run  1';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine 50sec Run02.daq', '438 01843 FPAA Bypassed 50Sec Spin Run  2';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine 50sec Run03.daq', '438 01843 FPAA Bypassed 50Sec Spin Run  3';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine 50sec Run04.daq', '438 01843 FPAA Bypassed 50Sec Spin Run  4';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine 50sec Run05.daq', '438 01843 FPAA Bypassed 50Sec Spin Run  5';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine 50sec Run06.daq', '438 01843 FPAA Bypassed 50Sec Spin Run  6';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine 50sec Run07.daq', '438 01843 FPAA Bypassed 50Sec Spin Run  7';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine 50sec Run08.daq', '438 01843 FPAA Bypassed 50Sec Spin Run  8';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine 50sec Run09.daq', '438 01843 FPAA Bypassed 50Sec Spin Run  9';
%     'C:\Data\20180730 Matrix DSP Prod\20180730 Matrix 451 09721 & 438 01843 FPAA ByPassed PreAmpVGain2 EngChamber DelayLine 50sec Run10.daq', '438 01843 FPAA Bypassed 50Sec Spin Run 10';
% 
%     'C:\Data\20180731 Matrix Noise\20170731 Matrix 451 09721 Prod Chamber Run 1.daq', 'Prod Cham. 451 09721 Run 1';
%     'C:\Data\20180731 Matrix Noise\20170731 Matrix 451 09721 Prod Chamber Run 2.daq', 'Prod Cham. 451 09721 Run 2';
%     'C:\Data\20180731 Matrix Noise\20170731 Matrix 451 09721 Prod Chamber Run 3.daq', 'Prod Cham. 451 09721 Run 3';
%     'C:\Data\20180731 Matrix Noise\20170731 Matrix 451 09721 Prod Chamber Run 4.daq', 'Prod Cham. 451 09721 Run 4';
%     'C:\Data\20180731 Matrix Noise\20170731 Matrix 451 09721 Prod Chamber Run 5.daq', 'Prod Cham. 451 09721 Run 5';
%     'C:\Data\20180731 Matrix Noise\20170731 Matrix 451 09721 Prod Chamber Run 6.daq', 'Prod Cham. 451 09721 Run 6';
%     'C:\Data\20180731 Matrix Noise\20170731 Matrix 451 09721 Prod Chamber Run 7.daq', 'Prod Cham. 451 09721 Run 7';
%     'C:\Data\20180731 Matrix Noise\20170731 Matrix 451 09721 Prod Chamber Run 8.daq', 'Prod Cham. 451 09721 Run 8';
%     'C:\Data\20180731 Matrix Noise\20170731 Matrix 451 09721 Prod Chamber Run 9.daq', 'Prod Cham. 451 09721 Run 9';
%     'C:\Data\20180731 Matrix Noise\20170731 Matrix 451 09721 Prod Chamber Run 10.daq', 'Prod Cham. 451 09721 Run 10';
%     
%    'C:\Data\20180809 Matrix Noise\20180809 Matrix RF 451 08959.daq', '451 08959';
%    'C:\Data\20180809 Matrix Noise\20180809 Matrix RF 451 09195.daq', '451 09195';
%    'C:\Data\20180809 Matrix Noise\20180809 Matrix RF 451 08959 fbRes2.94k.daq', '451 08959 fb=2.94kOhm';
    
    'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R6 451-08504 Chamber DelayLine Spin.daq', 'Matrix RF R6.0 451 08504';
    'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R6 451-08505 Chamber DelayLine Spin.daq', 'Matrix RF R6.0 451 08505';
    'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R6 451-08506 Chamber DelayLine Spin.daq', 'Matrix RF R6.0 451 08506';
    'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R7 451-BRD3 Chamber DelayLine Spin.daq', 'Matrix RF R7.0 451  BRD3';
    'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R7 451-BRD5 Chamber DelayLine Spin.daq', 'Matrix RF R7.0 451  BRD5';
    'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R7 451-BRD6 Chamber DelayLine Spin.daq', 'Matrix RF R7.0 451  BRD6';
    'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R7b 451-BRD1 Chamber DelayLine Spin.daq', 'Matrix RF R7.b 451  BRD1';
    'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R7b 451-BRD2 Chamber DelayLine Spin.daq', 'Matrix RF R7.b 451  BRD2';
    'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R7b 451-BRD4 Chamber DelayLine Spin.daq','Matrix RF R7.b 451  BRD4';
    'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF Arlon FCC Unit Chamber DelayLine Spin.daq', 'Matrix RF R1.1 410   FCC';

%     'C:\Data\20180809 Matrix Noise\20180816 Matix RF 451 09405 Eng DelayLine.daq', '451 09405 Matrix RF';
%     'C:\Data\20180809 Matrix Noise\20180817 Matix RF 451 09405 Reflow CeterRFSwitch Eng DelayLine.daq', '451 09405 Matrix RF Reflow Center RF Switch';
%     'C:\Data\20180809 Matrix Noise\20180816 Matix RF 451 09405 RTV Ch8 Eng DelayLine.daq', '451 09405 Matrix RF RTV Ch8';
%     'C:\Data\20180809 Matrix Noise\20180816 Matix RF 451 09405 RTV Ch8 mod1 Eng DelayLine.daq', '451 09405 Matrix RF RTV Ch8 mod1';
%     'C:\Data\20180809 Matrix Noise\20180816 Matix RF 451 09405 RTV Ch8 mod2 Eng DelayLine.daq', '451 09405 Matrix RF RTV Ch8 mod2';
%     'C:\Data\20180809 Matrix Noise\20180817 Matix RF 451 09405 DryRTV Ch8 Eng DelayLine.daq', '451 09405 Matrix RF DryRTV Ch8';
%     'C:\Data\20180809 Matrix Noise\20180814 Matix RF 451 09405 Eng DelayLine_orig.daq', '2018_08_14 Matrix RF pre rtv';
    
   % Good Production Units
% 'C:\Data\20180809 Matrix Noise\20180814 Matix RF 451 09595 Eng DelayLine.daq', '451 09595 Good';
% 'C:\Data\20180809 Matrix Noise\20180814 Matix RF 451 09453 Eng DelayLine.daq', '451 09453 Good';
% 'C:\Data\20180809 Matrix Noise\20180814 Matix RF 451 09378 Eng DelayLine.daq', '451 09378 Good';
% 
% 
% % Bad Production Units
% 'C:\Data\20180809 Matrix Noise\20180814 Matix RF 451 09860 Eng DelayLine.daq', '451 09860 Bad';
% 'C:\Data\20180809 Matrix Noise\20180814 Matix RF 451 09405 Eng DelayLine.daq', '451 09405 Bad';
% 'C:\Data\20180809 Matrix Noise\20180814 Matix RF 451 09238 Eng DelayLine.daq', '451 09238 Bad';
% 'C:\Data\20180809 Matrix Noise\20180814 Matix RF 451 09689 Eng DelayLine.daq', '451 09689 Bad';
%'C:\Data\20180712 Matrix RF Prod Eval\20180712 Matrix RF 175-0451 R3 451-06018 GeorgaUnit Chamber DelayLine.daq', '451 06018 Georgia Unit';
%'C:\Data\20180809 Matrix Noise\20180820 Matrix RF 451 06018 GeorgiaUnit Eng DelayLine.daq','08-20 451 06018 Georgia Unit';
%'C:\Data\20180809 Matrix Noise\20180820 Matrix RF 451 06018 GeorgiaUnit CuPatchR1 Eng DelayLine.daq','08-20 451 06018 Georgia Unit CuR1';
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit CuPatchR2 Eng DelayLine.daq','08-21 451 06018 Georgia Unit CuR2';
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit RemovedCu Eng DelayLine.daq','08-21 451 06018 Georgia Unit CuRemoved';
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit CuReAdded R1 Eng DelayLine.daq','08-21 451 06018 Georgia Unit CuReAdded r1';
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit CuReAdded R2 Eng DelayLine.daq','08-21 451 06018 Georgia Unit CuReAdded r2';
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit CuCentered R3 Eng DelayLine.daq','08-21 451 06018 Georgia Unit CuCentered r3';
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit CuCentered R4 Eng DelayLine.daq','08-21 451 06018 Georgia Unit CuCentered Reflowed Diodes r4'; % Reflowed Diodes
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit CuCentered SwappedDiodes R5 Eng DelayLine.daq','08-21 451 06018 Georgia Unit CuCentered Swapped Diodes r5'; 
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit CuCentered RotatedDiodes R6 Eng DelayLine.daq','08-21 451 06018 Georgia Unit CuCentered Rotated Diodes r6'; 
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit CuToFeedVia R7 Eng DelayLine.daq','08-21 451 06018 Georgia Unit CuToFeedVia r7'; 
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit Replaced CenterRFSwitch R8 Eng DelayLine.daq','08-21 451 06018 Georgia Unit Replaced RF Switches U20 & U27 r8';
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit Replaced CenterRFSwitch FBResTo2.5k R9 Eng DelayLine.daq','08-21 451 06018 Georgia Unit Replaced RF Switches U20 & U27 FBResTo2.5kOhm r9';
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit Replaced CenterRFSwitch FBResTo4.02k R10 Eng DelayLine.daq','08-21 451 06018 Georgia Unit Replaced RF Switches U20 & U27 FBResTo4.02kOhm r10';
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit BypassedAnalogSwitch DelayLine.daq','08-21 451 06018 Georgia Unit Bypassed Analog Switch';
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit C149To5ohm.daq','08-21 451 06018 Georgia Unit C149 to 5 Ohm Switch';
%'C:\Data\20180809 Matrix Noise\20180821 Matrix RF 451 06018 GeorgiaUnit C65&C164 to 1 Ohm.daq','08-21 451 06018 Georgia Unit C65 & C164 to 1 Ohm Switch';


% Use these for Base-Band Improvment plots.
% 'C:\Data\20180809 Matrix Noise\20180822 Matrix RF 451 06018 GeorgiaUnit NoMods Eng DelayLine.daq','08-22 451 06018 NoMods';
% 'C:\Data\20180809 Matrix Noise\20180822 Matrix RF 451 06018 GeorgiaUnit BaseBand IproveV1 Eng DelayLine.daq','08-22 451 06018 BaseBand Improve V1';
% 'C:\Data\20180809 Matrix Noise\20180822 Matrix RF 451 06018 GeorgiaUnit BaseBand IproveV1 w68.1OhmRes Eng DelayLine.daq','08-22 451 06018 BaseBand Improve V1 w68.1 Ohm Res';
% 'C:\Data\20180809 Matrix Noise\20180822 Matrix RF 451 06018 GeorgiaUnit BaseBand IproveV2 Eng DelayLine.daq','08-22 451 06018 BaseBand Improve V2';
% 'C:\Data\20180809 Matrix Noise\20180823 Matrix RF 451 06018 GeorgiaUnit BaseBand IproveV2 8CH Eng DelayLine.daq','08-23 451 06018 BaseBand Improve V2 8Chanls.';
% 'C:\Data\20180809 Matrix Noise\20180823 Matrix RF 451 06018 GeorgiaUnit BaseBand IproveV2 AllCHs Eng DelayLine.daq','08-23 451 06018 BaseBand Improve V2 All-Chanls.';
};

DB.Index.File = 1;
DB.Index.EIRP = 2;
DB.Index.Legend = 2;
numFiles = size(DB.DB,1);

colors = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 0.5 0.5 0.5;...
            0.5 0 0; 0 0.5 0; 0 0 0.5; 1 0.62 0.4; 0.49 1 0.83;...
            0.4 1 0.62; 0.62 0.4 1; 1 0.83 0.49;    0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0;];

FIG_NUM = 16;
FIG_PK = 1;
FIG_NO = 2;
FIG_MEAN = 3;
FIG_SNR = 4;

FIG_ROWS = 2;
FIG_COLS = 2;

LineWidth = 2.0;

figure(FIG_NUM);clf;
subplot(FIG_ROWS,FIG_COLS,FIG_PK);hold on;box on;grid on;ylabel('dB');xlabel('Antenna # & Mean'); title('PEAK');
subplot(FIG_ROWS,FIG_COLS,FIG_NO);hold on;box on;grid on;ylabel('dB');xlabel('Antenna # & Mean');title('MODE');
subplot(FIG_ROWS,FIG_COLS,FIG_MEAN);hold on;box on;grid on;ylabel('dB');xlabel('Antenna # & Mean');title('MEAN');
subplot(FIG_ROWS,FIG_COLS,FIG_SNR);hold on;box on;grid on;ylabel('dB');xlabel('Antenna # & Mean');title('MAX2MEAN');
ChannelLegend = cell(numFiles,1);
set(gcf,'DefaultAxesColorOrder',colors);


figure(29);clf;hold on;box on;grid on;ylabel('dB');xlabel('Bin (1 Based)');
for i = 1:numFiles
    figure(FIG_NUM);
    fprintf('Processing: %s\n',DB.DB{i,DB.Index.File});
    Daq = load_daq_data( DB.DB{i,DB.Index.File}, 'KeepDownChirp', true);
    Daq = process_daq_data(Daq,'DelayLineProdCham');
    
    subplot(FIG_ROWS,FIG_COLS,FIG_PK);
    plot( [Daq.pks_dB mean(Daq.pks_dB)], 'LineWidth', LineWidth,'color', colors(i,:));
    
    subplot(FIG_ROWS,FIG_COLS,FIG_NO);
    plot( [Daq.mode mean(Daq.mode)], 'LineWidth', LineWidth ,'color', colors(i,:));
    
    subplot(FIG_ROWS,FIG_COLS,FIG_MEAN);
    plot([Daq.meanAcrossTime_dB(Daq.targetResponseBin,:) mean(Daq.meanAcrossTime_dB(Daq.targetResponseBin,:))],'LineWidth',LineWidth, 'color',colors(i,:));
    
    subplot(FIG_ROWS,FIG_COLS,FIG_SNR);
    plot([Daq.mx2mn mean(Daq.mx2mn)],'LineWidth',LineWidth ,'color',colors(i,:));
    
    
    figure(29);
    plot(Daq.meanAcrossTime_dB -mean(Daq.meanAcrossTime_dB(80:100,:)),'color',colors(i,:));
    
    %     figure(20+i);clf;hold on;box on;grid on;axis([1 289 -2^15 2^15]);
    %     title(DB.DB{i,DB.Index.Legend});
    %     for j = 1:Daq.num_channels
    %         plot(squeeze(Daq.data(:,j,(Daq.channels_peak_indices(j)))),'LineWidth',LineWidth ,'color',colors(j,:));
    %     end
    
    % Plot Peaks
%     figure(30);
%     for k = 1:16
%         fprintf('Ant %i\t',k);
%         for j = -7:0
%             pk0 = 10*log10(mean(abs(Daq.DATA(Daq.targetResponseBin,k,-16+(0:7)+Daq.channels_peak_indices(k)+j)).^2));
%             pk1 = 10*log10(mean(abs(Daq.DATA(Daq.targetResponseBin,k,-8+(0:7)+Daq.channels_peak_indices(k)+j)).^2));
%             pk2 = 10*log10(mean(abs(Daq.DATA(Daq.targetResponseBin,k,(0:7)+Daq.channels_peak_indices(k)+j)).^2));
%             pk3 = 10*log10(mean(abs(Daq.DATA(Daq.targetResponseBin,k,+8+(0:7)+Daq.channels_peak_indices(k)+j)).^2));
%             pk4 = 10*log10(mean(abs(Daq.DATA(Daq.targetResponseBin,k,+16+(0:7)+Daq.channels_peak_indices(k)+j)).^2));
%             pk = max([pk0 pk1 pk2 pk3 pk4]);
%             fprintf('%0.2f\t',pk);
%             plot(k,pk,'og');
%         end
%         plot(k,Daq.DATA_dB(Daq.targetResponseBin,k,Daq.channels_peak_indices(k)),'or');
%         fprintf('\n');
%     end
    %%
    %Plot Noise
%     ed = (20:1.5:150)';
%     cen_dB = ed + 1.5/2;
%     cen = 10.^(cen_dB./10);
%     figure(32);
%     %for k = 1:16
%         indx0 = Daq.MeanAcrossTimeIndx0;
%         indx1 = Daq.MeanAcrossTimeIndx1;
%         pts = indx1-indx0 + 1;
%         pts = floor(pts/8) * 8;
%         noi_data_dB = abs(Daq.DATA(Daq.targetResponseBin,:,(0:(pts-1)) + indx0)).^2;
%         noi_data_dB = reshape(noi_data_dB,[1 16 pts/8 8]);
%         noi_data_dB = 10*log10(sum(noi_data_dB,4)./8);
%         n = histc(noi_data_dB,ed,3);
%         noi_pwr = bsxfun(@times,n,reshape(cen,[1 1 numel(cen)]));
%         noi_pwr = sum(sum(noi_pwr,3),1);
%         noi_pwr = noi_pwr./sum(sum(n,3),1);
%         noi_dB = 10*log10(noi_pwr);
%         plot(noi_dB,'-or','color',colors(i,:));
%     %end
    

end

% Add a Ledgend
figure(FIG_NUM);
subplot(FIG_ROWS,FIG_COLS,FIG_SNR);
l = legend(DB.DB{:,DB.Index.Legend});
%annotation('textbox','String','175-0050 Matrix DSP\nSNR vs PGA Gain','Interpreter','none');



