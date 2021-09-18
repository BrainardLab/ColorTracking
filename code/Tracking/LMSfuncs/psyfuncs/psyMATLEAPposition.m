function [bTrk,posXYZmm,posXmm,posYmm,posZmm] = psyMATLEAPposition(posXYZmm0,sgnXYZ)

% function [bTrk,posXYZmm,posXmm,posYmm,posZmm] = psyMATLEAPposition(posXYZmm0,sgnXYZ)
% 
%   example call: % SIMPLE CALL
%                   [posXYZmm,posXmm,posYmm,posZmm] = psyMATLEAPposition()
%
%                 % SIMPLE CALL
%                   [posXYZmm,posXmm,posYmm,posZmm] = psyMATLEAPposition([0 0 0],[1 1 -1])    
%
% get position from LEAP motion controller
% 
% requires that ../matleap/ is part of the matlab path
% see README_matLEAP_SetupForDummies.rtf in code base
%
% NOTE!!! do not use more than one psyMATLEAP*.m function per frame!!!
%                doing so will needlessly slow down framerate
%         !!! if you think you need to... see psyMATLEAPframe.m !!!
%
% posXYZmm0:  original position to subtract off from current position
% sgnXYZ:     multiplier on sign of native MATLEAP coordinate axes to
%             align coordinates with alternative axis sign convention
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bTrk:       boolean indicating if MATLEAP tracking detected
%             success == MATLEAP tracking detected
%             1 -> tracking success
%             0 -> tracking failure
% posXYZmm:   XYZ position in mm
%             if sgnXYZ = [1 1 1];
%               X -> -/+ indicates  left/right     of   center
%               Y -> -/+ indicates  below/above    the  center
%               Z -> -/+ indicates  farther/nearer than center
%             if sgnXYZ = [1 1 -1];
%               X -> -/+ indicates  left/right     of   center
%               Y -> -/+ indicates  below/above    the  center
%               Z -> -/+ indicates  nearer/farther than center
%             etc...
% posXmm:     X   position in mm
% posYmm:     Y   position in mm
% posZmm:     Z   position in mm
%
%             ***       see psyMATLEAPframe.m      ***

% INPUT HANDLING
if nargin <  1, posXYZmm0 = [0 0 0]; end
if nargin <  2, sgnXYZ    = [1 1 1]; end

% GET FRAME FROM LEAP MOTION CONTROLLER
f = matleap(1);

% BOOLEAN INDICATING IF TRACKING ACHIEVED 
% bTrk = (f.id ~= -1); % f.id  = -1 -> BAD  TRACK; bTrk = 0
%                      % f.id ~= -1 -> GOOD TRACK; bTrk = 1
bTrk = ~isempty(f.pointables);

% IF LEAP IS NOT CONNECTED, RETURN EMPTIES
if bTrk == 0
    posXYZmm      = [];
    posXmm        = [];
    posYmm        = [];
    posZmm        = [];
    % warning(['psyMATLEAPposition: WARNING! your LEAP motion controller could not achieve tracking!!!']);
    return
end

try
% POSITION OF FIRST EXTENDED FINGER (FROM RIGHT OF RIGHT HAND)
posXYZmm(1,:) = sgnXYZ.*([f.pointables(1).position(1) ...
                          f.pointables(1).position(2) ...
                          f.pointables(1).position(3)] - posXYZmm0);
catch
   killer = 1; 
end
% BUILD VARIABLES ONLY IF REQUESTD
if nargout > 1                      
    % POSITION ON EACH INDIVIDUAL COORDINATE AXIS
    try
    posXmm        = posXYZmm(1,1);
    posYmm        = posXYZmm(1,2);
    posZmm        = posXYZmm(1,3);
    catch
        killer = 1;
    end
end


