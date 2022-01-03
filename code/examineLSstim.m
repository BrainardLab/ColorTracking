function [directions, contrasts] = examineLSstim()

% function [directions, contrasts] = examineLSstim()
%
% interactive function for examining different color directions. It will
% prompt you in the command line for a color direction and contrast, then
% display the stimulus. To quit, enter 999 for either of the prompts. 
%
% outputs:
%          directions: all requested directions
%          contrasts : all requested contrasts

D.computer   = computer;
D.cmpInfo    = psyComputerInfo();
D.stereoMode = 0;

%%%%%%%%%%%%%%%%%%%%
% SET COLOR VALUES %
%%%%%%%%%%%%%%%%%%%%
D.blk        = 0.0;
D.bgd        = [0.5, 0.5, 0.5]; % 128; % 0.5000;
D.wht        = 1.0; % 255; % 1.0000;

bSKIPSYNCTEST = 0;
bDEBUG = 0;
imgSzXYdeg = [4 4];

%% -------------- SET UP PSYCHTOOLBOX --------------
% PTB-3 CORRECTLY INSTALLED AND FUNCTIONAL
AssertOpenGL;

% SETUP PSYCHTOOLBOX
psyPTBsetup(bSKIPSYNCTEST,bDEBUG); % call must come before psyPTBopenWindow

% LOAD MONITOR CALIBRATION DATA (GAMMA DATA)
[D.cal,D.gamPix,D.gamFnc,D.gamInv] = psyLoadCalibrationData(D.cmpInfo.localHostName);

% SETUP GAMMA CORRECTION OPTIONS
D.gammaCorrectionType = 'LookupTable';      % move to top of experiment file
psyPTBgammaCorrectSetup(D.gammaCorrectionType);

%%%%%%%%%%%%%%%%%%%
% OPEN PTB WINDOW %
%%%%%%%%%%%%%%%%%%%

% -------- INSTEAD OF psyPTBopenWindow -------- 

if ~exist('stereoMode','var') || isempty(stereoMode),
    stereoMode = 0;
    disp(['psyPTBopenWindow: setting D.stereoMode to ' num2str(stereoMode)])
end

if     strcmp(D.cmpInfo.localHostName,'jburge-marr')
    load('/Volumes/Data/BurgeLabCalibrationData/ViewSonicG220fb.mat');
    cal = cals{1};
elseif strcmp(D.cmpInfo.localHostName,'ben-Precision-7520')
    load('/home/ben/Documents/VisionScience/Data/BurgeLabCalibrationData/ViewSonicG220fb.mat');
    cal = cals{1};
else
    % Get Cal Data
    cal = LoadCalFile('ViewSonicG220fb',[],getpref('CorticalColorMapping','CalFolder'));
end

% Construct a calStructOBJ from the latest calibration
[calStructOBJ, ~] = ObjectToHandleCalOrCalStruct(cal);

% To  settings
gammaMethod = 2;
SetGammaMethod(calStructOBJ, gammaMethod, 256);
% Gamma Correct
D.correctedBgd = PrimaryToSettings(calStructOBJ,D.bgd')';

% SET STEREO MODE TO DISPLAY STRUCT
D.stereoMode = stereoMode;
% DISPLAY SCREEN WITH MAX ID FOR EXPERIMENT
D.sid = max(Screen('Screens')); % SCREEN, ONSCREEN WINDOW WITH GRAY BACKGROUND
% OPEN WINDOW
[D.wdwPtr, D.wdwXYpix]  = PsychImaging('OpenWindow', D.sid, D.correctedBgd, [],[], [], D.stereoMode);
% SET DEFAULT TEXT
Screen('TextSize',D.wdwPtr,24);
% FLIP SCREEN
Screen('Flip',D.wdwPtr);

% -------- END -------- 

% SET BLENDING OPTIONS
D         = psyPTBalphaBlending(D);           % requires D.wdwPtr
% DISPLAY PARAMETERS (ifi,
D         = psyPTBdisplayParameters(D);       % requires D.wdwPtr... PHASE OUT CALL: D.bitsOut = Screen('PixelSize',D.wdwPtr);
% DON'T GAMMA CORRECT IN PSYCHTOOLBOX
D.gamInv = linspace(0,1,1024)';
% CORRECT GAMMA
D         = psyPTBgammaCorrect(D);

% SET STIMULUS PARAMETERS
D.plyXYpix = bsxfun(@times,imgSzXYdeg, D.pixPerDegXY);
% D.plyXYpix = bsxfun(@times,S.imgSzXYdeg, D.pixPerDegXY-1);

% BUILD DESTINATION RECTANGLE IN MIDDLE OF DISPLAY
D.plySqrPix    = CenterRect([0 0 D.plyXYpix(1, 1) D.plyXYpix(1, 2)], D.wdwXYpix);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXATION/REFERENCE CROSS HAIRS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fixStmSzXYdeg = [7.5 60]./60;
fixStmSzXYpix = fixStmSzXYdeg.*D.pixPerDegXY;
Apix          = 2.5.*D.pixPerDegXY(1);
% TO DO: IMPROVE FIXATION CROSS
D.fixStm=psyFixStm_CrossHairs([D.wdwXYpix(3)/2 D.wdwXYpix(4)/2],2.*[Apix(1) fixStmSzXYpix(1, 2)], [fixStmSzXYpix(1, 1) fixStmSzXYpix(1, 2)], '|||||||||||||',[],0,0.50);
[fPosX,fPosY] = RectCenter(D.wdwXYpix);
% D.fixStm(:,end+1) = [fPosX-3 fPosY-3 fPosX+3 fPosY+3]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRESENT STIMULUS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

directions = [];
contrasts = [];

Screen('FillRect', D.wdwPtr, D.correctedBgd);
Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht], D.fixStm);
Screen('Flip',D.wdwPtr);

while 1
   promptDir = 'Enter color direction: ';
   promptContrast = 'Enter contrast: ';
   directionLS = input(promptDir);
   if directionLS>=999
      Screen('CloseAll');
      break;
   end
   contrastLS = input(promptContrast);
   if directionLS>=999
      Screen('CloseAll');
      break;
   end
   directions(end+1) = directionLS;
   contrasts(end+1) = contrastLS;
   Screen('TextSize', D.wdwPtr, 20);
   Screen('DrawText',D.wdwPtr, ['Generating stimuli...'], ...
           0.6.*[fPosX], 0.8.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
   Screen('Flip', D.wdwPtr);
   MaxContrastLMS = contrastLS.*[1/sqrt(tand(directionLS)^2+1) 0 tand(directionLS)/sqrt(tand(directionLS)^2+1)];
   [stm,~] = LMSstimulusGeneration(1,MaxContrastLMS,1,0,0,0.932);
   texCmpImg = Screen('MakeTexture', D.wdwPtr, stm, [], [], 2);
   Screen('DrawTexture', D.wdwPtr, texCmpImg, [],D.plySqrPix);
   Screen('DrawingFinished', D.wdwPtr);
   Screen('Flip', D.wdwPtr);
end

end