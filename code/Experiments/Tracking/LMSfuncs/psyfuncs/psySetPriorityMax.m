function [oldPriority,maxPriority,bPriorityMax] = psySetPriorityMax()

% function [oldPriority,maxPriority,bPriorityMax] = psySetPriorityMax()
%
%   example call: [oldPriority,maxPriority,bPriorityMax] = psySetPriorityMax();
%
% switch to high priority mode
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bPriorityMax:    boolean indicating whether priority is at max or not
%                  1 -> priority is at max... worked  as planned
%                  0 -> priority is at old... something is wrong
%
%          ***          psySetPriorityOld.m          ***



% GET CURRENT PRIORITY LEVEL
oldPriority=Priority();

% DETERMINE MAX AVAILABLE PRIORITY 
% NOTE: calling MaxPriority this way gets max priority for matlab & PTB
maxPriority=MaxPriority('GetSecs'); 

% HARDCODES PERFORMANCE FOR WINDOWS MACHINES 
% NOTE: see >> help Priority() for details
if IsWin % 1 = High. Priority(2) will return 1.
    maxPriority = 1;
end

% SET PRIORITY TO MAX PRIORITY (IF POSSIBLE)
if oldPriority < maxPriority
    % SET TO MAX PRIORITY
    Priority(maxPriority);
    % SET BOOLEAN
    bPriorityMax = 1;
else
    bPriorityMax = 0;
end
