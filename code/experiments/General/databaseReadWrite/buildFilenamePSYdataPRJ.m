function fname = buildFilenamePSYdataPRJ(prjCode,expType,subjName,stmType,hostName,fnameNum)

% function fname = buildFilenamePSYdataPRJ(prjCode,expType,subjName,stmType,hostName,fnameNum)
%
%   example call: % FOR COLLECTING DATA IN THE SPD PROJECT
%                   fname = buildFilenamePSYdataPRJ('SPD','JND','JNK','NAT')  
% 
%                 % FOR LOADING DATA IN THE SPD PROJECT... 
%                   fname = buildFilenamePSYdataPRJ('SPD','JND','JNK','NAT','jburge-hubel') 
%                   fname = buildFilenamePSYdataPRJ('SPD','JND','JNK','NAT','jburge-julesz') 
%
%                 % FOR COLLECTING DATA IN THE DSP PROJECT
%                   fname = buildFilenamePSYdataPRJ('DSP','TEST','JNK','STEREOGRAM')  
% 
%                 % FOR LOADING DATA IN THE DSP PROJECT... 
%                   fname = buildFilenamePSYdataPRJ('DSP','TEST','JNK','STEREOGRAM','jburge-wheatstone')  
%
% builds data file name for psychophysical expriment on speed discrimination
% 
% prjCode:          three-letter project code 
%                   'DSP' -> disparity
%                   'DRC' -> disparity reverse correlation
%                   'HOC' -> half-occlusion
%                   'PFE' -> pulfrich effect estimation
%                   'PFT' -> pulfrich effect tracking
%                   'TLT' -> tilt
%                   'SPD' -> speed
%                   'S3D' -> speed in 3D
% expType:          type of DSP experiment
%                   'TEST' -> stereogram test
%                   etc...
% subjName:         three initial code for each subject
%                   'JDB' -> johannes daniel burge
%                   'JNK' -> junk folder
% natORsin:         stimulus type
%                   'NAT' -> natural  stimuli
%                   'SIN' -> sinewave stimuli
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
fdirSrv = buildFolderNamePSY(prjCode,expType,subjName,'server');
fdirLoc = buildFolderNamePSY(prjCode,expType,subjName,'local');

% FILE NAME BASE (w.o FILE NUMBER)
fnameBase = [prjCode '_' expType '_' hostName '_' stmType '_' subjName];

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
            disp(['buildFilenamePSYdataPRJ: WARNING! FILES ON SERVER & LOCAL MACHINE DO NOT MATCH! CHECK TO MAKE SURE THAT ALL fNumbers = ' num2str(i) ' EXIST IN BOTH LOCATIONS. COPY FILES?']);
            end
        end
    end
end
