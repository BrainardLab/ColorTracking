function D = psyPTBopenWindow(D,stereoMode)

% function D = psyPTBopenWindow(D,stereoMode)
%
%   example call: D = psyPTBopenWindow(D,stereoMode)
%
% opens psychtoolbox window with full screen resolution
%
% D:          display structure
%              .gry      -> specifies background gray level
% stereoMode: mode for psychtoolbox presentation
%             0 -> no stereo
%             4 -> haploscope / split screen w. extended desktop
%             6 -> Red-Green
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% D:    display structure appended with window (wdw) data
%         .wdwPtr   -> window pointer
%         .wdwXYpix -> window dimensions

if ~exist('stereoMode','var') || isempty(stereoMode),
    stereoMode = 0;
    disp(['psyPTBopenWindow: setting D.stereoMode to ' num2str(stereoMode)])
end
% DEFAULT GRAY LEVEL IF NECESSARY
if ~isfield(D,'gry')
    D.gry = 0.5;
    disp(['psyPTBopenWindow: setting D.gry to default gray level. D.gry=' num2str(D.gry)]);
end

% SET STEREO MODE TO DISPLAY STRUCT
D.stereoMode = stereoMode;

% DISPLAY SCREEN WITH MAX ID FOR EXPERIMENT
D.sid = max(Screen('Screens')); % SCREEN, ONSCREEN WINDOW WITH GRAY BACKGROUND

% OPEN WINDOW
[D.wdwPtr, D.wdwXYpix]  = PsychImaging('OpenWindow', D.sid, D.gry, [],[], [], D.stereoMode);

% SET DEFAULT TEXT
Screen('TextSize',D.wdwPtr,24);

% FLIP SCREEN
Screen('Flip',D.wdwPtr);
