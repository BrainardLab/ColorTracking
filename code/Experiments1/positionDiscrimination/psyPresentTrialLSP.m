function S = psyPresentTrialLSP(D,S,t,msk1oF,indRnd)

% function S = psyPresentTrialLSP(D,S,t,msk1oF)
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
%       error(['psyPresentTrialLSP: WARNING! texture mask ''msk1oF'' not sized properly... Double check inputs']);
%       end
end

%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZE GetSecs() % FOR ACCURATE TRIAL TIMING
%%%%%%%%%%%%%%%%%%%%%%%%
GetSecs();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD trm TO STRUCT IF IT DOESN'T ALREADY EXIST %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isfield(S,'trm') S.trm(t) = 1; end
if length(S.trm) < t S.trm(t) = 1; end

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
for i = 1:size(S.stmLE,3)
   texCmpImg(i) = Screen('MakeTexture', D.wdwPtr, S.stmLE(:,:,i));
end
texStdImg = Screen('MakeTexture', D.wdwPtr, round(reshape(D.bgd,[1 1 3]).*255));

%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%% %
% % START TRIAL % %
% %%%%%%%%%%%%%%% %
%%%%%%%%%%%%%%%%%%%
% TIMER: BEGIN TRIAL
trlBgnSec = GetSecs();

for j = 0:[S.numIntrvl-1]
    Screen('LoadNormalizedGammaTable', D.wdwPtr, S.lookupTableSettings(:,:,indRnd),2);
    Screen('FillRect', D.wdwPtr, round(D.bgd.*S.trm(t).*255), D.wdwXYpix);
    Screen('Flip', D.wdwPtr);
    pause(0.2);
    sound(sin(0.54.*[0:1439]).*cosWindowFlattop([1 1440],720,720,0));
    % START FRAME LOOP
    for f = 1:numFrm
        %%%%%%%%%%%%%%%%%%%%%%%%
        %% DRAW LEFT EYE BUFFER %
        %%%%%%%%%%%%%%%%%%%%%%%%
        % DRAW LEFT EYE BACKGROUND
        Screen('FillRect', D.wdwPtr, round(D.bgd.*S.trm(t).*255), D.wdwXYpix);
        % DRAWING LEFT EYE FIXATION STIMULUS
%        Screen('FillRect', D.wdwPtr, round([D.wht,D.wht,D.wht].*255), [D.fixStm]); 
        % DRAW LEFT EYE STIMULUS
        %%%%%%%%%%%%%%
        % INTERVAL 1 % PRESENT STD or CMP STIMULUS (AS APPROPRIATE)
        %%%%%%%%%%%%%%
        Screen('DrawTexture', D.wdwPtr, texCmpImg(f), [], [S.tgtXpixL(f,t) S.tgtYpixL(f,t) S.tgtXpixL(f,t) S.tgtYpixL(f,t)] + D.plySqrPix);

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
    Screen('LoadNormalizedGammaTable', D.wdwPtr, S.lookupTableSettingsInit,2);
    Screen('FillRect', D.wdwPtr, round([D.wht,D.wht,D.wht].*255), [D.fixStm]); 
    Screen('Flip', D.wdwPtr);
    if j==0
       pause(0.2);
    end
end

% TIMER: END TRIAL
S.trlEndSec(t,1) = GetSecs()-trlBgnSec;
        
% CLOSE TEXTURES
Screen('Close', texCmpImg);
clear('texCmpImg');
Screen('Close', texStdImg);
clear('texStdImg');

% CLOSE 1/F TEXTURE
if bUseMsk,
Screen('Close', tex1oF);
end
