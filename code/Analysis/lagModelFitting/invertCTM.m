function [contrast,stimulus] = invertCTM(params,direction,targetLag)
% Invert QCM model for a particular direction
%
% Synopsis
%    [contrast,stimulus] = tfeQCMInvert(params,direction,response)
%
% Description:
%    Take a unit vector specifying a direction in stimulus space, the
%    parameters of the QCM model, and a desirec response, and find the
%    contrast that produces that response.  Also returns the corresponding
%    stimulus.
%
% Inputs:
%      params        - QCM model parameter struct
%      direction     - Direction, should have unit length
%      response      - Desired response
% 
% Outputs:
%      contrast      - Contrast that produces response. NaN if passed
%                      response not attainable.
%      stimulus      - Stimulus corresponding to contrast, given by
%                      contrast*direction

% History:
%   04/11/21 mab  Wrote it.


% Handle the pesky offset and check that there is an in-range contrast.
% Return NaN if not.
offsetResponse = targetLag-params.minLag;
if (offsetResponse <= 0)
    contrast = NaN;
    stimulus = contrast*direction;
    return;
end

% Invert Naka rushton to find desired output of quadratic computation.
theDimension = size(direction,1);
desiredEqContrast = -1* log((targetLag-params.minLag)./params.amplitude)./params.scale;

% Find what comes out of quadratic for the passed direction.
[~,Ainv,Q] = EllipsoidMatricesGenerate([1 params.minAxisRatio params.angle],'dimension',theDimension);
directionEqContrast = diag(sqrt(direction'*Q*direction));
contrast = desiredEqContrast/directionEqContrast;
stimulus = contrast*direction;