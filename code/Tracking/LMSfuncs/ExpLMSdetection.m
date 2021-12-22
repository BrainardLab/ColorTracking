function [S D] = ExpLMSdetection(S,subjName,IPDmm, phsDspArcmin, stmSzXYdeg, device,stmType, mtnType, mchL, mchR, BWort, bUseFeedback, bSKIPSYNCTEST, bDEBUG)

% function [S D] = ExpLMSdetection(S,subjName,IPDmm, phsDspArcmin, stmSzXYdeg, device, stmType, mtnType, mchL, mchR, BWort, bUseFeedback, bSKIPSYNCTEST, bDEBUG)
%
% + CHECK Screen('BlendFunction?') RE: DrawDots ANTIALIASING
%
%   example call: % TEST CODE
%                 expDirection = 'directionCheck';
%                 MaxContrastLMS = LMSstimulusContrast('experiment',expDirection);
%                 [~,S] = LMSstimulusGeneration(1*size(MaxContrastLMS,1),MaxContrastLMS,1,0,0,0.932);
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
% trlPerRun:     trials per run.  must be multiple of number of phase disparities (phsDspArcmin)
% phsDspArcmin:  phase differences to introduce disparity in arcmin  [nPhaseDif x 1]
%                phase to temporal offset with phased2offset.m and back with offset2phased.m
% stmSzXYdeg:    stimulus size in X and Y dimensions in Arcmin       [2 x 1]
% device:        version of SimVis device used in the current experiment
%                'UPENN' -> Victor's stay UPenn (April-18) device
%                'SV2'   -> second version
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
% mchL:           michelson contrast for left eye
%                   [ nCnd x nCmp ]
% mchR:           michelson contrast for right eye
%                   [ nCnd x nCmp ]
% BWort:         orientation bandwidth in radians
%                [    scalar   ] -> same   bandwidth for all  components
%                [  1   x nCmp ] -> unique bandwidth for each component
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NUMBER OF CONDITIONS IN RUN %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nCnd = max([size(mchL,1) size(mchR,1)]);
% TRIALS PER CONDITION
trlPerCnd = S.trlPerRun./nCnd;
% CHECK # TRIALS VALID GIVEN # CONDITIONS
if mod(trlPerCnd,1) ~= 0 error(['ExpLMSdetection: WARNING! trlPerRun=' num2str(trlPerRun) ' must be a factor of nCnd=' num2str(nCnd) '!']); end;
% DOUBLE CHECK THAT CONDITIONS ARE MATCHED
if ~isequal(size(mchL      ),size(    mchR  )) error(['ExpLMSdetection: WARNING! mchL     and mchR     must be the same size. Check inputs!']); end;

%%%%%%%%%%%%%%%%%%%%%%
% STIMULUS STRUCTURE %
%%%%%%%%%%%%%%%%%%%%%%
S.subjName     = repmat(subjName,    [  S.trlPerRun, 1]);
S.IPDmm        = IPDmm;
S.rndSeed      = randi(1000, 1); rng(S.rndSeed);

S.expType      = repmat(expType,     [S.trlPerRun, 1]);
S.stmType      = repmat(stmType,     [S.trlPerRun, 1]);      % STIMULUS TYPE
S.mtnType      = repmat(mtnType,     [S.trlPerRun, 1]);      % MOTION   TYPE
S.device       = repmat(device,      [S.trlPerRun, 1]);

S.stmSzXYdeg   = repmat(stmSzXYdeg,  [S.trlPerRun, 1]);

% NUMBER OF COMPONENTS
nCmp = size(S.frqCpdL,2);
S.mchL        = imresize(mchL,[S.trlPerRun nCmp],'nearest');
S.mchR        = imresize(mchR,[S.trlPerRun nCmp],'nearest');
S.BWort       = imresize(BWort,[S.trlPerRun, 1],'nearest');

% S.frqCpdCutoff = repmat(frqCpdCutoff,[S.trlPerRun, 1]);       %

S.magORval     = repmat('val',       [S.trlPerRun, 1]);       % SUBJ RESPONDS ACCORDING TO MAGNITUDE OF VARIABLE VS. SIGN OF VARIABLE?
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

% PHASE DISPARITIES (TEMPORAL OFFSETS)
S.phsDspArcmin = repmat(phsDspArcmin', [S.trlPerRun./length(phsDspArcmin), 1]);
% S.phsDegInit   = repmat([phsDegInit1; phsDegInit2], [S.trlPerRun(1)/2, 1]);
S.phsDegInit = round(rand([S.trlPerRun 1])).*180;
% RANDOM INDEX
indRnd = randsample(S.trlPerRun, S.trlPerRun);
S.phsDegInit   = S.phsDegInit(indRnd);
S.phsDspArcmin = S.phsDspArcmin(indRnd);
S.phsDspDeg    = S.phsDspArcmin./60;

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
S.fdirLoc       = buildFolderNamePSY('LS2',expType,S.subjName(1,:),'local');
S.fdirSrv       = buildFolderNamePSY('LS2',expType,S.subjName(1,:),'server');

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
S.stmSzXYpix    = bsxfun(@times,S.stmSzXYdeg,D.pixPerDegXY);
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


% Speficy LMS contrast vector
% MaxContrastLMS = 0.1.*[0 1 0]; %m-iso-10p.pdf
% MaxContrastLMS = 0.9.*[0 0 1]; %s-iso-90p.pdf
% MaxContrastLMS = 0.1.*[0.7071 0.7071 0]; %l+m-iso-10p.pdf
% MaxContrastLMS = 0.1.*[1 0 0]; %l-iso-10p.pdf
% MaxContrastLMS = 0.1.*[0.7071 -0.7071 0]; %l-m-iso-10p.pdf
% CREATE STIMULUS

% Load Cone Fundamentals
load T_cones_ss2

% CREATE THE STIMULI FOR ALL THE SESSION
S.Limg=[];
S.Rimg=[];
for t = 1:S.trlPerRun
    Apix       = S.Apix(t);                % AMPLITUDE       (PIX)
    phsDspDeg  = S.phsDspDeg(t);      % PHASE DISPARITY (RAD)
    nCycPerSec = S.nCycPerSec(t);        % NUM CYCLE
    phsDegInit = S.phsDegInit(t);
    phsDspDeg  = S.phsDspDeg(t);      % PHASE DISPARITY (RAD)
    stmSzXYpix = S.stmSzXYpix(t, :); % STIM SIZE IN XY (PIX)
    
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
% SECOND PRE-EXPERIMENT SCREEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRING SCREEN UP TO DESIRED GRAY LEVEL
Screen('FillRect', D.wdwPtr, D.correctedBgd);

while KbCheck(-1); end
if   bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
% PRESENT INSTRUCTIONS
Screen('TextSize', D.wdwPtr, 20);
%     Screen('DrawText',D.wdwPtr, ['Signal = ' num2str(tgtRMS2display) ' Noise = ' num2str(nseRMS2display)], ...
%            0.8.*[fPosX], 0.65.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
Screen('DrawText',D.wdwPtr, ['Press the down arrow key to view the target in the crosshairs.'], ...
       0.6.*[fPosX], 0.7.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
Screen('DrawText',D.wdwPtr, ['Press the up arrow key to start the experiment.'], ...
       0.7.*[fPosX], 0.75.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
Screen('FillRect',D.wdwPtr, [D.wht,D.wht,D.wht], D.fixStm);
Screen('Flip',D.wdwPtr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIRD PRE-EXPERIMENT SCREEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WAIT UNTIL ALL KEYS ARE RELEASED
while KbCheck(-1); end
Screen('TextSize', D.wdwPtr, 20);
if   D.bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
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
if   D.bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
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
    if   D.bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
    % PRESENT TRIAL
    psyPresentTrial2IFCmov(D,S,t,stdIphtXYTrgb(:,:,:,:,t),cmpIphtXYTrgb(:,:,:,:,t),msk1oF);
    if   D.bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
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

    % BREAK 1/3 AND 2/3 OF THE WAY THROUGH THE EXP
    if mod(t,breakEvery) == 0 & t ~=S.trlPerRun
        % RELEASE ALL KEYS
        while KbCheck(-1); end
        
        if   D.bUseMsk %MAKE MASK TEXTURE IF USING
           Screen('Close',tex1oF);
           clear msk1oF;
           % MAKE 1/F TEXTURE AND CIRCLE
           [~,mskNoise,mskCrcle] = psyMask1overF(D.scrnXYpix,D.kRadius,[0 0],0);
           % SCALE 1/F MASK
           mskNoise = mskNoise.*(D.gryNoVideoSwitcher./mean(mskNoise(:)));
           % ADD CIRCLE
           msk1oF   = cat(3,repmat(mskNoise,[1 1 3]),mskCrcle);
           % CONVERT TO R+B
           msk1oF = psyVideoSwitcherPHT2RGB(msk1oF,D.gamFncX,D.gamFncY,0);
           tex1oF   = Screen('MakeTexture', D.wdwPtr, msk1oF,[],[],2);
        else
           msk1oF = [];
        end
        
        % PRESENT INSTRUCTIONS
        Screen('TextSize', D.wdwPtr, 20);
        if   D.bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
        Screen('DrawText',D.wdwPtr, ['Press the down arrow key to view the target in the crosshairs.'], ...
                0.6.*[fPosX], 0.7.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
        Screen('DrawText',D.wdwPtr, ['Press the up arrow key to continue the experiment.'], ...
                0.7.*[fPosX], 0.75.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
        Screen('FillRect',D.wdwPtr, [D.wht,D.wht,D.wht], D.fixStm);
        Screen('Flip',D.wdwPtr);

        while 1
            % MONITOR KEY PRESS
            [ keyIsDown, ~, keyCode, ~] = KbCheck(-1);
            % IF PRESS DOWN KEY, PRESENT PRACTICE TARGET
            if keyIsDown & find(keyCode) == key_D_ARROW
                for i = 1:size(practiceTargetCrt,4)
                   Screen('TextSize', D.wdwPtr, 20);
                   if   D.bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
                   Screen('DrawText',D.wdwPtr, ['Press the down arrow key to view the target in the crosshairs.'], ...
                           0.6.*[fPosX], 0.7.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
                   Screen('DrawText',D.wdwPtr, ['Press the up arrow key to continue the experiment.'], ...
                           0.7.*[fPosX], 0.75.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
                   tgt2lookAt  = Screen('MakeTexture', D.wdwPtr, squeeze(practiceTargetCrt(:,:,:,i)),[],[],2);
                   Screen('DrawTexture', D.wdwPtr, tgt2lookAt, [], D.plySqrPix);
                   Screen('FillRect',D.wdwPtr, [D.wht,D.wht,D.wht], D.fixStm);
                   Screen('Flip',D.wdwPtr);
                end
            elseif keyIsDown & find(keyCode) == key_U_ARROW
                break;
            end
        end
        
        % WAIT UNTIL ALL KEYS ARE RELEASED
        while KbCheck(-1); end
        Screen('TextSize', D.wdwPtr, 20);
        if   D.bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
        Screen('DrawText',D.wdwPtr, ['Down arrow to continue.'], ...
                0.6.*[fPosX], 0.8.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
        Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht], D.fixStm);
        Screen('Flip',D.wdwPtr);
        % WAIT FOR KEYPRESS
        while 1
            % MONITOR KEY PRESS
            [ keyIsDown, ~, keyCode ] = KbCheck(-1);
            if keyIsDown & find(keyCode) == key_D_ARROW
                break;
            end
        end
        if   D.bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
        % DRAW FIXATION STIM
        Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht], D.fixStm);
        Screen('Flip',D.wdwPtr);
        pause(1.0);
    end
end

%% ------------------END OF SESSION--------------------
%%%%%%%%%%%%%
% PLOT DATA %
%%%%%%%%%%%%%

%%%%%%%%%%%%%
% SAVE DATA %
%%%%%%%%%%%%%
disp(['ExpLMSdetection: SAVING DATA...']);
if strcmp(D.cmpInfo.localHostName,'jburge-hubel')
    savePSYdataLMS(S.fname(1,:),expType,S.subjName(1,:),'both',0,S,'S');
else
    savePSYdataLMS(S.fname(1,:),expType,S.subjName(1,:),'local',0,S,'S');
end

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

