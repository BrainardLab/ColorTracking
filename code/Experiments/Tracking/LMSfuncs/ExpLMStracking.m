function [S D] = ExpLMStracking(subjName,IPDmm,trlPerRun, phsDspArcmin, stmSzXYdeg, device, dfcL, dfcR, vdfL, vdfR, ndfL, ndfR, stmType, mtnType, MaxContrastLMS, mchL, mchR, frqCpdL,frqCpdR, phsDegL, phsDegR, ortDeg, BWoct, BWort, bUseFeedback, bSKIPSYNCTEST, bDEBUG, bStatic, axSignMATLEAP)

% function [S D] = ExpLMStracking(subjName,IPDmm,trlPerRun, phsDspArcmin, stmSzXYdeg, device, dfcL, dfcR, vdfL, vdfR, ndfL, ndfR, stmType, mtnType, MaxContrastLMS, mchL, mchR, frqCpdL,frqCpdR, phsDegL, phsDegR, ortDeg, BWoct, BWort, bUseFeedback, bSKIPSYNCTEST, bDEBUG, bStatic, axSignMATLEAP)
%
% + CHECK Screen('BlendFunction?') RE: DrawDots ANTIALIASING
%
%   example call: % TEST CODE (2 SECOND TRACK)
%                 ExpLMStracking('JNK',65,10,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', 0.1.*[1 0 0], [0.5], [0.5], [4], [4], [0], [0], 0,[0.3461], [pi*(60/180)], 0, 1, 1, 0);
%{ 
                PILOT DATA
                MaxContrastLMS = 0.1.*[0 1 0]; %m-iso-10p.pdf
                MaxContrastLMS = 0.9.*[0 0 1]; %s-iso-90p.pdf
                MaxContrastLMS = 0.1.*[0.7071 0.7071 0]; %l+m-iso-10p.pdf
                MaxContrastLMS = 0.1.*[1 0 0]; %l-iso-10p.pdf
                MaxContrastLMS = 0.1.*[0.7071 -0.7071 0]; %l-m-iso-10p.pdf
                MaxContrastLMS = [0.1.*[0.7071 0 -0.7071]; 0.25.*[0.7071  0 0.7071]; 0.78.*[0 0 1]; 0.1.*[1 0 0]];
                
                % Without DEBUG mode
                ExpLMStracking('JNK',65,8,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', MaxContrastLMS, [0.5], [0.5], [1], [1], [0], [0], 0, [1.5], [pi*(60/180)], 0, 1, 0, 0);
                % With DEBUG Mode
                ExpLMStracking('JNK',65,10,[0],[15 60]./60, 'UPENN', 0.00, 0.00, 0.0000, 0.0000, 0.00, 0.00, 'CGB', 'BXZ', MaxContrastLMS, [0.5], [0.5], [1], [1], [0], [0], 0, [1], [1.5], 0, 1, 1, 0);
%}
% run target tracking experiment to measure delays for different cone
% contrast directions
%
% TASK:      subjects must use the mouse or LEAP motion controller to
%            track the target as accurately and precisely as possible
%
% ANALYSIS:  plotPFTdata.m -> for analyzing all runs
%
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
% dfcL:           defocus in the left  eye in diopters
% dfcR:           defocus in the right eye in diopters
% vdfL:           optical density of virtual neutral density filter in left  eye
% vdfR:           optical density of virtual neutral density filter in right eye
% ndfL:           optical density of  real   neutral density filter in left  eye
% ndfR:           optical density of  real   neutral density filter in right eye
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
% frqCpdL:   frequencies for std OR left  stimulus
%                   [ nCnd x nCmp ]
%              if stmType='BGB' || 'BGT' -> S.frqCpdStd assigned to LE
% frqCpdR:   frequencies for std OR left  stimulus
%                   [ nCnd x nCmp ]
%              if stmType='BGB' || 'BGT' -> S.frqCpdStd assigned to LE
%              NOTE!!! codes rms contrast if stmType='1oF'!!!
% phsDegL:     phase of std OR left stimulus in deg
%                [    scalar   ] -> same     phase   for all  components
%                [ nCnd x nCmp ] -> unique   phase   for each component
% phsDegR:     phase of std OR left stimulus in deg
%                [    scalar   ] -> same     phase   for all  components
%                [ nCnd x nCmp ] -> unique   phase   for each component
% ortDeg :     orientation in degrees
%                [    scalar   ]
% BWoct:         frequency   bandwidth in octaves
%                [    scalar   ] -> same   bandwidth for all  components
%                [  1   x nCmp ] -> unique bandwidth for each component
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
% bStatic:       flag for static experiment, to check on the screen the stimulus
%                1 -> connect and run it
%                0 -> not connect
% axSignMATLEAP: sign convention for MATLEAP positions on each coordinate axis
%                [ 1  1 -1] ->*rightside up*LEAP controller
%                              righthand to lefthand coord system
%                [-1 -1 -1] ->*updside down*LEAP controller
%                              righthand to lefthand coord system
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
if ~exist('bStatic','var')       || isempty(bStatic)        bStatic = 0;       end
if ~exist('axSignMATLEAP','var') || isempty(axSignMATLEAP)  axSignMATLEAP = [1 1 -1]; end

%%%%%%%%%%%%%%%%%%
% INPUT CHECKING % % ENSURE INPUTS ARE CONSISTENT WITH EXPERIMENT TYPES
%%%%%%%%%%%%%%%%%%

% *** FIX INPUT CHECKS BEFORE FORGET ***

expType = 'TRK';

% VALID DEFOCUS INPUTS? (IF ANY ARE NON-ZERO...) ONE PAIR PER RUN ONLY
if dfcL ~= 0 || dfcR ~= 0
    if ~strcmp(expType,'STB') && ~strcmp(expType,'SBF')
        error(['ExpLMStracking: WARNING! dfcL=[' num2str(dfcL) '] and dfcR=[' num2str(dfcR) '] are INVALID inputs for expType=' expType]);
    end
end
% VALID VDF INPUTS? (IF ANY ARE NON-ZERO...)
if ~isempty(find(vdfL ~= 0, 1)) || ~isempty(find(vdfR ~= 0, 1))
    if ~strcmp(expType,'VDF') && ~strcmp(expType,'SBF')
        error(['ExpLMStracking: WARNING! vdfL=[' num2str(vdfL) '] and vdfR=[' num2str(vdfR) '] are INVALID inputs for expType=' expType]);
    end
end
% VALID NDF INPUTS? (IF ANY ARE NON-ZERO...) ONE PAIR PER RUN ONLY
if ndfL ~= 0 || ndfR ~= 0
    if ~strcmp(expType,'LVF') && ~strcmp(expType,'LSB')
        error(['ExpLMStracking: WARNING! ndfL=[' num2str(ndfL) '] and ndfR=[' num2str(ndfR) '] are INVALID inputs for expType=' expType]);
    end
end

% *** SHOULD HAVE INPUT CHECKING FOR MICHELSON CONTRAST? THINK ***

% % CHECK MICHELSON CONTRAST INPUTS
% if ~isempty(find(mchL ~= 1, 1)) || ~isempty(find(mchR ~= 1, 1))
%     if ~strcmp(expType,'CPE') && ~strcmp(expType,'CGB') && ~strcmp(expType,'MGB')
%     error(['ExpLMStracking: WARNING! mchL=[' num2str(mchL) '] and mchR[=' num2str(mchR) '] are INVALID inputs for expType=' expType]);
%     end
% end
% CHECK MATLEAP SIGNED COORDINATE AXES
if numel(axSignMATLEAP) ~= 3 || (~isequal(axSignMATLEAP,[1 1 -1]) & ~isequal(axSignMATLEAP,[-1 -1 -1]))
    error(['ExpLMStracking: WARNING! axSignMATLEAP must equal [1 1 -1] for rightside up) OR [-1 -1 -1] for upside down. axSignMATLEAP=[' num2str(axSignMATLEAP) ']']);
else
    D.axSignMATLEAP = axSignMATLEAP;
    if     isequal(axSignMATLEAP,[ 1  1 -1]);
        D.orientMATLEAP = 'rightsideup';
    elseif isequal(axSignMATLEAP,[-1 -1 -1]);
        D.orientMATLEAP = 'upsidedown';
    end
end

if mod(trlPerRun,size(MaxContrastLMS,1))~=0
    error('ExpLMStracking: trlPerRun must be a multiple of number of stimulus conditions!');
end

if ~isequal(frqCpdL,frqCpdR) || ~isequal(mchL,mchR) || ~isequal(phsDegL,phsDegR)
    error('ExpLMStracking: frqCpd, mchL, and phsDeg need to be the same between the left and right eye for this experiment!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNIFY PARAMETER VALUES IF mtnType=BLX OR mtnType=BRX %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(mtnType,'BLX') dfcR=dfcL; vdfR=vdfL; ndfR=ndfL; mchR=mchL; pssTypeR=pssTypeL; end
if strcmp(mtnType,'BRX') dfcL=dfcR; vdfL=vdfR; ndfL=ndfR; mchL=mchR; pssTypeL=pssTypeR; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NUMBER OF CONDITIONS IN RUN %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nCnd = max([size(vdfL,1) size(vdfR,1) size(mchL,1) size(mchR,1)]);
% TRIALS PER CONDITION
trlPerCnd = trlPerRun./nCnd;
% CHECK # TRIALS VALID GIVEN # CONDITIONS
if mod(trlPerCnd,1) ~= 0 error(['ExpLMStracking: WARNING! trlPerRun=' num2str(trlPerRun) ' must be a factor of nCnd=' num2str(nCnd) '!']); end;
% DOUBLE CHECK THAT CONDITIONS ARE MATCHED
if ~isequal(size(vdfL      ),size(    vdfR  )) error(['ExpLMStracking: WARNING! vdfL     and vdfR     must be the same size. Check inputs!']); end;
if ~isequal(size(mchL      ),size(    mchR  )) error(['ExpLMStracking: WARNING! mchL     and mchR     must be the same size. Check inputs!']); end;

%%%%%%%%%%%%%%%%%%%%%%
% STIMULUS STRUCTURE %
%%%%%%%%%%%%%%%%%%%%%%
S.subjName     = repmat(subjName,    [  trlPerRun, 1]);
S.IPDmm        = IPDmm;
S.trlPerRun    = trlPerRun; %number of trials
S.rndSeed      = randi(1000, 1); rng(S.rndSeed);

S.expType      = repmat(expType,     [S.trlPerRun, 1]);
S.stmType      = repmat(stmType,     [S.trlPerRun, 1]);      % STIMULUS TYPE
S.mtnType      = repmat(mtnType,     [S.trlPerRun, 1]);      % MOTION   TYPE
S.device       = repmat(device,      [S.trlPerRun, 1]);

S.stmSzXYdeg   = repmat(stmSzXYdeg,  [S.trlPerRun, 1]);

S.dfcL         = repmat(dfcL,        [S.trlPerRun, 1]);       % DEFOCUS IN LE (IN DIOPTERS)
S.dfcR         = repmat(dfcR,        [S.trlPerRun, 1]);      % DEFOCUS IN RE (IN DIOPTERS)
if size(vdfL(:),1) == 1
    S.vdfL         = repmat(vdfL,        [S.trlPerRun, 1]);       % VIRTUAL OPTICAL DENSITY IN LE
    S.vdfR         = repmat(vdfR,        [S.trlPerRun, 1]);       % VIRTUAL OPTICAL DENSITY IN RE
else
    S.vdfL         = imresize(vdfL(:),[S.trlPerRun,1],'nearest'); % VIRTUAL OPTICAL DENSITY IN LE
    S.vdfR         = imresize(vdfR(:),[S.trlPerRun,1],'nearest'); % VIRTUAL OPTICAL DENSITY IN RE
    indRnd         = randsample(S.trlPerRun,S.trlPerRun);
    S.vdfL         = S.vdfL(indRnd,:);
    S.vdfR         = S.vdfR(indRnd,:);
end
S.trmL         = opticaldensity2transmittance(S.vdfL, 0);     % TRANSMITTANCE OF VIRTUAL FILTER IN LE
S.trmR         = opticaldensity2transmittance(S.vdfR, 0);     % TRANSMITTANCE OF VIRTUAL FILTER IN RE

S.ndfL         = repmat(ndfL,        [S.trlPerRun, 1]);       %  REAL   OPTICAL DENSITY IN LE
S.ndfR         = repmat(ndfR,        [S.trlPerRun, 1]);       %  REAL   OPTICAL DENSITY IN RE
if size(mchL(:),1) == 1
    S.mchL         = repmat(mchL,        [S.trlPerRun, 1]);       % MICHELSON CONTRAST IN LE
    S.mchR         = repmat(mchR,        [S.trlPerRun, 1]);       % MICHELSON CONTRAST IN RE
    indRnd         = randsample(S.trlPerRun,S.trlPerRun);
else
    indRnd         = randsample(S.trlPerRun,S.trlPerRun);
end

% NUMBER OF COMPONENTS
nCmp = size(frqCpdL,2);
S.frqCpdL     = imresize(frqCpdL,[S.trlPerRun nCmp],'nearest');
S.frqCpdR     = imresize(frqCpdR,[S.trlPerRun nCmp],'nearest');
S.phsDegL     = imresize(phsDegL,[S.trlPerRun nCmp],'nearest');
S.phsDegR     = imresize(phsDegR,[S.trlPerRun nCmp],'nearest');
S.mchL        = imresize(mchL,[S.trlPerRun nCmp],'nearest');
S.mchR        = imresize(mchR,[S.trlPerRun nCmp],'nearest');
S.MaxContrastLMS = imresize(MaxContrastLMS,[S.trlPerRun nCmp*3],'nearest');
S.ortDeg      = imresize(ortDeg,[S.trlPerRun, nCmp],'nearest');
S.BWoct       = imresize(BWoct,[S.trlPerRun,1],'nearest');
S.BWort       = imresize(BWort,[S.trlPerRun, 1],'nearest');

% SCRAMBLE
S.frqCpdL = S.frqCpdL(indRnd,:);
S.frqCpdR = S.frqCpdR(indRnd,:);
S.mchL    = S.mchL(indRnd,:);
S.mchR    = S.mchR(indRnd,:);
S.phsDegL = S.phsDegL(indRnd,:);
S.phsDegR = S.phsDegR(indRnd,:);
S.ortDeg = S.ortDeg(indRnd,:);
S.BWoct = S.BWoct(indRnd,:);
S.BWort = S.BWort(indRnd,:);
S.MaxContrastLMS = S.MaxContrastLMS(indRnd,:);

% S.frqCpdCutoff = repmat(frqCpdCutoff,[S.trlPerRun, 1]);       %

S.magORval     = repmat('val',       [S.trlPerRun, 1]);       % SUBJ RESPONDS ACCORDING TO MAGNITUDE OF VARIABLE VS. SIGN OF VARIABLE?
S.bUseFeedback = repmat(bUseFeedback,[S.trlPerRun, 1]);
S.bStatic      = bStatic;

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
S.phsDspArcmin = repmat(phsDspArcmin', [trlPerRun./length(phsDspArcmin), 1]);
% INITIAL PHASE DISPARITY (LEFT OR RIGHT SIDE START
phsDegInit1             = 0;
phsDegInit2             = 180;
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
if     strcmp(D.cmpInfo.localHostName,'jburge-wheatstone')
    D.stereoMode = 6;
elseif strcmp(D.cmpInfo.localHostName,'Mac-mini-de-VioBioMac-11')
    D.stereoMode = 2;
elseif strcmp(D.cmpInfo.localHostName,'PORTATILVIOBIO')
    D.stereoMode = 2;
elseif strcmp(D.cmpInfo.localHostName, 'DESKTOP-1B5EIAM')
    D.stereoMode = 2;
elseif strcmp(D.cmpInfo.localHostName,'jburge')
    % D.stereoMode = 0;   % NO STEREO MODE
    D.stereoMode = 4;   % LEFT / RIGHT SPLIT SCREEN
    %     D.stereoMode = 8; % RED  / BLUE  ANAGLYPH
else
    disp(['ExpLMStracking: WARNING! running in stereoMode b/c D.cmpInfo.localHostName~=jburge-wheatstone. Rather D.cmpInfo.localHostName' D.cmpInfo.localHostName ]);
    D.stereoMode = 0;
end

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
disp(['ExpLMStracking: Starting tracking experiment with Gabor ' D.cmpInfo.localHostName]);
disp(['                        Experimental type  = '         expType      ]);
disp(['                            Stimulus type  = '         stmType      ]);
disp(['                              Motion type  = '         mtnType      ]);
disp(['                        Total trls in Exp  = ' num2str(S.trlPerRun) ]);
disp(['                              Trls in Run  = ' num2str(S.trlPerRun) ]);
disp(['                              Fcs Err Dff  = ' num2str(dfcR-dfcL)   ]);
disp(['                              Opt Dns Dff  = ' num2str(vdfR-vdfL)   ]);
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
else
    % Get Cal Data
    cal = LoadCalFile('ViewSonicG220fb',[],getpref('ColorTracking','CalFolder'));
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
% S.lumL(1:S.trlPerRun,1)  = D.correctedBgd;  % PROPORTION OF LUMINANCE RANGE... e.g. 0.5 = min(L)+0.5.*diff(minmaxLocal(L))
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

for t = 1:S.trlPerRun;
    
    contrastImage = generateStimContrastProfile(S.imgSzXYdeg(t,:),S.smpPerDeg(t),S.frqCpdL(t),S.ortDeg(t),S.phsDegL(t),bandwidthOct2sigma(S.frqCpdL(t),S.BWoct(t)));
                                                                                                                                                                                                                                                                    
    SetSensorColorSpace(calStructOBJ,T_cones_ss2,S_cones_ss2);
  
    SetGammaMethod(calStructOBJ,2);
    
    backgroundExcitations = PrimaryToSensor(calStructOBJ,D.bgd');
    
    [stmLE,~,imgInfo] = generateChromaticGabor(calStructOBJ,contrastImage,backgroundExcitations,S.MaxContrastLMS(t,:)');
    
    stmRE = stmLE;
    
    % SAVE ALL STIMULI IN A STRUCTURE
    S.stmLE(:, :, :, t) = stmLE;
    S.stmRE(:, :, :, t) = stmRE;
end

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
    if     strcmp(S.mtnType(1,1),'S') % SINUSOIDAL MOTION
        % STIMULUS DURATION IN SECONDS
        secPerTrl     = 11;
        % STIMULUS DURATION IN MILLSECONDS
        S.durationMs  = repmat(secPerTrl.*1000,[S.trlPerRun 1]);;
        % ENSURE THAT INTERFRAME INTERVAL (IN SEC) IS A NICE ROUND NUMBER
        D.fps          = round(1./D.ifi);
        D.ifi          = 1./D.fps;
        % FRAME SAMPLES IN SECS
        S.tSec         = [0:D.ifi:nSecPerTrial]';
        % STIMULUS DURATION IN FRAMES
        numFrm         = length(S.tSec);
        sigmaQmm       = 0;
        S.sigmaQmm     = repmat(sigmaQmm,[S.trlPerRun, 1]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ONSCREEN IMAGE POSITION %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % DISPARITY CREATED SHIFTING THE LEFT EYE (phase difference added to LE)
        S.tgtXpixL(:, t)=Apix.*cosd((2*pi*nCycPerSec).*S.tSec + phsDegInit + phsDspDeg);
        S.tgtXpixR(:, t)=Apix.*cosd((2*pi*nCycPerSec).*S.tSec + phsDegInit);
    elseif strcmp(S.mtnType(1,1),'B') || strcmp(S.mtnType(1,1),'O') % BROWNIAN MOTION
        %% STIMULUS DURATION IN SECONDS
        secPerTrl    = 11;
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
            error(['ExpLMStracking: WARNING! unhandled mtnType=' mtnType]);
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
        disp(['ExpLMStracking: WARNING! unhandled stmType= ' S.stmType(1,:)]);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% START RUNNING EXPERIMENT %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DRAW LEFT EYE CONTENT
Screen('SelectStereoDrawBuffer', D.wdwPtr, 0);
% DRAW LEFT EYE BACKGROUND
Screen('FillRect', D.wdwPtr, D.correctedBgd.*S.trmL(1), D.wdwXYpix);
% DRAW LEFT EYE FIXATION
Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmL(1), D.fixStm); % Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht]           , D.fixStm);
% DRAW LEFT EYE 1/F MASK (IF NECESSARY)
if bUseMsk == 1 % Screen('BlendFunction', D.wdwPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawTexture', D.wdwPtr, tex1oF, [], [D.scrnXYpix.*(1-mskScale)/2 D.scrnXYpix-D.scrnXYpix.*(1-mskScale)/2], [], [], [], [D.wht D.wht D.wht].*S.trmL(1) );
end

% DRAW RIGHT EYE CONTENT
Screen('SelectStereoDrawBuffer', D.wdwPtr, 1);
% DRAW RIGHT EYE BACKGROUND
Screen('FillRect', D.wdwPtr, D.correctedBgd.*S.trmR(1), D.wdwXYpix);
% DRAW RIGHT EYE FIXATION
Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmR(1), D.fixStm); % Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht], D.fixStm);
% DRAW RIGHT EYE 1/F MASK (IF NECESSARY)
if bUseMsk == 1 % Screen('BlendFunction', D.wdwPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawTexture', D.wdwPtr, tex1oF, [], [D.scrnXYpix.*(1-mskScale)/2 D.scrnXYpix-D.scrnXYpix.*(1-mskScale)/2], [], [], [], [D.wht D.wht D.wht].*S.trmR(1) );
end

% FINISH DRAWING AND FLIP
Screen('DrawingFinished', D.wdwPtr);
Screen('Flip',D.wdwPtr);

% WAIT UNTIL ALL KEYS ARE RELEASED
while KbCheck(-1); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   COMMENTED OUT (WAIT FOR KEYPRESS)  %
% (USING WAIT FOR MOUSE CLICK INSTEAD) % % INSIDE psyPresentTrialTrackingBinoLMS.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % WAIT FOR KEYPRESS
% while 1
%     [ keyIsDown, ~, keyCode ] = KbCheck(-1);
%     if keyIsDown
%         pause(.15);
%         break;
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%
% FONT SIZE AND TYPE %
%%%%%%%%%%%%%%%%%%%%%%
Screen('TextSize', D.wdwPtr, 24);
Screen('TextFont', D.wdwPtr, 'Helvetica');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START PRESENTING TRIALS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
for t = 1:S.trlPerRun
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CHANGE LUMINANCE (IF NECESSARY) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%
    % DRAW LEFT SCREEN %
    %%%%%%%%%%%%%%%%%%%%
    Screen('SelectStereoDrawBuffer', D.wdwPtr, 0);
    % DRAW LEFT EYE BACKGROUND
    Screen('FillRect', D.wdwPtr, D.correctedBgd.*S.trmL(t), D.wdwXYpix);
    % DRAW LEFT EYE FIXATION
    Screen('FillRect',D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmL(t), D.fixStm);
    % DRAW LEFT EYE 1/F MASK
    if bUseMsk == 1,
        Screen('DrawTexture', D.wdwPtr, tex1oF, [],[D.scrnXYpix.*(1-mskScale)/2 D.scrnXYpix-D.scrnXYpix.*(1-mskScale)/2], [], [], [], [D.wht D.wht D.wht].*S.trmL(t) ); % Screen('BlendFunction', D.wdwPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    % DRAW RIGHT SCREEN %
    %%%%%%%%%%%%%%%%%%%%%
    Screen('SelectStereoDrawBuffer', D.wdwPtr, 1);
    % Screen('BlendFunction', D.wdwPtr, 'GL_ONE', 'GL_ONE');
    % DRAW RIGHT EYE BACKGROUND
    Screen('FillRect', D.wdwPtr, D.correctedBgd.*S.trmR(t), D.wdwXYpix);
    % DRAW RIGHT EYE FIXATION
    Screen('FillRect',D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmR(t), D.fixStm);
    % DRAW RIGHT EYE 1/F MASK
    if bUseMsk == 1,
        Screen('DrawTexture', D.wdwPtr, tex1oF, [],[D.scrnXYpix.*(1-mskScale)/2 D.scrnXYpix-D.scrnXYpix.*(1-mskScale)/2], [], [], [], [D.wht D.wht D.wht].*S.trmR(t) ); % Screen('BlendFunction', D.wdwPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FINISH DRAWING AND FLIP %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('DrawingFinished', D.wdwPtr);
    Screen('Flip', D.wdwPtr);
    
    pause(.2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SET DEFAULT PRIORITY TO DEFAULT (DEFENSIVE MOVE) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if t == 1 psySetPriorityDefault(); end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SET MATLAB PRIORITY TO MAX PRIORITY %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [oldPriority,maxPriority,bPriorityMax] = psySetPriorityMax();
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PRESENT INDIVIDUAL TRIAL %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [S,bLostTrack,bEscKeyPressed] = psyPresentTrialTrackingBinoLMS(D, S, t, msk1oF);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SET MATLAB PRIORITY TO OLD PRIORITY %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bPriorityMax = psySetPriorityOld(oldPriority,maxPriority,bPriorityMax);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SALVAGE TRIAL IF PROBLEM OCCURED (IF POSSIBLE) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if bLostTrack == 0 % NO ISSUES... PROCEED NORMALLY
        S.lostTrackCnt(t,1) = 0;
    elseif bLostTrack == 1 % LOST TRACK (FROM MATLEAP)
        % COUNT NUMBER OF LOST TRACKS PER TRIAL
        S.lostTrackCnt(t,1) = 1;
        % TRY AGAIN (UP TO THREE TIMES)
        while bLostTrack == 1 && S.lostTrackCnt(t) <= 3
            % RETRY TRIAL
            [S,bLostTrack,bEscKeyPressed] = psyPresentTrialTrackingBinoLMS(D, S, t, msk1oF);
            % COUNT NUMBER OF LOST TRACKS DURING TRIALS
            if bLostTrack == 1
                S.lostTrackCnt(t,1) = S.lostTrackCnt(t) + 1;
            end
        end
        % QUIT IF MANY TRACKS ARE LOST ON SAME TRIAL (SOMETHING IS WRONG)
        if S.lostTrackCnt(t,1) > 3
            % SHOW CURSOR
            ShowCursor(1);
            % CLOSE 1/F MASK TEXTURE
            if bUseMsk == 1,
                Screen('Close', tex1oF);
            end
            % CLOSE SCREEN
            Screen('CloseAll');
            sca
            disp(['ExpLMStracking: WARNING! Experiment quit b/c of MULTIPLE lost tracks']);
            return;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%
    % DRAW LEFT SCREEN %
    %%%%%%%%%%%%%%%%%%%%
    Screen('SelectStereoDrawBuffer', D.wdwPtr, 0);
    % DRAW LEFT EYE BACKGROUND
    Screen('FillRect', D.wdwPtr, D.correctedBgd.*S.trmL(t), D.wdwXYpix);
    % DRAW LEFT EYE FIXATION
    Screen('FillRect',D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmL(t), D.fixStm);
    % DRAW LEFT EYE 1/F MASK
    if bUseMsk == 1,
        Screen('DrawTexture', D.wdwPtr, tex1oF, [],[D.scrnXYpix.*(1-mskScale)/2 D.scrnXYpix-D.scrnXYpix.*(1-mskScale)/2], [], [], [], [D.wht D.wht D.wht].*S.trmL(t) ); % Screen('BlendFunction', D.wdwPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    % DRAW RIGHT SCREEN %
    %%%%%%%%%%%%%%%%%%%%%
    Screen('SelectStereoDrawBuffer', D.wdwPtr, 1);
    % Screen('BlendFunction', D.wdwPtr, 'GL_ONE', 'GL_ONE');
    % DRAW RIGHT EYE BACKGROUND
    Screen('FillRect', D.wdwPtr, D.correctedBgd.*S.trmR(t), D.wdwXYpix);
    % DRAW RIGHT EYE FIXATION
    Screen('FillRect',D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmR(t), D.fixStm);
    % DRAW RIGHT EYE 1/F MASK
    if bUseMsk == 1,
        Screen('DrawTexture', D.wdwPtr, tex1oF, [],[D.scrnXYpix.*(1-mskScale)/2 D.scrnXYpix-D.scrnXYpix.*(1-mskScale)/2], [], [], [], [D.wht D.wht D.wht].*S.trmR(t) ); % Screen('BlendFunction', D.wdwPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FINISH DRAWING AND FLIP %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('DrawingFinished', D.wdwPtr);
    Screen('Flip', D.wdwPtr);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % WAIT UNTIL ALL KEYS ARE RELEASED %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while KbCheck(-1); end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % EXIT IF ESCAPE KEY PRESSED IN TRACKING TRIAL %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if bEscKeyPressed == 1
        % SHOW CURSOR
        ShowCursor(1);
        % RETURN PRIORITY TO DEFAULT STATE
        psySetPriorityDefault()
        % CLOSE 1/F MASK TEXTURE
        if bUseMsk == 1,
            Screen('Close', tex1oF);
        end
        % CLOSE SCREEN
        Screen('CloseAll');
        sca
        disp(['ExpLMStracking: WARNING! Experiment quit b/c of ESCAPE key press']);
        return;
    end
    
    % COUNTER TO CHANGE THE TEXTURE EVERY D.mskReset TRIALS
    if bUseMsk == 1
        if mod(t + 1, D.mskReset) == 0
            Screen('Close', tex1oF);
            % msk1oF = psyMask1overF(D.scrnXYpix,[kWidth kHeight],[0 0],0,1);
            msk1oF = psyMask1overF(D.scrnXYpix.*mskScale,kRadius,[0 0],0,1);
            tex1oF = Screen('MakeTexture', D.wdwPtr, msk1oF, [], [], 2);
        end
    end
    
    pause(.15);
end
%% ------------------END OF SESSION--------------------
%%%%%%%%%%%%%
% PLOT DATA %
%%%%%%%%%%%%%
maxLagSec = 2;
smpBgnEnd = 1;
bPLOTxcorr = 1;
tLbl='X'; rLbl='X'; xcorrEasy(diff(S.tgtXmm),diff(S.rspXmm),[S.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr); xlim([-0.5 1.5]); ylim([-.1 .25]); plot([0 0],ylim,'k--'); formatFigure(['Lag (sec)'],['Correlation'],['Q=' num2str(S.sigmaQmm(1)) '; Tgt' tLbl ' vs Rsp' rLbl]); set(gcf,'position',[35  386 476 420]);
tLbl='Z'; rLbl='Z'; xcorrEasy(diff(S.tgtZmm),diff(S.rspZmm),[S.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr); xlim([-0.5 1.5]); ylim([-.1 .25]); plot([0 0],ylim,'k--'); formatFigure(['Lag (sec)'],['Correlation'],['Q=' num2str(S.sigmaQmm(1)) '; Tgt' tLbl ' vs Rsp' rLbl]); set(gcf,'position',[479 386 476 420]);
tLbl='X'; rLbl='Z'; xcorrEasy(diff(S.tgtXmm),diff(S.rspZmm),[S.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr); xlim([-0.5 1.5]); ylim([-.1 .25]); plot([0 0],ylim,'k--'); formatFigure(['Lag (sec)'],['Correlation'],['Q=' num2str(S.sigmaQmm(1)) '; Tgt' tLbl ' vs Rsp' rLbl]); set(gcf,'position',[917 386 476 420]);

%%%%%%%%%%%%%
% SAVE DATA %
%%%%%%%%%%%%%
disp(['ExpLMStracking: SAVING DATA...']);
if strcmp(D.cmpInfo.localHostName,'jburge-hubel')
    savePSYdataLMS(S.fname(1,:),expType,S.subjName(1,:),'both',0,S,'S');
else
    savePSYdataLMS(S.fname(1,:),expType,S.subjName(1,:),'local',0,S,'S');
end
% if strcmp(S.expType(1,:),'BPF')
%     S.stmLE = S.stmLE(:,:,1);
%     S.stmRE = S.stmRE(:,:,1);
%     for i = 1:5, disp(['ExpPulfrich: SAVING ONLY ONE stmLE AND stmRE IMAGE MATRIX B/C ALL ARE IDENTICAL...']); end
% else
%     for i = 1:5,
%     disp(['ExpLMStracking: WARNING! make sure to decide carefully whether or not to save all S.stmLE and S.stmRE fields w. expType=' expType(1,:)]);
%     end
% end
%
% if ismac == 1
%     if strcmp(D.cmpInfo.localHostName, 'Mac-mini-de-VioBioMac-11') == 1;
%         savePSYdataPFTlaptop(S.fname(1,:),S.expType(1, :),S.subjName(1, :),0,S,'S', [], D);
%     else
%         savePSYdataPFT(S.fname(1,:),S.expType(1, :),S.subjName(1, :),'both',0,S,'S',D,'D');
%       % savePSYdataPRJ('PFT',S.fname(1,:),S.expType(1, :),S.subjName(1, :),'local',0,S,'S',D,'D');
%     end
% elseif ismac == 0
%    savePSYdataPFTlaptop(S.fname(1,:),S.expType(1, :),S.subjName(1, :),0,S,'S', [], D);
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
ShowCursor(1);

% CLOSE PTB WINDOW
Screen('CloseAll');
sca

return
end

