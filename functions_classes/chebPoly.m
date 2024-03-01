%==============================================================================	
% p = chebPoly(N,a)
%
% Chebyshev polynomial where ChebPoly(N,a) = cos(N*acos(a)) if abs(a) <= 1
%==============================================================================
function p = chebPoly(N,a)

	index = find(a <= 0);
	p(index) = cos(N * acos(a(index)));
	
	index = find(a > 0);
	p(index) = cosh(N * acosh(a(index)));
	
	p = real(p);
	
