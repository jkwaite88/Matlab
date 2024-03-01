theta_degrees = linspace(-60,60,121).';
theta_radians = theta_degrees*pi/180;

lane_width = 12;

resolution_degrees_per_rangeFeet = 3.5/200;

ang_resolution_at_angle = 2.5./cosd(theta_degrees);

range_at_lane_width = lane_width./(2*sind(ang_resolution_at_angle/2));

x_range_at_lane_width = range_at_lane_width .* sind(theta_degrees);
y_range_at_lane_width = range_at_lane_width .* cosd(theta_degrees);


z = zeros(size(x_range_at_lane_width));
p = [x_range_at_lane_width y_range_at_lane_width z];
mm_per_foot = 304.8;
p_mm = p.*mm_per_foot;


figure(1);clf;hold on;
plot(x_range_at_lane_width, y_range_at_lane_width)

circ_lines_dist = [50 100 150 200 250];
for i = 1:length(circ_lines_dist)
    plot(circ_lines_dist(i)*cosd(0:1:180), circ_lines_dist(i)*sind(0:1:180), color=[0 0 0 0.2], LineWidth=0.1, LineStyle='-' )
end
title('Contour of 12 Foot Angular Resolution')
xlabel('Feet')
ylabel('Feet')
axis equal
legend('Contour of 12 Foot Angular Resolution')

fileName = "12_foot_angular_resolution_points.csv";
writeCsvForFusion(fileName, p_mm);

%%
%range reduction becasue of antenna pattern angular falloff
load('SweepwAbsNfoam.mat')
data_x = linspace(-90,90, length(data));
[mn, start] = min(abs(data_x + 60));
[mn, stop] = min(abs(data_x - 60));
data_x_FOV = data_x(start:stop);
data_y_FOV = data(start:stop);

figure(2);clf;
subplot(2,2,1)
hold on
plot(data_x, data)
plot(data_x_FOV, data_y_FOV,'r')
grid on
title('Atenna Pattern')

result = quadradicFit(data_x_FOV, data_y_FOV);
a = result(1);
b = result(2);
c = result(3);

data_FOV_fit_y = a*data_x_FOV.^2 + b*data_x_FOV + c;
plot(data_x_FOV, data_FOV_fit_y, 'k')
legend('Original Data', 'FOV Data', 'Curve Fit of FOV')


[mx_fit, mxIdx_fit] = max(data_FOV_fit_y);
degreesToShift = data_x_FOV(mxIdx_fit);

x_orig_shifted = data_x - degreesToShift;


[mn, start] = min(abs(x_orig_shifted+60));
[mn, stop] = min(abs(x_orig_shifted-60));

stride = 10;
x_FOV_shifted = x_orig_shifted(start:stride:stop);
y_FOV_shifted = data(start:stride:stop);


subplot(2,2,2)
hold on
plot(x_FOV_shifted, y_FOV_shifted)
%plot(xx_shifted, yy_fit, 'r')
grid on

%equation for curve fit with centered at max
[a, h, k, b, c] = quadradicFit2(x_FOV_shifted, y_FOV_shifted, 0);

y_FOV_shifted_fit = a.*x_FOV_shifted.^2 + b.*x_FOV_shifted + c;
plot(x_FOV_shifted, y_FOV_shifted_fit, 'k')
title('Antenna Pattern - Curve Fit Shifted to Center')
legend('Original Data', 'Curve Fit')
xlabel('Antenna Angle (degrees)')
ylabel('dB')

min_fit = min(y_FOV_shifted_fit);
max_fit = max(y_FOV_shifted_fit);
r = max_fit - min_fit;

%Calculate the range line of equal SNR, due to antena pattern gain falloff near the edge of the FOV
G1 = max(y_FOV_shifted_fit);
G1 = 10.^(G1./10);
R1_500 = 500; %feet
G2 = y_FOV_shifted_fit;
G2 = 10.^(G2./10);
R2_500 = nthroot((G2*R1_500^4)./(G1),4);
R1_800 = 800; %feet
R2_800 = nthroot((G2*R1_800^4)./(G1),4);

rotate_deg = 90;
R2_500_x = R2_500.*cosd(x_FOV_shifted + rotate_deg);
R2_500_y = R2_500.*sind(x_FOV_shifted + rotate_deg);

subplot(2,2,3)
hold on
plot(x_FOV_shifted, R2_500)
title('Line of Equal SNR Due to Antenna Pattern Variation')
xlabel('Antenna Angle (degrees)')
ylabel('Range (feet)')
legend('Contour of Equal SNR')


subplot(2,2,4)
%polar(x_FOV_shifted.*pi./180, R2)

plot(R2_500_x, R2_500_y)
xlabel('Range (feet)')
ylabel('Range (feet)')

axis equal


%% Dilemma Zone
mph2fps = 1.46667;
car_mph = [45 65];
dilemma_seconds = [2.5 5.5 7.5];
dilemma_distance = zeros(length(car_mph),length(dilemma_seconds));

dilemma_distance = car_mph.' * dilemma_seconds .*mph2fps;

boresight_max_dilemma_feet = [500 800];
edge_max_delema_feet = [min(R2_500) min(R2_800)];
max_dilemna_vehicle_mph_boresight = (boresight_max_dilemma_feet.' * (1./dilemma_seconds)) ./mph2fps;
max_dilemna_vehicle_mph_edge = (edge_max_delema_feet.' * (1./dilemma_seconds)) ./mph2fps;


%% Plot equal SNR lines

figure(3);clf;hold on;
%plot 12 foot angular resolution line
plot(x_range_at_lane_width, y_range_at_lane_width)


%plot equal SNR lines
rotate_deg = 90;
x_500 = R2_500.*cosd(x_FOV_shifted+rotate_deg);
y_500 = R2_500.*sind(x_FOV_shifted + rotate_deg);
x_800 =R2_800.*cosd(x_FOV_shifted+rotate_deg);
y_800 = R2_800.*sind(x_FOV_shifted + rotate_deg);
plot(x_500, y_500, color=[1 0 0 1], LineWidth=0.5, LineStyle='-' )
plot(x_800, y_800, color=[0 1 0 1], LineWidth=0.5, LineStyle='-' )


%plot circular range lines
circ_lines_dist = [ 100  200 300 400 500 500 700 800];
for i = 1:length(circ_lines_dist)
    plot(circ_lines_dist(i)*cosd(30:1:150), circ_lines_dist(i)*sind(30:1:150), color=[0 0 0 0.2], LineWidth=0.1, LineStyle='-' )
    text(circ_lines_dist(i)*cosd(30), circ_lines_dist(i)*sind(30), sprintf('%d', circ_lines_dist(i)) , color=[0 0 0 1])
end
plot([0 800*cosd(30)], [0 800*sind(30)], color=[0 0 0 0.2], LineWidth=0.1, LineStyle='-' )
plot([0 800*cosd(150)], [0 800*sind(150)], color=[0 0 0 0.2], LineWidth=0.1, LineStyle='-' )

title('Equal SNR Contours')
xlabel('Feet')
ylabel('Feet')
legend('12 Foot Angular Resolution', 'Contour Equal SNR - 500 feet boresight', 'Contour Equal SNR - 800 feet boresight')

axis equal

a_500 = [x_500.' y_500.' zeros(length(x_500),1)].*mm_per_foot;
writeCsvForFusion("Equal_SNR_500.csv", a_500)
a_800 = [x_800.' y_800.' zeros(length(x_800),1)].*mm_per_foot;
writeCsvForFusion("Equal_SNR_800.csv", a_800 )

%% Plot equal SNR lines and Dilemma Zones lines

figure(4);clf;hold on;
%plot 12 foot angular resolution line
plot(x_range_at_lane_width, y_range_at_lane_width, DisplayName = '12 Foot Angular Resolution')


%plot equal SNR lines
rotate_deg = 90;
plot(R2_500.*cosd(x_FOV_shifted+rotate_deg), R2_500.*sind(x_FOV_shifted + rotate_deg), color=[1 0 0 1], LineWidth=0.5, LineStyle='-', DisplayName='Equal SNR Contour - 500 feet boresight' )
plot(R2_800.*cosd(x_FOV_shifted+rotate_deg), R2_800.*sind(x_FOV_shifted + rotate_deg), color=[0 1 0 1], LineWidth=0.5, LineStyle='-', DisplayName='Equal SNR Contour - 800 feet boresight' )

c = colorC;

dilemma_colors = [c.color01(7,:); c.color01(8,:); c.color01(9,:); c.color01(15,:)];
line_style = ["--" "-."];

for mph_i = 1:2
    for seconds_i = 2:3
        dilemma_dist = dilemma_distance(mph_i, seconds_i);
        x_dilemma_range = dilemma_dist * cosd(30:1:150);
        y_dilemma_range = dilemma_dist * sind(30:1:150);
        plot(x_dilemma_range, y_dilemma_range, color=[dilemma_colors(mph_i,:) 1], LineWidth=1, LineStyle=line_style(mod(seconds_i,2)+1), DisplayName= sprintf('Dilemma: %dmph, %2.1fsec, %3.0f feet', car_mph(mph_i), dilemma_seconds(seconds_i), dilemma_dist));
    end
end

dilemma_colors = [c.color01(16,:); c.color01(17,:); c.color01(18,:); c.color01(19,:)];
line_style = ["-" "-"];
j = 0;
for feet_i = 1:2
    for seconds_i = 2:3
        j = j + 1;
        dilemma_speed = max_dilemna_vehicle_mph_boresight(feet_i, seconds_i);
        x_dilemma_speed = (seconds_i - 2) * 10;
        y_dilemma_speed = boresight_max_dilemma_feet(feet_i);
        plot(x_dilemma_speed, y_dilemma_speed, color=[dilemma_colors(j,:) 1], Marker=".", MarkerSize=10, LineWidth=1, LineStyle="none", DisplayName= sprintf('Dilemma Speed: %2.1fmph; %2.1fsec, %3.0f feet', dilemma_speed, dilemma_seconds(seconds_i), y_dilemma_speed));
    end
end

dilemma_colors = [c.color01(20,:); c.color01(21,:); c.color01(22,:); c.color01(23,:)];
line_style = ["-" "-"];
j = 0;
for feet_i = 1:2
    for seconds_i = 2:3
        j = j + 1;
        range =edge_max_delema_feet(feet_i);
        dilemma_speed = max_dilemna_vehicle_mph_edge(feet_i, seconds_i);
        x_dilemma_speed = range * cosd(150);
        y_dilemma_speed = range * sind(150) + (seconds_i - 2) * 10;
        plot(x_dilemma_speed, y_dilemma_speed, color=[dilemma_colors(j,:) 1], Marker=".", MarkerSize=10, LineWidth=1, LineStyle="none", DisplayName= sprintf('Dilemma Speed: %2.1fmph; %2.1fsec, %3.0f feet', dilemma_speed, dilemma_seconds(seconds_i), y_dilemma_speed));
    end
end



%plot circular range lines
circ_lines_dist = [ 100  200 300 400 500 600 700 800];
for i = 1:length(circ_lines_dist)
    plot(circ_lines_dist(i)*cosd(30:1:150), circ_lines_dist(i)*sind(30:1:150), color=[0 0 0 0.2], LineWidth=0.1, LineStyle='-', HandleVisibility='off')
    text(circ_lines_dist(i)*cosd(30), circ_lines_dist(i)*sind(30), sprintf('%d', circ_lines_dist(i)) , color=[0 0 0 1])
end
plot([0 800*cosd(30)], [0 800*sind(30)], color=[0 0 0 0.2], LineWidth=0.1, LineStyle='-', HandleVisibility='off' )
plot([0 800*cosd(150)], [0 800*sind(150)], color=[0 0 0 0.2], LineWidth=0.1, LineStyle='-', HandleVisibility='off' )

%plot dilemma zones distances
mph_45_i = 1;
mph_65_i = 2;
dilemma_3p5_i = 1;
dilemma_5p5_i = 2;
dilemma_7p5_i = 3;



title('Sensor Footprint ')
xlabel('Feet')
ylabel('Feet')

legend()

axis equal


%%
a = [ 728.739940 950.377454 0.000000 704.463847 966.678090 0.000000 784.494849 901.372712 0.000000 598.576006 1037.778462 0.000000 1200.250000 0.000000 0.000000 0.000000 0.000000 240.250000 846.503065 846.871741 0.000000 514.991562 1079.355625 0.000000 920.529901 762.471056 0.000000 432.827832 1116.348655 0.000000 949.886141 729.000941 0.000000 458.198921 1107.605821 0.000000 338.757628 1148.765088 0.000000 987.643680 672.643000 0.000000 309.967997 1158.685945 0.000000 1037.151613 598.746101 0.000000 211.019670 1178.962449 0.000000 275.333164 1165.783320 0.000000 1056.628677 559.488056 0.000000 156.374544 1190.160335 0.000000 1089.838428 492.550356 0.000000 1106.832814 458.296408 0.000000 86.175116 1195.250920 0.000000 1127.931660 396.861510 0.000000 0.000000 1201.500000 0.000000 1157.758617 310.012395 0.000000 0.000000 0.000000 0.000000 1189.073112 156.386263 0.000000];
m_x = a(1:3:end);
m_y = a(2:3:end);
m_z = a(3:3:end);
figure(5);clf; hold on;
plot(m_x, m_y)
for i = 1:length(m_x)
    text(m_x(i), m_y(i), sprintf('%d', i))
end


%%
a = [3000 500 0 200 1000 0 3000 500 100 3000 500 100 200 1000 0 200 1000 100 0 0 0 3000 500 0 0 0 100 0 0 100 3000 500 0 3000 500 100 200 1000 0 0 0 0 200 1000 100 200 1000 100 0 0 0 0 0 100 200 1000 100 0 0 100 3000 500 100 0 0 0 200 1000 0 3000 500 0];
b = 10.*a;

%%






function writeCsvForFusion(fileName, p)
    % fileName - will be written in current directory
    %p -  Nx3 matrix of date containing the x, y, z points
    %p must be in millimeters
    
    %the values of p must be scaled by 10 to import into Fusion 360
     %"0.1 in excel csv file is 1mm in Fusion 360"
    a = p./10;
    writematrix(a, fileName);
end


function result = quadradicFit(x, y)
%Used the model a*x^2 + b*x + c, where a, b, and c are the unknowns
%Matrix equation: A*[a b c].' = v
    
    %consturct system matrix
    if (size(x,2) ~= 1)
        x = x.';
    end
    %x must be vertical vector
    A = [x.^2 x ones(length(x),1)];

    %Construct right-hand side veritcal vector
    if (size(y,2) ~= 1)
        y = y.';
    end
    v = y;

    %solve in least squares sense
    result = A\v;
end

function [a, h, k, b, c] = quadradicFit2(x, y, t)

%Used the model a(x - h)^2 + k, where the vertex is at (h, k).
% In this function we force h = t
% a, b, and c are also returned for the quadradic form of a*x^2 + b*x + c

%Matrix equation: A*[a b c].' = v
    
    %consturct system matrix
    if (size(x,2) ~= 1)
        x = x.';
    end
    %x must be vertical vector
    A = [x.^2 x ones(length(x),1)];

    %Construct right-hand side veritcal vector
    if (size(y,2) ~= 1)
        y = y.';
    end
    v = y;

    %solve in least squares sense
    result = A\v;

    a = result(1);
    b = result(2);
    c = result(3);
    a = a;
    h = t;
    k = c-t^2;
    
end

