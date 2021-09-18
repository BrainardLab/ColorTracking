function [defaultPriority] = psySetPriorityDefault()

% function [defaultPriority,maxPriority] = psySetPriorityDefault(defaultPriority,maxPriority)
%
%   example call: 
%
% revert to default priority after changing priority from default
% NOTE! this function may ONLY be called after psySetPriorityMax.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% defaultPriority: default priority
%
%     ***  see psySetPriorityOld() & psySetPriorityMax()   ***


% DEFAULT PRIORITY VALUE
defaultPriority = 0;

% SET DEFAULT PRIORITY
Priority(defaultPriority);
