function [C, sampleBaseTheta, targetL, targetS,expDirPoints] = generateIsorepsoneContour(params, targetLag, numSamples, varargin)
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
%    numSamples        - number of sample in the contour.
% 
% Outputs:
%    C                 - Contrasts need to reach the target lag.
%    sampleBaseTheta   - The corresponding directions to the contrasts.
%    targetL           - L cone contrast component 
%    targetS           - S cone contrast component 
%
% Optional key/value pairs:
%    None

% MAB 11/18/21

%% Input Parser
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('params',@isstruct);
p.addRequired('targetLag',@isscalar);
p.addRequired('numSamples',@isscalar);
p.addParameter('dataDirections',[],@isvector);
p.parse(params,targetLag,numSamples,varargin{:});


% set the step size of theta
sampleResolution = 360./numSamples;

% create the theta sample base
sampleBaseTheta = 0:sampleResolution:360;

% % use the target lag to get the m output
 m = -log((targetLag - params.minLag) ./ params.amplitude);
% 
% % use m and the weights to get the contrast per direction
% C = m ./ ((params.weightL .* cosd(sampleBaseTheta)) - (params.weightS .* sind(sampleBaseTheta)));

C = m ./ (sqrt(params.weightL.^2 + params.weightS.^2) .* cosd(sampleBaseTheta + atand(params.weightS./params.weightL)));

posMechIndx = find(C >0);
negMechIndx = find(C <0);

% change polar to cartesian 
[targetL.pos, targetS.pos] = pol2cart(deg2rad(sampleBaseTheta(posMechIndx)),C(posMechIndx));
[targetL.neg, targetS.neg] = pol2cart(deg2rad(sampleBaseTheta(negMechIndx)),abs(C(negMechIndx)));

if ~isempty(p.Results.dataDirections)
    dataDirections = p.Results.dataDirections;
    dataDirPoints = m ./ (sqrt(params.weightL.^2 + params.weightS.^2) .* cosd(dataDirections + atand(params.weightS./params.weightL)));
    %m ./ abs((params.weightL .* cosd(p.Results.dataDirections)) - (params.weightS .* sind(p.Results.dataDirections)));
    [expDirL, expDirS] = pol2cart(deg2rad(p.Results.dataDirections),dataDirPoints);
    expDirPoints= [expDirL; expDirS];
else
    expDirPoints = [];
end