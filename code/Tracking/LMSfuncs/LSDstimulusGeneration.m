function [stm,S] = LSDstimulusGeneration(MaxContrastLMS,frqCpd,phsDeg,ortDeg,BWoct,cmpIntrvl,indRnd)

% function [stm,S] = LSDstimulusGeneration(trlPerRun,MaxContrastLMS,frqCpd,phsDeg,ortDeg,BWoct)
%
% example call: 
%               expDirection = 'Experiment2-Pos'; 
%               MaxContrastLMS = LMSstimulusContrast('experiment',expDirection);
%               cmpIntrvl = [ones([floor(size(MaxContrastLMS,1)/2) 1]); zeros([ceil(size(MaxContrastLMS,1)/2) 1])];
%               indRnd = randperm(size(MaxContrastLMS,1))';
%               [stm,~] = LSDstimulusGeneration(MaxContrastLMS,1,0,0,0.932,cmpIntrvl,indRnd);
%
% generates chromatic gabor stimuli for LMS experiment
%
% inputs: 
%             trlPerRun     : trials per run.  must be multiple of number of phase disparities (phsDspArcmin)
%             MaxContrastLMS: cone contrasts 
%                                   [nCnd x 3]
%             frqCpd        : frequencies for std OR left  stimulus
%                                   [ nCnd x nCmp ]
%             phsDeg        : phase of std OR left stimulus in deg
%                                   [    scalar   ] -> same     phase   for all  components
%                                   [ nCnd x nCmp ] -> unique   phase   for each component
%             ortDeg        : orientation in degrees
%                                   [    scalar   ]
%             BWoct         : frequency   bandwidth in octaves
%                                   [    scalar   ] -> same   bandwidth for all  components
%                                   [  1   x nCmp ] -> unique bandwidth for each component
%             cmpIntrvl     : comparison intervals
%             indRnd        : indices for randomizing

% DISPLAY PARAMETERS (BACKGROUND, CMPINFO)
D.bgd        = [0.5, 0.5, 0.5];
D.cmpInfo = psyComputerInfo;

S = struct;

trlPerRun = size(MaxContrastLMS,1);
% HARD-CODED STRUCT FIELDS
S.trlPerRun    = trlPerRun;
S.imgSzXYdeg    = repmat(2.*[2 2],[S.trlPerRun, 1]);
S.smpPerDeg     = repmat(128,     [S.trlPerRun, 1]);

% TURN INPUT PARAMETERS INTO STRUCT FIELDS
nCmp = size(frqCpd,2);
frqCpd     = imresize(frqCpd,[S.trlPerRun nCmp],'nearest');
phsDeg     = imresize(phsDeg,[S.trlPerRun nCmp],'nearest');
S.MaxContrastLMS = imresize(MaxContrastLMS,[S.trlPerRun nCmp*3],'nearest');
S.ortDeg      = imresize(ortDeg,[S.trlPerRun, nCmp],'nearest');
S.BWoct       = imresize(BWoct,[S.trlPerRun,1],'nearest');

S.frqCpdL = frqCpd;
S.frqCpdR = frqCpd;
S.phsDegL = phsDeg;
S.phsDegR = phsDeg;

% RANDOMIZE
S.frqCpdL = S.frqCpdL(indRnd,:);
S.frqCpdR = S.frqCpdR(indRnd,:);
S.phsDegL = S.phsDegL(indRnd,:);
S.phsDegR = S.phsDegR(indRnd,:);
S.ortDeg = S.ortDeg(indRnd,:);
S.BWoct = S.BWoct(indRnd,:);
S.MaxContrastLMS = S.MaxContrastLMS(indRnd,:);
S.indRnd = indRnd; 
S.cmpIntrvl = cmpIntrvl(indRnd);

% LOAD CALIBRATION FILES
if     strcmp(D.cmpInfo.localHostName,'jburge-marr')
    load('/Volumes/Data/BurgeLabCalibrationData/ViewSonicG220fb.mat');
    cal = cals{1};
elseif strcmp(D.cmpInfo.localHostName,'ben-Precision-7520')
    load('/home/ben/Documents/VisionScience/Data/BurgeLabCalibrationData/ViewSonicG220fb.mat');
    cal = cals{1};
else
    resourcesDir =  getpref('CorticalColorMapping','CalDataFolder');
    load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
    cal = cals{3};
end

load T_cones_ss2

% Construct a calStructOBJ from the latest calibration
[calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(cal);

% To  settings
gammaMethod = 2;
SetGammaMethod(calStructOBJ, gammaMethod, 256);
% Gamma Correct
D.correctedBgd = PrimaryToSettings(calStructOBJ,D.bgd')';

for t = 1:S.trlPerRun
    
    contrastImage = generateStimContrastProfile(S.imgSzXYdeg(t,:),S.smpPerDeg(t),S.frqCpdL(t),S.ortDeg(t),S.phsDegL(t),bandwidthOct2sigma(S.frqCpdL(t),S.BWoct(t)));
                                                                                                                                                                                                                                                                    
    SetSensorColorSpace(calStructOBJ,T_cones_ss2,S_cones_ss2);
  
    SetGammaMethod(calStructOBJ,2);
    
    backgroundExcitations = PrimaryToSensor(calStructOBJ,D.bgd');
    
    [stm(:,:,:,t),~,~] = generateChromaticGabor(calStructOBJ,contrastImage,backgroundExcitations,S.MaxContrastLMS(t,:)');
    
end

S.stmLE = stm;
S.stmRE = stm;

end