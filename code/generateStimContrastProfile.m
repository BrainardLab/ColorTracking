function [contrastImage, sRGBimage] = generateStimContrastProfile(imgSzXYdeg,smpPerDeg,fx,angle,phase,sigma,varargin)

p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('angle',@isnumeric);
p.addRequired('sigma', @isnumeric);
p.addRequired('fx', @isnumeric);
p.addRequired('phase', @isnumeric);
p.addRequired('imgSzXYdeg', @isnumeric);
p.addRequired('smpPerDeg', @isnumeric);
p.parse(angle,sigma,fx,phase,imgSzXYdeg,smpPerDeg, varargin{:});

% SIZE OF IMAGE IN SAMPLES
imgSzXYsmp = imgSzXYdeg.*smpPerDeg;
 
% 1D POSITION AND FREQUENCY SAMPLES
xDeg  = smpPos(smpPerDeg,imgSzXYsmp(1));
yDeg  = smpPos(smpPerDeg,imgSzXYsmp(2));
% 
% % 2D POSITIONS IN DEG
[meshX,meshY] = meshgrid(xDeg,yDeg);

% Generate the Gabor spatial contrast profile of the stimulus
sineWavePattern = sin(2*pi*(fx * cosd(angle)*meshX + fx*sind(angle)*meshY) + deg2rad(phase));
gaussPattern = exp(-((meshX).^2+(meshY).^2)/(2*sigma^2));
contrastImage = sineWavePattern.* gaussPattern;

% Generate an sRGB image
sRGBimage = repmat(lin2rgb(contrastImage),[1,1,3]);

end