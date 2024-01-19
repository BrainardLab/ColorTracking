function [S D] = ExpLSP(S,subjName,IPDmm,stmType, mtnType, indRnd, bUseFeedback, bSKIPSYNCTEST, bDEBUG)

% function [S D] = ExpLSP(S,subjName,IPDmm, stmType, mtnType, indRnd, bUseFeedback, bSKIPSYNCTEST, bDEBUG)
%
% + CHECK Screen('BlendFunction?') RE: DrawDots ANTIALIASING
%
%   example call: % TEST CODE
%                 targetContrast = [0.1 0.05 0.4 0.2 0.1 0.05 0.4 0.2 0.5 0.25]';
%                 targetContrastAngle = [45 45 75 75 -45 -45 -75 -75 90 90]';
%                 cmpIntrvl = [ones([floor(length(targetContrast)/2) 1]); zeros([ceil(length(targetContrast)/2) 1])];
%                 cmpIntrvl = [cmpIntrvl flipud(cmpIntrvl)];
%                 indRnd = randperm(length(targetContrast))';
%                 indRnd = [indRnd randperm(length(targetContrast))'];
%                 [stm,S] = LSDstimulusGeneration(targetContrast,targetContrastAngle,1,0,0,0.932,cmpIntrvl);
%                 ExpLSP(S,'JNK',65,'CGB', 'BXZ', indRnd, 1, 0, 1);
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
% indRnd        : indices for randomizing
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

expType = 'JND';

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

S.magORval     = 'val';       % SUBJ RESPONDS ACCORDING TO MAGNITUDE OF VARIABLE VS. SIGN OF VARIABLE?
S.numIntrvl = ones([S.trlPerRun 1]);
% CMP IS ALWAYS 'GREATER' THAN STD
S.stdX = zeros([S.trlPerRun 1]);
S.bUseFeedback = repmat(bUseFeedback,[S.trlPerRun, 1]);

% STIMULUS PARAMETERS IMAGE PARAMETERS
S.imgSzXYdeg    = repmat(2.*[2 2],         [S.trlPerRun, 1]);
S.smpPerDeg     = repmat(128,           [S.trlPerRun, 1]);    % FOR STIM TEXTURE CREATION

% FIXATION CROSS HAIRS WIDTHS
S.fixStmSzXYdeg = repmat([7.5 60]./60,  [S.trlPerRun, 1]);

% RANDOMIZE
frqCpdL = S.frqCpdL;
frqCpdR = S.frqCpdR;
phsDegL = S.phsDegL;
phsDegR = S.phsDegR;
ortDeg = S.ortDeg;
BWoct = S.BWoct;
targetContrast = S.targetContrast;
targetContrastAngle = S.targetContrastAngle;

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

%%%%%%%%%%%%%%%%%%%%%%%%
% PRINT DATA TO SCREEN %
%%%%%%%%%%%%%%%%%%%%%%%%
disp(['ExpLSP: Starting tracking experiment with Gabor ' D.cmpInfo.localHostName]);
disp(['                        Experimental type  = '         expType      ]);
disp(['                            Stimulus type  = '         stmType      ]);
disp(['                              Motion type  = '         mtnType      ]);
disp(['                        Total trls in Exp  = ' num2str(S.trlPerRun) ]);
disp(['                              Trls in Run  = ' num2str(S.trlPerRun) ]);
% for i=1,
%     disp(['                 Saving PSYdata to fdirLoc = ' num2str(S.fdirLoc(1,:)) ]);
%     disp(['                 Saving PSYdata to fdirSrv = ' num2str(S.fdirSrv(1,:)) ]);
%     disp(['                 Saving PSYdata to fname   = ../' num2str(S.fname(  1,:)) ]);
% end
pause(2);

%% -------------- SET UP PSYCHTOOLBOX --------------
% PTB-3 CORRECTLY INSTALLED AND FUNCTIONAL
AssertOpenGL;

% SETUP KEYBOARD
KbName('UnifyKeyNames')
key_ESCAPE    = KbName('escape');
key_RETURN    = KbName('return');
key_SPACE_BAR = KbName('space');
gamepadIndex = Gamepad('GetNumGamepads');
bttnOneNum = 3;
bttnTwoNum = 2;

% SETUP PSYCHTOOLBOX
% psyPTBsetup(bSKIPSYNCTEST,bDEBUG); % call must come before psyPTBopenWindow

% PREPARE PSYCHIMAGING
PsychImaging('PrepareConfiguration');
% FLOATING POINT NUMBERS
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
% SKIP SYNCTESTS OR NOT
Screen('Preference', 'SkipSyncTests', bSKIPSYNCTEST);
% DEBUGGING WINDOW
if bDEBUG == 1
    % OPACITY
    opacityAlpha = 0.5;
    % ENABLE ALPHA WINDOW FOR DEBUGGING
    PsychDebugWindowConfiguration([],opacityAlpha); % NOTE! must call before opening ptb window
elseif bDEBUG == 0
    gribble = 1;
end

% LOAD MONITOR CALIBRATION DATA (GAMMA DATA)
% [D.cal,D.gamPix,D.gamFnc,D.gamInv] = psyLoadCalibrationData(D.cmpInfo.localHostName);

% SETUP GAMMA CORRECTION OPTIONS
% D.gammaCorrectionType = 'LookupTable';      % move to top of experiment file
% psyPTBgammaCorrectSetup(D.gammaCorrectionType);

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
    resourcesDir =  getpref('ColorTracking','CalDataFolder');
    load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
    calCell = 4;
    cal = cals{calCell};
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
oldResolution=Screen('Resolution', D.sid,[],[],60);
% OPEN WINDOW
%[D.wdwPtr, D.wdwXYpix]  = PsychImaging('OpenWindow', D.sid, D.bgd, [],[], [], D.stereoMode);
[D.wdwPtr, D.wdwXYpix]  = BitsPlusPlus('OpenWindowBits++',D.sid,[128 128 128]');
[saveGamma,~]=Screen('ReadNormalizedGammaTable',D.wdwPtr);
Screen('LoadNormalizedGammaTable', D.wdwPtr, S.lookupTableSettingsInit,2);
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
% D.gamInv = linspace(0,1,1024)';
% CORRECT GAMMA
% D         = psyPTBgammaCorrect(D);

% SET STIMULUS PARAMETERS
D.plyXYpix = bsxfun(@times,S.imgSzXYdeg, D.pixPerDegXY);
% D.plyXYpix = bsxfun(@times,S.imgSzXYdeg, D.pixPerDegXY-1);

% BUILD DESTINATION RECTANGLE IN MIDDLE OF DISPLAY
D.plySqrPix    = CenterRect([0 0 D.plyXYpix(1, 1) D.plyXYpix(1, 2)], D.wdwXYpix);

% STIMULUS PARAMETERS IN PIXELS (REQUIRES DISPLAY INFO)
S.imgSzXYpix    = bsxfun(@times,S.imgSzXYdeg,D.pixPerDegXY);
S.fixStmSzXYpix = bsxfun(@times,S.fixStmSzXYdeg,D.pixPerDegXY);
S.Apix          = S.Adeg.*D.pixPerDegXY(1);

%%%%%%%%%%%%%%%%%%%%%%
% STIMULUS GENERATION %
%%%%%%%%%%%%%%%%%%%%%%
% SET MEAN LUMINANCE
% S.lumL(1:S.trlPerRun,1)  = D.correctedBgd;  % PROPORTION OF LUMINANCE RANGE... e.g. 0.5 = min(L)+0.5.*diff(minmaxLocal(L))
% S.lumR(1:S.trlPerRun,1)  = D.correctedBgd;
S.meanDC(1:S.trlPerRun,1) = mean(D.correctedBgd);

% Load Cone Fundamentals
load T_cones_ss2

% CREATE THE STIMULI FOR ALL THE SESSION
S.Limg=[];
S.Rimg=[];
for i = 1:size(indRnd,2)
    for t = 1:S.trlPerRun
        % NUM FRAMES COMPUTED VIA DESIRED DURATION
        if strcmp(S.mtnType(1,:),'LIN') % BROWNIAN MOTION
            %% STIMULUS DURATION IN SECONDS
            secPerTrl    = 0.4;
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
%             % WORLD TARGET POSITION IN MM W.R.T. MONITOR CENTER
%             % TARGET SPACE XYZ COORDS IN MM W.R.T. MONITOR CENTER
%             tgtXmm(:,t,i) =  cumsum(sigmaQmm.*[0; randn(numFrm-1,1)]);
%             tgtYmm(:,t,i) =  zeros(numFrm,1);
%             tgtZmm(:,t,i) =  zeros(numFrm,1);
%             % TARGET SPACE LR COORDS IN MM W.R.T. MONITOR CENTER
%             [tgtXmmL(:,t,i),  tgtXmmR(:,t,i)]=screenXfromRangeXZ([tgtXmm(:,t,i) tgtZmm(:,t,i)+D.scrnZmm],D.scrnZmm,S.IPDmm,0); % axis tight
%             tgtYmmL(:,t,i) = tgtYmm(:,t,i); tgtYmmR(:,t,i) = tgtYmm(:,t,i);
            
            tgtXpixTmp = zeros([numFrm 1]);
            % PROPORTION OF TOTAL FRAMES TAKEN UP BY EACH STIMULUS
            propFrmStim = 0.4;
            % NUMBER OF FRAMES TAKEN UP BY EACH STIMULUS 
            numFrmStim = round(numFrm.*propFrmStim);
            % PUT STIMULUS OFF THE SCREEN FOR ISI
            tgtXpixTmp(numFrmStim+1:numFrm-numFrmStim) = NaN;
            % POSITION OF SECOND STIMULUS
            tgtXpixTmp(numFrm-numFrmStim+1:numFrm) = S.posXoffsetPix(t,i);
            % SCREEN TARGET POSITION IN PIXELS
            tgtXpixL(:,t,i) = tgtXpixTmp;
            tgtXpixR(:,t,i) = tgtXpixTmp;
            tgtYpixL(:,t,i) = zeros(size(tgtXpixTmp));
            tgtYpixR(:,t,i) = zeros(size(tgtXpixTmp));
            tgtXdegL = tgtXpixL/D.pixPerDegXY(1);
            tgtXdegR = tgtXpixR/D.pixPerDegXY(1);
            tgtYdegL = tgtYpixL/D.pixPerDegXY(2);
            tgtYdegR = tgtYpixR/D.pixPerDegXY(2);
            %         % SCREEN TARGET POSITION IN DEGREES
            %         tgtXdegL(:,t,i) = atand(tgtXmmL(:,t,i)./D.scrnZmm);
            %         tgtXdegR(:,t,i) = atand(tgtXmmR(:,t,i)./D.scrnZmm);
            %         tgtYdegL(:,t,i) = atand(tgtYmmL(:,t,i)./D.scrnZmm);
            %         tgtYdegR(:,t,i) = atand(tgtYmmR(:,t,i)./D.scrnZmm);
        else
            disp(['ExpLSP: WARNING! unhandled stmType= ' S.stmType(1,:)]);
        end
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
D.fixStm = D.fixStm(:,end);

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
% EXPERIMENT ITSELF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STORE cmpIntrvl OUTSIDE OF STRUCT
cmpIntrvl = S.cmpIntrvl;
for i = 1:size(indRnd,2) % FOR EACH RUN
%     indRndSpecial = mod(indRnd(:,i),size(indRnd,1));
%     indRndSpecial(indRndSpecial==0) = size(indRnd,1);
    % PULL OUT ONE COLUMN OF cmpIntrvl VALUES
    S.cmpIntrvl = cmpIntrvl(:,i);
    % RANDOMIZE A BUNCH OF THINGS
%    S.cmpIntrvl = S.cmpIntrvl(indRndSpecial,:);
    S.frqCpdL = frqCpdL(indRnd(:,i),:);
    S.frqCpdR = frqCpdR(indRnd(:,i),:);
    S.phsDegL = phsDegL(indRnd(:,i),:);
    S.phsDegR = phsDegR(indRnd(:,i),:);
    S.ortDeg = ortDeg(indRnd(:,i),:);
    S.BWoct = BWoct(indRnd(:,i),:);
    S.targetContrast = targetContrast(indRnd(:,i),:);
    S.targetContrastAngle = targetContrastAngle(indRnd(:,i),:);
    S.tgtXpixL = squeeze(tgtXpixL(:,:,i));
    S.tgtXpixR = squeeze(tgtXpixR(:,:,i));
    S.tgtYpixL = squeeze(tgtYpixL(:,:,i));
    S.tgtYpixR = squeeze(tgtYpixR(:,:,i));
    S.cmpX = S.posXoffsetPix(:,i);
%     S.tgtXmm = squeeze(tgtXmm(:,:,i));
%     S.tgtYmm = squeeze(tgtYmm(:,:,i));
%     S.tgtZmm = squeeze(tgtZmm(:,:,i));
%     S.tgtXmmL = squeeze(tgtXmmL(:,:,i));
%     S.tgtXmmR = squeeze(tgtXmmR(:,:,i));
%     S.tgtYmmL = squeeze(tgtYmmL(:,:,i));
    % MAKE TEMPORAL WINDOW
    S.timeWindow = cosWindowFlattop([1 numFrm+1],floor((numFrm+1)/2),ceil((numFrm+1)/2),0,0);
    % S.timeWindow = cosWindowFlattop([1 numFrm],0,numFrm,0,0);
    % WINDOW STIMULUS
    stmLE = S.stmLE;
    for j = 1:length(S.timeWindow)
        stmTmp = ((stmLE-mean(stmLE(:)))./mean(stmLE(:))).*S.timeWindow(j);
        S.stmLE(:,:,j) = round(stmTmp.*mean(stmLE(:))+mean(stmLE(:)));
    end
    %%%%%%%%%%%%%%%
    % FILE NAMING %
    %%%%%%%%%%%%%%%

    S.fname         = buildFilenamePSYdataLMS(expType,S.subjName(1,:),S.stmType(1,:),[],[]);
    S.fname         = repmat(S.fname,[S.trlPerRun 1]);
    S.fdirLoc       = buildFolderNamePSY('LSD',expType,S.subjName(1,:),'local');
    S.fdirSrv       = buildFolderNamePSY('LSD',expType,S.subjName(1,:),'server');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PRE-EXPERIMENT SCREEN
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % BRING SCREEN UP TO DESIRED GRAY LEVEL
    Screen('FillRect', D.wdwPtr, round(D.bgd.*255));

    % WAIT UNTIL ALL KEYS ARE RELEASED
    while KbCheck(-1) || Gamepad('GetButton', gamepadIndex, bttnOneNum) || Gamepad('GetButton', gamepadIndex, bttnTwoNum); end
%    Screen('LoadNormalizedGammaTable', D.wdwPtr, saveGamma,[]);
    Screen('LoadNormalizedGammaTable', D.wdwPtr, S.lookupTableSettingsInit,2);
    Screen('Flip',D.wdwPtr);
    if i==1; pause(3.6); end
    Screen('TextSize', D.wdwPtr, 20);
    if   bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
    
%     Screen('DrawText',D.wdwPtr, ['Block ' num2str(i) '. Hit green down button to see primer stimulus.'], ...
%        0.6.*[fPosX], 0.8.*[fPosY], round([D.wht].*255));
%     Screen('FillRect', D.wdwPtr, round([D.wht,D.wht,D.wht].*255), D.fixStm);
%     Screen('Flip',D.wdwPtr);    
%     while ~Gamepad('GetButton', gamepadIndex, bttnOneNum); end
%     while KbCheck(-1) || Gamepad('GetButton', gamepadIndex, bttnOneNum) || Gamepad('GetButton', gamepadIndex, bttnTwoNum); end
%     
%     Screen('LoadNormalizedGammaTable', D.wdwPtr, S.lookupTableSettings(:,:,indPrimer),2);
%     texPrimer = Screen('MakeTexture', D.wdwPtr, stmLE);
%     Screen('DrawTexture', D.wdwPtr, texPrimer, [], D.plySqrPix);
%     Screen('Flip',D.wdwPtr);
%     pause(3);
    
%    Screen('Close', texPrimer);
%    Screen('LoadNormalizedGammaTable', D.wdwPtr, S.lookupTableSettingsInit,2);
    Screen('DrawText',D.wdwPtr, ['Block ' num2str(i) '. First trial starts exactly one second after you hit the blue left button.'], ...
           0.6.*[fPosX], 0.8.*[fPosY], round([D.wht].*255));
    Screen('FillRect', D.wdwPtr, round([D.wht,D.wht,D.wht].*255), D.fixStm);
    Screen('Flip',D.wdwPtr);
    % WAIT FOR KEYPRESS
    while ~Gamepad('GetButton', gamepadIndex, bttnOneNum); end
    while KbCheck(-1) || Gamepad('GetButton', gamepadIndex, bttnOneNum) || Gamepad('GetButton', gamepadIndex, bttnTwoNum); end
    
    % DRAW FIXATION STIM
    if   bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
    Screen('FillRect', D.wdwPtr, round([D.wht,D.wht,D.wht].*255), D.fixStm);
    Screen('Flip',D.wdwPtr);
    pause(1.0);
    
    % CREATE & DISPLAY STIMULI
    for t = 1:size(indRnd,1)
%         Screen('LoadNormalizedGammaTable', D.wdwPtr, S.lookupTableSettings(:,:,indRnd(t,i)),2);
%         Screen('Flip', D.wdwPtr);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % INDIVIDUAL TRIAL CODE STARTS HERE %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if   bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
        % PRESENT TRIAL
     %   psyPresentTrial2IFCmov(D,S,t,stdIphtXYTrgb(:,:,:,:,t),cmpIphtXYTrgb(:,:,:,:,t),msk1oF);
         S = psyPresentTrialLSP(D,S,t,msk1oF,indRnd(t,i));
        if   bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
        
        Screen('TextSize', D.wdwPtr, 14);
        % MAKE & DRAW FIXATION CROSS
        Screen('FillRect',D.wdwPtr, round([D.wht,D.wht,D.wht].*255), D.fixStm);
        Screen('DrawText',D.wdwPtr, [num2str(t) '  of ' num2str( size(indRnd,1) ) ' trials'], [20], [20], round([D.wht.*255]));
        Screen('LoadNormalizedGammaTable', D.wdwPtr, S.lookupTableSettingsInit,2);
        % FLIP
        Screen('Flip', D.wdwPtr);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % WAIT UNTIL ALL KEYS ARE RELEASED %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        while KbCheck(-1) || Gamepad('GetButton', gamepadIndex, bttnOneNum) || Gamepad('GetButton', gamepadIndex, bttnTwoNum); end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % WAIT FOR SUBJECT RESPONSE %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        while 1
            isResponse = 0;
            % WAIT FOR KEYPRESS
            key_L_ARROW = Gamepad('GetButton', gamepadIndex, bttnOneNum);
            if key_L_ARROW; isResponse = 1; end
            key_R_ARROW = Gamepad('GetButton', gamepadIndex, bttnTwoNum);
            if key_R_ARROW; isResponse = 1; end
            [ keyIsDown, ~, keyCode ] = KbCheck(-1);
            if keyIsDown; isResponse = 1; end
            if isResponse

                % DOWN ARROW RESPONSE
                if key_L_ARROW

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
                if key_R_ARROW

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
                    Screen('LoadNormalizedGammaTable', D.wdwPtr, S.lookupTableSettingsInit,2);
                    Screen('CloseAll');
                    % CLOSE VIDEO SWITCHER
                    % PsychVideoSwitcher('SwitchMode', D.sid, 0, 1); 
                    disp(['ExpEqvInputNse: WARNING! Experiment quit b/c of ESCAPE key press']);
                    return;
                    break;
                end

                while KbCheck(-1) || Gamepad('GetButton', gamepadIndex, bttnOneNum) || Gamepad('GetButton', gamepadIndex, bttnTwoNum); end
            end
        end
        pause(.15);
    end
    %%%%%%%%%%%%%
    % SAVE DATA %
    %%%%%%%%%%%%%
    S.stmLE = stmLE;
    disp(['ExpLSP: SAVING DATA...']);
    try
        if strcmp(D.cmpInfo.localHostName,'jburge-hubel')
            savePSYdataLMS(S.fname(1,:),expType,S.subjName(1,:),'both',0,S,'S');
        else
            savePSYdataLMS(S.fname(1,:),expType,S.subjName(1,:),'local',0,S,'S');
        end
    catch
        display('ExpLSP: WARNING! Having trouble saving data...');
    end
end

%% ------------------END OF SESSION--------------------
%%%%%%%%%%%%%
% PLOT DATA %
%%%%%%%%%%%%%

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
Screen('LoadNormalizedGammaTable', D.wdwPtr, S.lookupTableSettingsInit,2);
% CLOSE PTB WINDOW
Screen('CloseAll');
sca

return
end

