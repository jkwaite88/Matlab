function [bw, bwAngle, pkIdx] = beamwidth(mag, db_down, azimuth_angles_degrees, steerAngle, peakType)
%   INPUTS:
%   mag - magnitude array containg data
%   azimuth_angles_degrees - array containing angles corresponding to mag
%   db_down  - the width with be found this many db down from the peak
%   steerAngle - if there are several peaks nearly the same prominance of the max the peak at the steer angle will be chosen (set to 0 if not used)
%   peakType = 1: Return width of maximum peak 
%              2: Return width of peak nearest to steerAngle
        

    %overall max
    [max_mag, max_idx] = max(mag);
    
    bw = 0;
    if peakType == 1
        bw =  findWidthOfPeak(mag, db_down, max_idx, azimuth_angles_degrees);
        bwAngle = azimuth_angles_degrees(max_idx);
        pkIdx = max_idx;
    elseif peakType == 2

        [pks,pk_locs,w,p] = findpeaks(mag);
        [min_angle_dif, min_angle_dif_idx] = min(abs(azimuth_angles_degrees(pk_locs) - steerAngle));
         bw =  findWidthOfPeak(mag, db_down, pk_locs(min_angle_dif_idx), azimuth_angles_degrees);
         bwAngle = azimuth_angles_degrees(pk_locs(min_angle_dif_idx));
         pkIdx = pk_locs(min_angle_dif_idx);
    else
        error('Incorrect peakType')
    end
end


function [beamWidth] =  findWidthOfPeak(mag, db_down, indexOfPeak, angles_degrees)
%  INPUTS:
%    mag - magnitude array containg data
%    indexOfPeak - index of peak that width with be found
%    angles_degrees - array containing angles corresponding to mag
    
       
    lower_idx = indexOfPeak;
    mag_idx = indexOfPeak;
    peakMag = mag(indexOfPeak);
    while mag_idx >= 1
        delta = peakMag - mag(mag_idx);
        if delta >= db_down
            lower_idx = mag_idx;
            break;
        end
        mag_idx = mag_idx -1;
    end
    upper_idx = indexOfPeak;
    mag_idx = indexOfPeak;
    while mag_idx <= length(mag)
        delta = peakMag - mag(mag_idx);
        if delta >= db_down
            upper_idx = mag_idx;
            break;
        end
        mag_idx = mag_idx + 1;
    end
    beamWidth = angles_degrees(upper_idx) - angles_degrees(lower_idx);
end