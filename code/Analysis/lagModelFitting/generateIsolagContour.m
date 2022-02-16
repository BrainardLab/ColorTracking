function [targetL, targetS,expDirPoints] = generateIsolagContour(params, targetLag, numMechanisms, varargin)
% Generates the contrasts per chromatic direction needed to obtain a
% criterion lag.
%
% Syntax:
%   [C, sampleBaseTheta] = generateIsorepsoneContour(params, targetLag, numMechanisms)
%
% Description:
%
%
% Inputs:
%    params            - Parameters from the CTM model fit:
%                        weightL, weightS, amplitude, minLag.
%    targetLag         - The target lag for the isolag contour.
%    numMechanisms     - number of mechanisms  the contour.
%
% Outputs:
%    C                 - Contrasts need to reach the target lag.
%    sampleBaseTheta   - The corresponding directions to the contrasts.
%    targetL           - L cone contrast component
%    targetS           - S cone contrast component
%
% Optional key/value pairs:
%    numSamples        - The sample resolution of the contour
%    dataDirections    - the direction tested in the LS plane (in angles).
%                        If provided, the itersection of the direction and
%                        the contour will be plotted.

% MAB 11/18/21

%% Input Parser
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('params',@isstruct);
p.addRequired('targetLag',@isscalar);
p.addRequired('numMechanisms',@isscalar);
p.addParameter('numSamples',200,@isscalar);
p.addParameter('lAxissampleRange',[-1,1],@isscalar);
p.addParameter('dataDirections',[],@isvector);
p.parse(params,targetLag,numMechanisms,varargin{:});

numSamples = p.Results.numSamples;

% create the theta sample base
lContrastSpacing = p.Results.lAxissampleRange(1):1/round(numSamples./2):p.Results.lAxissampleRange(2);

% % use the target lag to get the m output
m = -log((targetLag - params.minLag) ./ params.amplitude);

%% use m and the weights to get the contrast per direction
if numMechanisms == 1
    % calulate for the + and - parallel planes
    sContrastPos = (m - (params.weightL.*lContrastSpacing))./(-1.*params.weightS);
    sContrastNeg = (-1.*m - (params.weightL.*lContrastSpacing))./(-1.*params.weightS);

    % package the outputs
    targetL =  lContrastSpacing;
    targetS.pos = sContrastPos;
    targetS.neg = sContrastNeg;

elseif numMechanisms == 2
    sContrastPos_mech1 = (m - (params.weightL_1.*lContrastSpacing))./(-1.*params.weightS_1);
    sContrastNeg_mech1 = (-1.*m - (params.weightL_1.*lContrastSpacing))./(-1.*params.weightS_1);
    
    sContrastPos_mech2 = (m - (params.weightL_2.*lContrastSpacing))./(-1.*params.weightS_2);
    sContrastNeg_mech2 = (-1.*m - (params.weightL_2.*lContrastSpacing))./(-1.*params.weightS_2);

    % package the outputs
    targetL =  lContrastSpacing;
    targetS.posMech1 = sContrastPos_mech1;
    targetS.negMech1 = sContrastNeg_mech1;
    targetS.posMech2 = sContrastPos_mech2;
    targetS.negMech2 = sContrastNeg_mech2;
end

if ~isempty(p.Results.dataDirections)
    dataDirections = p.Results.dataDirections;
    dataDirPoints = m ./ (sqrt(params.weightL.^2 + params.weightS.^2) .* cosd(dataDirections + atand(params.weightS./params.weightL)));
    [expDirL, expDirS] = pol2cart(deg2rad(p.Results.dataDirections),dataDirPoints);
    expDirPoints= [expDirL; expDirS];
else
    expDirPoints = [];
end