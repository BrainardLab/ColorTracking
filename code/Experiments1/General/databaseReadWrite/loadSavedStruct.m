function S = loadSavedStruct(fdirLoc,fdirSrv,fname,structName)
%
% function S = loadSavedStruct(fdirLoc,fdirSrv,fname)
%
% example call : S = loadSavedStruct(fdirLoc,fdirSrv,fname)
%
% Loads saved structure with a given folder location and file name
%
% fdirloc:      directory location
% fdirSrv:      directory location
% fname:        filename
% structName:   string identifying the name of the variable into 
%               which the output structure is read
%%%%%%%%%%%%%%%%%%%%%%%%%%
% S:            saved struct with name specified by structname

% LOAD AND PASS SAVED STRUCTURE
try
load([fdirLoc filesep fname]);
catch
load([fdirSrv filesep fname]);
end


% LOAD AND PASS SAVED STRUCTURE
% if fopen([fdirLoc filesep fname],'r') ~= -1
%     load([fdirLoc filesep fname]);
%     disp(['loadSavedStruct:' fdirLoc filesep fname ' successfully loaded locally']);
% else
%     if fopen([fdirSrv filesep fname],'r') ~= -1
%         load([fdirSrv filesep fname]);
%         disp(['loadSavedStruct:' fdirSrv filesep fname ' successfully loaded from server']);
%     else error(['loadSavedStruct:' fname ' unavailable at both local and server locations. Populate and rerun']);
%     end
% end

S = eval(structName);

% CAST STRUCT FIELDS TO DOUBLES
S = structSingle2Double(S);