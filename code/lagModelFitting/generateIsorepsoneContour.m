function [C, sampleBaseTheta] = generateIsorepsoneContour(params, targetLag, numSamples)

sampleResolution = 360./numSamples;

sampleBaseTheta = 0:sampleResolution:360;

m = -log((targetLag - params.minLag) ./ params.amplitude);

C = m ./ abs((params.weightL .* sind(sampleBaseTheta)) + (params.weightS .* cosd(sampleBaseTheta)));