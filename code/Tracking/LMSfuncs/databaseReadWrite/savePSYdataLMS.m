function savePSYdataLMS(fname,expType,subjName,localORserver,bOverwrite,V1,V1name)
         
% function savePSYdataLMS(fname,expType,subjName,localORserver,bOverwrite,V1,V1name)
%
%   example call : savePSYdataLMS(fname,expType,subjName,'local',0,V1,'V1name')
%
% save psychometric data from spatial frequency binding experiment
%
%
% fname:         name by which mat file will be saved
% subjName:      three letter code identifying each subject
%                'JNK' -> junk
%                'JDB' -> johannes burge
%                'BMC' -> benjamin chin
%                 etc....
% expType:       experiment type
%                'SDL'   -> Stimulus DeLay
%                'RNR'   -> Rigid VS Non-Rigid
% localORserver: where to save
%                'local'  -> save to local machine
%                'server' -> save to server
%                'both'   -> save to both
% bOverwrite:    overwrite or not, if a file with name fname is already present
%                 1 -> overwrite
%                 0 -> do not overwrite
% V1:            variable containing the data to be saved
% V1name:        name which the saved variable when the file with name fname is loaded 


if ~exist('localORserver','var') || isempty(localORserver) localORserver = 'both'; end
if ~exist('bOverwrite','var')    || isempty(bOverwrite)    bOverwrite = 0;         end
if bOverwrite == 1, error(['savePSYdataLMS: WARNING! bOverwrite = 1. This is not allowed. Set it equal to 0 jackass!']); end
if bOverwrite ~= 0, error(['savePSYdataLMS: WARNING! bOverwrite has invalid value: ' num2str(bOverwrite) '. bOverwrite must equal 0!!!']); end
if isempty(findstr(fname,expType)) || isempty(findstr(fname,subjName))
    error(['savePSYdataLMS: WARNING! fname and input parameters are mismatched. expType and subjName do not appear in filename']); 
end

if strcmp(localORserver,'local')
    try
        fdir  = buildFolderNamePSY('LSD',expType,subjName,'local');
        % SAVE DATA IF FILE DOES NOT EXIST OR IF USER SAYS TO OVERWRITE REGARDLESS   
        savePSYdataLMSfunc(fdir,fname,bOverwrite,V1,V1name)
    catch
        lasterr
        error(['savePSYdataLMS: WARNING! could not save locally: [ ' fdir filesep fname ']. Check directory?']);   
    end
elseif strcmp(localORserver,'server')
    try
        fdir  = buildFolderNamePSY('LSD',expType,subjName,'server');
        % SAVE DATA IF FILE DOES NOT EXIST OR IF USER SAYS TO OVERWRITE REGARDLESS   
        savePSYdataLMSfunc(fdir,fname,bOverwrite,V1,V1name)
        disp(['savePSYdataLMS: Saved ' fdir filesep fname ' ...']);
    catch
        lasterr
        error(['savePSYdataLMS: WARNING! could not save to server: [ ' fdir filesep fname ']. Check connection?']);   
    end
elseif strcmp(localORserver,'both')
    try
        fdir  = buildFolderNamePSY('LSD',expType,subjName,'local');
        % SAVE DATA IF FILE DOES NOT EXIST OR IF USER SAYS TO OVERWRITE REGARDLESS   
        savePSYdataLMSfunc(fdir,fname,bOverwrite,V1,V1name);
        disp(['Saved ' fdir filesep fname ' ...']);
    catch
        lasterr
        error(['savePSYdataLMS: WARNING! could not save to both locally:  [ ' fdir filesep fname ']. Check directory?']);   
    end
    try
        fdir  = buildFolderNamePSY('LSD',expType,subjName,'server');
        % SAVE DATA IF FILE DOES NOT EXIST OR IF USER SAYS TO OVERWRITE REGARDLESS   
        savePSYdataLMSfunc(fdir,fname,bOverwrite,V1,V1name)
        disp(['savePSYdataLMS: Saved ' fdir filesep fname ' ...']);
    catch
        lasterr
        error(['savePSYdataLMS: WARNING! could not save to server: [ ' fdir filesep fname ']. Check connection?']);   
    end
    
else
    error(['savePSYdataLMS: WARNING! unrecognized localORserver value: ' localORserver]);
end

function savePSYdataLMSfunc(fdir,fname,bOverwrite,V1,V1name)

% ASSIGN USER-SPECIFIED NAME TO SAVED PAYLOAD
S.(V1name) = V1;

% CHECK WHETHER FILE WITH SAME NAME EXISTS
if     bOverwrite == 0
    fid = fopen([fdir filesep fname],'r');
    if fid == -1 % note that fid = -1 when the file does not exist
        % SAVE DATA
        save([fdir filesep fname],'-struct','S');
        disp(['savePSYdataLMS: Saved ' fdir filesep fname ' ...']);
    else
        error(['savePSYdataLMS: WARNING! file already exists = ''' [fdir filesep fname] '''. You should probably check buildFilenamePSYdataLMS!!!']);
    end
end