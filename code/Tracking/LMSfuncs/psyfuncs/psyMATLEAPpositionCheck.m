function [bTrkChk,posXYZmm0,posXmm0,posYmm0,posZmm0] = psyMATLEAPpositionCheck(maxSec,posXmmLims,posYmmLims,posZmmLims)

% function [bTrkChk,posXYZmm0,posXmm0,posYmm0,posZmm0] = psyMATLEAPpositionCheck(maxSec,posXmmLims,posYmmLims,posZmmLims)
% 
%   example call: % SIMPLE CALL
%                   [bTrkChk,posXYZmm0,posXmm0,posYmm0,posZmm0] = psyMATLEAPpositionCheck(5,[-100 100],[25 450],[-100 100])
%
% TO DO: CHECK TIMING LOAD CAUSED BY MULTIPLE ||s IN IF STATEMENT
% 
% ensure that finger position LEAP controller is within specified limits
% 
% requires that ../matleap/ is part of the matlab path
% see README_matLEAP_SetupForDummies.rtf in ../Shared/Matlab/
%
% NOTE!!! do not use more than one psyMATLEAP*.m function per frame!!!
%       !!!     doing so will needlessly slow down framerate     !!!
%        !!! if you think you need to... see psyMATLEAPframe.m !!!
%
% maxSecs:    max seconds to allow user to position finger within limits
% posXmmLims: limits of X-position coordinates                 [ 1 x 2 ]
%             [] -> only checks if LEAP controller is connected
% posYmmLims: limits of Y-position coordinates                 [ 1 x 2 ]
%             [] -> only checks if LEAP controller is connected
% posZmmLims: limits of Z-position coordinates                 [ 1 x 2 ]
%             [] -> only checks if LEAP controller is connected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bTrkChk:     boolean indicating tracking check success or failure
%              success == track detected AND position within limits
%              1 -> success
%              0 -> failure
% posXYZmm0:   XYZ position in mm in native LEAP coordinate system
% posXmm0:     X   position in mm
% posYmm0:     Y   position in mm
% posZmm0:     Z   position in mm
%
%              ***               see psyMATLEAPframe.m              ***

%%%%%%%%%%%%%%%%%%
% INPUT HANDLING %
%%%%%%%%%%%%%%%%%%
maxSecMAX = 10;
if isscalar(maxSec) 
    if maxSec > maxSecMAX 
    error(['psyMATLEAPpositionCheck: WARNING! maxSec=' num2str(maxSecMAX) ' which exceeds maxSecMAX=' num2str(maxSecMAX)]); 
    end
else
    error(['psyMATLEAPpositionCheck: WARNING! isscalar(maxSec)=0. maxSec must be a positive scalar']); 
end
if ~exist('posXmmLims','var') || isempty(posXmmLims) posXmmLims = [-Inf Inf]; end
if ~exist('posYmmLims','var') || isempty(posYmmLims) posYmmLims = [-Inf Inf]; end
if ~exist('posZmmLims','var') || isempty(posZmmLims) posZmmLims = [-Inf Inf]; end

% GET FRAME FROM LEAP MOTION CONTROLLER
warning off;
tic; while toc < 0.1 end
[bTrk,posXYZmm0] = psyMATLEAPposition();
tic; disp(['psyMATLEAPpositionCheck: ITS GO TIME!']);
while bTrk == 0 || ... 
      posXYZmm0(1) < posXmmLims(1) || posXYZmm0(1) > posXmmLims(2) || ...
      posXYZmm0(2) < posYmmLims(1) || posXYZmm0(2) > posYmmLims(2) || ...
      posXYZmm0(3) < posZmmLims(1) || posXYZmm0(3) > posZmmLims(2)
      [bTrk,posXYZmm0] = psyMATLEAPposition();
      if toc > maxSec 
          warning on;
          bTrkChk = 0;
          if nargout > 1 posXYZmm0 = []; end
          if nargout > 2 posXmm0   = []; end
          if nargout > 3 posYmm0   = []; end
          if nargout > 4 posZmm0   = []; end
          warning(['psyMATLEAPpositionCheck: WARNING! bTrkChk=0; posXYZmm=[' num2str(posXYZmm0) ']. Desired position not achieved!']);
          return;
      end
end
% SUCCESS ACHIEVED
bTrkChk = 1;

% BUILD INDI-COORDINATE VARIABLES ONLY IF REQUESTED
if nargout > 2
    % POSITION ON EACH INDIVIDUAL COORDINATE AXIS
    posXmm0        = posXYZmm0(1,1);
    posYmm0        = posXYZmm0(1,2);
    posZmm0        = posXYZmm0(1,3);
end

