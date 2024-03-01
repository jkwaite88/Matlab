function [w_out] = quant_weight(w_in, res_amp_db, res_phs_deg);

% [w_out] = quant_weight(w_in, res_amp_db, res_phs_deg);
%
% Quantizes weights.

if (res_amp_db == 0),
  w_amp1 = abs(w_in);
else
  w_amp_db = 20*log10(abs(w_in));
  w_amp1 = 10.^(round(w_amp_db/res_amp_db)*res_amp_db/20);
end

w_phs_deg = angle(w_in)*180/pi;
if (res_phs_deg == 0),
  w_phs_deg1 = w_phs_deg;
else  
  w_phs_deg1 = round(w_phs_deg/res_phs_deg)*res_phs_deg;
end

w_out = w_amp1.*exp(j*w_phs_deg1*pi/180);
