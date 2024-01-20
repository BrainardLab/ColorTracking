function D = psyPTBalphaBlending(D)

% function D = psyPTBalphaBlending(D)
%
%   example call:
%
% sets alpha blending for use with experiment...
%
% MODIFY FUNCTION TO ALLOW CONTROL OF BLENDING OPTOINS
%
% see documentation at: http://docs.psychtoolbox.org/BlendFunction
% and demo code     at: http://psychtoolbox-3.googlecode.com/svn/trunk/Psychtoolbox/PsychDemos/PsychTutorials/AlphaImageTutorial.m


% SET ALPHA BLENDING OPTIONS FOR EXPERIMENT
Screen('BlendFunction', D.wdwPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % MOST COMMON ALPHA-BLENDING FACTORS
% Screen('BlendFunction', D.wdwPtr, GL_ONE, GL_ZERO);                    % DISABLES    ALPHA-BLENDING


disp(['psyPTBalphaBlending: WARNING! insert input parameter(s) so that blending options can be set by user and/or experiment']);
