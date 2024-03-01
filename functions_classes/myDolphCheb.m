% w = myDolphCheb(N,a)
%
% Dolph-Chebyshev window. a is a value that represents a =
% 20*log10(peakVal/sidelobeVal). In other words if we want our sidelobes x dB down
% from the main lobe then set a = x;

function w = myDolphCheb(N,a)



	%=============================================================
	% Time Sample Method   ___
	%				1	-		  \-M                                       -
	% w(n) =	  --- |1 + 2r / chebyPoly(xo*cos(thetaM/2))*cos(m*thetaN)|
	%           N  -      /__m=1                                     -
	%=============================================================

	r = 1/(10^(a/20));
	M = (N-1)/2;
	xo = cosh(acosh(1/r)/(2*M));

	for (n = -M:M)
		thetaN = 2*pi*n/(N);
		
		thetaM = 2*pi*[1:M]/(N);
		
		ms = chebPoly(2*M,xo*cos(thetaM/2)) .* cos([1:M]*thetaN);

		w(n+M+1) = 2 * r * sum(ms);
		

		w(n+M+1) = (1 + w(n+M+1))/(N);
		
	end %== End for each tap
	
	%== This creates N + 1 samples. So to get back to N samples we take
	%== out the middle sample to preserve symetrys
	w = w'/max(w);


