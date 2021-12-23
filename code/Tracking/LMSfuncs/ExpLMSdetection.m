function [S D] = ExpLMSdetection(S,subjName,IPDmm,stmType, mtnType, bUseFeedback, bSKIPSYNCTEST, bDEBUG)

% function [S D] = ExpLMSdetection(S,subjName,IPDmm, stmType, mtnType, bUseFeedback, bSKIPSYNCTEST, bDEBUG)
%
% + CHECK Screen('BlendFunction?') RE: DrawDots ANTIALIASING
%
%   example call: % TEST CODE
%                 expDirection = 'directionCheck';
%                 MaxContrastLMS = LMSstimulusContrast('experiment',expDirection);
%                 [~,S] = LMSstimulusGeneration(1*size(MaxContrastLMS,1),MaxContrastLMS,1,0,0,0.932);
%                 ExpLMSdetection(S,'JNK',65,'CGB', 'BXZ', 1, 0, 1);
%
% run target detection experiment to measure thresholds for different cone
% contrast directions. 
%
% S       : stimulus struct from LMSstimulusGeneration
% subjName:      three initial subject code
%                'JNK'   -> Junk
%                'JDB'   -> Johannes Daniel Burge
%                'LKC'   -> Larry K Cormack
%                'VRL'   -> Victor Rodriguez Lopez
% stmType:        stimulus type
%                'CGB'   -> compound   gabor  in one eye, gabor in other
% mtnType:        motion type
%                 BXZ -> brownian   motion in XZ
%                 BXY -> brownian   motion in XY
%                 B0X -> brownian   motion in X
%                 B0Z -> brownian   motion in Z
%                 BLX -> brownian   motion in X; LE only
%                 BRZ -> brownian   motion in X; RE only
%                 SXZ -> sinusoidal motion onscreen (X only)
%                        elliptical motion in depth (XZ    )
% MaxContrastLMS: cone contrasts 
%                   [nCnd x 3]
% bUseFeedback:  boolean indicating whether to use feedback or not
%                1 -> use feedback
%                0 -> don't
% bSKIPSYNCTEST: flag for skipping the psychtoolbox synctests
%                1 -> skip PTB sync tests
%                0 -> skip PTB sync tests
%                NOTE!   in general experimental data should be gathered only when = 0
%                NOTE!!! in haploscope rig (UPenn), experimental data should be gathered when = 1, due to problems with psychToolbox
% bDEBUG:        flag for debugging
%                1 -> DEBUGGIN!
%                0 -> run for serious
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% S:             stimulus parameters and subject responses
% D:         	 display  parameters

%%
%%%%%%%%%%%%%%%%%%
% INPUT HANDLING %
%%%%%%%%%%%%%%%%%%
if ~exist('bSKIPSYNCTEST','var') || isempty(bSKIPSYNCTEST)  bSKIPSYNCTEST = 0; end
if ~exist('bUseFeedback','var')  || isempty(bUseFeedback)   bUseFeedback = 0;  end
if ~exist('bDEBUG','var')        || isempty(bDEBUG)         bDEBUG = 0;        end

%%%%%%%%%%%%%%%%%%
% INPUT CHECKING % % ENSURE INPUTS ARE CONSISTENT WITH EXPERIMENT TYPES
%%%%%%%%%%%%%%%%%%

% *** FIX INPUT CHECKS BEFORE FORGET ***

expType = 'DTC';

%%%%%%%%%%%%%%%%%%%%%%
% STIMULUS STRUCTURE %
%%%%%%%%%%%%%%%%%%%%%%
S.subjName     = repmat(subjName,    [  S.trlPerRun, 1]);
S.IPDmm        = IPDmm;
S.rndSeed      = randi(1000, 1); rng(S.rndSeed);

S.expType      = repmat(expType,     [S.trlPerRun, 1]);
S.stmType      = repmat(stmType,     [S.trlPerRun, 1]);      % STIMULUS TYPE
S.mtnType      = repmat(mtnType,     [S.trlPerRun, 1]);      % MOTION   TYPE

% S.frqCpdCutoff = repmat(frqCpdCutoff,[S.trlPerRun, 1]);       %

S.magORval     = 'mag';       % SUBJ RESPONDS ACCORDING TO MAGNITUDE OF VARIABLE VS. SIGN OF VARIABLE?
S.numIntrvl = repmat(2,[S.trlPerRun 1]);
S.cmpIntrvl = round(rand([S.trlPerRun 1]));
% CMP IS ALWAYS 'GREATER' THAN STD
S.stdX = zeros([S.trlPerRun 1]);
S.cmpX = ones([S.trlPerRun 1]);
S.bUseFeedback = repmat(bUseFeedback,[S.trlPerRun, 1]);

% STIMULUS PARAMETERS IMAGE PARAMETERS
S.imgSzXYdeg    = repmat(2.*[2 2],         [S.trlPerRun, 1]);
S.smpPerDeg     = repmat(128,           [S.trlPerRun, 1]);    % FOR STIM TEXTURE CREATION

% FIXATION CROSS HAIRS WIDTHS
S.fixStmSzXYdeg = repmat([7.5 60]./60,  [S.trlPerRun, 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SINUSOIDAL MOTION PARAMETERS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AMPLITUDE
S.Adeg          = repmat(2.5,           [S.trlPerRun, 1]);
% NUMBER OF CYCLES PER SECOND
S.nCycPerSec    = repmat(1,             [S.trlPerRun, 1]);
% VELOCITY
S.Vdps          = repmat(2.5,           [S.trlPerRun, 1]); % REMOVE FROM STRUCT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINE RIG IDENTITY & STEREO MODE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
D.computer   = computer;
D.cmpInfo    = psyComputerInfo();
D.stereoMode = 0;

%%%%%%%%%%%%%%%%%%%%
% SET COLOR VALUES %
%%%%%%%%%%%%%%%%%%%%
D.blk        = 0.0;
D.bgd        = [0.5, 0.5, 0.5]; % 128; % 0.5000;
D.wht        = 1.0; % 255; % 1.0000;

%%%%%%%%%%%%%%%
% FILE NAMING %
%%%%%%%%%%%%%%%

S.fname         = buildFilenamePSYdataLMS(expType,S.subjName(1,:),S.stmType(1,:),[],[]);
S.fname         = repmat(S.fname,[S.trlPerRun 1]);
S.fdirLoc       = buildFolderNamePSY('LS3',expType,S.subjName(1,:),'local');
S.fdirSrv       = buildFolderNamePSY('LS3',expType,S.subjName(1,:),'server');

%%%%%%%%%%%%%%%%%%%%%%%%
% PRINT DATA TO SCREEN %
%%%%%%%%%%%%%%%%%%%%%%%%
disp(['ExpLMSdetection: Starting tracking experiment with Gabor ' D.cmpInfo.localHostName]);
disp(['                        Experimental type  = '         expType      ]);
disp(['                            Stimulus type  = '         stmType      ]);
disp(['                              Motion type  = '         mtnType      ]);
disp(['                        Total trls in Exp  = ' num2str(S.trlPerRun) ]);
disp(['                              Trls in Run  = ' num2str(S.trlPerRun) ]);
for i=1,
    disp(['                 Saving PSYdata to fdirLoc = ' num2str(S.fdirLoc(1,:)) ]);
    disp(['                 Saving PSYdata to fdirSrv = ' num2str(S.fdirSrv(1,:)) ]);
    disp(['                 Saving PSYdata to fname   = ../' num2str(S.fname(  1,:)) ]);
end
pause(2);

%% -------------- SET UP PSYCHTOOLBOX --------------
% PTB-3 CORRECTLY INSTALLED AND FUNCTIONAL
AssertOpenGL;

% SETUP KEYBOARD
KbName('UnifyKeyNames')
key_U_ARROW   = KbName('upArrow');
key_D_ARROW   = KbName('downArrow');
key_L_ARROW   = KbName('leftArrow');
key_R_ARROW   = KbName('rightArrow');
key_ESCAPE    = KbName('escape');
key_RETURN    = KbName('return');
key_SPACE_BAR = KbName('space');

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
D.plyXYpix = bsxfun(@times,S.imgSzXYdeg, D.pixPerDegXY);
% D.plyXYpix = bsxfun(@times,S.imgSzXYdeg, D.pixPerDegXY-1);

% BUILD DESTINATION RECTANGLE IN MIDDLE OF DISPLAY
D.plySqrPix    = CenterRect([0 0 D.plyXYpix(1, 1) D.plyXYpix(1, 2)], D.wdwXYpix);
plySqrPixCrdXY = D.plySqrPix(1:2);

% STIMULUS PARAMETERS IN PIXELS (REQUIRES DISPLAY INFO)
S.imgSzXYpix    = bsxfun(@times,S.imgSzXYdeg,D.pixPerDegXY);
S.fixStmSzXYpix = bsxfun(@times,S.fixStmSzXYdeg,D.pixPerDegXY);
S.Apix          = S.Adeg.*D.pixPerDegXY(1);

%%%%%%%%%%%%%%%%%%%%%%
% STIMULUS GENERATION %
%%%%%%%%%%%%%%%%%%%%%%
% SET MEAN LUMINANCE
% S.lumL(1:S.trlPerRun,1)  = D.correctedBgd;  % PROPORTION OF LUMINANCE RANGE... e.g. 0.5 = min(L)+0.5.*diff(minmax(L))
% S.lumR(1:S.trlPerRun,1)  = D.correctedBgd;
S.meanDC(1:S.trlPerRun,1) = mean(D.correctedBgd);

% Load Cone Fundamentals
load T_cones_ss2

% CREATE THE STIMULI FOR ALL THE SESSION
S.Limg=[];
S.Rimg=[];
for t = 1:S.trlPerRun
    % NUM FRAMES COMPUTED VIA DESIRED DURATION
    if strcmp(S.mtnType(1,1),'B') || strcmp(S.mtnType(1,1),'O') % BROWNIAN MOTION
        %% STIMULUS DURATION IN SECONDS
        secPerTrl    = 1;
        % STIMULUS DURATION IN MILLISECONDS
        S.durationMs  = repmat(secPerTrl.*1000,[S.trlPerRun 1]);
        % ENSURE THAT INTERFRAME INTERVAL (IN SEC) IS A NICE ROUND NUMBER
        D.fps          = round(1./D.ifi);
        D.ifi          = 1./D.fps;
        % FRAME SAMPLES IN SECS
        S.tSec        = [0:D.ifi:secPerTrl]';
        % STIMULUS DURATION IN FRAMES
        numFrm         = length(S.tSec);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % WORLD & SCREEN TARGET POSITION %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % WORLD STANDARD DEVIATION IN MM PER FRAME
        sigmaQmm      = 0.8;
        S.sigmaQmm    = repmat(sigmaQmm,[S.trlPerRun, 1]);
        % WORLD TARGET POSITION IN MM W.R.T. MONITOR CENTER
        if      strcmp(mtnType,'BXZ') || strcmp(mtnType,'OXZ') % BROWNIAN MOTION IN XZ
            % TARGET SPACE XYZ COORDS IN MM W.R.T. MONITOR CENTER
            S.tgtXmm(:,t) =  cumsum(sigmaQmm.*[0; randn(numFrm-1,1)]);
            S.tgtYmm(:,t) =  zeros(numFrm,1);
            S.tgtZmm(:,t) =  cumsum(sigmaQmm.*[0; randn(numFrm-1,1)]);
            % TARGET SPACE LR COORDS IN MM W.R.T. MONITOR CENTER
            [S.tgtXmmL(:,t),  S.tgtXmmR(:,t)]=screenXfromRangeXZ([S.tgtXmm(:,t) S.tgtZmm(:,t)+D.scrnZmm],D.scrnZmm,S.IPDmm,0); % axis tight
            S.tgtYmmL(:,t) = S.tgtYmm(:,t); S.tgtYmmR(:,t) = S.tgtYmm(:,t);
        elseif  strcmp(mtnType,'B0Z') || strcmp(mtnType,'O0Z') % BROWNIAN MOTION IN Z ONLY
            % TARGET SPACE XYZ COORDS IN MM W.R.T. MONITOR CENTER
            S.tgtXmm(:,t) =  zeros(numFrm,1);
            S.tgtYmm(:,t) =  zeros(numFrm,1);
            S.tgtZmm(:,t) =  cumsum(sigmaQmm.*[0; randn(numFrm-1,1)]);
            % TARGET SPACE LR COORDS IN MM W.R.T. MONITOR CENTER
            [S.tgtXmmL(:,t),  S.tgtXmmR(:,t)]=screenXfromRangeXZ([S.tgtXmm(:,t) S.tgtZmm(:,t)+D.scrnZmm],D.scrnZmm,S.IPDmm,0); % axis tight
            S.tgtYmmL(:,t) = S.tgtYmm(:,t); S.tgtYmmR(:,t) = S.tgtYmm(:,t);
        elseif      strcmp(mtnType,'BXY') || strcmp(mtnType,'OXY') % BROWNIAN MOTION IN XY
            % TARGET SPACE XYZ COORDS IN MM W.R.T. MONITOR CENTER
            S.tgtXmm(:,t) =  cumsum(sigmaQmm.*[0; randn(numFrm-1,1)]);
            S.tgtYmm(:,t) =  cumsum(sigmaQmm.*[0; randn(numFrm-1,1)]);
            S.tgtZmm(:,t) =  zeros(numFrm,1);
            % TARGET SPACE LR COORDS IN MM W.R.T. MONITOR CENTER
            S.tgtXmmL(:,t) = S.tgtXmm(:,t); S.tgtXmmR(:,t) = S.tgtXmm(:,t);
            S.tgtYmmL(:,t) = S.tgtXmm(:,t); S.tgtYmmR(:,t) = S.tgtXmm(:,t);
            % [S.tgtXmmL(:,t), S.tgtXmmR(:,t)]=screenXfromRangeXZ([S.tgtXmm(:,t) S.tgtZmm(:,t)+D.scrnZmm],D.scrnZmm,S.IPDmm,0); % axis tight
            S.tgtYmmL(:,t) = S.tgtYmm(:,t); S.tgtYmmR(:,t) = S.tgtYmm(:,t);
        elseif  strcmp(mtnType,'BPX') || strcmp(mtnType,'OPX') % BROWNIAN MOTION IN X ONLY W. PULFRICH RESPONSE
            S.tgtXmm(:,t) =  cumsum(sigmaQmm.*[0; randn(numFrm-1,1)]);
            S.tgtYmm(:,t) =  zeros(numFrm,1);
            S.tgtZmm(:,t) =  zeros(numFrm,1);
            % TARGET SPACE LR COORDS IN MM W.R.T. MONITOR CENTER
            S.tgtXmmL(:,t) = S.tgtXmm(:,t); S.tgtXmmR(:,t) = S.tgtXmm(:,t);
            S.tgtYmmL(:,t) = S.tgtYmm(:,t); S.tgtYmmR(:,t) = S.tgtYmm(:,t);
        elseif  strcmp(mtnType,'B0X') || strcmp(mtnType,'O0X') % BROWNIAN MOTION IN X ONLY
            S.tgtXmm(:,t) =  cumsum(sigmaQmm.*[0; randn(numFrm-1,1)]);
            S.tgtYmm(:,t) =  zeros(numFrm,1);
            S.tgtZmm(:,t) =  zeros(numFrm,1);
            % TARGET SPACE LR COORDS IN MM W.R.T. MONITOR CENTER
            S.tgtXmmL(:,t) = S.tgtXmm(:,t); S.tgtXmmR(:,t) = S.tgtXmm(:,t);
            S.tgtYmmL(:,t) = S.tgtYmm(:,t); S.tgtYmmR(:,t) = S.tgtYmm(:,t);
        elseif  strcmp(mtnType,'BLX') || strcmp(mtnType,'OLX') % BROWNIAN X MOTION IN LE ONLY
            S.tgtXmm(:,t) =  cumsum(sigmaQmm.*[0; randn(numFrm-1,1)]);
            S.tgtYmm(:,t) =  zeros(numFrm,1);
            S.tgtZmm(:,t) =  nan(numFrm,1);
            % TARGET SPACE LR COORDS IN MM W.R.T. MONITOR CENTER
            S.tgtXmmL(:,t) = S.tgtXmm(:,t); S.tgtXmmR(:,t) = nan(numFrm,1);
            S.tgtYmmL(:,t) = S.tgtYmm(:,t); S.tgtYmmR(:,t) = nan(numFrm,1);
        elseif  strcmp(mtnType,'BRX') || strcmp(mtnType,'ORX') % BROWNIAN X MOTION IN RE ONLY
            S.tgtXmm(:,t) =  cumsum(sigmaQmm.*[0; randn(numFrm-1,1)]);
            S.tgtYmm(:,t) =  zeros(numFrm,1);
            S.tgtZmm(:,t) =  nan(numFrm,1);
            % TARGET SPACE LR COORDS IN MM W.R.T. MONITOR CENTER
            S.tgtXmmL(:,t) = nan(numFrm,1); S.tgtXmmR(:,t) = S.tgtXmm(:,t);
            S.tgtYmmL(:,t) = nan(numFrm,1); S.tgtYmmR(:,t) = S.tgtYmm(:,t);
        else
            error(['ExpLMSdetection: WARNING! unhandled mtnType=' mtnType]);
        end
        
        % SCREEN TARGET POSITION IN PIXELS
        S.tgtXpixL(:,t) = S.tgtXmmL(:,t).*D.pixPerMmXY(1);
        S.tgtXpixR(:,t) = S.tgtXmmR(:,t).*D.pixPerMmXY(1);
        S.tgtYpixL(:,t) = S.tgtYmmL(:,t).*D.pixPerMmXY(2);
        S.tgtYpixR(:,t) = S.tgtYmmR(:,t).*D.pixPerMmXY(2);
        
        %         % SCREEN TARGET POSITION IN DEGREES
        %         S.tgtXdegL(:,t) = atand(S.tgtXmmL(:,t)./D.scrnZmm);
        %         S.tgtXdegR(:,t) = atand(S.tgtXmmR(:,t)./D.scrnZmm);
        %         S.tgtYdegL(:,t) = atand(S.tgtYmmL(:,t)./D.scrnZmm);
        %         S.tgtYdegR(:,t) = atand(S.tgtYmmR(:,t)./D.scrnZmm);
    else
        disp(['ExpLMSdetection: WARNING! unhandled stmType= ' S.stmType(1,:)]);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXATION/REFERENCE CROSS HAIRS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TO DO: IMPROVE FIXATION CROSS
% D.fixStm=psyFixStm_CrossHairs([D.wdwXYpix(3)/2 D.wdwXYpix(4)/2],[S.Apix(1) S.fixStmSzXYpix(1, 2)], [S.fixStmSzXYpix(1, 1) S.fixStmSzXYpix(1, 2)], '|||||||' ,[],0);
% D.fixStm=psyFixStm_CrossHairs([D.wdwXYpix(3)/2 D.wdwXYpix(4)/2],[S.Apix(1) S.fixStmSzXYpix(1, 2)], [S.fixStmSzXYpix(1, 1) S.fixStmSzXYpix(1, 2)], '|||||||||',[],0,0.75);
% D.fixStm=psyFixStm_CrossHairs([D.wdwXYpix(3)/2 D.wdwXYpix(4)/2],[S.Apix(1) S.fixStmSzXYpix(1, 2)], [S.fixStmSzXYpix(1, 1) S.fixStmSzXYpix(1, 2)], '|||||||||||',[],0,0.60);
D.fixStm=psyFixStm_CrossHairs([D.wdwXYpix(3)/2 D.wdwXYpix(4)/2],2.*[S.Apix(1) S.fixStmSzXYpix(1, 2)], [S.fixStmSzXYpix(1, 1) S.fixStmSzXYpix(1, 2)], '|||||||||||||',[],0,0.50);
[fPosX,fPosY] = RectCenter(D.wdwXYpix);
D.fixStm(:,end+1) = [fPosX-3 fPosY-3 fPosX+3 fPosY+3]';

%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE 1/F TEXTURE MASK % (OR NOT)
%%%%%%%%%%%%%%%%%%%%%%%%%
bUseMsk = 0;
% HOW BIG MASK IS RELATIVE TO SCREEN
mskScale = [0.4 0.65];
if  bUseMsk == 1
    % SIZE OF 1/F MASK
    kRadius = 0.5*[2 1.8];
    msk1oF = psyMask1overF(floor(D.scrnXYpix.*mskScale./2).*2,kRadius,[0 0],0,1);
    %    msk1oF = psyMask1overF(D.scrnXYpix,[kWidth kHeight],[0 0],0,1);
    tex1oF = Screen('MakeTexture', D.wdwPtr, msk1oF, [], [], 2);
    D.mskReset=1;
else
    msk1oF = [];
end

S.mskScale = repmat(mskScale,[S.trlPerRun, 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRE-EXPERIMENT SCREEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRING SCREEN UP TO DESIRED GRAY LEVEL
Screen('FillRect', D.wdwPtr, D.correctedBgd);

% WAIT UNTIL ALL KEYS ARE RELEASED
while KbCheck(-1); end
Screen('TextSize', D.wdwPtr, 20);
if   bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
Screen('DrawText',D.wdwPtr, ['First trial starts exactly one second after you hit the down arrow.'], ...
       0.6.*[fPosX], 0.8.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht], D.fixStm);
Screen('Flip',D.wdwPtr);
% WAIT FOR KEYPRESS
while 1
    [ keyIsDown, ~, keyCode ] = KbCheck(-1);
    if keyIsDown & find(keyCode) == key_D_ARROW
        break;
    end
end
% DRAW FIXATION STIM
if   bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht], D.fixStm);
Screen('Flip',D.wdwPtr);
pause(1.0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENT ITSELF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CREATE & DISPLAY STIMULI
for t = 1:S.trlPerRun
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INDIVIDUAL TRIAL CODE STARTS HERE %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if   bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
    % PRESENT TRIAL
 %   psyPresentTrial2IFCmov(D,S,t,stdIphtXYTrgb(:,:,:,:,t),cmpIphtXYTrgb(:,:,:,:,t),msk1oF);
     S = psyPresentTrialDetectionLMS(D,S,t,msk1oF);
    if   bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
    Screen('TextSize', D.wdwPtr, 14);
    % MAKE & DRAW FIXATION CROSS
    Screen('FillRect',D.wdwPtr, [D.wht,D.wht,D.wht], D.fixStm);
    Screen('DrawText',D.wdwPtr, [num2str(t) '  of ' num2str( S.trlPerRun ) ' trials'], [20], [20], [D.wht],[D.wht D.wht D.wht]);
    % FLIP
    Screen('Flip', D.wdwPtr);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % WAIT UNTIL ALL KEYS ARE RELEASED %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while KbCheck(-1); end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % WAIT FOR SUBJECT RESPONSE %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while 1
        % WAIT FOR KEYPRESS
        [ keyIsDown, ~, keyCode ] = KbCheck(-1);
        if keyIsDown

            % DOWN ARROW RESPONSE
            if find(keyCode) == key_D_ARROW

                % 1ST INTERVAL SELECTED
                chsIntrvl = 0;
                S = psyCollectResponse(S,t,chsIntrvl,S.magORval);

                % FEEDBACK
                if S.bUseFeedback(t) == 1
                    psyFeedbackSound(S.Rcorrect(t));
                end
                % TIMING CHECKS
                S.clock(t,:) = fix(clock);
                break % breaks out of while loop and moves to next trial OR ends experiment
            end

            % UP  ARROW RESPONSE
            if find(keyCode) == key_U_ARROW

                % 2ND INTERVAL SELECTED
                chsIntrvl = 1;
                S = psyCollectResponse(S,t,chsIntrvl,S.magORval);

                % FEEDBACK
                if S.bUseFeedback(t) == 1
                    psyFeedbackSound(S.Rcorrect(t));
                end
                % TIMING CHECKS
                S.clock(t,:) = fix(clock);
                break % breaks out of while loop and moves to next trial OR ends experiment
            end

            % % SPACE BAR RESPONSE (REPEAT TRIAL?)
            % if find(keyCode) == key_SPACE_BAR
            %
            % % DO STUFF
            %
            %     break
            % end

            % EXIT EXPERIMENT
            if keyCode(key_ESCAPE)
                Screen('CloseAll');
                % CLOSE VIDEO SWITCHER
                % PsychVideoSwitcher('SwitchMode', D.sid, 0, 1); 
                disp(['ExpEqvInputNse: WARNING! Experiment quit b/c of ESCAPE key press']);
                return;
                break;
            end

            while KbCheck(-1); end
        end
    end
    pause(.15);
end

%% ------------------END OF SESSION--------------------
%%%%%%%%%%%%%
% PLOT DATA %
%%%%%%%%%%%%%

%%%%%%%%%%%%%
% SAVE DATA %
%%%%%%%%%%%%%
% disp(['ExpLMSdetection: SAVING DATA...']);
% if strcmp(D.cmpInfo.localHostName,'jburge-hubel')
%     savePSYdataLMS(S.fname(1,:),expType,S.subjName(1,:),'both',0,S,'S');
% else
%     savePSYdataLMS(S.fname(1,:),expType,S.subjName(1,:),'local',0,S,'S');
% end

%%%%%%%%%%%%%%%%%
% CLOSE SCREENS %
%%%%%%%%%%%%%%%%%
% CLOSE TEXTURE
if bUseMsk == 1,
    Screen('Close', tex1oF);
    clear('tex1oF');
end
% SHOW CURSOR
ShowCursor();

% CLOSE PTB WINDOW
Screen('CloseAll');
sca

return
end

