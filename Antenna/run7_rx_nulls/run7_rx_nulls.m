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
%Number of radar chips with 3 transmit and 4 receive channels
N_chips = 2 ;

% Number of elements
N_tx = 3*N_chips;
N_rx = 4*N_chips ;

% Spacing (in wavelengths)
k0 = 2*pi;
d_rx = 0.5;
%d_tx = d_rx*N_rx;
d_tx = 3 ;

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
phi0_deg_range = [0:1:90];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
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

  % Get grating lobe directions, which need to be cut off by the Rx beam.
  mu0 = sind(phi0_deg);
  n = [ceil(-d_tx*(1+mu0)):floor(d_tx*(1-mu0))];
  mu = sind(phi0_deg) + n/d_tx;
  phi_gl_deg = asind(mu);
  
  % Plot the tx pattern
  %figure(1);
  %patt_tx = w_tx.'*A_tx; 
  %p = plot(phi_deg, 20*log10(abs(patt_tx)), phi_gl_deg, zeros(size(phi_gl_deg)), 'x');

  % Remove the grating lobe closest to the desired main-beam direction
  [val idx] = min(abs(phi_gl_deg - phi0_deg));
  phi_gl_deg = phi_gl_deg([[1:idx-1] [idx+1:length(phi_gl_deg)]]);
  
  % Can only put N_rx-1 nulls, so reduce list to those whose angles are as far
  % from endfire as possible.
  fprintf('Phi0 = %d deg.  Grating lobes to cancel = %d\n', phi0_deg, length(phi_gl_deg));
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
  a_main_rx = exp(j*k0*x_rx*sind(phi0_deg));
  alpha = V_null'*conj(a_main_rx)/sqrt(a_main_rx'*a_main_rx);
  
  w_rx = V_null*alpha;
  
  % Apply quantization
  w_tx = quant_weight(w_tx, tx_res_amp_dB, tx_res_phs_deg);

  patt_tx = w_tx.'*A_tx; 
  patt_rx = w_rx.'*A_rx; 

  if (norm_patt),
    patt_tx = patt_tx/max(abs(patt_tx));
    patt_rx = patt_rx/max(abs(patt_rx));
  end

  patt = patt_tx.*patt_rx;

  % Plot patterns
  %figure(2);
  p = plot(phi_deg, 20*log10(abs(patt_tx)), phi_deg, 20*log10(abs(patt_rx)), ...
           phi_deg, 20*log10(abs(patt)), 'k');
  legend('Transmit', 'Receive', 'Joint');
  set(p(3), 'LineWidth', 2);
  grid on;
  ylim([-50 0]);
  
  pause;

end



