
clear all

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

% Speficy LMS contrast vector
MaxContrastLMS = .1*[.7071 -.7071 0];


[stimPrimariesMod,coneExcitations,imgInfo] = generateChromaticGabor(calStructOBJ,backgroundPrimaries,MaxContrastLMS', 0, 'stimHalfSize', 60, 'fx', 6, 'sigma',.14);

% Make the background
for ii = 1: length(backgroundPrimaries)
    background(ii,:) =  backgroundPrimaries(ii) .* ones([1 imgInfo.rows*imgInfo.cols]);
end


theGabor =  stimPrimariesMod + background;

% To  settings
gammaMethod = 1;
SetGammaMethod(calStructOBJ, gammaMethod, 1024);
settings = PrimaryToSettings(calStructOBJ,theGabor);

%  Back to image format
chromaticGabor = reshape(settings', [imgInfo.rows  imgInfo.cols 3]);


hFig = figure; clf;
set(hFig, 'Position', [10 10  400 500]);
image(chromaticGabor); axis 'image'; axis 'ij'
title('input image');
set(gca, 'XColor', 'none', 'YColor', 'none', 'XTick', [], 'YTick', [], 'FontSize', 14);
box off
bk = PrimaryToSettings(calStructOBJ,backgroundPrimaries);
set(hFig, 'Color', bk);




