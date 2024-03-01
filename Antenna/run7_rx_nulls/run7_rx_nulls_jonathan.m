% Joint transmit/receive beamforming.  See if MIMO-type array 
% is able to cut off grating lobes like we expect.  
%
% We do the usual case of narrow receive spacing and
% wide transmit spacing.
%
% In this example, we quantize the transmit weights since
% we assume we are doing real analog Tx beamforming.
% Receive weights can be arbitrary since they are set
% digitally.

norm_patt = 1;

% Number of elements
N_radarChips = 4;
N_tx = 3*N_radarChips;
N_rx = 4*N_radarChips;

% Spacing (in wavelengths)
k0 = 2*pi;
d_rx = 0.5;
%d_tx = d_rx*N_rx;
d_tx = 6.5;

% Chebychev weights
sll_tx = 40; 

% Sample angles
N_phi = 1801;
phi1_deg = -90;
phi2_deg = +90;

% Resolution of Tx phase shifter and attenuator
% Ideal
tx_res_amp_dB = 3;
tx_res_phs_deg = 5.625 ;
   
% Steering angle range
phi0_deg_range = [-10.8:2:0];


Field_of_view_degrees = 60; 
Half_Field_of_view_degrees = Field_of_view_degrees/2; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
colors = colorC;
figNum = 2;
figure(figNum);
clf;
plot_patch_flag = 1;
numberOfRxSteerAngles = 0;
pk_angles_rx_all = [];

% Get angle samples
phi_deg = [0:N_phi-1]/(N_phi-1)*(phi2_deg - phi1_deg) + phi1_deg;

% Antenna positions
x_rx = [0:N_rx-1].'*d_rx;
x_tx = [0:N_tx-1].'*d_tx;

% Get steering vectors.  Assume antennas along the x axis
% and that the boresight direction is zero degrees (along +y axis).
A_tx = exp(j*k0*x_tx*sind(phi_deg));
A_rx = exp(j*k0*x_rx*sind(phi_deg));

for phi0_i = 1:length(phi0_deg_range),
  % Steering direction
  phi0_deg = phi0_deg_range(phi0_i);

  % Get antenna weights
  w_tx = chebwin(N_tx, sll_tx).*exp(-j*k0*x_tx*sind(phi0_deg));

  % Apply quantization
  w_tx = quant_weight(w_tx, tx_res_amp_dB, tx_res_phs_deg);
    
  patt_tx = w_tx.'*A_tx; 
  if (norm_patt),
    patt_tx = patt_tx/max(abs(patt_tx)); 
  end

  %find all tx lobes inside field of view
  [pk_mag, pk_angle] = find_peaks_in_FOV(20*log10(abs(patt_tx)), phi_deg, Half_Field_of_view_degrees);
  numberOfRxSteerAngles = numberOfRxSteerAngles + length(pk_mag);
  pk_angles_rx_all(phi0_i,:) = pk_angle;
  for lobe_i = 1:length(pk_mag)  
  % Get grating lobe directions, which need to be cut off by the Rx beam.
      phi0_rx_deg = pk_angle(lobe_i);
      mu0 = sind(phi0_rx_deg);
      n = [ceil(-d_tx*(1+mu0)):floor(d_tx*(1-mu0))];
      mu = sind(phi0_rx_deg) + n/d_tx;
      phi_gl_deg = asind(mu);
      
      % Plot the tx pattern
      %figure(1);
      %patt_tx = w_tx.'*A_tx; 
      %p = plot(phi_deg, 20*log10(abs(patt_tx)), phi_gl_deg, zeros(size(phi_gl_deg)), 'x');
    
      % Remove the grating lobe closest to the desired main-beam direction
      [val idx] = min(abs(phi_gl_deg - phi0_rx_deg));
      phi_gl_deg = phi_gl_deg([[1:idx-1] [idx+1:length(phi_gl_deg)]]);
      
      % Can only put N_rx-1 nulls, so reduce list to those whose angles are as far
      % from endfire as possible.
      fprintf('Phi0 = %3.1f deg.; Phi0_rx= %3.1f  Grating lobes to cancel = %d\n', phi0_deg, phi0_rx_deg, length(phi_gl_deg));
      while (length(phi_gl_deg) >= N_rx),
        [val idx] = max(abs(phi_gl_deg));
        phi_gl_deg = phi_gl_deg([[1:idx-1] [idx+1:length(phi_gl_deg)]]);
      end
      
      % We will try to put nulls in the Tx grating lobe directions.  Get Rx 
      % steering vectors for those directions.  Get antennas across the columns
      % and steering direction down the rows.
      A_rx1 = exp(j*k0*x_rx*sind(phi_gl_deg)).';
      
      % The SVD of A_rx tells us the space of excitations (the null space)
      % where we have nulls in the desired (grating lobe) directions.
      [U S V] = svd(A_rx1);
      idx_null = [length(phi_gl_deg)+1:N_rx];
      V_null = V(:, idx_null);
      
      % Use remaining DOFs to steer power in main beam direction.
      a_main_rx = exp(j*k0*x_rx*sind(phi0_rx_deg));
      alpha = V_null'*conj(a_main_rx)/sqrt(a_main_rx'*a_main_rx);
      
      w_rx = V_null*alpha;
      
    
      
      patt_rx = w_rx.'*A_rx; 
      if (norm_patt),
        patt_rx = patt_rx/max(abs(patt_rx));
      end
    
      patt = patt_tx.*patt_rx;
      [bw_patt, bwAngle_patt, pkIdx] = beamwidth(20*log10(abs(patt)), 3, phi_deg, phi0_rx_deg, 2);
        
      % Plot patterns
      figure(figNum);
      subplot(2,1,1)
      p1 = plot(phi_deg, 20*log10(abs(patt_tx)), phi_deg, 20*log10(abs(patt_rx)), ...
               phi_deg, 20*log10(abs(patt)), 'k');
      set(p1(3), 'LineWidth', 2);
      hold on;
      plot(bwAngle_patt, 20*log10(abs(patt(pkIdx))),'r.')
      patch('Faces',[ 1 2 3 4] ,'Vertices', [-90 0; -90 -100; -Half_Field_of_view_degrees -100; -Half_Field_of_view_degrees 0],'FaceColor',[.7 .7 .7], 'FaceAlpha', 0.3)
      patch('Faces',[ 1 2 3 4] ,'Vertices', [90 0; 90 -100; Half_Field_of_view_degrees -100; Half_Field_of_view_degrees 0],'FaceColor',[.7 .7 .7], 'FaceAlpha', 0.3)
      hold off;
      title(sprintf('Tx Steer Angle Degrees: %3.1f;  Rx Steer Angle %3.1f\nJoint Beamwidth: %4.2f', phi0_deg, phi0_rx_deg, bw_patt))
      grid on;
      legend('Transmit', 'Receive', 'Joint');
      ylim([-50 0]);

      sp2 = subplot(2,1,2);
        
      p2 = plot(phi_deg, 20*log10(abs(patt)), 'color', colors.color01(phi0_i,:));
      if plot_patch_flag
        patch('Faces',[ 1 2 3 4] ,'Vertices', [-90 0; -90 -100; -Half_Field_of_view_degrees -100; -Half_Field_of_view_degrees 0],'FaceColor',[.7 .7 .7], 'FaceAlpha', 0.3)
        patch('Faces',[ 1 2 3 4] ,'Vertices', [90 0; 90 -100; Half_Field_of_view_degrees -100; Half_Field_of_view_degrees 0],'FaceColor',[.7 .7 .7], 'FaceAlpha', 0.3)
        plot_patch_flag = 0;
      end
      if (lobe_i == 1)
        h_plot_legend(phi0_i) = p2;  
        legned_strings{phi0_i} = sprintf('Tx Steer Angle: %3.1f', phi0_deg);
      end
      
      if (phi0_i == 1) && (lobe_i == 1)
          hold on;
      end
      grid on;
      ylim([-50 0]);
     pause;
  end
  %pause;
end
rx_angles = sort(pk_angles_rx_all(:));
str1 = sprintf('Number of Tx Steer Angles: %d\nNumber of Rx Steer Angles: %d\n', length(phi0_deg_range), numberOfRxSteerAngles);
str2 = num2str(rx_angles', ' %3.1f');
title([str1, 'Rx Steer Angles: ',str2])
legend(sp2, h_plot_legend, legned_strings)
  

function [pk_mag, pk_angle] = find_peaks_in_FOV(mag, angles, half_FOV)
    pk_max = max(mag);
    [pks,pk_locs,w,p] = findpeaks(mag);
    pk_locs_idx_FOV = find( (angles(pk_locs) >= -half_FOV) & (angles(pk_locs) <= half_FOV) & ( abs(pk_max - mag(pk_locs)) <= 10)); 
    pk_mag = mag(pk_locs(pk_locs_idx_FOV));
    pk_angle = angles(pk_locs(pk_locs_idx_FOV));
end
