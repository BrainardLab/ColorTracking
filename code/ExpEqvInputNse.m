function [S D] = ExpEqvInputNse(Sexp,subjName,indTrl,bUseFeedback,breakEvery,bSKIPSYNCTEST,bDEBUG)

% function [S D] = ExpEqvInputNse(Sexp,subjName,indTrl,bUseFeedback,breakEvery,bSKIPSYNCTEST,bDEBUG)
%
% example calls: S = psyStimStructSPD_EQV('trlPerLvl',50,'numXpos',15,'smpPerSec',60,'numFrm',15,'stmXYdeg',[1 1],'nseRMS', ...
%                                         [0.1],'tgtRMS',[0.15],'frqCpd',[1], ...
%                                         'phsRad',[],'spdDegPerSec',2,'DC',0.4, ...
%                                         'WtimeDskWdth',7,'WtimeRmpWdth',8,'rndSd',1,'bPlot',0)
%                S = ExpEqvInputNse(S,'JNK',1:50,1,10,1,0)
%
% run equivalent input noise experiment
%
% S              : stimulus structure (see psyNatStimStructure_NATRMS.m)
% subjName       : three initial subject code
%                'JNK', 'JDB', etc
% indTrl         : indices of trials to run e.g. only trials 1 to 30
% bUseFeedback   : boolean indicating whether to use feedback or not
% breakEvery     : how many trials to have between breaks
% bSKIPSYNCTEST  : flag for skipping the psychtoolbox synctests
%                NOTE! experimental data should be gathered only when = 0
%                1 -> skip ptb sync tests
%                0 -> skip ptb sync tests
% bDEBUG:        flag for debugging
%                1 -> DEBUGGIN!
%                0 -> run for serious
% %%%%%%%%%%%%%%%%%%%%%%
% S:             stimulus parameters and subject responses
% D:         	 display  parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT PARSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = inputParser();
p.addRequired('Sexp',@isstruct);
p.addRequired('subjName',@isstr);
p.addRequired('indTrl',@isnumeric);
p.addRequired('bUseFeedback',@isnumeric);
p.addRequired('bSKIPSYNCTEST',@isnumeric);
p.addRequired('bDEBUG',@isnumeric);

p.parse(Sexp,subjName,indTrl,bUseFeedback,bSKIPSYNCTEST,bDEBUG);

Sexp = p.Results.Sexp;
subjName = p.Results.subjName;
indTrl = p.Results.indTrl;
bUseFeedback = p.Results.bUseFeedback;
bSKIPSYNCTEST = p.Results.bSKIPSYNCTEST;
bDEBUG = p.Results.bDEBUG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STRUCT FIELDS TO DEFINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUT HANDLING
if ~exist('bSKIPSYNCTEST','var') || isempty(bSKIPSYNCTEST)  bSKIPSYNCTEST = 0; end
if ~exist('bDEBUG','var')        || isempty(bDEBUG)         bDEBUG = 0;        end

S              = structElementSelect(Sexp,indTrl,Sexp.trlPerExp);

if ~isfield(S,'prjCode')
    S.prjCode      = 'SPD';
    display(['ExpEqvInputNse: WARNING! prjCode not defined in Sexp previously. Add it to psyStimStructSPD_EQV']);
end

S.subjName     = subjName;
S.stmType      = 'SIN';
S.magORval     = 'mag';
S.trlPerRun    = length(indTrl);
S.bUseFeedback = repmat(bUseFeedback,   [S.trlPerRun 1]);
S.isi          = 0.25;        % INTER-STIMULUS INTERVAL IN SECONDS

% DISPLAY RIG IDENTITY & COLOR VALUES
D.computer  = computer;
D.cmpInfo   = psyComputerInfo;

% GET COMPUTER INFO
D.cmpInfo = psyComputerInfo();
% LOAD MONITOR CALIBRATION DATA (GAMMA DATA)
[D.cal,D.gamFncX,D.gamFncY,D.gamInv] = psyLoadCalibrationData(D.cmpInfo.localHostName);
if size(D.gamFncY,2) == 3
   D.gamFncY = D.gamFncY(:,3); 
end
% % *** FIX THIS EVENTUALLY: GAMMA FUNCTION MUST GO FROM 0 TO 1 ***
D.gamFncY = D.gamFncY-min(D.gamFncY);
D.gamFncY = D.gamFncY/max(D.gamFncY);

D.blk       = 0.0;
D.gryNoVideoSwitcher = 0.4;
D.gry       = squeeze(psyVideoSwitcherPHT2RGB(D.gryNoVideoSwitcher,D.gamFncX,D.gamFncY,0))'; % 128; % 0.5000;
D.wht       = 1.0; % 255; % 1.0000;
D.bUseMsk   = 1;     
D.kRadius   = 0.25;

% % SET MEAN LUMINANCE
% S.stdDC(1:S.trlPerRun,:) = D.gry;  % PROPORTION OF LUMINANCE RANGE... e.g. 0.5 = min(L)+0.5.*diff(minmax(L))
% S.cmpDC(1:S.trlPerRun,:) = D.gry;

% FILE NAMING
S.fname         = buildFilenamePSYdataSPD(S.expType(1,:),S.subjName,S.stmType);
S.fname         = repmat(S.fname,[S.trlPerRun 1]);
S.fdirLoc       = buildFolderNamePSY(S.prjCode,S.expType(1,:),S.subjName,'local');
S.fdirSrv       = buildFolderNamePSY(S.prjCode,S.expType(1,:),S.subjName,'server');

% PRINT DATA TO SCREEN
disp(['ExpEqvInputNse: Starting ' ' experiment! on ' D.cmpInfo.localHostName]);
disp(['                        Total Trls in Exp  = ' num2str(S.trlPerExp) ]);
disp(['                              Trls in Run  = ' num2str(S.trlPerRun) ]);
disp(['tgtRMS values: ' num2str(unique(S.tgtRMS)')]);
disp(['nseRMS values: ' num2str(unique(S.nseRMS)')]);
disp(['Freq values: ' num2str(unique(S.frqCpd)')]);
disp(['                        Correct stim coded as stim with larger ' S.magORval ]);
disp(['      Saving PSYdata to fname= ' num2str(S.fname(1,:)) ]);
pause(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATING XYT STIM FOR PRESENTATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Y WINDOW JUST FOR PRESENTATION
S.Wy = cosWindow([S.numXpos(1) 1],1)';

for t = 1:S.trlPerRun
     % CMP STIMS CONTAINS TARGET & NOISE
     [cmpIphtXYTtmp, cmpIwebXTtmp] = psyCreateStimEQV(S.IccdWeb(:,t),S.numXpos(t),S.numFrm(t),S.tgtRMS(t),S.DC(t),S.W,S.Wy,1,S.IccdWebNseCmp(:,t),S.nseRMS(t),0);
     % TGT STIMS CONTAINS          NOISE ONLY
     [stdIphtXYTtmp, stdIwebXTtmp] = psyCreateStimEQV([],            S.numXpos(t),S.numFrm(t),S.tgtRMS(t),S.DC(t),S.W,S.Wy,1,S.IccdWebNseStd(:,t),S.nseRMS(t),0);
     % XYT MOVIES
     cmpIphtXYT(:,:,:,t) = cmpIphtXYTtmp;
     stdIphtXYT(:,:,:,t) = stdIphtXYTtmp;
     % XT MOVIES
     S.IccdWebXTcmp(:,t) = cmpIwebXTtmp;
     S.IccdWebXTstd(:,t) = stdIwebXTtmp;
     % CONVERT EACH FRAME INTO AN R+B IMAGE
     for f = 1:size(cmpIphtXYT,3)
        cmpIphtXYTrgb(:,:,:,f,t) = psyVideoSwitcherPHT2RGB(squeeze(cmpIphtXYT(:,:,f,t)),D.gamFncX,D.gamFncY,0); 
        stdIphtXYTrgb(:,:,:,f,t) = psyVideoSwitcherPHT2RGB(squeeze(stdIphtXYT(:,:,f,t)),D.gamFncX,D.gamFncY,0); 
     end
end

% CREATE PRACTICE TARGET FOR SUBJECT TO LOOK AT BEFORE EXPERIMENT STARTS
% practiceTarget = psyCreateStimEQV(S.IccdWeb(:,t),S.numXpos(t),S.numFrm(t),max(S.tgtRMS),S.DC(t),S.W,S.Wy,1,S.IccdWebNseCmp(:,t),0,0);
practiceTarget = psyCreateStimEQV(S.IccdWeb(:,t),S.numXpos(t),S.numFrm(t),0.15,S.DC(t),S.W,S.Wy,1,S.IccdWebNseCmp(:,t),0,0);
% CONVERT EACH FRAME INTO AN R+B IMAGE
for f = 1:size(practiceTarget,3)
    practiceTargetCrt(:,:,:,f) = psyVideoSwitcherPHT2RGB(squeeze(practiceTarget(:,:,f)),D.gamFncX,D.gamFncY,0); 
end

% UNIQUE STIMULUS AND NOISE VALUES FOR PRE-EXPERIMENT SCREEN
tgtRMS2display = unique(S.tgtRMS);
nseRMS2display = unique(S.nseRMS);

% LETS YOU KNOW EXPERIMENT STARTED
sound(sin(0.54.*[0:1439]).*cosWindowFlattop([1 1440],720,720,0));

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

%%%%%%%%%%%%%%%%%%%
% OPEN PTB WINDOW %
%%%%%%%%%%%%%%%%%%%
D         = psyPTBopenWindow(D);    % returns .wdwPtr, .wdwXYpix
% SET BLENDING OPTIONS
D         = psyPTBalphaBlending(D); % requires D.wdwPtr
% DISPLAY PARAMETERS
D         = psyPTBdisplayParameters(D); % requires D.wdwPtr... PHASE OUT CALL: D.bitsOut = Screen('PixelSize',D.wdwPtr);

% SET STIMULUS PARAMETERS %
D.plyXYpix = bsxfun(@times,S.stmXYdeg,D.pixPerDegXY);

% BUILD DESTINATION RECTANGLE IN MIDDLE OF DISPLAY
D.plySqrPix    = CenterRect([0 0 D.plyXYpix(1) D.plyXYpix(2)], D.wdwXYpix);
plySqrPixCrdXY = D.plySqrPix(1:2);
plySqrPixSizXY = D.plySqrPix(3:4)-D.plySqrPix(1:2);

% BUILD FIXATION CROSS HAIRS
% WRITE FUNCTION FOR BUILDING FIXATION CROSS HAIRS
% psyFixationStim_CrossHairs( );
[fPosX,fPosY] = RectCenter(D.wdwXYpix);
D.fixStm = [fPosX-1,fPosY+plySqrPixSizXY(2),fPosX+1,fPosY+plySqrPixSizXY(2)+25; ...
            fPosX-1,fPosY-plySqrPixSizXY(2),fPosX+1,fPosY-plySqrPixSizXY(2)-25; ...
            fPosX+plySqrPixSizXY(1),fPosY+1,fPosX+plySqrPixSizXY(1)+25,fPosY-1; ...
            fPosX-plySqrPixSizXY(1),fPosY+1,fPosX-plySqrPixSizXY(1)-25,fPosY-1]';

% NUMBER OF ROWS IN THE IMAGE WE WILL USE FOR TESTING QUANTIZATION
numRowsTestQuantImg = round(D.wdwXYpix(3)/40);
% NUMBER OF ROWS IN THE IMAGE WE WILL USE FOR TESTING QUANTIZATION
numColsTestQuantImg = round(D.wdwXYpix(4)/2);
% CREATE IMAGE FOR TESTING QUANTIZATION
testQuantImg = zeros([numRowsTestQuantImg numColsTestQuantImg]);
% NUMBER OF BARS IN TEST IMAGE
numTestBars = 20;
% MAKE ENDING LOCATIONS FOR EACH BAR IN IMAGE
barCoordinatesPix = [1:round(numColsTestQuantImg/numTestBars):numColsTestQuantImg];
for i = 2:length(barCoordinatesPix) % FOR EACH ENDING LOCATION
   % MAKE THE BAR
   testQuantImg(:,barCoordinatesPix(i-1)+1:barCoordinatesPix(i)) = (i-2)./1023; 
end
% Screen('Preference', 'SkipSyncTests', 0);
% CONVERT TO RGB IMAGE COMPATIBLE WITH VIDEO SWITCHER
testQuantImgCrt = psyVideoSwitcherPHT2RGB(testQuantImg,D.gamFncX,D.gamFncY,0); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START RUNNING EXPERIMENT--CONFIRM GRAY LEVELS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MAKE BLACK SCREEN
Screen('FillRect', D.wdwPtr, 0);
Screen('Flip',D.wdwPtr);
% MAKE TEXTURE
testQuantImgPresent = Screen('MakeTexture', D.wdwPtr, testQuantImgCrt,[],[],2);

if   D.bUseMsk %MAKE MASK TEXTURE IF USING
    % MAKE 1/F TEXTURE AND CIRCLE
    [~,mskNoise,mskCrcle] = psyMask1overF(D.scrnXYpix,D.kRadius,[0 0],0);
    % SCALE 1/F MASK
    mskNoise=mskNoise.*(D.gryNoVideoSwitcher./mean(mskNoise(:)));
    % ADD CIRCLE
    msk1oF   = cat(3,repmat(mskNoise,[1 1 3]),mskCrcle);
    % CONVERT TO R+B
    msk1oF = psyVideoSwitcherPHT2RGB(msk1oF,D.gamFncX,D.gamFncY,0);
    % MAKE 1/F TEXTURE
    tex1oF   = Screen('MakeTexture', D.wdwPtr, msk1oF,[],[],2);
else
    msk1oF = [];
end

while KbCheck(-1); end
while 1
    % MONITOR KEY PRESS
    [ keyIsDown, ~, keyCode, ~] = KbCheck(-1);
    Screen('TextSize', D.wdwPtr, 20);
    Screen('DrawText',D.wdwPtr, 'Press up arrow to continue.', ...
           0.6.*[fPosX], 0.65.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
    Screen('DrawText',D.wdwPtr, ['If the video switcher is working, you should see ' num2str(numTestBars-2) ' unique gray bars below.'], ...
           0.6.*[fPosX], 0.7.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
    Screen('DrawTexture', D.wdwPtr, testQuantImgPresent, [], D.plySqrPix+[-300 -75 300 0]);
    Screen('Flip',D.wdwPtr);
    % IF PRESS UP ARROW, CONTINUE
    if keyIsDown & find(keyCode) == key_U_ARROW
        break;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SECOND PRE-EXPERIMENT SCREEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRING SCREEN UP TO DESIRED GRAY LEVEL
Screen('FillRect', D.wdwPtr, D.gry);

while KbCheck(-1); end
if   D.bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REDUCE TARGET UNCERTAINTY %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while 1
    % MONITOR KEY PRESS
    [ keyIsDown, ~, keyCode, ~] = KbCheck(-1);
    % IF PRESS DOWN ARROW, SHOW TARGET
    if keyIsDown & find(keyCode) == key_D_ARROW
        % DRAW 1/F TEXTURE
 %       if   D.bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
        for i = 1:size(practiceTargetCrt,4)
           % PRESENT INSTRUCTIONS
           tgt2lookAt  = Screen('MakeTexture', D.wdwPtr, squeeze(practiceTargetCrt(:,:,:,i)),[],[],2);
%          % DRAW 1/F TEXTURE
           if   D.bUseMsk; Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end
           % DRAW TARGET
           Screen('DrawTexture', D.wdwPtr, tgt2lookAt, [], D.plySqrPix);
%            Screen('DrawText',D.wdwPtr, ['Signal = ' num2str(tgtRMS2display) ' Noise = ' num2str(nseRMS2display)], ...
%                    0.8.*[fPosX], 0.65.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
           Screen('DrawText',D.wdwPtr, ['Press the down arrow key to view the target in the crosshairs.'], ...
                  0.6.*[fPosX], 0.7.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
           Screen('DrawText',D.wdwPtr, ['Press the up arrow key to start the experiment.'], ...
                  0.7.*[fPosX], 0.75.*[fPosY], [D.wht],[D.wht D.wht D.wht]);
           Screen('FillRect',D.wdwPtr, [D.wht,D.wht,D.wht], D.fixStm);
           Screen('Flip',D.wdwPtr);
        end
    % IF PRESS UP ARROW, CONTINUE
    elseif keyIsDown & find(keyCode) == key_U_ARROW
        break;
    end
end

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

%%%%%%%%%%%%%
% SAVE DATA %
%%%%%%%%%%%%%

disp(['ExpEqvInputNse: SAVING DATA...']);
savePSYdataSPD(S.fname(1,:),S.expType(1,:),S.subjName,'both',0,S,'S');

% PLOT DATA
psyfitgengaussHi2Low(S.stdX,S.nseRMS,S.R==S.cmpIntrvl,[],[],[],1,2,1)

%%%%%%%%%%%%%%%%%%%%
% CLOSE PTB WINDOW %
%%%%%%%%%%%%%%%%%%%%
pause(1);
Screen('CloseAll');
sca
return
