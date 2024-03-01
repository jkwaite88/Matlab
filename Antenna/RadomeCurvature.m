%RadomeCurvature
fc = 61.25e9;
lambda = 3e8/fc;
lambda_mil = lambda*39370;
milsPerMeter = 39370;
N_elements = 8;
element_spacing_wavelength = 0.5;
steer_angle_degrees = 30.0;

element_position_wavelength = ((1:N_elements)*element_spacing_wavelength).';
element_position_wavelength = element_position_wavelength - mean(element_position_wavelength);
element_position_mil = element_position_wavelength*lambda_mil;
D = max(element_position_mil) - min(element_position_mil);
%elipse

thickness_mil = 65;


M = 0.6;
x1_axis = 1000*D;
y1_axis = 1*D;


x2_axis = x1_axis + thickness_mil;
y2_axis = y1_axis + thickness_mil;

x_delta = 0.0001;
N_x = 200;
x_ellipse1 = linspace(-x1_axis,x1_axis,N_x).';
x_ellipse2 = linspace(-x2_axis,x2_axis,N_x).';

y_ellipse1 = +sqrt(y1_axis^2 * (1 - x_ellipse1.^2./(x1_axis^2)));

y_ellipse2 = +sqrt(y2_axis^2 * (1 - x_ellipse2.^2./(x2_axis^2)));


%line
dy = 1;
dx = dy*tand(steer_angle_degrees);
m = dy/dx;



figure(1);clf;hold on
plot(x_ellipse1, y_ellipse1, color='b')
plot(x_ellipse2, y_ellipse2, color='r')
plot(element_position_mil.', zeros( N_elements, 1).', Color='k', LineStyle='none', Marker='square', MarkerSize=6)



%draw element rays
y1 = 0;
for i = 1:N_elements
    %find where line interstect ellipse
    x1 = element_position_mil(i);
    if abs(m) ~= Inf 
        A1 = y1_axis^2 + x1_axis^2 * m^2;
        B1 = -2 * x1_axis^2 * m * (m*x1 - y1);
        C1 = x1_axis^2*((m*x1-y1)^2 - y1_axis^2);
    
        A2 = y2_axis^2 + x2_axis^2 * m^2;
        B2 = -2 * x2_axis^2 * m * (m*x1 - y1);
        C2 = x2_axis^2*((m*x1-y1)^2 - y2_axis^2);
    
        [num_solutions1, roots1] = quadradicEquationRoots(A1, B1, C1);
        [num_solutions2, roots2] = quadradicEquationRoots(A2, B2, C2);
        if steer_angle_degrees >= 0
            root_idx = 1;
        else
            root_idx = 2;
        end
        x2 = roots1(root_idx);
        y2 = m * (x2 - x1) + y1;
        x3 = roots2(root_idx);
        y3 = m * (x3 - x1) + y1;
    else
        x2 = x1;
        x3 = x1;
        y2 = sqrt(y1_axis^2*(1-x1^2/x1_axis^2));
        y3 = sqrt(y2_axis^2*(1-x1^2/x2_axis^2));
    end
    plot([x1 x2 x3], [y1 y2 y3], color='k', marker ='.', MarkerSize=8)
    d23(i) = sqrt((x2-x3)^2 + (y2-y3)^2);
    text(x3*1.05, y3*1.05,  sprintf('%3.1f',d23(i)))
    
end

thickness_change_mil = max(d23)-thickness_mil;
thickness_change_wavelength = thickness_change_mil/lambda_mil;
str1 = sprintf('Radome: Thicknes %3.1f mil; Radius %3.1f',thickness_mil, y1_axis);
str2 = sprintf('\nEffective Thickness - min %3.1f; max %3.1f; delta %3.1f', min(d23), max(d23), (max(d23) - min(d23)));
str3 = sprintf('\nThickness change between 0%c and %3.1f%c =  %5.4f mils (%5.4f%c)', char(176), steer_angle_degrees, char(176), thickness_change_mil,thickness_change_wavelength, char(0x03BB));
str4 = sprintf('\nFrequency %4.2f GHz; Wavelength %3.2f mil; Antenna Aperature %4.1f mil; Steer angle %3.1f%c' , fc/1e9, lambda_mil, D, steer_angle_degrees, char(0x00B0));
title(strcat(str1, str2, str4))
xlabel('mil')
ylabel('mil')
axis([min(x_ellipse2)*1.05 max(x_ellipse2)*1.05 -0.01 max(y_ellipse2)*1.05])
axis equal
grid on

function [num_solutions, roots] = quadradicEquationRoots(a, b, c)
    %This function takes the coefficients of a qaudradic equation and 
    % returns the number of solutions, 0, 1, or 2
    % returns the roots, if they exist

    discriminant = b^2 - 4*a*c;
    if discriminant < 0
        num_solutions = 0;
        roots(1) = NaN;
        roots(2) = NaN;
    else
        num_solutions = 2;
        roots(1) = (-b + sqrt(discriminant))/(2*a);
        roots(2) = (-b - sqrt(discriminant))/(2*a);
    end


end