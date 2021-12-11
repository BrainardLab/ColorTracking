function [stm,S] = LMSstimulusGeneration(trlPerRun,MaxContrastLMS,frqCpd,phsDeg,ortDeg,BWoct)

% function [stm,S] = LMSstimulusGeneration(trlPerRun,MaxContrastLMS,frqCpd,phsDeg,ortDeg,BWoct)
%
% example call: 
%               expDirection = 'Experiment2-Pos'; 
%               MaxContrastLMS = LMSstimulusContrast('experiment',expDirection);
%               [stm,~] = LMSstimulusGeneration(1*size(MaxContrastLMS,1),MaxContrastLMS,1,0,0,0.932);
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

D.bgd        = [0.5, 0.5, 0.5];
D.cmpInfo = psyComputerInfo;

S = struct;
S.trlPerRun    = trlPerRun;
S.imgSzXYdeg    = repmat(2.*[2 2],[S.trlPerRun, 1]);
S.smpPerDeg     = repmat(128,     [S.trlPerRun, 1]);

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

if     strcmp(D.cmpInfo.localHostName,'jburge-marr')
    load('/Volumes/Data/BurgeLabCalibrationData/ViewSonicG220fb.mat');
    cal = cals{1};
else
    % Get Cal Data
    cal = LoadCalFile('ViewSonicG220fb',[],getpref('CorticalColorMapping','CalFolder'));
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