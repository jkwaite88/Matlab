%rcs of trihedral corner reflector

f = 79e9;
c = 3e8;
a_m = .105; %length of corner reflector edge from corner to point

lambda_m = c/f;

sigma = 4*pi*a_m^4/(3*lambda_m^2);


sprintf('RCS of tetrahedral corner reflecet with side length of %4.1f meters: %4.1f m^2', a_m, sigma')
%['RCS of tetrahedral corner reflecet with side length of ', num2str(a_m), 'meters: ', num2str(sigma),' m^{2}']
