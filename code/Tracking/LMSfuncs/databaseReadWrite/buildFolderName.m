function fdir = buildFolderName(imgSet,imageORpatch,prjCode,serverORlocal,customRootDir)

% function fdir = buildFolderName(imgSet,imageORpatch,prjCode,serverORlocal)
%
%   example call: % RAW IMAGES ON SERVER
%                   fdir = buildFolderName('LRSI','image','RAW','server')
%
%                 % DVN IMAGES ON SERVER ( half-occlusion images )
%                   fdir = buildFolderName('LRSI','image','DVN','server')
%
%                 % GRD IMAGES ON SERVER ( gradient images )
%                   fdir = buildFolderName('LRSI','image','GRD','server')
%
% builds folder name for image in database of specified type
%
% imgSet:          which image database to load from
%                   'D7H'      -> nikon (D)(7)00 (H)andheld
%                   'LRSI'     -> (L)uminance (R)ange (S)tereo (I)mage
% imageORpatch:    whether the file is an image or a patch
%                  'image'     -> folder in image database
%                  'patch'     -> folder in patch database
% prjCode:        three-letter project code
%                  'RAW' -> raw
%                  'S3D' -> speed in 3D
%                  'SPD' -> speed in 2D
%                  'BLR' -> defocus blur
%                  'DSP' -> disparity
%                  'DVN' -> da vinci images (i.e. half occlusions images)
%                  'GRD' -> gradient images (i.e. half occlusions images)
% serverORlocal:   string determining the location of file directory
%                  'server'    -> folder name on server
%                  'local'     -> folder name on local machine
% customRootDir:   specifies a custom root directory for LRSI2 database, excluding up to 'LRSI'
%                  directory. Overrides serverORlocal
%                  ~exist/[] -> no custom direcotry, use severORlocal if specified.

if     strcmp(imgSet,'D7H');  nDgt = 3;
elseif strcmp(imgSet,'LRSI'); nDgt = 3;
end

% DEFAULT prjCode TO 'RAW'
if ~exist('prjCode','var') || isempty(prjCode) prjCode = 'RAW'; disp(['buildFolderName: WARNING! prjCode defaulting to RAW...']); end
% CHECH THAT prjCode IS VALID
if ~strcmp(prjCode,'RAW') && ~strcmp(prjCode,'S3D') && ~strcmp(prjCode,'SPD') && ...
   ~strcmp(prjCode,'BLR') && ~strcmp(prjCode,'DSP') && ~strcmp(prjCode,'DVN') && ...
   ~strcmp(prjCode,'GRD')
    error(['buildFolderName: WARNING! unhandled prjCode = ' num2str(prjCode) '. If this is a new project code, i) add code to line above, and ii) make sure folder is in ../Project_Database folder tree...']);
end

% GENERATE FILE DIRECTORY (LOCAL MACHINE OR SERVER)
if exist('customRootDir','var')==1 && ~isempty(customRootDir)
    imageORpatchStr = [upper(imageORpatch(1)) imageORpatch(2:end)];
    fdirRoot=customRootDir;
elseif strcmp(serverORlocal,'server') || strcmp(serverORlocal,'both')
    imageORpatchStr = [upper(imageORpatch(1)) imageORpatch(2:end)];
    % SERVER DIRECTORY
    % fdirRoot  = [filesep 'Volumes' filesep 'VisionScience' filesep 'Project_Databases' ]; % OLD SERVER BRUNSWICK
    fdirRoot  = [filesep 'Volumes' filesep 'Data' filesep 'Project_Databases' ]; % NEW SERVER GIBSON

elseif strcmp(serverORlocal,'local') || strcmp(serverORlocal,'both')
    %disp(['buildFolderName: WARNING! update to match hardcoded local machine Image Database directory']);
    imageORpatchStr = [upper(imageORpatch(1)) imageORpatch(2:end)];
    % LOCAL DIRECTORY
    fdirRoot  = [filesep 'Users' filesep 'Shared' filesep 'VisionScience' filesep 'Project_Databases' ];
else
    error(['buildFolderName: WARNING! bServerDir has unhandled value: ' serverORlocal]);
end
fdir  = [fdirRoot  filesep imgSet filesep imageORpatchStr filesep prjCode  ];
