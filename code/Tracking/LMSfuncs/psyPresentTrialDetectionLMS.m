function [S,bTrkBad,bEsc] = psyPresentTrialDetectionLMS(D,S,t,msk1oF)

% function [S,bTrkBad,bEsc] = psyPresentTrialDetectionLMS(D,S,t,msk1oF)
%
% % TO DO: ADD CRITICAL FIELDS TO COMMENT SECTION
%          ADD WARNING THAT LEAP CONTROLLER COULD NOT BE DETECTED
%
% present target tracking psychophysical trial using 
% binocular LE and RE stimuli to assess Pulrich effect 
% with texture mapped stimuli
%
% Stimuli are mapped onto PTB-generated rectangles as textures
%   S.stmLE: left  eye image texture 
%   S.stmRE: right eye image texture
%
%   S.tgtXpixL: specifies LE rectangle vertices in X
%   S.tgtXpixR: specifies RE rectangle vertices in X
%   S.tgtYpixL: specifies LE rectangle vertices in Y
%   S.tgtYpixR: specifies RE rectangle vertices in Y
%
% NOTE! function assumes that Psychtoolbox StereoMode is engaged
%
% D:              display structure with critical fields
%                 D.wdwPtr        -> window pointer
%                 D.wdwXYpix      -> window size
%                 D.scrnXYpix     -> screen dimensions in XY pix
%                 D.scrnZmm       -> screen distance   in Z  mm
%                 D.pixPerMmXY    -> screen pixels per mm in XY
%                 D.bgd           -> gray  level
%                 D.wht           -> white level
%                 D.fixStm        -> fixation stimulus
%                 D.axSignMATLEAP -> [1 1 -1]
% S:              subject/stimulus structure with critical fields
%                 .numIntrvl      -> number of intervals
%                 .tgtXmm         -> target X position in mm
%                 .tgtYmm         -> target Y position
%                 .tgtZmm         -> target Z position
%                 .tgtXmmL        -> target X position in mm in LE
%                 .tgtXmmR        -> target X position in mm in RE
%                 .tgtYmmL        -> target Y position in mm in LE
%                 .tgtYmmR        -> target Y position in mm in RE
%                 .numFrm         -> number of frames per stimulus
%                 .isi            -> inter-stimulus interval
%                 .ifi            -> inter-frame interval
%                 .fps            -> frames per second
%                 .stmLE          -> image to creat LE texture
%                 .stmRE          -> image to creat RE texture
% t:              trial number
% msk1oF:         1/f texture for peripheral mask... see psyMask1overF.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% S:              subject/stimulus structure updated with tracking data
%                 .rspXmm         -> response X position in mm
%                 .rspYmm         -> response Y position in mm
%                 .rspZmm         -> response Z position in mm
%                 .rspXmmL        -> response X position in mm in LE
%                 .rspXmmR        -> response X position in mm in RE
%                 .rspYmmL        -> response Y position in mm in LE
%                 .rspYmmR        -> response Y position in mm in RE
% bTrkBad:        trial aborted bc LEAP controller lost hand track
% bEsc:           quits experiment if escape key pressed

%%%%%%%%%%%%%%%%%%
% INPUT HANDLING %
%%%%%%%%%%%%%%%%%%
% USE 1/F TEXTURE OR NOT
if ~exist('msk1oF','var') || isempty(msk1oF) 
    bUseMsk = 0;
else
%       if size(msk1oF,2) == D.scrnXYpix(1) && size(msk1oF,1) == D.scrnXYpix(2)
    bUseMsk = 1;
%       else
%       error(['psyPresentTrialDetectionLMS: WARNING! texture mask ''msk1oF'' not sized properly... Double check inputs']);
%       end
end

%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZE GetSecs() % FOR ACCURATE TRIAL TIMING
%%%%%%%%%%%%%%%%%%%%%%%%
GetSecs();
%%%%%%%%%%%%%%%%%%%
% OUTPUT HANDLING %
%%%%%%%%%%%%%%%%%%%
bTrkBad = 0;
bEsc    = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZE VALUES FOR QUITTING EXPERIMENT %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KbName('UnifyKeyNames')
key_ESCAPE = KbName('escape');
key_SPACE  = KbName('space');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD trmL and trmR TO STRUCT IF IT DOESN'T ALREADY EXIST %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isfield(S,'trmL') S.trmL(t) = 1; end
if length(S.trmL) < t S.trmL(t) = 1; end
if ~isfield(S,'trmR') S.trmR(t) = 1; end
if length(S.trmR) < t S.trmR(t) = 1; end

%%%%%%%%%%%%%%%%%%%%%%%%
% MOUSE CURSOR DETAILS %
%%%%%%%%%%%%%%%%%%%%%%%%
mssClr = [.1 .1 .1];
% mssSzPix = 9;
mssSzPix = 5;

%%%%%%%%%%%%%%%%%%%%
% STIMULUS TEXTURE %
%%%%%%%%%%%%%%%%%%%%
texLimg = Screen('MakeTexture', D.wdwPtr, S.stmLE(:, :, :, t), [], [], 2);
texRimg = Screen('MakeTexture', D.wdwPtr, S.stmRE(:, :, :, t), [], [], 2);

% MAKE 1/F MASK TEXTURE
if bUseMsk == 1, tex1oF = Screen('MakeTexture', D.wdwPtr, msk1oF,[],[],2); end % WARNING! REMEMBER TO CLOSE TEXTURES!

% SCREEN CENTER
D.scrnXYpixCtr = round(D.scrnXYpix/2);

%%%%%%%%%%%%%%%%%%%%%%%%
% INIT RESPONSE VECTOR %
%%%%%%%%%%%%%%%%%%%%%%%%
S.rspXpixL(:,t) = zeros(size(S.tgtXmmL(:,t)));   % ARRAY OF MOUSE CURSOR LE SCREEN POSITIONS 
S.rspXpixR(:,t) = zeros(size(S.tgtXmmR(:,t)));   % ARRAY OF MOUSE CURSOR RE SCREEN POSITIONS 

S.rspXmm(:,t)   = zeros(size(S.tgtXmm( :,t)));   % ARRAY OF MOUSE CURSOR  X-SPACE  POSITIONS 
S.rspYmm(:,t)   = zeros(size(S.tgtYmm( :,t)));
S.rspZmm(:,t)   = zeros(size(S.tgtZmm( :,t)));   % ARRAY OF MOUSE CURSOR  Z-SPACE  POSITIONS 
S.rspXmmL(:,t)  = zeros(size(S.tgtXmmL(:,t)));
S.rspXmmR(:,t)  = zeros(size(S.tgtXmmR(:,t)));
S.rspYmmL(:,t)  = zeros(size(S.tgtYmmL(:,t)));
S.rspYmmR(:,t)  = zeros(size(S.tgtYmmR(:,t)));

%%%%%%%%%%%%%%%%%%%%%%
% SET MOUSE POSITION % MOUSE PIX ASSUME (0,0) IS AT SCREEN CENTER
%%%%%%%%%%%%%%%%%%%%%%
mssXpixBgn = D.scrnXYpixCtr(1); 
mssYpixBgn = D.scrnXYpixCtr(2); 
SetMouse(mssXpixBgn,mssYpixBgn,D.wdwPtr);
HideCursor();

%%%%%%%%%%%%%%%%%
% PRESENT TRIAL %
%%%%%%%%%%%%%%%%%
numFrm = size(S.tgtXpixL(:,t),1);
if S.bStatic == 0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CLICK OR SPACE BAR STARTS TRIAL %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%
    % DRAW LEFT EYE BUFFER %
    %%%%%%%%%%%%%%%%%%%%%%%%
    Screen('SelectStereoDrawBuffer', D.wdwPtr, 0);
    % DRAW LEFT EYE BACKGROUND
    Screen('FillRect', D.wdwPtr, D.correctedBgd.*S.trmL(t), D.wdwXYpix);
    % DRAW LEFT EYE FIXATION
    Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmL(t), [D.fixStm]); % Screen('FillRect', D.wdwPtr, [ ], [D.fixStm]);
    % DRAW LEFT EYE 1/F TEXTURE
    if bUseMsk, 
    Screen('DrawTexture', D.wdwPtr, [tex1oF], [],[D.scrnXYpix.*(1-S.mskScale(t,:))/2 D.scrnXYpix-D.scrnXYpix.*(1-S.mskScale(t,:))/2], [], [], [], [D.wht,D.wht,D.wht].*S.trmL(t) ); 
    end  
    
    % DRAW LEFT EYE INSTRUCTIONS
    Screen('DrawText',D.wdwPtr,['CLICK or press SPACE to start trial! (' num2str(t,'%02d') '/' num2str(S.trlPerRun,'%02d') ')'] ,D.scrnXYpixCtr(1)-230,D.scrnXYpixCtr(2)-12,1.0.*S.trmL(t)); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % DRAW RIGHT EYE BUFFER %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('SelectStereoDrawBuffer', D.wdwPtr, 1);
    % DRAW RIGHT EYE BACKGROUND
    Screen('FillRect', D.wdwPtr, D.correctedBgd.*S.trmR(t), D.wdwXYpix);
    % DRAW RIGHT EYE FIXATION
    Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmR(t), [D.fixStm]); % Screen('FillRect', D.wdwPtr, [ ], [D.fixStm]);
    % DRAW RIGHT EYE 1/F TEXTURE
    if bUseMsk, 
    Screen('DrawTexture', D.wdwPtr, [tex1oF], [], [D.scrnXYpix.*(1-S.mskScale(t,:))/2 D.scrnXYpix-D.scrnXYpix.*(1-S.mskScale(t,:))/2], [], [], [], [D.wht,D.wht,D.wht].*S.trmR(t)); 
    end  

    % DRAW RIGHT EYE INSTRUCTIONS
    Screen('DrawText',D.wdwPtr,['CLICK or press SPACE to start trial! (' num2str(t,'%02d') '/' num2str(S.trlPerRun,'%02d') ')'],D.scrnXYpixCtr(1)-230,D.scrnXYpixCtr(2)-12,1.0.*S.trmR(t)); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FINISH DRAWING & FLIP SCREEN IN BOTH EYES %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FINISH DRAWING
    Screen('DrawingFinished', D.wdwPtr);
    % FLIP SCREEN
    Screen('Flip',    D.wdwPtr);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % WAIT FOR A CLICK OR SPACE BAR % (OR ESC TO QUIT EXPERIMENT)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while(1)
        %%%%%%%%%%%%%%%%
        % KEY PRESS??? %
        %%%%%%%%%%%%%%%%
        [ keyIsDown, ~, keyCode ] = KbCheck(-1);
        if keyIsDown
            % EXIT EXPERIMENT
            if keyCode(key_ESCAPE) == 1
                bEsc = 1;
                return;
            end
            % START TRIAL
            if keyCode(key_SPACE) == 1
                SetMouse(mssXpixBgn,mssYpixBgn,D.wdwPtr);
                break;
            end
            while KbCheck(-1); end
        end
        %%%%%%%%%%%%%%%%%%%
        % BUTTON PRESS??? %
        %%%%%%%%%%%%%%%%%%%
        [~,~,buttons] = GetMouse(D.wdwPtr);
        %%%%%%%%%%%%%%%%%%%%%%
        % SET MOUSE POSITION % 
        %%%%%%%%%%%%%%%%%%%%%%
        SetMouse(mssXpixBgn,mssYpixBgn,D.wdwPtr);
        if buttons(1)
            break
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DRAW STIMULUS AND MOUSE CURSOR AT SCREEN CENTER %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%
    % DRAW LEFT EYE BUFFER %
    %%%%%%%%%%%%%%%%%%%%%%%%
    Screen('SelectStereoDrawBuffer', D.wdwPtr, 0);
    % DRAW LEFT EYE BACKGROUND
    Screen('FillRect', D.wdwPtr, D.correctedBgd.*S.trmL(t), D.wdwXYpix);
    % DRAW LEFT EYE FIXATION
    Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmL(t), [D.fixStm]); % Screen('FillRect', D.wdwPtr, [  ], [D.fixStm]);
    % DRAW LEFT EYE STIMULUS
    Screen('DrawTexture', D.wdwPtr, texLimg, [], [S.tgtXpixL(1,t) S.tgtYpixL(1,t) S.tgtXpixL(1,t) S.tgtYpixL(1,t)] + D.plySqrPix, [], [], [], [D.wht,D.wht,D.wht].*S.trmL(t));
    % Screen('DrawTexture', D.wdwPtr, texLimg, [], [S.tgtXpixL(1,t) 0 S.tgtXpixL(1,t) 0] + D.plySqrPix);
    % DRAW LEFT EYE 1/F TEXTURE
    if bUseMsk,
    Screen('DrawTexture', D.wdwPtr, [tex1oF], [], [D.scrnXYpix.*(1-S.mskScale(t,:))/2 D.scrnXYpix-D.scrnXYpix.*(1-S.mskScale(t,:))/2], [], [], [], [D.wht,D.wht,D.wht].*S.trmL(t)); 
    end
    
    % DRAW LEFT MOUSE CURSOR AT SCREEN CENTER
    if ~strcmp(S.mtnType(t,1),'O')
    Screen('DrawDots', D.wdwPtr, [mssXpixBgn, mssYpixBgn], mssSzPix, mssClr.*S.trmL(t));
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % DRAW RIGHT EYE BUFFER %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('SelectStereoDrawBuffer', D.wdwPtr, 1);
    % DRAW RIGHT EYE BACKGROUND
    Screen('FillRect', D.wdwPtr, D.correctedBgd.*S.trmR(t), D.wdwXYpix);
    % DRAWING RIGHT EYE FIXATION
    Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmR(t), [D.fixStm]); 
    % DRAW RIGHT EYE STIMULUS
    Screen('DrawTexture', D.wdwPtr, texRimg, [], [S.tgtXpixR(1,t) S.tgtYpixR(1,t) S.tgtXpixR(1,t) S.tgtYpixR(1,t)] + D.plySqrPix, [], [], [], [D.wht,D.wht,D.wht].*S.trmR(t));
    % DRAW RIGHT EYE 1/F TEXTURE
    if bUseMsk, 
    Screen('DrawTexture', D.wdwPtr, [tex1oF], [], [D.scrnXYpix.*(1-S.mskScale(t,:))/2 D.scrnXYpix-D.scrnXYpix.*(1-S.mskScale(t,:))/2], [], [], [], [D.wht,D.wht,D.wht].*S.trmR(t)); 
    end  
    
    % DRAW RIGHT EYE MOUSE CURSOR AT SCREEN CENTER
    if ~strcmp(S.mtnType(t,1),'O')
    Screen('DrawDots', D.wdwPtr, [mssXpixBgn, mssYpixBgn], mssSzPix, mssClr.*S.trmR(t));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FINISH DRAWING & FLIP SCREEN IN BOTH EYES %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FINISH DRAWING
    Screen('DrawingFinished', D.wdwPtr);
    % FLIP SCREEN
    Screen('Flip',    D.wdwPtr);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SHORT DELAY BEFORE GAME BEGINS %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pause(0.75);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DETECT LEAP MOTION CONTROLLER %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DETECT MOTION CONTROLLER: NUMBER OF SECONDS TO CHECK
    sec2chk = 1;
    % DETECT MOTION CONTROLLER: TRY TO DETECT FOR sec2chk 
    bTrk = 0;
    if     bTrk == 1 S.bUseMATLEAP(t,1) = true; 
    elseif bTrk == 0 S.bUseMATLEAP(t,1) = false; 
    end
    
    % SET THE MOUSE TO THE SCREEN CENTER
    SetMouse(mssXpixBgn,mssYpixBgn,D.wdwPtr);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INITAL MOUSE OR LEAP POSITION %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if     S.bUseMATLEAP(t,1) == 0 % USE MOUSE
        % GET MOUSE POSITION
        [mssXpix,mssYpix] = GetMouse(D.wdwPtr); 
    elseif S.bUseMATLEAP(t,1) == 1 % USE LEAP
        % GET LEAP  POSITION
        [bTrkChk,mssXYZmm0,mssXmm0,mssYmm0,mssZmm0] = psyMATLEAPpositionCheck(sec2chk,[-100 100],[30 400],[-100 100]);
    end
    
    %%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%% %
    % % START TRIAL % %
    % %%%%%%%%%%%%%%% %
    %%%%%%%%%%%%%%%%%%%
    % TIMER: BEGIN TRIAL
    trlBgnSec = GetSecs();
    
    % START FRAME LOOP
    for f = 1:numFrm
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % COLLECT MOUSE OR MATLEAP POSITION %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if      S.bUseMATLEAP(t,1) == 0, 
            % RAW MOUSE SCREEN COORDS IN PIXELS 
            [mssXpix,mssYpix] = GetMouse(D.wdwPtr);
            % MOUSE   XYZ COORDS IN MM W.R.T. MONITOR CENTER
            mssXmm       =  (mssXpix-D.scrnXYpixCtr(1))./D.pixPerMmXY(1);
            mssYmm       =  (mssYpix-D.scrnXYpixCtr(2))./D.pixPerMmXY(2); 
            mssZmm       = -(mssYpix-D.scrnXYpixCtr(2))./D.pixPerMmXY(2); % MOUSE POS IN Zmm = MOUSE POS IN Ymm
        elseif  S.bUseMATLEAP(t,1) == 1, 
            % MATLEAP XYZ COORDS IN MM NORMALIZED BY 
            [bTrk,mssXYZmm,mssXmm,mssYmm,mssZmm] = psyMATLEAPposition(mssXYZmm0,D.axSignMATLEAP);
            
            % LEAP TRACKING FAILED (PREVENTS EXPERIMENT FROM CRASHING)
            if bTrk == 0
               bTrkBad = true;
               return;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ZERO CERTAIN COORDINATES FOR MOTION TYPE %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if     strcmp(S.mtnType(1,:),'BXZ') || strcmp(S.mtnType(1,:),'OXZ') % BROWNIAN MOTION IN XZ
            % ZERO Y-COORD IN MM W.R.T. MONITOR CENTER
            mssYmm       =   0;
            % LR COORDS IN MM W.R.T. MONITOR CENTER
            [mssXmmL,mssXmmR] = screenXfromRangeXZ([mssXmm mssZmm+D.scrnZmm],D.scrnZmm,S.IPDmm,0);
            mssYmmL = mssYmm; mssYmmR = mssYmm;
        elseif     strcmp(S.mtnType(1,:),'B0Z') || strcmp(S.mtnType(1,:),'O0Z') % BROWNIAN MOTION IN XZ
            % ZERO X & Y-COORDS IN MM W.R.T. MONITOR CENTER
            mssXmm       =   0;
            mssYmm       =   0;
            % LR COORDS IN MM W.R.T. MONITOR CENTER
            [mssXmmL,mssXmmR] = screenXfromRangeXZ([mssXmm mssZmm+D.scrnZmm],D.scrnZmm,S.IPDmm,0);
            mssYmmL = mssYmm; mssYmmR = mssYmm;
        elseif strcmp(S.mtnType(1,:),'BXY') || strcmp(S.mtnType(1,:),'OXY') % BROWNIAN MOTION IN XY
            % ZERO Z-COORD IN MM W.R.T. MONITOR CENTER
            mssZmm       =   0;
            % LR COORDS IN MM W.R.T. MONITOR CENTER
            [mssXmmL,mssXmmR] = screenXfromRangeXZ([mssXmm mssZmm+D.scrnZmm],D.scrnZmm,S.IPDmm,0);
            mssYmmL = mssYmm; mssYmmR = mssYmm;
        elseif strcmp(S.mtnType(1,:),'BPX') || strcmp(S.mtnType(1,:),'OPX') % BROWNIAN MOTION IN X W. XZ RESPONSE 
            % ZERO Y-COORD IN MM W.R.T. MONITOR CENTER
            mssYmm       =   0;
            % LR COORDS IN MM W.R.T. MONITOR CENTER
            [mssXmmL,mssXmmR] = screenXfromRangeXZ([mssXmm mssZmm+D.scrnZmm],D.scrnZmm,S.IPDmm,0);
            mssYmmL = mssYmm; mssYmmR = mssYmm;
        elseif strcmp(S.mtnType(1,:),'B0X') || strcmp(S.mtnType(1,:),'BLX') || strcmp(S.mtnType(1,:),'BRX') || ...  % BROWNIAN MOTION IN XY     
               strcmp(S.mtnType(1,:),'O0X') || strcmp(S.mtnType(1,:),'OLX') || strcmp(S.mtnType(1,:),'ORX')
            % ZERO Y & Z-COORDS IN MM W.R.T. MONITOR CENTER
            mssYmm       =   0;
            mssZmm       =   0;
            
            % LR COORDS IN MM W.R.T. MONITOR CENTER
            mssXmmL = mssXmm; mssXmmR = mssXmm;
            mssYmmL = mssYmm; mssYmmR = mssYmm;
        else error(['psyPresentTrialDetectionLMS: WARNING! unhandled mtnType=' num2str(S.mtnType(1,:)) '. WRITE CODE?!?']);
        end
        % MOUSE SCREEN LR COORDS: PIXELS W.R.T. SCREEN CENTER
        mssXpixL = mssXmmL.*D.pixPerMmXY(1) + mssXpixBgn;
        mssXpixR = mssXmmR.*D.pixPerMmXY(1) + mssXpixBgn;
        mssYpixL = mssYmmL.*D.pixPerMmXY(2) + mssYpixBgn;
        mssYpixR = mssYmmR.*D.pixPerMmXY(2) + mssYpixBgn;
        %%%%%%%%%%%%%%%%%%%%%%%%%%% 
        % STORE OBSERVER RESPONSE % IN COORDS W.R.T. SCREEN OR MONITOR CENTER 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        S.rspXpixL(f,t) = mssXpixL - mssXpixBgn;
        S.rspXpixR(f,t) = mssXpixR - mssXpixBgn;
        S.rspXmm(f,t)   = mssXmm;
        S.rspYmm(f,t)   = mssYmm;
        S.rspZmm(f,t)   = mssZmm;
        S.rspXmmL(f,t)  = mssXmmL;
        S.rspXmmR(f,t)  = mssXmmR;
        S.rspYmmL(f,t)  = mssYmmL;
        S.rspYmmR(f,t)  = mssYmmR;
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        %% DRAW LEFT EYE BUFFER %
        %%%%%%%%%%%%%%%%%%%%%%%%
        Screen('SelectStereoDrawBuffer', D.wdwPtr, 0);
        % DRAW LEFT EYE BACKGROUND
        Screen('FillRect', D.wdwPtr, D.correctedBgd.*S.trmL(t), D.wdwXYpix);
        % DRAWING LEFT EYE FIXATION STIMULUS
        Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmL(t), [D.fixStm]); 
        % DRAW LEFT EYE STIMULUS
        Screen('DrawTexture', D.wdwPtr, texLimg, [], [S.tgtXpixL(f,t) S.tgtYpixL(f,t) S.tgtXpixL(f,t) S.tgtYpixL(f,t)] + D.plySqrPix, [], [], [], [D.wht,D.wht,D.wht].*S.trmL(t));
        % DRAW LEFT EYE 1/F TEXTURE
        if bUseMsk, 
        Screen('DrawTexture', D.wdwPtr, [tex1oF], [],[D.scrnXYpix.*(1-S.mskScale(t,:))/2 D.scrnXYpix-D.scrnXYpix.*(1-S.mskScale(t,:))/2], [], [], [], [D.wht,D.wht,D.wht].*S.trmL(t)); 
        end  
        
        % DRAW LEFT MOUSE CURSOR (XYZ POSITION VIA LE & RE)
        if ~strcmp(S.mtnType(t,1),'O')
        Screen('DrawDots', D.wdwPtr, [mssXpixL, mssYpixL], mssSzPix, mssClr.*S.trmL(t)); % 3D XZ MOUSE CURSOR POSITION   
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%
        % DRAW RIGHT EYE BUFFER %
        %%%%%%%%%%%%%%%%%%%%%%%%%
        Screen('SelectStereoDrawBuffer', D.wdwPtr, 1);
        % DRAW RIGHT EYE BACKGROUND
        Screen('FillRect', D.wdwPtr, D.correctedBgd.*S.trmR(t), D.wdwXYpix);
        % DRAWING RIGHT EYE FIXATION
        Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmR(t), [D.fixStm]); 
        % DRAW RIGHT EYE STIMULUS
        Screen('DrawTexture', D.wdwPtr, texRimg, [], [S.tgtXpixR(f,t) S.tgtYpixR(f,t) S.tgtXpixR(f,t) S.tgtYpixR(f,t)] + D.plySqrPix, [], [], [], [D.wht,D.wht,D.wht].*S.trmR(t));
        % DRAW RIGHT EYE 1/F TEXTURE
        if bUseMsk,
        Screen('DrawTexture', D.wdwPtr, [tex1oF], [], [D.scrnXYpix.*(1-S.mskScale(t,:))/2 D.scrnXYpix-D.scrnXYpix.*(1-S.mskScale(t,:))/2], [], [], [], [D.wht,D.wht,D.wht].*S.trmR(t)); 
        end
        
        % DRAW RIGHT MOUSE CURSOR (XZ POSITION VIA LE & RE)
        if ~strcmp(S.mtnType(t,1),'O')
        Screen('DrawDots', D.wdwPtr, [mssXpixR, mssYpixR], mssSzPix, mssClr.*S.trmR(t)); % 3D XZ MOUSE CURSOR POSITION
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FINISH DRAWING & FLIP SCREEN IN BOTH EYES %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FINISH DRAWING & FLIP
        Screen('DrawingFinished', D.wdwPtr);
        Screen('Flip', D.wdwPtr);
        
    end
    
    % TIMER: END TRIAL
    S.trlEndSec(t,1) = GetSecs()-trlBgnSec;
    
elseif S.bStatic == 1
    % STATIC STIMULUS. TO CHECK SIZE, COLOR, ETC
    while ~KbCheck
        %%%%%%%%%%%%%%%%%%%%%%%%
        % DRAW LEFT EYE BUFFER %
        %%%%%%%%%%%%%%%%%%%%%%%%
        Screen('SelectStereoDrawBuffer', D.wdwPtr, 0);
        % DRAWING LEFT EYE FIXATION
        Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmL(t), [D.fixStm]); 
        % DRAW LEFT EYE STIMULUS
        Screen('DrawTexture', D.wdwPtr, texLimg, [], [S.tgtXpixL(1, t) S.tgtYpixL(1,t) S.tgtXpixL(1, t) S.tgtYpixL(1,t)] + D.plySqrPix, [], [], [], [D.wht D.wht D.wht].*S.trmL(t) );
        % DRAW LEFT EYE 1/F TEXTURE
        if bUseMsk,
        Screen('DrawTexture', D.wdwPtr, [tex1oF], [],[D.scrnXYpix.*(1-S.mskScale(t,:))/2 D.scrnXYpix-D.scrnXYpix.*(1-S.mskScale(t,:))/2], [], [], [], [D.wht D.wht D.wht].*S.trmL(t)); 
        end
        
        % DRAW LEFT MOUSE CURSOR (XZ POSITION VIA LE & RE)
        if ~strcmp(S.mtnType(t,1),'O')
        Screen('DrawDots', D.wdwPtr, [mssXpixBgn, mssYpixBgn], mssSzPix, mssClr.*S.trmL(t));    % 3D XZ MOUSE CURSOR POSITION    
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%
        % DRAW RIGHT EYE BUFFER %
        %%%%%%%%%%%%%%%%%%%%%%%%%
        Screen('SelectStereoDrawBuffer', D.wdwPtr, 1);
        % DRAWING RIGHT EYE FIXATION
        Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht].*S.trmR(t), [D.fixStm]);        
        % DRAW RIGHT EYE STIMULUS
        Screen('DrawTexture', D.wdwPtr, texRimg, [], [S.tgtXpixR(1, t) S.tgtYpixR(1,t) S.tgtXpixR(1, t) S.tgtYpixR(1,t)] + D.plySqrPix, [], [], [], [D.wht D.wht D.wht].*S.trmR(t));
        % DRAW 1/F TEXTURE
        if bUseMsk,
        Screen('DrawTexture', D.wdwPtr, [tex1oF], [], [D.scrnXYpix.*(1-S.mskScale(t,:))/2 D.scrnXYpix-D.scrnXYpix.*(1-S.mskScale(t,:))/2], [], [], [], [D.wht D.wht D.wht].*S.trmR(t)); 
        end
        
        % DRAW RIGHT MOUSE CURSOR (XZ POSITION VIA LE & RE)
        if ~strcmp(S.mtnType(t,1),'O')
        Screen('DrawDots',    D.wdwPtr, [mssXpixBgn, mssYpixBgn], mssSzPix, mssClr.*S.trmR(t));    % 3D XZ MOUSE CURSOR POSITION    
        end
        
        % FINISH DRAWING THIS FRAME
        Screen('DrawingFinished', D.wdwPtr);
        
        % FLIP SCREEN
        D.flipTime(t) = Screen('Flip', D.wdwPtr);
    end
end
        
% CLOSE TEXTURES
Screen('Close', texLimg);
Screen('Close', texRimg);
clear('texLimg');
clear('texRimg');

% CLOSE 1/F TEXTURE
if bUseMsk,
Screen('Close', tex1oF);
end
