function psyPTBsetup(bSKIPSYNCTEST,bDEBUG)

% function psyPTBsetup(bSKIPSYNCTEST,bDEBUG)
%
%   example call: psyPTBsetup();
%
% setup psychotoolbox for psychophysical experiment
%
% gamCrctType:   gamma correction type (might want to move to other function)
% bSKIPSYNCTEST: skip ptb sync tests or not
%                1 -> use alpha window
%                0 -> don't
% bDEBUG:        boolean determining whether debugging alpha window will be used
%                1 -> use alpha window
%                0 -> don't

if ~exist('bSKIPSYNCTEST','var') || isempty(bSKIPSYNCTEST) bSKIPSYNCTEST = 0; end
if ~exist('bDEBUG','var')        || isempty(bDEBUG)        bDEBUG = 0;        end

% PREPARE PSYCHIMAGING
PsychImaging('PrepareConfiguration');
% FLOATING POINT NUMBERS
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
% USE NORMALIZED [0 1] RANGE FOR COLOR AND LUMINANCE LEVELS
PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
% SKIP SYNCTESTS OR NOT
Screen('Preference', 'SkipSyncTests', bSKIPSYNCTEST);
% DEBUGGING WINDOW
if bDEBUG == 1
    % OPACITY
    opacityAlpha = 0.5;
    % ENABLE ALPHA WINDOW FOR DEBUGGING
    PsychDebugWindowConfiguration([],opacityAlpha); % NOTE! must call before opening ptb window
    % PRINT TO SCREEN
    disp(['psyPTBsetup: WARNING! bDEBUG=1 and opacityAlpha=' num2str(opacityAlpha)]);
elseif bDEBUG == 0
    % DO NOT RUN PsychDebugWindowConfiguration() BECAUSE IT MESSES UP
    % TIMING on YOSEMITE
    gribble = 1;
end
