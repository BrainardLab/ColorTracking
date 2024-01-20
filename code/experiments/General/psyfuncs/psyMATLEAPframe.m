function f = psyMATLEAPframe()

% function f = psyMATLEAPframe()
%
%   example call: f = psyMATLEAPframe()
%
% gets frame from LEAP motion controller
% 
% requires that ../matleap/ is part of the matlab path
% see README_matLEAP_SetupForDummies.rtf in code base
%                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% f:    matleap frame struct with the following fields
%       .id         -> frame ID
%       .timestamp  -> seconds
%       .pointables -> finger information in 5 element struct
%                      each struct element 
%                   .id             -> finger ID
%                   .position       -> position of finger ?tip?
%                                      X=(1); Y=(2); Z(3)
%                   .velocity       -> velocity of finger ?tip?
%                   .direction      -> ornttion of finger ?tip?
%                   .is_extended    -> boolean if  extended
%                   .is_finger      -> boolean if  finger
%                   .is_tool        -> boolean if  tooluse
%                   .is_valid       -> boolean if  tracking is good
%                   .length         -> length of finger?
%                   .width          -> width  of finger?
%                   .touch_distance -> ?????
%                   .time_visible   -> ?????
%       .hands      -> hand information in 1 or 2 element struct
%                   .??? hand struct fields not currently relevant
%                   .??? hand struct fields not currently relevant
%       .version    -> version code identifying how much info is returned


f = matleap(1);

