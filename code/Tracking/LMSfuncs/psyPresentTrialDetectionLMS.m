function S = psyPresentTrialDetectionLMS(D,S,t,msk1oF)

% function S = psyPresentTrialDetectionLMS(D,S,t,msk1oF)
%
%
% present jittering chromatic target on screen
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD trmL and trmR TO STRUCT IF IT DOESN'T ALREADY EXIST %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isfield(S,'trmL') S.trmL(t) = 1; end
if length(S.trmL) < t S.trmL(t) = 1; end
if ~isfield(S,'trmR') S.trmR(t) = 1; end
if length(S.trmR) < t S.trmR(t) = 1; end

% MAKE 1/F MASK TEXTURE
if bUseMsk == 1, tex1oF = Screen('MakeTexture', D.wdwPtr, msk1oF,[],[],2); end % WARNING! REMEMBER TO CLOSE TEXTURES!

% SCREEN CENTER
D.scrnXYpixCtr = round(D.scrnXYpix/2);

HideCursor();

%%%%%%%%%%%%%%%%%
% PRESENT TRIAL %
%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
% STIMULUS TEXTURE %
%%%%%%%%%%%%%%%%%%%%
numFrm = size(S.tgtXpixL(:,t),1);
texLimg = Screen('MakeTexture', D.wdwPtr, S.stmLE(:, :, :, t), [], [], 2);
stmBG = ones([0 0 0]);
stmBG(:,:,1) = D.correctedBgd(1).*ones([size(S.stmLE,1) size(S.stmLE,2)]);
stmBG(:,:,2) = D.correctedBgd(2).*ones([size(S.stmLE,1) size(S.stmLE,2)]);
stmBG(:,:,3) = D.correctedBgd(3).*ones([size(S.stmLE,1) size(S.stmLE,2)]);
texSimg = Screen('MakeTexture', D.wdwPtr, stmBG, [], [], 2);

%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%% %
% % START TRIAL % %
% %%%%%%%%%%%%%%% %
%%%%%%%%%%%%%%%%%%%
% TIMER: BEGIN TRIAL
trlBgnSec = GetSecs();

for j = 0:[S.numIntrvl-1]
    sound(sin(0.54.*[0:1439]).*cosWindowFlattop([1 1440],720,720,0));
    % START FRAME LOOP
    for f = 1:numFrm
        %%%%%%%%%%%%%%%%%%%%%%%%
        %% DRAW LEFT EYE BUFFER %
        %%%%%%%%%%%%%%%%%%%%%%%%
        % DRAW LEFT EYE BACKGROUND
        Screen('FillRect', D.wdwPtr, D.correctedBgd.*S.trmL(t), D.wdwXYpix);
        % DRAWING LEFT EYE FIXATION STIMULUS
        Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht], [D.fixStm]); 
        % DRAW LEFT EYE STIMULUS
 %       Screen('DrawTexture', D.wdwPtr, texLimg, [], [S.tgtXpixL(f,t) S.tgtYpixL(f,t) S.tgtXpixL(f,t) S.tgtYpixL(f,t)] + D.plySqrPix, [], [], [], []);
        %%%%%%%%%%%%%%
        % INTERVAL 1 % PRESENT STD or CMP STIMULUS (AS APPROPRIATE)
        %%%%%%%%%%%%%%
        if j == 0
            if     S.cmpIntrvl(t) == 0
                Screen('DrawTexture', D.wdwPtr, texLimg, [], [S.tgtXpixL(f,t) S.tgtYpixL(f,t) S.tgtXpixL(f,t) S.tgtYpixL(f,t)] + D.plySqrPix);
            elseif S.cmpIntrvl(t) == 1
                Screen('DrawTexture', D.wdwPtr, texSimg, [], [S.tgtXpixL(f,t) S.tgtYpixL(f,t) S.tgtXpixL(f,t) S.tgtYpixL(f,t)] + D.plySqrPix);
            end
        end
        %%%%%%%%%%%%%%
        % INTERVAL 2 % PRESENT CMP or STD STIMULUS (AS APPROPRIATE)
        %%%%%%%%%%%%%%
        if j == 1
            if     S.cmpIntrvl(t) == 0
                % t0 = GetSecs;
                Screen('DrawTexture', D.wdwPtr, texSimg, [], [S.tgtXpixL(f,t) S.tgtYpixL(f,t) S.tgtXpixL(f,t) S.tgtYpixL(f,t)] + D.plySqrPix);
                % Secs_DrawTexture(t) = GetSecs-t0;
            elseif S.cmpIntrvl(t) == 1
                % t0 = GetSecs;
                Screen('DrawTexture', D.wdwPtr, texLimg, [], [S.tgtXpixL(f,t) S.tgtYpixL(f,t) S.tgtXpixL(f,t) S.tgtYpixL(f,t)] + D.plySqrPix);
                % Secs_DrawTexture(t) = GetSecs-t0;
            end
        end
        % DRAW LEFT EYE 1/F TEXTURE
        if bUseMsk, 
        Screen('DrawTexture', D.wdwPtr, [tex1oF], [],[D.scrnXYpix.*(1-S.mskScale(t,:))/2 D.scrnXYpix-D.scrnXYpix.*(1-S.mskScale(t,:))/2], [], [], [], []); 
        end  

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FINISH DRAWING & FLIP SCREEN IN BOTH EYES %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FINISH DRAWING & FLIP
        Screen('DrawingFinished', D.wdwPtr);
        Screen('Flip', D.wdwPtr);

    end
end

% TIMER: END TRIAL
S.trlEndSec(t,1) = GetSecs()-trlBgnSec;
        
% CLOSE TEXTURES
Screen('Close', texLimg);
clear('texLimg');

% CLOSE 1/F TEXTURE
if bUseMsk,
Screen('Close', tex1oF);
end
