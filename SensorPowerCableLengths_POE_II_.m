%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Start configuration options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
% This is the maximum cable length to calculate for
LcabMax = 7000;

% This is the cable length we would like to achieve
LcabTarget = 5000;

%% Power guaranteed to sensor
%% 802.3AF says:
%%      Class       Min PSE Power       Max PD Power
%%      1           4                   3.84
%%      2           7                   6.49
%%      3,4,or 0    15.4                12.95
%% 802.3AT says:
%%      Class       Min PSE Power       Max PD Power
%%      4           30                  25.5
Ppd = 7;

%% option to power limit the source supply power
PpseMax = 40;

%% The voltage of the source power supply
%% POE standard is 48, but we can run up to 56V
%% LTC4266 quad PSE says 45-57V for IEEE type 1 (POE 802.3AF)
%% LTC4266 quad PSE says 51-57V for IEEE type 2 (POE+ 802.3AT)
%% 802.3AF says min PSE voltage = 44 and min MaxCurrent = 0.35 (PSE min power = 15.4W)
%% 802.3AF says min PD voltage = 37 @min MaxCurrent = 12.95W
%% 802.3AT says min PSE voltage = 44 (for type 1) and 50 (for type 2)
%% 802.3AT says min MaxCurrent = 0.6 (PSE min power = 30W for type 2)
%% 802.3AT says min PD voltage = 42.5 (type 2) @min MaxCurrent = 25.5W
%% LTC4269-1 says min startup input voltage = 37.2V
%% LTC4269-1 says max shutdown input voltage = 30V
Vpse = 54;% * 54;  % a 54V supply regulated at +- 5% is 51-57V

%% The minimum voltage at the device required to run
VpdMin = 8; %% no lower than LTC4269-1 min startup input voltage (37.2)



%% This is an arbitrary derating since I can't test all configurations.  I
%% feel OK with this.  The things I worry about are differences in power
%% supply operation and extreamly low temperatures, and power supply
%% derating at high temperatures.  Also, any surge suppression will
%% negatively effect maximum cable runs.
LengthDerating = 1;%0.90;  %%allow 90% Max Length


%% Current limit of source supply
%% LTC4266 quad PSE says:
%%      Class        Icut       Ilim
%%      1            112mA      425mA
%%      2            206mA      425mA
%%      3 or 0       375mA      425mA
%%      4            638mA      850mA
%% POE+ current limit is 600mA
%% POE current limit is 350mA
Ilimit = 2; %%LTC4266 quad PSE says class 4 Icut is 638mA

%% Various cable conductivity from random sources
%% Legend : Resistance      Gauge   Strands/Gauge
%%          28.5 ohms/1kft  24awg solid Belden 74001E industrial ethernet Cat 5E 
%%          26.2 ohms/1kft  24awg solid 
%%          25.67 ohms/1kft 24awg 
%%          16.6 ohms/1kft  22awg   solid
%%          14.7 ohms/1kft  22awg   (7/30)
%%          10.3 ohms/1kft  20awg   (7/28) 
%%          5.9 ohms/kft    18awg   (7/26) 
%%          3.7 ohms/kft    16awg   (7/24) 
%%          4.35 ohms/kft   16awg   (19x29) Lake Cable SVX162S/485-WAV (Datasheet)
%%          5.15 ohms/kft   16awg   (19x29) Lake Cable SVX162S/485-WAV (Measured)
%%          2.3 ohms/kft    14awg   (7/22)
%%          1.7 ohms/kft    12awg
%%          1.1 ohms/kft    10awg 
%%          0.67 ohms/kft   8awg 
%%          0.47 ohms/kft   6awg
%%          6.4 ohms/kft    18awg solid copper core RG6/RG58(Alpha 9848)
%%          28 ohms/kft     18awg copper coated steel core RG6
%%          2.7 ohms/kft    single copper braid shield RG6
%%          5.0 ohms/kft    single copper braid shield RG6 belden 5339x5 datasheet
%%          2.6 ohms/kft    single copper braid shield RG6 Carol C5761 datasheet
%%          1.7 ohms/kft    dual copper braid shield RG6
%%          9.0 ohms/kft    single aluminum braid shield RG6
%%          4.5 ohms/kft    single copper braid shield RG58(Alpha 9848)
%%          3.7 ohms/kft    aluminum quad shield RG6
%%         28.59 ohms/kft   CAT5 24AWG bare copper
%%         28.59 ohms/kft   CAT5 24AWG bare copper
%%         14.3 ohms/kft    CAT5 24AWG pair (one direction for POE) bare copper
%%	   244 ohms/kft	    RG179 30awg 7x38 silver plated copper covered steel center conductor (belden 83264)
%%	   8.5 ohms/kft	    RG179 shield silver plated copper (belden 83264)
%%	   70.5 ohms/kft    RG179 28.5awg bare copper center conductor (belden 179dt)
%%	   8.0 ohms/kft	    RG179 shield tinned copper with foil (belden 179dt)


%% used cable conductivity for sending power
RftCab1 = 5.9;%5.15; %%6.4; %% in ohms/1000ft (+DC cable)-- replace with appropriate
                    %% impedance from comment above for selected cable. 
                    %% Standard parallel resistance equation applies for 
                    %% multiple wires
%% used cable conductivity for return path
RftCab2 = 5.9;%5.15; %%2.7; %% in ohms/1000ft (-DC cable)-- replace with appropriate
                    %% impedance from comment above for selected cable. 
                    %% Standard parallel resistance equation applies for 
                    %% multiple wires


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End configuration options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%









OptionsString = ['LcabMax: ' num2str(LcabMax) char(10)...
                 'LcabTarget: ' num2str(LcabTarget) char(10)...
                 'Ppd: ' num2str(Ppd) char(10)...
                 'PpseMax: ' num2str(PpseMax) char(10)...
                 'Vpse: ' num2str(Vpse) char(10)...
                 'VpdMin: ' num2str(VpdMin) char(10)...
                 'LengthDerating: ' num2str(LengthDerating) char(10)...
                 'Ilimit: ' num2str(Ilimit) char(10)...
                 'RftCab1: ' num2str(RftCab1) char(10)...
                 'RftCab2: ' num2str(RftCab2) char(10)...
                ]

RftCab1 = RftCab1 / 1000;
RftCab2 = RftCab2 / 1000;

% make array for cable in 1 foot increments and make resistance array too
Lcab = 1:1:LcabMax;
Rcab = (RftCab1 + RftCab2) .* Lcab;

% make a matrix with columns as the coefficients of the quadratic equation
%       -b +-(b^2 -4ac)^0.5
%  x = ----------------------
%                2a
%
% where a = Rcab, b = -Vpse, and c = Ppd
%
%    ------Rcab----------
%    |                  |
%    |                  |
%  Vpse                 Rl  (=Ppd/I^2)
%    |                  |
%    |                  |
%    --------------------
%
%  Vpse = I*Rcab + I*Rl
%  Vpse = I*Rcab + Ppd/I
%  Vpse*I = I^2*Rcab + Ppd
%  Rcab*I^2 -Vpse*I + Ppd = 0
%
Ipolys = horzcat(Rcab.', ones(length(Rcab), 1) * (-Vpse), ones(length(Rcab), 1) * (Ppd));

LimitString = 'LcabMax Limited';

% find the currents that are real
Icab1MaxIdx = 0;
Icab2MaxIdx = 0;
MaxRealIdx = 0;
for a=1:length(Rcab)
    Iroots = roots(Ipolys(a:a,1:3));
    Icab1(a) = min(Iroots);
    Icab2(a) = max(Iroots);
    
    ridx = find(abs(imag(Icab1(a)))< eps('double').*abs(real(Icab1(a))));
    if ridx == 1
        Icab1MaxIdx = a;
        MaxRealIdx = a;
        LimitString = 'Impedance Match Limited';
    end

    ridx = find(abs(imag(Icab2(a)))< eps('double').*abs(real(Icab2(a))));
    if ridx == 1
        Icab2MaxIdx = a;
        MaxRealIdx = a;
        LimitString = 'Impedance Match Limited';
    end
end


% find the currents that don't violate the minimum PD voltage input
for a=1:Icab1MaxIdx
   if (Ppd / Icab1(a)) < VpdMin
       if a < Icab1MaxIdx
            Icab1MaxIdx = a;
            LimitString = 'PD Voltage Limited';
       end
   end
end

% find the currents that are below the current limit
for a=1:Icab1MaxIdx
   if Icab1(a) > Ilimit
       if a < Icab1MaxIdx
            Icab1MaxIdx = a;
            LimitString = 'Current Limited';
       end
   end
end

% find the PSE power that is below the power limit
for a=1:Icab1MaxIdx
   if (Ppd + Rcab(a) * Icab1(a)^2) > PpseMax
       if a < Icab1MaxIdx
            Icab1MaxIdx = a;
            LimitString = 'PSE Power Limited';
       end
   end
end

% if we get through all of these and the length is not current, power, or
% voltage limited then it is only limited by the imaginary currents.  In
% this case, the other current factors may apply, so check these for limits

% find the currents that don't violate the minimum PD voltage input
Icab2MinIdx = 1;
for a=1:Icab2MaxIdx
   if (Ppd / Icab2(a)) < VpdMin
       if a > Icab2MinIdx
            Icab2MinIdx = a;
       end
   end
end

% find the currents that are below the current limit
for a=1:Icab2MaxIdx
   if Icab2(a) > Ilimit
       if a > Icab2MinIdx
            Icab2MinIdx = a;
       end
   end
end

% find the PSE power that is below the power limit
for a=1:Icab2MaxIdx
   if (Ppd + Rcab(a) * Icab2(a)^2) > PpseMax
       if a > Icab2MinIdx
            Icab2MinIdx = a;
       end
   end
end


Vpd1 = Ppd ./ Icab1;
Vpd2 = Ppd ./ Icab2;
Ppse1 = (ones(length(Rcab), 1) * Ppd).' + Icab1 .* Icab1 .* Rcab;
Ppse2 = (ones(length(Rcab), 1) * Ppd).' + Icab2 .* Icab2 .* Rcab;

Icab1DerateIdx = floor(LengthDerating * Icab1MaxIdx);

MaxLenStr = ['Max Derated Cable Length = ' ...
            num2str(Icab1DerateIdx) ' Feet' ...
            char(10) ...
            'PSE @ ' num2str(Vpse) 'V / ' ...
            num2str(Ppse1(Icab1DerateIdx)) 'W / ' ...
            num2str(Icab1(Icab1DerateIdx)) 'A' ...
            char(10) ...
            'PD @ ' num2str(Vpd1(Icab1DerateIdx)) 'V / ' ...
            num2str(Ppd) 'W / ' ...
            num2str(Icab1(Icab1DerateIdx)) 'A']


figure(1)
plot(Icab1(1:Icab1MaxIdx));
hold on;
plot(get(gca,'xlim'), [Ilimit Ilimit], 'R')
if Icab1MaxIdx >= LcabTarget
   plot(LcabTarget, Icab1(LcabTarget), 'k+');
end
plot(Icab1DerateIdx, Icab1(Icab1DerateIdx), 'k*');
plot(Icab2MinIdx:Icab2MaxIdx, Icab2(Icab2MinIdx:Icab2MaxIdx), 'g');
hold off;
xlabel('Cable Length (in feet)');
ylabel('Current');
title (MaxLenStr);

figure(2)
plot(Vpd1(1:Icab1MaxIdx));
hold on;
plot(get(gca,'xlim'), [VpdMin VpdMin], 'R')
if Icab1MaxIdx >= LcabTarget
   plot(LcabTarget, Vpd1(LcabTarget), 'k+');
end
plot(Icab2MinIdx:Icab2MaxIdx, Vpd2(Icab2MinIdx:Icab2MaxIdx), 'g');
plot(Icab1DerateIdx, Vpd1(Icab1DerateIdx), 'k*');
hold off;
xlabel('Cable Length (in feet)');
ylabel('Voltage @ PD input');
title (MaxLenStr);

figure(3)
plot(Ppse1(1:Icab1MaxIdx));
hold on;
plot(get(gca,'xlim'), [PpseMax PpseMax], 'R')
if Icab1MaxIdx >= LcabTarget
   plot(LcabTarget, Ppse1(LcabTarget), 'k+');
end
plot(Icab2MinIdx:Icab2MaxIdx, Ppse2(Icab2MinIdx:Icab2MaxIdx), 'g');
plot(Icab1DerateIdx, Ppse1(Icab1DerateIdx), 'k*');
hold off;
xlabel('Cable Length (in feet)');
ylabel('Power @ Pse');
title (MaxLenStr);

if Icab1MaxIdx >= LcabTarget
   TargetLenStr = ['Target Cable Length = ' ...
            num2str(LcabTarget) ' Feet' ...
            char(10) ...
            'PSE @ ' num2str(Vpse) 'V / ' ...
            num2str(Ppse1(LcabTarget)) 'W / ' ...
            num2str(Icab1(LcabTarget)) 'A' ...
            char(10) ...
            'PD @ ' num2str(Vpd1(LcabTarget)) 'V / ' ...
            num2str(Ppd) 'W / ' ...
            num2str(Icab1(LcabTarget)) 'A']
end

LimitString






    




