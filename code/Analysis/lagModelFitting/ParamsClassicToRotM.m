function rotMParams = ParamsClassicToRotM(classicParams)

% Get angle
rotMParams.angle = atand(classicParams.weightS_1/classicParams.weightL_1);

% Rotate mechanism 1 back
invR = deg2rotm(-rotMParams.angle);

% Get raw mechanism 1 to get scale factor
rawMech1 = invR*[classicParams.weightL_1 classicParams.weightS_1]';

% Pull out scale factor
rotMParams.scale = rawMech1(1);

% Get scaled S cone weight
weightS_1 = classicParams.weightS_1/rotMParams.scale;

% Find orthogonal direction
weightL_2 = classicParams.weight_M2*weightS_1;
weightS_2 = -classicParams.weight_M2;
rotMParams.minAxisRatio = classicParams.weight_M2;


rotMParams.minLag = classicParams.minLag;
rotMParams.amplitude = classicParams.amplitude;

end
