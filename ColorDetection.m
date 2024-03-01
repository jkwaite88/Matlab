% color detection

blue = [0 0 255];
pixel = [10 10 200];
ang_thres = 25; % degrees. You should change this to suit your needs
ang = acosd(dot(blue/norm(blue),pixel/norm(pixel)));
mag_thres = 64; % You should change this to suit your needs
mag = norm(pixel);
isBlue = ang <= ang_thres & mag >= mag_thres; % Apply both thresholds