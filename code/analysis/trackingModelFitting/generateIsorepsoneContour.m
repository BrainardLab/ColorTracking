function [C, sampleBaseTheta, targetL, targetS,expDirPoints] = generateIsorepsoneContour(params, targetLag, numMechanisms, varargin)
% Generates the contrasts per chromatic direction needed to obtain a
% criterion lag.
%
% Syntax:
%   [C, sampleBaseTheta] = generateIsorepsoneContour(params, targetLag, numSamples)
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
p.addParameter('numSamples',300,@isscalar);
p.addParameter('dataDirections',[],@isvector);
p.parse(params,targetLag,numMechanisms,varargin{:});

numSamples = p.Results.numSamples;

% set the step size of theta
sampleResolution = 360./numSamples;

% create the theta sample base
sampleBaseTheta = 0:sampleResolution:360;

% % use the target lag to get the m output
m = -log((targetLag - params.minLag) ./ params.amplitude);
%
% % use m and the weights to get the contrast per direction
% C = m ./ ((params.weightL .* cosd(sampleBaseTheta)) - (params.weightS .* sind(sampleBaseTheta)));

if numMechanisms == 1
    C = m ./ (sqrt(params.weightL.^2 + params.weightS.^2) .* cosd(sampleBaseTheta + atand(params.weightS./params.weightL)));
elseif numMechanisms == 2
    C_1 = m ./ (sqrt(params.weightL_1.^2 + params.weightS_1.^2) .* cosd(sampleBaseTheta + atand(params.weightS_1./params.weightL_1)));
    C_2 = m ./ (sqrt(params.weightL_2.^2 + params.weightS_2.^2) .* cosd(sampleBaseTheta + atand(params.weightS_2./params.weightL_2)));
    
    C = min([C_1,C_2]);
end

posMechIndx = find(C >0);
negMechIndx = find(C <0);

% change polar to cartesian
[targetL.pos, targetS.pos] = pol2cart(deg2rad(sampleBaseTheta(posMechIndx)),C(posMechIndx));
[targetL.neg, targetS.neg] = pol2cart(deg2rad(sampleBaseTheta(negMechIndx)),abs(C(negMechIndx)));

if ~isempty(p.Results.dataDirections)
    dataDirections = p.Results.dataDirections;
    dataDirPoints = m ./ (sqrt(params.weightL.^2 + params.weightS.^2) .* cosd(dataDirections + atand(params.weightS./params.weightL)));
    [expDirL, expDirS] = pol2cart(deg2rad(p.Results.dataDirections),dataDirPoints);
    expDirPoints= [expDirL; expDirS];
else
    expDirPoints = [];
end