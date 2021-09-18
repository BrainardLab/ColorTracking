function D = psyPTBdisplayParameters(D,localHostName)

% function D = psyPTBdisplayParameters(D)
%
%   example call: psyPTBdisplayParameters(D)
%
% adds screen parameters to display structure D

% INTER-FRAME INTERVAL QUERY FRAME DURATION
if ~exist('D','var') || isempty(D)
    D=struct;
else
    if isfield(D,'wdwPtr')
        % FRAME RATE (AS RETURNED BY OPERATING SYSTEM)
        D.fps = Screen('FrameRate',D.wdwPtr); % MORE ROBUST THAN 'GetFlipInterval' 
        % INTERFRAME INTERVAL (IN SECONDS)
        D.ifi = 1./D.fps;
        
        if D.fps == 0 || isinf(D.ifi) || isnan(D.ifi)
        D.ifi     = Screen('GetFlipInterval', D.wdwPtr);
        D.fps     = round(1./D.ifi);
        D.ifi     = 1./D.fps;
        end
    end
    % INTER-FRAME INTERVAL (IN SECONDS)
    if isfield(D,'wdwPtr')
        
    end
    % FRAMES PER SECOND
    if isfield(D,'ifi')
        D.fps     = 1/D.ifi;
    end
end

% GET LOCAL HOST NAME (IF IT DOES NOT ALREADY EXIST)
D.cmpInfo = psyComputerInfo();
try
    localHostName = D.cmpInfo.localHostName;
end
if ~exist('localHostName','var') || isempty(localHostName);
    localHostName=psyLocalHostName;
    remoteFlag=0;
else
    D.localHostName=localHostName;
    remoteFlag=1;
end

% ==============================================================================
% COMPUTER / DISPLAY SPECIFIC INFO

%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPEED EXPERIMENT SETUP %
%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(localHostName, 'jburge-hubel')
    D.scrnZmm    = 925;       % VIEWING DISTANCE
    D.scrnXYmm   = [405 303]; % DISPLAY SIZE IN MM
    %D.bitsIn     = 12;
    %D.gamFncExponent = 2.2;
    % disp(['psyPTBdisplayParameters: WARNING! bitsIn not set.']);
    D.comp       = 'MACI64';
    D.lumCdm2max = [];
%%%%%%%%%%%%%%%%%%%%%
% BEN CHIN COMPUTER %
%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(localHostName, 'jburge-marr')      % PERSONAL MAC LAPTOP
    D.scrnZmm    = 500;       % VIEWING DISTANCE
    D.scrnXYmm   = [595 359]; % DISPLAY SIZE IN MM AND PIXELS
    D.bitsIn     = 12;
    D.gamFncExponent = 2.2;
    D.comp       = 'MACI64';
    D.lumCdm2max = [];
%%%%%%%%%%%%%%%%%%%%%
% MICHAEL COMPUTER %
%%%%%%%%%%%%%%%%%%%%%

elseif strcmp(localHostName, 'BrainardLab-21-01')      % imac
    D.scrnZmm    = 500;       % VIEWING DISTANCE
    D.scrnXYmm   = [595 359]; % DISPLAY SIZE IN MM AND PIXELS
    D.bitsIn     = 12;
    D.gamFncExponent = 2.2;
    D.comp       = 'MACI64';
    D.lumCdm2max = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BEN CHIN PERSONAL LAPTOP 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(localHostName, 'ben-Precision-7520') 
    D.scrnZmm    = 500; % VIEWING DISTANCE
    D.scrnXYmm   = [345 195]; % DISPLAY SIZE IN MM AND PIXELS
    D.bitsIn     = 12; % Leave undefined to avoid overwritting of D.gamFnc
    D.gamFncExponent = 2.2;
    D.comp       = 'GLNXA64';
    D.lumCdm2max = [];
end
% PROMPT USER TO MEASURE MONITOR LUMINANCE (IF NECESSARY)
if ~isfield(D,'lumCdm2max') || isempty(D.lumCdm2max) 
    for i = 1:5
    disp(['psyPTBdisplayParameters.m: WARNING! lumCdm2max not entered for localHostName ' localHostName '. Break out the Spectroradimoter!!!']); 
    end
end
        
% ==============================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE OTHER SCREEN PARAMS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%$%%%%%
%|| (remoteFlag==1 && strcmp(D.comp,'GLNXA64'))
%(remoteFlag==1 && strcmp(D.comp,'PCWIN64'))

% SCREEN SIZE IN PIXELS
if isfield(D,'wdwPtr')
    %FROM D.wdwPtr
    [D.scrnXYpix(1),D.scrnXYpix(2)] = Screen('WindowSize',D.wdwPtr);
elseif remoteFlag==0
    %FROM SYSTEM
    if strcmp(computer,'GLNXA64')
        [~,scrn]=system('xrandr -q | sed ''s/primary //g'' | grep " connected" | awk ''{print $3}'' | grep "[0-9]" | sed ''s/\(x\|+\)/ /g''');
    elseif strcmp(computer,'PCWIN64')
        [~,scrn]=system('wmic desktopmonitor get screenheight, screenwidth');
    else
        [~,scrn]=system('system_profiler SPDisplaysDataType | grep Resolution | awk ''{print $2 " " $4}''');
    end
    scrn=strsplit(scrn,'\n');
    scrn=scrn(~cellfun(@isempty, scrn));
    scrn=reshape(scrn,size(scrn,2),1);
    for i = 1:size(scrn,1)
        D.scrnXYpix(i,:)=strsplit(scrn{i});
    end
    if strcmp(computer, 'PCWIN64')
        D.scrnXYpix=D.scrnXYpix(2:end,:);
    end
end
% 
D.scrnXYdeg   = 2.*atan2d(0.5.*D.scrnXYmm,D.scrnZmm); % SCREEN SIZE IN DEG
D.scrnXYdeg   =     180.*(     D.scrnXYmm/D.scrnZmm)./pi; % SCREEN SIZE IN DEG
if isfield(D,'scrnXYpix')
    if iscell(D.scrnXYpix)
        D.scrnXYpix=str2double(D.scrnXYpix);
    end
    if size(D.scrnXYpix,1)==1
        D.pixPerDegXY = D.scrnXYpix(1:2)./D.scrnXYdeg;                % PIXELS PER DEG
        D.pixPerMmXY  = D.scrnXYpix(1:2)./D.scrnXYmm;                 % PIXELS PER MM
    else
        for i = 1:size(D.scrnXYpix,1)
            D.pixPerDegXY(i,:) = D.scrnXYpix(i,1:2)./D.scrnXYdeg(i,:);             % PIXELS PER DEG
            D.pixPerMmXY(i,:)  = D.scrnXYpix(i,1:2)./D.scrnXYmm(i,:);              % PIXELS PER MM
        end
    end
else
    display('WARNING: pixel-density not defined explicitly for host.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD CALIBRATION DATA %
%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(D,'wdwPtr')
   %  D.bitsOut           = Screen('PixelSize',D.wdwPtr)./4; % BIT DEPTH ('pixelsize' is poorly named)
    D.bitsOut = Screen('PixelSize',D.wdwPtr)./3; % TakaDoi updated 10-02-17
end
% GAMMA INFO (LEGACY CODE... PHASE OUT EVENTUALLY)
if isfield(D,'bitsIn')
    [D.gamPix D.gamFnc D.gamFncInv] = gammaTableOpticalBenchRoom(0:(2^D.bitsIn-1),1);
end
