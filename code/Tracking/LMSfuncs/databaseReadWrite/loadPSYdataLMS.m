function S = loadPSYdataLMS(expType,subjName,expName,stmType,dataFileNums,localHostName,serverORlocal)

% function S = loadPSYdataLMS(expType,subjName,stmType,dataFileNum,localHostName,serverORlocal)
%
%   example calls: S = loadPSYdataLMS('SDL','JDB','MGB',[1],localHostName,'local'); 
%                 
% load psychometric data from project LMS (spatial frequency binding experiment)
%
% expType:       experiment type code
%                'SDL'   -> Stimulus DeLay
%                'RNR'   -> Rigid VS Non-Rigid (still working out details)
%                'TRK'   -> tracking experiment
%                'JND'   -> just-noticeable difference
% subjName:      subject name
% stmType:       stimulus type
%                'MGB'   -> monocular Gabor
%                'MGT'   -> monocular grating
%                'MPB'   -> monocular pillbox
%                'BGB'   -> binocular Gabor
%                'BGT'   -> binocular grating
%                'BPB'   -> binocular pillbox
% dataFileNums:  cell of data file numbers
% serverORlocal: where to load the data from
%                'server' -> load data from server
%                'local'  -> load data from local machine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% S:             concatenated stimulus structure
%%

% BUILD DIRECTORY
fdir = buildFolderNamePSY(expName,expType,subjName,serverORlocal);

Sall = [];
for i = 1:length(dataFileNums)
    % DATA FILE NAME (
    fname = buildFilenamePSYdataPRJ(expName,expType,subjName,stmType,localHostName,dataFileNums(i));
    % fname = buildFilenamePSYdataPRJ('SPD',expType,subjName,stmType,localHostName,dataFileNums(i));
    try
    load([fdir filesep fname]);
    disp(['loadPSYdataLMS: BRAVO! successfully loaded: ' fname ' ...'])
    % COMBINE STRUCTS
    if ~strcmp(expName,'LSD') && (strcmp(expType,'TRK') || strcmp(expType,'JND'))
       S = rmfield(S,'fname');
       S = rmfield(S,'stmRE');
       S = rmfield(S,'stmLE');
       Sall = structmerge(Sall,S,S.trlPerRun);
    elseif strcmp(expName,'LSD')
        Stmp.stdX = S.stdX(4:end);
        Stmp.cmpX = S.cmpX(4:end);
        Stmp.R = S.R(4:end);
        Stmp.cmpIntrvl = S.cmpIntrvl(4:end);
        Stmp.targetContrast = S.targetContrast(4:end);
        Stmp.targetContrastAngle = S.targetContrastAngle(4:end);
        
%         Stmp.stdX = S.stdX;
%         Stmp.cmpX = S.cmpX;
%         Stmp.R = S.R;
%         Stmp.cmpIntrvl = S.cmpIntrvl;
%         Stmp.targetContrast = S.targetContrast;
%         Stmp.targetContrastAngle = S.targetContrastAngle;      

         Sall = structmerge(Sall,Stmp,length(Stmp.R));
    else
        disp(['loadPSYdataLMS: INVALID ARGUMENT TO expType = ' num2str(expType) '. WRITE CODE!?']);
    end
    catch
    lasterr
    disp(['loadPSYdataLMS: WARNING! could not load: ' fname ' ... Is the server down?']);
    end
end

S = Sall;

end