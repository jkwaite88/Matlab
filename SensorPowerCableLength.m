% Sensor Power Cable length 
clear
% This is the maximum cable length to calculate for
LcabMax = 6000;

% This is the cable length we would like to achieve
LcabTarget = 4000;

%% Power guaranteed to sensor
%% 802.3AF says:
%%      Class       Min PSE Power       Max PD Power
%%      1           4                   3.84
%%      2           7                   6.49
%%      3,4,or 0    15.4                12.95
%% 802.3AT says:
%%      Class       Min PSE Power       Max PD Power
%%      4           30                  25.5
%Ppd = 8.7;
Ppd = 20;

%% option to power limit the source supply power
PpseMax =40;

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
VpdMin = 10; %% no lower than LTC4269-1 min startup input voltage (37.2)



%% This is an arbitrary derating since I can't test all configurations.  I
%% feel OK with this.  The things I worry about are differences in power
%% supply operation and extreamly low temperatures, and power supply
%% derating at high temperatures.  Also, any surge suppression will
%% negatively effect maximum cable runs.
LengthDerating = 0.90;  %%allow 90% Max Length


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
%%           7.3 ohms/1kft  18awg   (7/0.0152) tinned copper - Lake Cable T181PR222PRS/ER-WAV
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
%%          14.7 ohms/kft expanse 22 AWG (there are two wires in the twisted pair
%%          4.35 ohms/kft expanse sheild
%%          3.76 ohms/kft expanse 16 AWG

%% used cable conductivity for sending power
RftCab1 = 7.3;%5.15; %%6.4; %% in ohms/1000ft (+DC cable)-- replace with appropriate
                    %% impedance from comment above for selected cable. 
                    %% Standard parallel resistance equation applies for 
                    %% multiple wires
%% used cable conductivity for return path
RftCab2 = 7.3;%5.15; %%2.7; %% in ohms/1000ft (-DC cable)-- replace with appropriate
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

%See notes in OneNote notebook, page titled "Sensor Power Cable Length"

%           I --> 
%    ------Rcab----------
%    |                  |
%    |                  |
%  Vpse                 Rpd  (=Ppd/I^2)
%    |                  |
%    |                  |
%    --------------------

%  Vpse = I*Rcab + I*Rpd
%  Vpse = I*Rcab + Ppd/I
%  Vpse*I = I^2*Rcab + Ppd
%  Rcab*I^2 -Vpse*I + Ppd = 0

%       -b +-(b^2 -4ac)^0.5
%  I = ----------------------
%                2a
%
% where a = Rcab, b = -Vpse, and c = Ppd

RftCab1 = RftCab1 / 1000; % Resistance per foot
RftCab2 = RftCab2 / 1000; % Resistance per foot
RftCab = RftCab1 + RftCab2;

RftCab = RftCab / LengthDerating; %apply length derating as more resistance, could do it a different way

Lcab = (1:1:LcabMax).';
Rcab = Lcab*RftCab;
N = length(Rcab);

Iroots = zeros(N,2);
I.min = zeros(N,1);
I.max = zeros(N,1);
I.realRoots = zeros(N,1);
for i = 1:N
    r = Vpse^2 - 4 * Rcab(i)*Ppd; %(b^2 -4ac)
    if r >= 0
        Iroots(i,:) = (roots([Rcab(i) -Vpse Ppd])).'; %real
    else
        Iroots(i,:) = nan*[0 0]; %imag
    end
    
end
Iroots = sort(Iroots,2); %sort - put small root first
i = find(~isnan(Iroots(:,2))); %real current indexes

[maxCblLen maxCblLenIdx] = max(Lcab(i));
Vcab = Iroots .* repmat(Rcab,1,2);
Pcab = Vcab.^2./repmat(Rcab,1,2);
Vpd = Vpse - Vcab;
Ppd_calc = Vpd.*Iroots;
Ppse = Iroots.*Vpse;
BelowPpseMaxIdx = find(Ppse<=PpseMax);
AbovePpseMaxIdx = find(Ppse>PpseMax);

MaxLenStr = ['Max Derated Cable Length = ' ...
            num2str(maxCblLen) ' Feet' ...
            char(10) ...
            'PSE @ ' num2str(Vpse) 'V / ' ...
            num2str(Ppse(maxCblLenIdx)) 'W / ' ...
            num2str(Iroots(maxCblLenIdx,1)) 'A' ...
            char(10) ...
            'PD @ ' num2str(Vpd(maxCblLenIdx)) 'V / ' ...
            num2str(Ppd) 'W / ' ...
            num2str(Iroots(maxCblLenIdx,1)) 'A'];


figure(11)
clf
hold on;
%find where PpseMax is exceeded
AbovePpseMaxIdx = find(Ppse(:,1)>PpseMax);
plot(Lcab(AbovePpseMaxIdx), Iroots(AbovePpseMaxIdx,1),'linewidth', 9, 'color',[0 1 1]);
AbovePpseMaxIdx = find(Ppse(:,2)>PpseMax);
plot(Lcab(AbovePpseMaxIdx), Iroots(AbovePpseMaxIdx,2),'linewidth', 9, 'color', [0 1 1]);
%find where Ilimit is exceeded
idx1 = find(Iroots(:,1)>Ilimit);
idx2 = find(Iroots(:,2)>Ilimit);
plot(Lcab(idx1),Iroots(idx1,1), 'Color', [1 0 0],'linewidth', 6)
plot(Lcab(idx2),Iroots(idx2,2), 'Color', [1 0 0],'linewidth', 6)
%plot where Vpd is not met
idx1 = find(Vpd(:,1)<VpdMin);
idx2 = find(Vpd(:,2)<VpdMin);
plot(Lcab(idx1),Iroots(idx1,1),'Color', [0 0 0],'linewidth', 3)
plot(Lcab(idx2),Iroots(idx2,2), 'Color', [0 0 0],'linewidth', 3)
%plot Current limit line
plot([Lcab(1) Lcab(end)], [Ilimit Ilimit], 'r')
%plot max and desired cable lenghts
plot(maxCblLen, Iroots(maxCblLenIdx,1),'k*')
[mn, minIdx] = min(abs(Lcab - LcabTarget));
if isnan((Iroots(minIdx,1)))
    plot(LcabTarget, Iroots(maxCblLenIdx,1),'kx')
else
    plot(LcabTarget, Iroots(minIdx,1),'kx')
end
plot(Lcab,Iroots(:,2),'g')
plot(Lcab,Iroots(:,1),'b')
hold off;
xlabel('Cable Length (Feet)');
ylabel('Current (Amps)');
axis([0 LcabMax 0 Ilimit*1.1])
title(MaxLenStr)
legend('Ppse Limited', 'Ipse Limited', 'Vpd limited','Ipse Limit', 'Max Cable Lenght', 'Desired Cable Length', 'Voltage Source Option', 'Current Source Option')

figure(12)
clf
hold on;
%plot Current limit line
plot([Lcab(1) Lcab(end)], [VpdMin VpdMin], 'r')
%find Vpdmin is exceeded
idx1 = find(Vpd(:,1)<VpdMin);
idx2 = find(Vpd(:,2)<VpdMin);
plot(Lcab(idx1),Vpd(idx1,1), 'Color', [1 0 0],'linewidth', 3)
plot(Lcab(idx2),Vpd(idx2,2), 'Color', [1 0 0],'linewidth', 3)
%plot max and desired cable lenghts
plot(maxCblLen, Vpd(maxCblLenIdx,1),'k*')
[mn, minIdx] = min(abs(Lcab - LcabTarget));
plot(LcabTarget, Vpd(minIdx,1),'kx')
plot(Lcab,Vpd(:,2),'g')
plot(Lcab,Vpd(:,1),'b')
% plot(Lcab,Vcab(:,1),'k')
% plot(Lcab,Vcab(:,2),'k')
hold off;
xlabel('Cable Length (Feet)');
ylabel('Votls @ PD input');
axis([0 LcabMax 0 Vpse*1.1])
title(MaxLenStr)
legend('Vpd Limited', 'Vpd Limit', 'Max Cable Lenght', 'Desired Cable Length', 'Current Source Option', 'Voltage Source Option')

figure(13)
clf
hold on;
%plot Current limit line
plot([Lcab(1) Lcab(end)], [PpseMax PpseMax], 'r')
plot(Lcab, Ppse(:,1), 'b')
plot(Lcab, Pcab(:,1), 'k')
plot(Lcab, Ppd_calc(:,1), 'c')
hold off;
xlabel('Cable Length (Feet)');
ylabel('Watts');
axis([0 LcabMax 0 Vpse*1.1])
title(MaxLenStr)
legend('Ppse Limit', 'Ppse' , 'Pcab', 'Ppd')