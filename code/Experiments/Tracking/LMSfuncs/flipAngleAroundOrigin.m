function thetaFlipDeg = flipAngleAroundOrigin(thetaDeg)

% function thetaFlipDeg = flipAngleAroundOrigin(thetaDeg)
%
% flips angle around origin
%
% inputs:
%        thetaDeg: angle in degrees
%
% outputs:
%        thetaFlipDeg: flipped angle in degrees

if thetaDeg>=0
    thetaFlipDeg = thetaDeg-180;
else
    thetaFlipDeg = thetaDeg+180;
end

end