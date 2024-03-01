%antenna spinning calibration
%********************
%we really want to have mulitple antenna offsets instead of multiple target
%ranges (although that migh be interesting, too)

target_range_m = [5 10 20 30 40];
target_position_m = [zeros(size(target_range_m)); target_range_m].';
antenna_offset_m = [0 0.001 0.003 0.020].';
antenna_position_m = [zeros(size(antenna_offset_m)) antenna_offset_m]; % [x, y]

element_num = 8;

element_spacing_wavelengths = 0.5;

antennaArrayWidth_wavelengths =     element_spacing_wavelengths * (element_num - 1);

frequency_hz = 60.5e9;
c = 3e8;
lambda_m = c/frequency_hz;

antennaArrayWidth_m = antennaArrayWidth_wavelengths * lambda_m;

%rotate antenna

theta_deg = linspace(-90, 90, 11).';

element_position_o_m = ((1:element_num) * element_spacing_wavelengths).';
element_position_o_m = (element_position_o_m - mean(element_position_o_m))*lambda_m;
element_position_o_m = [element_position_o_m zeros(size(element_position_o_m))];
element_position_offset_o_m = zeros(length(antenna_offset_m),element_num,2);
element_position_m = zeros(length(antenna_offset_m), length(theta_deg), element_num, 2);
for offset_i = 1:length(antenna_offset_m)
    element_position_offset_o_m(offset_i,:,:) = element_position_o_m + antenna_position_m(offset_i,:);
    element_position_m(offset_i,:,:,:) = rotateAboutPoint(squeeze(element_position_offset_o_m(offset_i,:,:)), [0, 0], theta_deg);

end




element_distance_m = zeros(length(target_range_m),length(antenna_offset_m), length(theta_deg),element_num);

for target_i = 1:length(target_range_m)
    for offset_i = 1:length(antenna_offset_m)
        for theta_i = 1:length(theta_deg)
            element_distance_m(target_i, offset_i, theta_i,:) = sqrt( (target_position_m(target_i,1)-element_position_m(offset_i, theta_i,:,1)).^2 + (target_position_m(target_i,2)-element_position_m(offset_i, theta_i,:,2)).^2);
        end 
    end
end

myColor = colorC;
colororder(myColor.color01)
fh1 = figure(1);clf;
subplot(1,2,1)
ax1 = gca;
grid(ax1,"on")
subplot(1,2,2)
ax2 = gca;
hold(ax2,"on")

for offset_i = 1:length(antenna_offset_m)
    x_limit =  max(abs(element_position_m(:,:,:,1)),[],"all");
    ymin = min(element_position_m(:,:,:,2),[],"all");
    ymax = max(element_position_m(:,:,:,2),[],"all");
    for i = 1:length(theta_deg)
        figure(fh1)
        ph1 = plot(ax1, squeeze(element_position_m(offset_i,i,:,1)), squeeze(element_position_m(offset_i,i,:,2)), color='b', marker='.', LineStyle='none');
        axis(ax1,[-x_limit x_limit ymin_limit (ymin + 2*x_limit)])
        grid(ax1,"on")
        axis(ax1,'square')
        %axis(ax1,"equal")
       
        %subplot 2
        for j = 1:length(target_range_m)
            if j == 2
                hold(ax2,"on")
            end
            ph2_1 = plot(ax2,target_position_m(j,1),target_position_m(j,2), color=myColor.color01(j,:), marker='.', LineStyle='none');
        end
        ph2_2 = plot(ax2, squeeze(element_position_m(offset_i,i,:,1)), squeeze(element_position_m(offset_i,i,:,2)), color='b', marker='.', LineStyle='none');
        axis(ax2, [-x_limit x_limit, ymin_limit, inf])
        hold(ax2,"off")
        pause(0.1)
    end
end
%%
target_i = 4;

fh2 = figure(2);
th1 = tiledlayout(1,length(antenna_offset_m));
for offset_i = 1:length(antenna_offset_m)
    nexttile
    hold on
    for element_i = 1:element_num
        plot(squeeze(element_distance_m(target_i,offset_i,:,element_i)), color= myColor.color01(element_i,:))
    end
    title(sprintf("Antenna Offset: %3.1f (mm)", antenna_offset_m(offset_i)*1000))
end
title(th1, sprintf("Target Range: %3.1f (m)",target_range_m(target_i)))
ylabel(th1, sprintf("Distance (m)"))

function outCoord = rotateAboutPoint(inCoord, point, theta_deg)
%Rotate 2-d coordinates around point by theta degrees
%INPUT: inCoord: a nx2 matrix of x, y points
%       point: a 1x2  coordinate of the point to rotate around
%       theta_deg: a mx1 vector of degrees by which inCoord will be rotated
%OUTPUT:
%       outCoord: an mxnx2 matrix of rotated points

    outCoord =  zeros(length(theta_deg),size(inCoord,1), size(inCoord, 2));
        
    s = sind(theta_deg);
    c = cosd(theta_deg);
    x = inCoord(:,1).' - point(1,1);
    y = inCoord(:,2).' - point(1,2);

    outCoord(:,:,1) = c*x - s*y;
    outCoord(:,:,2) = s*x + c*y;

    outCoord(:,:,1) = outCoord(:,:,1) + point(1,1);
    outCoord(:,:,2) = outCoord(:,:,2) + point(1,2);
end