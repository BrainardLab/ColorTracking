function Sall = loadPSYdataLMSall(expType, subjNames, expName, stmType, dataFileNums, localHostName, serverORlocal)

% function Sall = loadPSYdataLMSall(expType, subjName, stmType, dataFileNums, localHostName, serverORlocal)
%
% wrapper function for loadPSYdataLMS for seemlessly loading 
% multiple data files at the same time
%
% expType:       experiment type code
%                'TRK'   -> tracking experiment
%                'JND'   -> just-noticeable difference
% subjName:      subject name
% stmType:       stimulus type
%                'CGB' -> compound Gabor
% dataFileNums:  cell of data file numbers--MAKE SURE THESE LINE UP WITH
%                subjNames
% serverORlocal: where to load the data from
%                'server' -> load data from server
%                'local'  -> load data from local machine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sall:        'super struct' that contains data of all participants
%% 

Sall = [];

% MAKE SURE TWO KEY INPUT PARAMETERS HAVE THE SAME LENGTH
if size(subjNames,1) ~= length(dataFileNums)
    error(['subjNames matrix AND dataFileNums CELL DO NOT HAVE THE SAME NUMBER OF ENTRIES']);
end

for i = 1:size(subjNames,1)
    % LOAD FILE
    S = loadPSYdataLMS(expType,subjNames(i,:),expName,stmType,cell2mat(dataFileNums(i)),localHostName,serverORlocal);
    
    % DATA FROM ALL SUBJECTS MERGED TOGETHER
    Sall = structmerge(Sall,S);
end

end