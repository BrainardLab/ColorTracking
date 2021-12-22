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
            while KbCheck(-1); end
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
    %%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%% %
    % % START TRIAL % %
    % %%%%%%%%%%%%%%% %
    %%%%%%%%%%%%%%%%%%%
    % TIMER: BEGIN TRIAL
    trlBgnSec = GetSecs();
    
    % START FRAME LOOP
    for f = 1:numFrm
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

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FINISH DRAWING & FLIP SCREEN IN BOTH EYES %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FINISH DRAWING & FLIP
        Screen('DrawingFinished', D.wdwPtr);
        Screen('Flip', D.wdwPtr);
        
    end
    
    % TIMER: END TRIAL
    S.trlEndSec(t,1) = GetSecs()-trlBgnSec;
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
