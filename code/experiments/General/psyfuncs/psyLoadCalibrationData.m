function [cal,gamPix,gamFnc,gamInv] = psyLoadCalibrationData(localhostname)

% function [cal,gamPix,gamFnc,gamInv] = psyLoadCalibrationData(localhostname)
%
%   example call: % LOAD CALIBRATION DATA FROM CURRENT COMPUTER
%                   D.infoCmp = psyComputerInfo;
%                   D.cal = psyLoadCalibrationData(psyLocalHostName);
%                   plot(D.cal.processedData.gammaInput,D.cal.processedData.gammaTable); formatFigure('Pix In','Pix Out',D.infoCmp.localHostName); axis square;
%
%                 % LOAD CALIBRATION DATA FROM PROPIXX PROJECTOR
%                   D.cal = psyLoadCalibrationData('jburge-helmholtz');
%                   plot(D.cal.processedData.gammaInput,D.cal.processedData.gammaTable); formatFigure('Pix In','Pix Out','ProPixx Projector'); axis square;
%

% loads monitor calibration data specific to the computer running the code
%
% if you are running an unrecognized computer, this function will have to
% be modified... PLEASE DO NOT MODIFY UNLESS YOU KNOW WHAT YOU ARE DOING!
%
% localhostname:    local BurgeLab computer name
% %%%%%%%%%%%%%%%%%%%%%%%%
% cal:              calibration struct (BRAINARD LAB FORMAT)
% gamPix:           input gamma values
% gamFnc:           gamma function
% gamInv:           inverse gamma
%                   .

switch localhostname
    %%%%%%%%%%%%%%%%%%%%%%%%
    % EXPERIMENT COMPUTERS %
    %%%%%%%%%%%%%%%%%%%%%%%%
    case 'jburge-helmholtz'
        fname = 'ProPixx_Calib.mat';
	case 'jburge-wheatstone'
        % Taka 2018-08-16
        % In future, we can use VIEWPixx3D_Calib.mat for psyPTBgammaCorrect
        % Alternatively, use GammaCorrection class's luminance2intensity() method to directly convert luminance
        % (in this case, do not use psyPTBgammaCorrect)
%         fname = 'Linear8bit_Artificial.mat';
        fname = 'VIEWPixx3D_Calib_Dec_15_2020.mat';
    case 'jburge-hubel' % SPEED EXPERIMENT COMPUTER
        fname = 'ViewSonicG220fb.mat';

	%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEVELOPMENT COMPUTERS %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    case 'BrainardLab-21-01' % MICHAEL'S DESKTOP
        fname = 'ViewSonicG220fb.mat';
    case 'jburge-marr' % BEN DESKTOP
        fname = 'ViewSonicG220fb.mat';        
    case 'blobfish' % SPEED EXPERIMENT COMPUTER
        fname = 'ViewSonicG220fb.mat';
    case 'ben-Precision-7520'
        fname = 'ViewSonicG220fb.mat';
    otherwise
        error(['psyLoadCalibrationData: WARNING! unhandled localhostname= ' num2str(localhostname) '. Write code?']);
end

% TRY LOADING DATA FROM LOCAL DISK
if strcmp(localhostname,'ben-Precision-7520')
   fdir = '~/Documents/VisionScience/Data/BurgeLabCalibrationData/';
elseif strcmp(localhostname,'jburge-marr')   
   fdir = ['/Users/Shared/VisionScience/BurgeLabCalibrationData/'];    
elseif strcmp(localhostname,'blobfish')
   fdir = '/home/brainardlab/labDropbox/CNST_materials/ColorTrackingTask/calData/';
elseif strcmp(localhostname,'BrainardLab-21-01')   
   fdir = ['/Users/michael/Documents/MATLAB/toolboxes/Psychtoolbox-3/Psychtoolbox/PsychCalDemoData/']; 
else
   fdir = ['/Users/Shared/Matlab/BurgeLabCalibrationData/'];
end
flag = exist(fdir,'dir');
if flag == 0 || exist([fdir fname],'file') ~= 2
    % TRY LOADING DATA FROM SERVER
    fdir = ['/Volumes/Data/BurgeLabCalibrationData/'];
end

cal  = psyLoadCalFile(fname,[],fdir);

% CONVERT GAMMA DATA IN cal STRUCT TO STANDARD FORMAT
gamPix = cal.processedData.gammaInput;
gamFnc = cal.processedData.gammaTable;
for i = 1:size(gamFnc,2)
    try
    gamInv(:,i) = interp1(gamFnc(:,i),gamPix,linspace(min(gamFnc(:)),max(gamFnc(:)),numel(gamPix))');
    catch
    gamInv(:,i) = zeros(numel(gamPix),1);
    end
end

% WRITE TO SCREEN
if  ~isempty(cal)
    disp(['psyLoadCalibrationData: Loaded ' fdir fname ' ! ']);
else
    error(['psyLoadCalibrationData: WARNING! could not load calibration data. Tried ' fdir fname ' ! ']);
end
