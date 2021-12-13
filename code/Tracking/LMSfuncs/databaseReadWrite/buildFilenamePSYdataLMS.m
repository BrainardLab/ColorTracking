function fname = buildFilenamePSYdataLMS(expType,subjName,stmType,hostName,fnameNum)

% function fname = buildFilenamePSYdataSPD(expType,subjName,stmType,hostName,fnameNum)
%
%   example call: % FOR COLLECTING DATA... hostName = psyLocalHostName();
%                   fname = buildFilenamePSYdataLMS('SDL','JNK','MGB')  
% 
%                 % FOR LOADING DATA... 
%                   fname = buildFilenamePSYdataLMS('SDL','JNK','MGB','jburge-hubel')  
%                   fname = buildFilenamePSYdataLMS('SDL','JNK','MGB','jburge-julesz')  
%
% builds data file name for psychophysical expriment on speed discrimination
% 
% expType :         experiment type
%                   'SDL'   -> Stimulus DeLay
%                   'RNR'   -> Rigid VS Non-Rigid
% subjName:         three initial code for each subject
%                   'JDB' -> 
%                   'JNK' -> junk folder
% stmType :         stimulus type
%                   'MGB'   -> monocular Gabor
%                   'MGT'   -> monocular grating
%                   'BGB'   -> binocular Gabor
%                   'BGT'   -> binocular grating
% hostName:         computer hostName data was collected on
%                   useful input when loading data
%                   [] -> automatically set using psyLocalHostName()
% fnameNum:         data file number... 
%                   useful input when loading data
%                   [] -> automatically picks next datafile number
%%%%%%%%%%%%%%%%%%
% dataFileNameServ: 
% fnameNum:  duh

% SPECIFIES WHICH COMPUTER DATA IS BEING COLLECTED ON
if ~exist('hostName','var') || isempty(hostName)
    hostName = psyLocalHostName();
end

% FILE DIRECTORIES ON SERVER AND LOCAL MACHINE
fdirSrv = buildFolderNamePSY('LS3',expType,subjName,'server');
fdirLoc = buildFolderNamePSY('LS3',expType,subjName,'local');

% FILE NAME BASE (w.o FILE NUMBER)
fnameBase = ['LS3_' expType '_' hostName '_' stmType '_' subjName];

% IF FILE DOES NOT EXIST YET, CREATE APPROPRIATE FILE NUMBER
if exist('fnameNum','var') && ~isempty(fnameNum)
    fname = [fnameBase '_' num2str(fnameNum,'%03d') '.mat'];
else
    % ITERATE THE FILE NUMBER
    for i = 1:1000
        % CHECKS TO SEE WHETHER DATAFILE WITH IDENTICAL NAME ALREADY EXISTS
        fidSrv = fopen([fdirSrv filesep fnameBase '_' num2str(i,'%03d') '.mat'],'r'); 
        fidLoc = fopen([fdirLoc filesep fnameBase '_' num2str(i,'%03d') '.mat'],'r');
        if fidSrv == -1 && fidLoc == -1
            % NEW FILENAME
            fname = [fnameBase '_' num2str(i,'%03d') '.mat'];
            break
        elseif fidSrv ~= -1 && fidLoc ~= -1
            % CLOSE OPEN FILES
            if fidSrv > 0, fclose(fidSrv); end
            if fidLoc > 0, fclose(fidLoc); end
        else 
            % CLOSE OPEN FILES
            if fidSrv > 0, fclose(fidSrv); end
            if fidLoc > 0, fclose(fidLoc); end
            for i = 1:5,
            disp(['buildFilenamePSYdataLMS: WARNING! FILES ON SERVER & LOCAL MACHINE DO NOT MATCH! CHECK TO MAKE SURE THAT ALL fNumbers = ' num2str(i) ' EXIST IN BOTH LOCATIONS. COPY FILES?']);
            end
        end
    end
end
