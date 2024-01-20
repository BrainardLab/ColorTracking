function bPriorityMax = psySetPriorityOld(oldPriority,maxPriority,bPriorityMax)

% function bPriorityMax = psySetPriorityOld(oldPriority,maxPriority,bPriorityMax)
%
%   example call: 
%
% revert to default priority after changing priority from default
%
% NOTE! this function may ONLY be called after psySetPriorityMax.m
%
% oldPriority:     default priority
% maxPriority:     default priority
% bPriorityMax:    boolean indicating whether priority is at max or not
%                  1 -> priority at max... change to zero
%                  0 -> priority at old... dont do nuthin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bPriorityMax:    boolean indicating whether priority is at max or not
%                  1 -> priority at max... something is wrong
%                  0 -> priority at old... worked  as planned
%
%          ***          psySetPriorityOld.m          ***

if bPriorityMax ~= 1
   disp(['psySetPriorityOld: WARNING! bPriorityMax=' num2str(bPriorityMax) '. Are you sure you are using the function correctly?']);
end

% GET CURRENT PRIORITY LEVEL
nowPriority=Priority();

% CHECK IF NEW AND OLD PRIORITIES ARE THE SAME
if round(oldPriority) ~= round(nowPriority)
    % SET TO OLD PRIORITY
    Priority(oldPriority);
    % SET BOOLEAN
    bPriorityMax = 0;
elseif round(oldPriority) == round(nowPriority)
    % SET BOOLEAN
    bPriorityMax = 0;
end

% DETECT PROBLEM
if round(nowPriority)<maxPriority
    disp(['psySetPriorityOld: WARNING! Thread priority=' num2str(nowPriority) ' was degraded by the OS during the trial and does not equal maxPriority=' num2str(maxPriority)])
end
        