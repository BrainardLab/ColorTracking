clear all
close all

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
MaxContrastLMS = [.4 .4 .4];

% generate the modualtion around the background
[stimPrimariesMod1,imgInfo] = generateChromaticGabor(calStructOBJ,backgroundPrimaries,MaxContrastLMS, orientation,'phase',0);

% Make the background
for ii = 1: length(backgroundPrimaries)
    background(ii,:) =  backgroundPrimaries(ii) .* ones([1 imgInfo.rows*imgInfo.cols]);
end

%% Add GABOR 2
% Speficy LMS contrast vector
MaxContrastLMS = [.1 -.1 0];

% set the contrast steps
contrastSteps = 0.25;
contrastsRatio = 0:contrastSteps:1;

% set the phase steps
phaseSteps = 45;
phases = 0:phaseSteps:360-phaseSteps;

counter = 1;


% set up contrast flicker
% time base
Fs = 60;                  % samples per second
dt = 1/Fs;                % seconds per sample
StopTime = 4;             % seconds
timebase = (0:dt:StopTime-dt)';  % seconds
%Sine wave:
Fc = 1;                     % hertz

contrastMod = cos(2*pi*Fc*timebase);

contrastMod = (contrastMod + abs(min(contrastMod)));
contrastMod = contrastMod./max(contrastMod);
vidfile = VideoWriter('gaborStim2.mp4','MPEG-4');
vidfile.FrameRate = Fs;
open(vidfile);
for mm = 1:length(contrastMod)
    counter = 1;
    for jj = 1:length(phases)
        
        [stimPrimariesMod2,imgInfo] = generateChromaticGabor(calStructOBJ,backgroundPrimaries,MaxContrastLMS, orientation,'phase',phases(jj));
        
        for kk = 1:length(contrastsRatio)
            
            stimPrimaries = contrastMod(mm).*((contrastsRatio(kk)*stimPrimariesMod1) + ((1-contrastsRatio(kk)) * stimPrimariesMod2)) + background;
            
            % To  settings
            gammaMethod = 1;
            SetGammaMethod(calStructOBJ, gammaMethod, 1024);
            settings = PrimaryToSettings(calStructOBJ,stimPrimaries);
            
            %  Back to image format
            mask = reshape(settings', [imgInfo.rows  imgInfo.cols 3]);
            gabors{counter} = mask;
            counter = counter + 1;
        end
    end
    
    A = montage(gabors,'Size',[length(phases) length(contrastsRatio)]);
    writeVideo(vidfile, A.CData);
    
end
close(vidfile)