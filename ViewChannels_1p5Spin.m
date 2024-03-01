% This script assumes there is no curruptions in the data file.
% This script expects the spin of the sensor to be 1.5 turns.
%% Set some constants and the file to be processed.
% Start a timer.
tic;

% Set some constants.
SAMPLES_PER_SEC = 1e6;
POSITIVE_FULL_SCALE = 32767;
NEGATIVE_FULL_SCALE = -32768;
NUM_SAMPS_IN_HEADER = 3;
FFT_SIZE = 256;
NUM_DATA_RECORDS = 1000000;

% Auto increment the figure number
% if exist('FIG_NUM','var')
%    FIG_NUM = FIG_NUM + 10;
% else
%     FIG_NUM = 10;
% end

%FILE_NAME = 'C:\Data\20160427_RogersVsArlon_Chamber\20160504_MatrixRF_175-0451_BRD#6_SpinF1.5_Ro4450F_CH0Shorted&Covered.daq';FIG_NUM = 50;
%FILE_NAME = 'C:\Data\20160427_RogersVsArlon_Chamber\20160504_MatrixRF_175-0451_BRD#6_SpinF1.5_Ro4450F_CH0Shorted.daq';FIG_NUM = 60;
%FILE_NAME = 'C:\Data\20160427_RogersVsArlon_Chamber\20160504_MatrixRF_175-0451_BRD#6_SpinF1.5_Ro4450F.daq';FIG_NUM = 70;
%FILE_NAME = 'C:\Data\20160427_RogersVsArlon_Chamber\20160504_MatrixRF_175-0410_SN41012873_SpinF1p5_Arlon.daq';FIG_NUM = 80;
%FILE_NAME = 'C:\Data\20160427_RogersVsArlon_Chamber\20160506_MatrixRF_175-0451_BRD#6_SpinF1.5_Ro4450F_CH0Shorted&Covered.daq';FIG_NUM=90;
%FILE_NAME = 'C:\Data\20160427_RogersVsArlon_Chamber\20160506_MatrixRF_175-0451_BRD#6_SpinF1.5_Ro4450F_CH0,4,5Covered.daq';FIG_NUM = 100;
%FILE_NAME = 'C:\Data\20160427_RogersVsArlon_Chamber\20160506_MatrixRF_175-0451_BRD#6_SpinF1.5_Ro4450F_CH14NotCovered.daq';FIG_NUM=110;
%FILE_NAME = 'C:\Data\2016_04_12_Chamber_OriginalHD.daq';FIG_NUM = 120;
%FILE_NAME = 'C:\Data\20160524_Matrix_Rogers\20160524_Matrix_Spin1p5_OddChsCoverd.daq';FIG_NUM = 130;
%FILE_NAME = 'C:\Data\20160427_RogersVsArlon_Chamber\20160710_MatrixRF_175-0410Rev2_Arlon_SpinF1.5.daq';FIG_NUM = 200;
%FILE_NAME = 'C:\Data\20160427_RogersVsArlon_Chamber\20160710_MatrixRF_175-0451Rev2_Ro4003C_BRD1_SpinF1.5.daq';FIG_NUM = 210;
%FILE_NAME = 'C:\Data\20160427_RogersVsArlon_Chamber\20160710_MatrixRF_175-0451Rev2_Ro4003C_BRD2_SpinF1.5.daq';FIG_NUM = 220;
%FILE_NAME = 'C:\Data\20160427_RogersVsArlon_Chamber\20160710_MatrixRF_175-0451Rev2_Ro4003C_BRD3_SpinF1.5.daq';FIG_NUM = 230;
%FILE_NAME = 'C:\Data\20160427_RogersVsArlon_Chamber\20160710_MatrixRF_175-0451Rev2_Ro4003C_BRD4_SpinF1.5.daq';FIG_NUM = 240;
%FILE_NAME = 'C:\Data\20161102_MatrixRo4003Rev3_CE_Compliance\20161102_MatrixRo4003Rev3_BRDNum2_AGC_0.5_Spin1.0_NoMods.daq';FIG_NUM = 100;
%FILE_NAME = 'C:\Data\20161102_MatrixRo4003Rev3_CE_Compliance\20161102_MatrixRo4003Rev3_BRDNum2_AGC_0.5_Spin1.0_HMC498Bias250mA.daq';FIG_NUM = 110;
%FILE_NAME = 'C:\Data\20161102_MatrixRo4003Rev3_CE_Compliance\20161102_MatrixRo4003Rev3_BRDNum2_AGC_0.5_Spin1.0_HMC498Bias200mA.daq';FIG_NUM = 120;
%FILE_NAME = 'C:\Data\20161102_MatrixRo4003Rev3_CE_Compliance\20161102_MatrixRo4003Rev3_BRDNum2_AGC_0.5_Spin1.0_wAbsorber_2.38dBTxReduction.daq';FIG_NUM = 130;
%FILE_NAME = 'C:\Data\20161102_MatrixRo4003Rev3_CE_Compliance\20161102_MatrixRo4003Rev3_BRDNum2_AGC_0.5_Spin1.0_wAbsorberOn12GHzTXLine.daq';FIG_NUM = 140;
%FILE_NAME = 'C:\Data\20161102_MatrixRo4003Rev3_CE_Compliance\20161103_MatrixRo4003Rev3_BRDNum2_AGC_0.5_Spin1.0_NoMods.daq';FIG_NUM = 150;
%FILE_NAME = 'C:\Data\20161102_MatrixRo4003Rev3_CE_Compliance\20161103_MatrixRo4003Rev3_BRDNum1_AGC_0.5_Spin1.0_NoMods.daq';FIG_NUM = 160;
%FILE_NAME = 'C:\Data\20161102_MatrixRo4003Rev3_CE_Compliance\20161114_MatrixRF_175-0451Rev3_Ro4003C_BRD1daq'; FIG_NUM = 170;
%FILE_NAME = 'C:\Data\20161102_MatrixRo4003Rev3_CE_Compliance\20161114_MatrixRF_175-0451Rev3_Ro4003C_BRD2.daq'; FIG_NUM = 180;
%FILE_NAME = 'C:\Data\20161102_MatrixRo4003Rev3_CE_Compliance\20161114_MatrixRF_175-0451Rev3_Ro4003C_BRD2_wHMC499LC4_200mA.daq'; FIG_NUM = 190;
%FILE_NAME = 'C:\Data\20161102_MatrixRo4003Rev3_CE_Compliance\20161114_MatrixRF_175-0451Rev3_Ro4003C_BRD1_ControlSweep.daq'; FIG_NUM = 200;
%FILE_NAME = 'C:\Data\20161102_MatrixRo4003Rev3_CE_Compliance\20161114_MatrixRF_175-0451Rev3_Ro4003C_BRD2_wHMC499LC4_253mA.daq'; FIG_NUM = 210;
%FILE_NAME = 'C:\Data\20161102_MatrixRo4003Rev3_CE_Compliance\20161114_MatrixRF_175-0451Rev3_Ro4003C_BRD2_wHMC499LC4_300mA.daq'; FIG_NUM = 220;
%FILE_NAME = 'C:\Data\20160427_RogersVsArlon_Chamber\20161007_Matrix_175-0451_Rev3_BRD1.daq'; FIG_NUM = 250;
%FILE_NAME = 'C:\Data\20161206_175-0451_Rev3\20161206_175-0451_R3.0_Proto_MatrixRF_BRD1_WT_Brd.daq'; FIG_NUM = 290;
%FILE_NAME = 'C:\Data\20161206_175-0451_Rev3\20161206_175-0451_R3.1_MatrixRF_Cirq_Brd.daq'; FIG_NUM = 300;
%FILE_NAME = 'C:\Data\20161206_175-0451_Rev3\20161208_175-0451_R3.0_Proto_BR1_MatrixRF_Westak_Brd.daq'; FIG_NUM = 370;
%FILE_NAME = 'C:\Data\20161206_175-0451_Rev3\20161208_175-0451_R3.1_Beta_MatrixRF_SN431-00009_Westak_Brd.daq'; FIG_NUM = 380;
%FILE_NAME = 'C:\Data\20161206_175-0451_Rev3\20161208_175-0451_R3.1_Beta_MatrixRF_SN431-00023_Circuitronix_Brd.daq'; FIG_NUM = 390;
%FILE_NAME = 'C:\Data\20161206_175-0451_Rev3\20161215_175-0451_R3.0_Proto_MatrixRF_BRD1_Westak_Brd.daq'; FIG_NUM = 400;
FilePathDB = {
    'C:\Data\20161206_175-0451_Rev3\';
    'C:\Data\20170116_MatrixRF_451R4\';
    'C:\Data\20170222_175-0451 Rev. 5.0\';
    };
FileNameDB = {
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00019_Circuitronix_PCB.daq'; %1
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00018_Circuitronix_PCB.daq'; %2
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00020_Circuitronix_PCB.daq'; %3
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00021_Circuitronix_PCB.daq'; %4
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00022_Circuitronix_PCB.daq'; %5
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00023_Circuitronix_PCB.daq'; %6
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.0_Beta_SN410-00008_Westak_PCB.daq';       %7
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.0_Beta_SN410-00006_Westak_PCB.daq';       %8
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00010_Westak_PCB.daq';       %9
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00011_Westak_PCB.daq';       %10
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00017_Westak_PCB.daq';       %11
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00016_Westak_PCB.daq';       %12
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00013_Westak_PCB.daq';       %13
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00012_Westak_PCB.daq';       %14
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00009_Westak_PCB.daq';       %15
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00015_Westak_PCB.daq';       %16
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.1_Beta_SN410-00014_Westak_PCB.daq';       %17
    'C:\Data\20161206_175-0451_Rev3\20161216_MatrixRF_175-0451_R3.0_Beta_SN410-00007_Westak_PCB.daq';       %18
     
    'C:\Data\20170116_MatrixRF_451R4\20170116_MatrixRF_175-0451_R4.0_SN451-00024.daq';                      %19
    'C:\Data\20170116_MatrixRF_451R4\20170116_MatrixRF_175-0451_R4.0_SN451-00025.daq';                      %20
    'C:\Data\20170116_MatrixRF_451R4\20170116_MatrixRF_175-0451_R4.0_SN451-00026.daq';                      %21
    'C:\Data\20170116_MatrixRF_451R4\20170116_MatrixRF_175-0451_R4.0_SN451-00027.daq';                      %22
    'C:\Data\20170116_MatrixRF_451R4\20170116_MatrixRF_175-0451_R4.0_SN451-00028.daq';                      %23
    'C:\Data\20170116_MatrixRF_451R4\20170116_MatrixRF_175-0451_R4.0_SN451-00029.daq';                      %24
    'C:\Data\20170116_MatrixRF_451R4\20170116_MatrixRF_175-0451_R4.0_SN451-00030.daq';                      %25
    'C:\Data\20170116_MatrixRF_451R4\20170116_MatrixRF_175-0451_R4.0B_SN451-00031.daq';                     %26
    'C:\Data\20170116_MatrixRF_451R4\20170116_MatrixRF_175-0451_R4.0B_SN451-00032.daq';                     %27
    'C:\Data\20170116_MatrixRF_451R4\20170116_MatrixRF_175-0451_R4.0B_SN451-00033.daq';                     %28
    
    '20170222_175-0451 Rev 5.0 SN45100034_AGC0.5.daq';      %29
    '20170222_MatrixRF_175-0451_R4.0_SN451-00025_Ref.daq';  %30
    '20170222_175-0451 Rev 5.0 SN45100035_AGC0.5.daq';          
    '20170222_175-0451 Rev 5.0 SN45100036_AGC0.5.daq';
    '20170222_175-0451 Rev 5.0 SN45100037_AGC0.5.daq';
    '20170222_175-0451 Rev 5.0 SN45100038_AGC0.5.daq';
    '20170222_175-0451 Rev 5.0B SN45100039_AGC0.5.daq';
    '20170222_175-0451 Rev 5.0B SN45100040_AGC0.5.daq';
    '20170222_175-0451 Rev 5.0B SN45100041_AGC0.5.daq';
    '20170222_175-0451 Rev 5.0B SN45100042_AGC0.5.daq';
    '20170222_175-0451 Rev 5.0B SN45100043_AGC0.5.daq';
 
'C:\Data\20170222_175-0451 Rev. 5.0\20170222_175-0451 Rev 5.0 SN45100034_AGC0.5.daq';                       %40
'C:\Data\20170222_175-0451 Rev. 5.0\20170222_175-0451 Rev 5.0 SN45100035_AGC0.5.daq';                       %41
'C:\Data\20170222_175-0451 Rev. 5.0\20170222_175-0451 Rev 5.0 SN45100036_AGC0.5.daq';                       %42
'C:\Data\20170222_175-0451 Rev. 5.0\20170222_175-0451 Rev 5.0 SN45100037_AGC0.5.daq';                       %43
'C:\Data\20170222_175-0451 Rev. 5.0\20170222_175-0451 Rev 5.0 SN45100038_AGC0.5.daq';                       %44
'C:\Data\20170222_175-0451 Rev. 5.0\20170222_175-0451 Rev 5.0B SN45100039_AGC0.5.daq';                      %45
'C:\Data\20170222_175-0451 Rev. 5.0\20170222_175-0451 Rev 5.0B SN45100040_AGC0.5.daq';                      %46
'C:\Data\20170222_175-0451 Rev. 5.0\20170222_175-0451 Rev 5.0B SN45100041_AGC0.5.daq';                      %47
'C:\Data\20170222_175-0451 Rev. 5.0\20170222_175-0451 Rev 5.0B SN45100042_AGC0.5.daq';                      %48
'C:\Data\20170222_175-0451 Rev. 5.0\20170222_175-0451 Rev 5.0B SN45100043_AGC0.5.daq';                      %49

'C:\Data\20160427_RogersVsArlon_Chamber\20160504_MatrixRF_175-0410_SN41012873_SpinF1p5_Arlon.daq';          %50
'C:\Data\20160427_RogersVsArlon_Chamber\20160504_MatrixRF_175-0410_SN41012874_SpinF1p5_Arlon.daq';          %51
'C:\Data\20160427_RogersVsArlon_Chamber\20160504_MatrixRF_175-0410_SN41012875_SpinF1p5_Arlon.daq';          %52
'C:\Data\20160427_RogersVsArlon_Chamber\20160504_MatrixRF_175-0410_SN41012876_SpinF1p5_Arlon.daq';          %53
'C:\Data\20160427_RogersVsArlon_Chamber\20160504_MatrixRF_175-0410_SN41012879_SpinF1p5_Arlon.daq';          %54
'C:\Data\20160427_RogersVsArlon_Chamber\20160504_MatrixRF_175-0410_SN41012885_SpinF1p5_Arlon.daq';          %55
'C:\Data\20170302_Matrix_RF_175-0451_Rev3.1_wAbsorber\20170302_Matrix_RF_175-0451_Rev4.0_SN451-00026_ForReferance.daq';
'C:\Data\20170302_Matrix_RF_175-0451_Rev3.1_wAbsorber\20170302_Matrix_RF_175-0451_Rev3.1_SN451-00015_wAbsorber_NoLid.daq';
'C:\Data\20170302_Matrix_RF_175-0451_Rev3.1_wAbsorber\20170302_Matrix_RF_175-0451_Rev4.0_SN451-00009_wAbsorber_NoLid.daq';
'C:\Data\20170302_Matrix_RF_175-0451_Rev3.1_wAbsorber\20170302_Matrix_RF_175-0451_Rev5.0_SN451-00038_NoLid.daq';

'C:\Data\20170322 175-0451 Rev 6.0 Chamber\20170322 FCC Matrix RF for Referance.daq';
'C:\Data\20170322 175-0451 Rev 6.0 Chamber\20170322 175-0451 Rev 5.0 Matrix RF SN451 00035 NoLid.daq';
'C:\Data\20170322 175-0451 Rev 6.0 Chamber\20170322 175-0451 Rev 6.0 Matrix RF SN451 00044 NoLid.daq';
'C:\Data\20170322 175-0451 Rev 6.0 Chamber\20170322 175-0451 Rev 6.0 Matrix RF SN451 00045 NoLid.daq';
'C:\Data\20170322 175-0451 Rev 6.0 Chamber\20170322 175-0451 Rev 6.0 Matrix RF SN451 00046 NoLid.daq';
'C:\Data\20170322 175-0451 Rev 6.0 Chamber\20170322 175-0451 Rev 6.0 Matrix RF SN451 00047 NoLid.daq';
'C:\Data\20170322 175-0451 Rev 6.0 Chamber\20170322 175-0451 Rev 6.0 Matrix RF SN451 00048 NoLid.daq';
'C:\Data\20170322 175-0451 Rev 6.0 Chamber\20170322 175-0451 Rev 6.0 Matrix RF SN451 00049 NoLid.daq';

'C:\Data\20170406 HD Univ Ave\20170407 HD XCVR Rogers Chamber Spin 20MHzSigGen.daq'
'C:\Data\20170406 HD Univ Ave\20170407 HD XCVR Rogers Chamber No Mods.daq'
'C:\Data\20170406 HD Univ Ave\20170407 HD XCVR Arlon Rev12.0 No Mods.daq'

% 175-0451 Rev 6.0 Westak PCB Build
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170410 175-0451 Rev 6.0 Matrix RF SN 451 00046 Circuitronix Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170410 175-0451 Rev 6.0 Matrix RF SN 451 00050 Westak Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170410 175-0451 Rev 6.0 Matrix RF SN 451 00051 Westak Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170410 175-0451 Rev 6.0 Matrix RF SN 451 00052 Westak Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170410 175-0451 Rev 6.0 Matrix RF SN 451 00053 Westak Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170410 175-0451 Rev 6.0 Matrix RF SN 451 00054 Westak Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170410 175-0451 Rev 6.0 Matrix RF SN 451 00055 Westak Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170410 Matrix RF BID200 FCC Unit Chamber.daq'


'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 Matrix RF BID200 FCC Unit Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00050 Westak w4dB Atten Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00051 Westak w4dB Atten Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00052 Westak w4dB Atten Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00053 Westak w4dB Atten Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00054 Westak w4dB Atten Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00055 Westak w4dB Atten Chamber.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00046 Circuitronix Control Chamber.daq'

'C:\Data\20170410 175-0451 Rev 6 Westak Chamber\20170412 175-0410 Rev 2.1 Matrix RF SN 410 18172 Production Unit.daq' % #87
'C:\Data\20170410 175-0451 Rev 6 Westak Chamber\20170412 175-0410 Rev 2.1 Matrix RF SN 410 20215 Production Unit.daq' % #88
'C:\Data\20170410 175-0451 Rev 6 Westak Chamber\20170412 175-0410 Rev 2.1 Matrix RF SN 410 20216 Production Unit.daq' % #89
'C:\Data\20170410 175-0451 Rev 6 Westak Chamber\20170412 175-0410 Rev 2.1 Matrix RF SN 410 20221 Production Unit.daq' % %90
'C:\Data\20170410 175-0451 Rev 6 Westak Chamber\20170412 175-0410 Rev 2.1 Matrix RF SN 410 20226 Production Unit.daq' % #91
'C:\Data\20170410 175-0451 Rev 6 Westak Chamber\20170412 175-0410 Rev 2.1 Matrix RF SN 410 20228 Production Unit.daq' % #92
'C:\Data\20170410 175-0451 Rev 6 Westak Chamber\20170412 175-0410 Rev 2.1 Matrix RF SN 410 20229 Production Unit.daq' % #93
% Back to 3dB attenuators
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00050 Westak backto 3dB Attn.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00051 Westak backto 3dB Attn.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00052 Westak backto 3dB Attn.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00053 Westak backto 3dB Attn.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00054 Westak backto 3dB Attn.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00055 Westak backto 3dB Attn.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 175-0451 Rev 6.0 Matrix RF SN 451 00046 Circuitronix Control for backto 3dB.daq'
'C:\Data\201704010 175-0451 Rev 6 Westak Chamber\20170412 Matrix RF BID200 FCC Unit Chamber Control for backto 3dB.daq'

% 2017 May 19th, Matrix Production CH7 % 8 Issue
'C:\Data\20170519 Matrix Production Chamber\20170519 175-0410 R2.1 SN 410 19091.daq';
'C:\Data\20170519 Matrix Production Chamber\20170519 175-0410 R2.1 SN 410 19555.daq';
'C:\Data\20170519 Matrix Production Chamber\20170519 175-0410 R2.1 SN 410 19113.daq';
'C:\Data\20170519 Matrix Production Chamber\20170519 175-0410 R2.1 SN 410 19538.daq';
'C:\Data\20170519 Matrix Production Chamber\20170519 175-0410 R2.1 SN 410 18810.daq';
'C:\Data\20170519 Matrix Production Chamber\20170519 175-0410 R2.1 SN 410 19074.daq';
'C:\Data\20170519 Matrix Production Chamber\20170519 175-0410 R2.1 SN 410 19198.daq';
'C:\Data\20170519 Matrix Production Chamber\20170519 175-0410 R2.1 SN 410 19159.daq';

%Passing Units
'C:\Data\20170519 Matrix Production Chamber\20170519 175-0410 R2.1 SN 410 19832.daq';
'C:\Data\20170519 Matrix Production Chamber\20170519 175-0410 R2.1 SN 410 19835.daq';
'C:\Data\20170519 Matrix Production Chamber\20170519 175-0410 R2.1 SN 410 19833.daq';
'C:\Data\20170519 Matrix Production Chamber\20170519 175-0410 R2.1 SN 410 19836.daq';

% 2017 June 15, 175-0451 Rev. 6.0 Production Validation, Circuitronix PCBs 
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00056 Circ PCB.daq'; % Num 114
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00057 Circ PCB.daq'; % Num 115
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00058 Circ PCB.daq'; % Num 116
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00059 Circ PCB.daq'; % Num 117
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00060 Circ PCB.daq'; % Num 118
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00061 Circ PCB LowProCu.daq'; % Num 119

% 2017 June 15, 175-0451 Rev. 6.0 Production Validation, Westak PCBs 
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00077 Westak PCB.daq'; % Num 120
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00081 Westak PCB.daq'; % Num 121
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00082 Westak PCB.daq'; % Num 122
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00083 Westak PCB.daq'; % Num 123
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00084 Westak PCB.daq'; % Num 124
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00085 Westak PCB.daq'; % Num 125
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00086 Westak PCB.daq'; % Num 126
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00087 Westak PCB.daq'; % Num 127
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00085 Spin2 Westak PCB.daq'; % Num 128
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170615 175-0451 R6.0 Prod SN 451 00085 Spin3 Westak PCB.daq'; % Num 129

'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00077 Westak PCB.daq';                          % Num 130
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00081 Westak PCB.daq';                          % Num 131
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00082 Westak PCB.daq';                          % Num 132
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00083 Westak PCB.daq';                          % Num 133
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00084 Westak PCB.daq';                          % Num 134
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00085 Westak PCB.daq';                          % Num 135
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00086 Westak PCB.daq';                          % Num 136    
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00087 Westak PCB.daq';                          % Num 138
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00056 Circuitronix PCB.daq';                    % Num 139
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00057 Circuitronix PCB.daq';                    % Num 140
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00058 Circuitronix PCB.daq';                    % Num 141
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00059 Circuitronix PCB.daq';                    % Num 142
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00060 Circuitronix PCB.daq';                    % Num 143
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00061 Circuitronix  Rogers LoPro PCB.daq';      % Num 144

'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170620 175-0451 R6.0 Prod SN 451 00084 Westak PCB.daq';                           % Num 145

% Four 175-0451 R6.0 with bad etching - check to see how performance is
% impacted.
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170621 175-0451 R6.0 Prod SN 451 00362 Westak PCB.daq';                           % Num 146
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170621 175-0451 R6.0 Prod SN 451 00363 Westak PCB.daq';                           % Num 147
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170621 175-0451 R6.0 Prod SN 451 00364 Westak PCB.daq';                           % Num 148
'C:\Data\20170615 175-0451 Rev. 6.0 Prod\20170621 175-0451 R6.0 Prod SN 451 00365 Westak PCB.daq';                           % Num 149

% Circuitronics Production build of 250 - not working very well.
'C:\Data\20170905 Circuitronics Matrix RF\20170831 175-0451 R6 Circ Rogers PCBA.daq';

% HDA X2 Testing
'C:\Users\jcollier\OneDrive - Wavetronix LLC\20170914_HDA_X2_Chamber_HDfmt_X2_ChanSwap.daq';

% HD Noise Figure Measurments
'C:\Data\20171010 HD NF Measurements\20171010 HD Xcvr Spin.daq';                                                            % Num 151
'C:\Data\20171010 HD NF Measurements\20171010 HD Xcvr Spin ChirpNoSpin 1Ant.daq';
'C:\Data\20171010 HD NF Measurements\20171010 HD Xcvr Spin ChirpNoSpin.daq';
'C:\Data\20171010 HD NF Measurements\20171010 HD Xcvr Spin ChirpNoSpin 1Ant CW 24p125GHz.daq';
'C:\Data\20171010 HD NF Measurements\20171010 HD Xcvr Spin ChirpNoSpin 1Ant DDSPwrDn.daq';

'C:\Data\20171010 HD NF Measurements\20171010 HD Orig ActiveTargetSpin.daq';
'C:\Data\20171010 HD NF Measurements\20171010 HD Orig Unit2 ActiveTargetSpin.daq';                                          % Num 157

% HD XCVR with LTC 100MHz Ref Clk & Si5338 EVB for 670MHz Lo
'C:\Data\20171010 HD NF Measurements\20171103 HD XCVR wLT RefClk & Si5338 670MHzLo Chamber Spin 1.daq';
'C:\Data\20171010 HD NF Measurements\20171103 HD XCVR wLT RefClk & Si5338 670MHzLo Chamber UpDown 0x000F000F.daq'
'C:\Data\20171010 HD NF Measurements\20171103 HD XCVR wLT RefClk & Si5338 670MHzLo NewRangeComp Chamber Spin 1.daq'

% HD XCVR new extern clk comparison - starting over to make before and
% after measurments of everything

'C:\Data\20171108 HD Clk\20171108 HD XCVR Brd4 Chamber Spin.daq';
'C:\Data\20171108 HD Clk\20171108 HD XCVR Brd4 Ext LTCClkRef & Si5338 Chamber Spin.daq'

% Matrix SNR Investigation
'C:\Data\20180328 Matrix SNR\20180328 Matrix RF Rogers R6 DelayLine.daq';
'C:\Data\20180328 Matrix SNR\20180328 Matrix RF Rogers R3 wAbsorber DelayLine.daq'
'C:\Data\20180328 Matrix SNR\20180328 Matrix RF Circ Rogers R6 DelayLine.daq'
'C:\Data\20180328 Matrix SNR\20180328 Matrix RF WT Rogers R6 SN52 DelayLine.daq'
'C:\Data\20180328 Matrix SNR\20180328 Matrix RF WT Rogers R3 SN451_00009 NoAbsorber DelayLine.daq'
'C:\Data\20180328 Matrix SNR\20180328 Matrix RF CT Arlon FCC SN_BID200 DelayLine.daq'
'C:\Data\20180328 Matrix SNR\20180328 Matrix RF WT R3 SN451_00012 PGA1p0 CW -36p5dBm AllChans.daq'
'C:\Data\20180328 Matrix SNR\20180328 Matrix RF WT R3 SN451_00012 PGA1p0 CW -27p8dBm AllChans.daq'
'C:\Data\20180328 Matrix SNR\20180328 Matrix RF WT R3 SN451_00012 PGA1p0 CWCh08 -34p13dBmHorn AllChans.daq'
'C:\Data\20180328 Matrix SNR\20180410 Matrix RF WT R3 SN451_00012 PGA1p0 CWCh07 -33p13dBmHorn AllChans.daq'
'C:\Data\20180328 Matrix SNR\20180410 Matrix RF WT R3 SN451_00012 PGA1p0 CWCh07 -22p13dBmHorn AllChans.daq'

'C:\Data\20180328 Matrix SNR\20180412 Matrix RF WT R3 SN451_00012 PGA1p0 1WattAmp wFan2.daq'
'C:\Data\20180328 Matrix SNR\20180412 Matrix RF WT R3 SN451_00012 PGA1p0 1WattAmp wFan 12VDC.daq'
'C:\Data\20180328 Matrix SNR\20180412 Matrix RF WT R3 SN451_00012 PGA1p0 1WattAmp w24GHzFilt -32.8dBm.daq';
'C:\Data\20180328 Matrix SNR\20180412 Matrix RF WT R3 SN451_00012 PGA1p0 HMC498 -32.8dBm.daq';
'C:\Data\20180328 Matrix SNR\20180412 Matrix RF WT R3 SN451_00012 PGA1p0 1WattAmp followby498 -33.0dBm.daq';
'C:\Data\20180328 Matrix SNR\20180412 Matrix RF WT R3 SN451_00009 PGA1p0 -30.9dBm.daq';
'C:\Data\20180328 Matrix SNR\20180412 Matrix RF WT R6 SN451_04977 PGA1p0 -31.8dBm.daq';
'C:\Data\20180328 Matrix SNR\20180412 Matrix RF CT R6 SN451_00045 PGA1p0 -31.8dBm.daq';
'C:\Data\20180328 Matrix SNR\20180418 Matrix RF WT R3 451-00009 ChamberValidationDelayLine.daq';
'C:\Data\20180328 Matrix SNR\20180424 Matrix RF WT R3 451-00009 DelayLine NoAbsorber -31.1dBm.daq';
'C:\Data\20180328 Matrix SNR\20180424 Matrix RF WT R3 451-00009 DelayLine wAbsorberAfter498 -31.9dBm.daq';
'C:\Data\20180328 Matrix SNR\20180424 Matrix RF WT R3 451-00009 DelayLine wAbsorberBefore498 -31.1dBm.daq';
'C:\Data\20180328 Matrix SNR\20180424 Matrix RF WT R3 451-00009 DelayLine wMoreAbsorberBefore498 -31.2dBm.daq';
'C:\Data\20180328 Matrix SNR\20180424 Matrix RF WT R3 451-00009 DelayLine wGrayAbsorberBefore498 -31.8dBm.daq';

'C:\Data\20180328 Matrix SNR\20180411 Matrix RF WT R3 SN451_00012 PGA1p0 AllChans PA pwr_set10.daq';
'C:\Data\20180328 Matrix SNR\20180411 Matrix RF WT R3 SN451_00012 PGA1p0 AllChans PA pwr_set15.daq';
'C:\Data\20180328 Matrix SNR\20180411 Matrix RF WT R3 SN451_00012 PGA1p0 AllChans PA pwr_set20.daq';
'C:\Data\20180328 Matrix SNR\20180411 Matrix RF WT R3 SN451_00012 PGA1p0 AllChans PA pwr_set25.daq';
'C:\Data\20180328 Matrix SNR\20180411 Matrix RF WT R3 SN451_00012 PGA1p0 AllChans PA pwr_set29.daq';

% Matrix RF 175-0451 Rev7 & Rev7b comparision. R7 RF Attenuator Remove &
% R7b has RF Atten. moved after PA.
'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R7 451-BRD3 Chamber DelayLine Spin.daq'
'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R7 451-BRD5 Chamber DelayLine Spin.daq'
'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R7 451-BRD6 Chamber DelayLine Spin.daq'
'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R7b 451-BRD1 Chamber DelayLine Spin.daq'
'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R7b 451-BRD2 Chamber DelayLine Spin.daq'
'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R7b 451-BRD4 Chamber DelayLine Spin.daq'
'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R6 451-08504 Chamber DelayLine Spin.daq'
'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R6 451-08505 Chamber DelayLine Spin.daq'
'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF 175-0451 R6 451-08506 Chamber DelayLine Spin.daq'
'C:\Data\20180618 Matrix RF R7\20180618 Matrix RF Arlon FCC Unit Chamber DelayLine Spin.daq'
'C:\Data\20180618 Matrix RF R7\20180626 Matrix RF Arlon FCC Unit Chamber DelayLine Spin.daq'
'C:\Data\20180618 Matrix RF R7\20180626 Matrix RF 175-0451 R7 451-BRD3 w3dBPadAdded Chamber DelayLine Spin.daq'

'C:\Data\20180618 Matrix RF R7\20180626 HD XCVR VPole Chamber DelayLine Spin.daq'

'C:\Data\20180618 Matrix RF R7\20180626 HD XCVR 175-0173 R12 SN173_A1122 Chamber DelayLine Spin.daq'
'C:\Data\20180618 Matrix RF R7\20180626 HD XCVR 175-0173 R12 SN173_A1122 fixLNLDOBypass & opamp_fb_ResChamber DelayLine Spin.daq'

};

FileIndx = size(FileNameDB,1)-0;

NFNs = numel(FileNameDB);
FIG_NUM =  10*FileIndx+500;
FILE_NAME = [FileNameDB{FileIndx}];
[filePath,fileName,fileExt] = fileparts(FILE_NAME); 
fprintf('File Name : %s\n',FILE_NAME);
%% Read DAQ file into memory.

[NUM_UP_CHIRP_SAMPLES, NUM_DOWN_CHIRP_SAMPLES, NUM_ANTENNAS] = findChirpParametersFromWaspDaqFile(FILE_NAME);

fid = fopen(FILE_NAME,'r');
if (fid == -1)
   error('Unable to open file');
end

numSampsInChirp = NUM_UP_CHIRP_SAMPLES + NUM_DOWN_CHIRP_SAMPLES;
numSampsPerPulse = numSampsInChirp + NUM_SAMPS_IN_HEADER;

[data,numRead] = fread(fid,[numSampsPerPulse,  NUM_DATA_RECORDS],'int16');
fclose(fid);

%% Process Time Data
dateStr = datestr(now,29);

t1 = NUM_SAMPS_IN_HEADER + 1;
t2 = NUM_SAMPS_IN_HEADER + NUM_UP_CHIRP_SAMPLES;
%%window = chebwin((t2-t1+1),70);
window = blackmanharris((t2-t1+1));
Window = repmat(window,1,size(data,2));
UpChirpSamples = t1:t2;
Data = fft(data(UpChirpSamples,:).*Window(:,1:size(data,2)),FFT_SIZE);
% Throw Away Conjugate
Data = Data(1:(end/2+1),:);


%% reshape Data to the format dataMatrix(sample,antennaNum,scanNum)
scans = floor(size(Data,2)/NUM_ANTENNAS);
% If Data is not a multiple of the NUM_ANTENNAS then fix it!
Data = Data(:,1:(scans*NUM_ANTENNAS));
Data = reshape(Data,size(Data,1),NUM_ANTENNAS,scans);


data = reshape(data(:,1:(scans*NUM_ANTENNAS)),numSampsPerPulse,NUM_ANTENNAS,scans);

%%
Data_Mean = 10*log10(mean(abs(Data.^2),3));
fprintf('Mean bin 29 %f\n',Data_Mean(29,2));
figure(10);clf;plot(Data_Mean);
%return
%% Convert to decibles.
DatadB = 20*log10(abs(Data));

%% Find pulse and bin where signal is max (for each channel)
% Since the sensor spins 1.5 times find the first peaks 
% and the second peaks to also find the degrees per pluse.
midSpinChirpIdx = floor(scans/2);
binsToSearchForMax = 10:100;
[maxMag3, maxIdxPulse3] = max(DatadB(binsToSearchForMax,:,(midSpinChirpIdx+1):end),[],3);
[maxMag, maxBins] = max(maxMag3,[],1);

% Do a sanity check - all of the maxBins should be equal to each other
% sense the active target is at the same range in all of the channels.
if ~(all(maxBins == maxBins(1)))
    fprintf('**** WARNING: All peaks not found in same range bin! ****\n');
end

maxBins = mode(maxBins);
maxIdxPulse = maxIdxPulse3(maxBins,:) + midSpinChirpIdx;
maxBins = maxBins + binsToSearchForMax(1) - 1;
% Find the first peaks
[maxMagFirst, maxIdxPulseFirst] = max(DatadB(maxBins,:,1:midSpinChirpIdx),[],3);
pulse2deg = 360/mean(maxIdxPulse - maxIdxPulseFirst);
zero_deg_idx = round(mean(maxIdxPulse));

x_axis_uncomp = pulse2deg*((1:scans) - zero_deg_idx);

% Compensate the x_axis (angle of rotation) for the finite dimensions of
% the chamber.
R = 3.880; % Radius of rotation in Inches.
D = 127.0 + 0i; % Distance of rotation to Front of Horn Antenna.

x_axis = x_axis_uncomp - angle(D-R*exp(1i*pi*x_axis_uncomp/180))*180/pi;

pk_deg = x_axis(maxIdxPulse)-x_axis(zero_deg_idx);

%% Find beamwidths
dBDownPoint = 6;
dBDownLeftIdx = zeros(1,NUM_ANTENNAS);
dBDownRightIdx = zeros(1,NUM_ANTENNAS);
for i = 1:NUM_ANTENNAS
    %find dB down to left of max
    dBDownLeftIdx(i) = 0;
    for j = maxIdxPulse(i):-1:1
        if DatadB(maxBins,i,j) < (maxMag(i) - dBDownPoint)
            dBDownLeftIdx(i) = j;
            break;
        end
    end
    %find dB down to right of max
    dBDownRightIdx(i) = 0;
    for j = maxIdxPulse(i):1:size(DatadB,3)
        if DatadB(maxBins,i,j) < (maxMag(i) - dBDownPoint)
            dBDownRightIdx(i) = j;
            break;
        end
    end
end

antBeamWidthDegs = x_axis(dBDownRightIdx + 1) - x_axis(dBDownLeftIdx );

%% Find the Mode of the Channels.
histBins = 1:100;
maxToMode = zeros(1, NUM_ANTENNAS);
myMode = zeros(1, NUM_ANTENNAS);
myBinsMode = zeros(NUM_ANTENNAS,FFT_SIZE/2+1);
for b = 1:(FFT_SIZE/2+1)
    for i = 1:NUM_ANTENNAS
        hh = hist(squeeze(DatadB(b,i,:)),histBins);
        [mx, mxi] = max(hh);
        myBinsMode(i,b) = histBins(mxi);
    end
end

for i = 1:NUM_ANTENNAS
    hh = hist(squeeze(DatadB(maxBins,i,:)),histBins);
    [mx, mxi] = max(hh);
    myMode(i) = histBins(mxi);
    maxToMode(i) = maxMag(i) - myMode(i);
end
%% Plot Channel Data.
colors = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1; 0.5 0.5 0.5;...
            0.5 0 0; 0 0.5 0; 0 0 0.5; 1 0.62 0.4; 0.49 1 0.83;...
            0.4 1 0.62; 0.62 0.4 1; 1 0.83 0.49];
titleStr = sprintf('%s PkBin = %i',fileName,maxBins);
legStr = cell(1,NUM_ANTENNAS);

figure(FIG_NUM);clf;

subplot(2,2,3);hold on;grid;box on;
ViewAngle = 90;
for i = 1:NUM_ANTENNAS
    plot( x_axis, squeeze( DatadB( maxBins, i, :) ), 'color', colors(i, :) );
    %legStr{i} = sprintf('Ant. %d; Mx2Md=%3.1f, Md=%3.1f, BW = %3.1f, %3.1f°', (i-1), maxToMode(i), myMode(i),antBeamWidthDegs(i),pk_deg(i));
    legStr{i} = sprintf('Ant. %d; Mx2Md=%3.1f, BW = %3.1f, %3.1f°', (i-1), maxToMode(i), antBeamWidthDegs(i),pk_deg(i));
end
title(sprintf('%s - %s',titleStr,dateStr),'Interpreter', 'none');
ylabel('dB');xlabel('Degrees');
legend(legStr, 'location', 'NorthWest');
set(gca,'xtick',-540:10:180);
mPk = mean(maxMag);
axis([-ViewAngle ViewAngle 30 105]);


subplot(2,2,1); hold on; grid on;box on;
for i = 1:NUM_ANTENNAS        
    plot(x_axis, squeeze(DatadB(maxBins,i,:)) - maxMag(i),'color',colors(i,:));
end
title(sprintf('%s - %s Normalized',titleStr,dateStr),'Interpreter', 'none')
ylabel('dB');xlabel('Degrees');
set(gca,'xtick',-540:10:180);
axis([-ViewAngle ViewAngle -70 5]);


%% Plot Range where Peak is Normilized
subplot(2,2,2);hold on;box on;axis([1 128 -50 10]);grid on;
for i = 1:NUM_ANTENNAS
    plot(squeeze( max( DatadB(:,i,:), [], 3))- maxMag(i),'color',colors(i,:));
end
title('Max across bins');
%% Plot Range where Peak is
subplot(2,2,4);
hold on;grid on;box on;axis([1 128 40 100]);
for i = 1:NUM_ANTENNAS;
    %plot(squeeze(20*log10(mean(abs(Data(:,i,:)),3)))- maxMag(i),'color',colors(i,:));
    plot(squeeze(20*log10(mean(abs(Data(:,i,:)),3))),'color',colors(i,:));
end
xlabel('Bin #'); ylabel('Mean (dBc)');
%title('Mean across bins Normalized to Peak Response');
title('Mean across bins');

%% Print stats
fprintf('MaxToMode: Min %3.1f Avg %3.1f Max %3.1f\n',min(maxToMode),mean(maxToMode),max(maxToMode));
%% Print off the elapsed time.
elapsedTime = toc;
fprintf(1,'Elapsed time: %.0f seconds\n\n', elapsedTime);
pk_deg'


%% Plot Heat Map of Channel x
figure(FIG_NUM+1);clf;
hold on;%axis([1 128 -50 10]);grid on;
i = 2;
    imagesc(squeeze( ( DatadB(:,i,:)))- maxMag(i));caxis([-60 0]);colorbar;

title(['Channel: ' num2str(i-1)]);

%%

