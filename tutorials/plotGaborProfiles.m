% plot L M and S profiles

% Determine location of resourcesDir
[codeDir,~] = fileparts(which(mfilename));
[rootDir,~] = fileparts(codeDir);
resourcesDir = sprintf('%s/calFiles',rootDir);

% Select the calibration file for a particular display (here a ViewSonic display)
displayCalFileName = sprintf('%s/ViewSonicProbe', resourcesDir);

% Load the calibration file
load(displayCalFileName, 'cals');

% Construct a calStructOBJ from the latest calibration
[calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(cals{end});

% Speficy primary values for background
backgroundPrimaries = [.3 .3 .3]';

% specify the gabor orientation
orientation = 0;

%% GABOR 1
% Speficy LMS contrast vector
MaxContrastLMS = [0.3 0.3 0.3];

% generate the modualtion around the background
[stimPrimariesMod1,imgInfo] = generateChromaticGabor(calStructOBJ,backgroundPrimaries,MaxContrastLMS, orientation,'phase',0);

% Make the background
for ii = 1: length(backgroundPrimaries)
    background(ii,:) =  backgroundPrimaries(ii) .* ones([1 imgInfo.rows*imgInfo.cols]);
end

%% Add GABOR 2
% Speficy LMS contrast vector
MaxContrastLMS = [0.1 -0.1 0.9];
gaborPhase = 190;

[stimPrimariesMod2,imgInfo] = generateChromaticGabor(calStructOBJ,backgroundPrimaries,MaxContrastLMS, orientation,'phase',gaborPhase);

stimPrimaries = stimPrimariesMod1 + stimPrimariesMod2 + background;

% To  settings
gammaMethod = 1;
SetGammaMethod(calStructOBJ, gammaMethod, 1024);
settings = PrimaryToSettings(calStructOBJ,stimPrimaries);

%  Back to image format
gaborImage = reshape(settings', [imgInfo.rows  imgInfo.cols 3]);


% reshape the modulations
theModulation = stimPrimariesMod1 + stimPrimariesMod2;
%  Back to image format
theModulationImage = reshape(theModulation', [imgInfo.rows  imgInfo.cols 3]);




subplot(2,4,1)
image(gaborImage); axis 'image'; axis 'ij'
%title(sprintf('LMS cone contrast image\n(%2.2f, %2.2f, %2.2f)', stimLMScontrast(1), stimLMScontrast(2), stimLMScontrast(3)));
set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
box off

imgSize = size(gaborImage);
subplot(2,4,2)
sliceR = gaborImage(round(imgSize(1)/2),:,1);
plot(sliceR,'r')
title('R Primary');

subplot(2,4,3)
sliceR = gaborImage(round(imgSize(1)/2),:,2);
plot(sliceR,'g')
title('G Primary');

subplot(2,4,4)
sliceR = gaborImage(round(imgSize(1)/2),:,3);
plot(sliceR,'b')
title('B Primary');


imgSize = size(theModulationImage);
subplot(2,4,5)
sliceR = theModulationImage(round(imgSize(1)/2),:,1);
plot(sliceR,'r')
title('L Contrast Modulation');

subplot(2,4,6)
sliceR = theModulationImage(round(imgSize(1)/2),:,2);
plot(sliceR,'g')
title('M Contrast Modulation');

subplot(2,4,7)
sliceR = theModulationImage(round(imgSize(1)/2),:,3);
plot(sliceR,'b')
title('S Contrast Modulation');
