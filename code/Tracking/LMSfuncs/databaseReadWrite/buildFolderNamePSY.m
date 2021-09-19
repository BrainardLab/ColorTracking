function fdir = buildFolderNamePSY(prjCode,expType,subjName,serverORlocal,imgDim)

% function fdir = buildFolderNamePSY(prjCode,expType,subjName,serverORlocal)
%
%   example call: % FOLDER FOR JNK DATA ON SERVER IN SPD PROJECT
%                   fdir = buildFolderNamePSY('SPD','BIAS','JNK','server')
%
%                 % FOLDER FOR JNK DATA ON LOCAL MACHINE IN SPD PROJECT
%                   fdir = buildFolderNamePSY('SPD','BIAS','JNK','local')
%
% builds folder name for image in database of specified type
%
% prjCode:          three-letter project code
%                   'SPD'     -> speed project
%                   'DSP'     -> disparity project
%                   'TLT'     -> tilt project
%                   'EQV'     -> equivalent input noise
%                   'DRC'     -> disparity reverse correlation 
%                   'PFE'     -> pulfrich effect estimation
%                   'SFB'     -> spatial frequency binding experiment
%                   'PRE'     -> Pulfrich rotated ellipse experiment
% expType:          particular experiment within the specified project
%                   'BIAS'    -> e.g.
%                   'NATRMS' -> JND study with contrast not fixed
% subjName:        three letter code indicating subject identity
%                   'JNK'     -> junk
%                   'JDB'     -> johannes burge
%                   'BMC'     -> benjamin chin
% serverORlocal:   string determining the location of file directory
%                   'server'    -> folder name on server
%                   'local'     -> folder name on local machine

% CHECK THAT projCode IS VALID
if  ~strcmp(prjCode,'SPD') && ~strcmp(prjCode,'S3D') &&  ...
   ~strcmp(prjCode,'DSP') && ~strcmp(prjCode,'DRC') && ...
   ~strcmp(prjCode,'TLT') && ~strcmp(prjCode,'HOC') && ...
   ~strcmp(prjCode,'PFE') && ~strcmp(prjCode,'PFT') && ...
   ~strcmp(prjCode,'SFB') && ~strcmp(prjCode,'NPE') && ...
   ~strcmp(prjCode,'PRE') && ~strcmp(prjCode,'LMS')
    error(['buildFolderNamePSY: WARNING! unhandled prjCode = ' num2str(prjCode) '. If this is a new project code, i) add code to line above, and ii) make sure folder is in ../Project_Database folder tree...']);
end

if ~exist('imgDim','var') || isempty(imgDim)
    imgDim='0';
end

% GENERATE FILE DIRECTORY (LOCAL MACHINE OR SERVER)
if strcmp(serverORlocal,'server') || strcmp(serverORlocal,'both')
    % SERVER DIRECTORY
    fdirRoot  = [filesep 'Volumes' filesep 'Data' filesep 'Project_PsyData' ];
elseif strcmp(serverORlocal,'local') || strcmp(serverORlocal,'both')
    % LOCAL DIRECTORY
    fdirRoot  = fullfile('/Users', 'michael', 'labDropbox', 'ColorTrackingTask','Data');
else
    error(['buildFolderNamePSY: WARNING! bServerDir has unhandled value: ' serverORlocal]);
end

fdir  = fullfile(fdirRoot,subjName);


% SPECIAL CASE FOR BEN LAPTOP
cmpInfo = psyComputerInfo;
if strcmp(cmpInfo.localHostName,'ben-Precision-7520')
    fdirRoot = '~/Documents/VisionScience/Project_PsyData';
    fdir  = [fdirRoot filesep prjCode filesep expType filesep subjName   ];
end
    
    