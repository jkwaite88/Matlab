%webcamLedDetect script

cam = webcam(2);
frameDelay = 0.1;
cam.Focus = 50;

%preview(cam);
%%
img = snapshot(cam);

% Display the frame in a figure window.
image(img);
%%
figure(1)
for idx = 1:20
    img = snapshot(cam);
    frame(idx).rgb = img;
    F(idx,:,:,:) = img;
    image(frame(idx).rgb);
    pause(frameDelay)
end

%%
x = 380;
y = 229;
dx = 7;
dy = 7;


figure(2)
clf;
for idx = 1:20
       
    image(frame(idx).rgb);
    rectangle('Position', [x-dx/2, y-dy-2, dx, dy], 'EdgeColor','b')
    pause(frameDelay)
end


figure(3)
clf;
hold on;
plot(F(:,x,y,1),'r')
plot(F(:,x,y,2),'g')
plot(F(:,x,y,3),'b')
