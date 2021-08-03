%this demo will create additive gabor patches in different color direction
%with different temporal phase

colorDir_1 = 45;
colorDir_2 =  -2;

% time base
Fs = 60;                  % samples per second
dt = 1/Fs;                % seconds per sample
StopTime = 1;             % seconds
timebase = (0:dt:StopTime-dt)';  % seconds
%Sine wave:
Fc = 1;                     % hertz
% phase 
p1 = deg2rad(0);
p2 = deg2rad(50);

A1 = cos(2*pi*Fc*timebase +p1);
A2 = cos(2*pi*Fc*timebase +p2);


% get unit vectors in the two color directions
[x1,y1] = pol2cart(deg2rad(colorDir_1),1);

[x2,y2] = pol2cart(deg2rad(colorDir_2),1);

xMod_1 = A1*x1; 
yMod_1 = A1*y1;
xMod_2 = A2*x2; 
yMod_2 = A2*y2;

figure;hold on 
scatter(xMod_1,yMod_1)
scatter(xMod_2,yMod_2)

xComb = xMod_1 + xMod_2;
yComb = yMod_1 + yMod_2;

figure;hold on 
sz = 25;
c = linspace(1,10,length(xComb));
scatter(xComb,yComb,sz,c,'filled')
axis square
ylim([-2,2])
xlim([-2,2])
% 
% G1 = gabor(2,0)
% imshow(real(G1.SpatialKernel),[]);