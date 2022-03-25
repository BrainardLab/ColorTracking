function classicParams = ParamsRotMToClassic(rotMParams)

R = deg2rotm(rotMParams.angle);
E = [1,0;0,rotMParams.minAxisRatio];
theWeights = (R*E*rotMParams.scale)';

classicParams.weightL_1 = theWeights(1,1);
classicParams.weightS_1 = theWeights(1,2);
weightL_2 = theWeights(2,1);
weightS_2 = theWeights(2,2);

if (abs( weightL_2 / classicParams.weightS_1) - abs(weightS_2 / classicParams.weightL_1) < 1e-10)
    classicParams.weight_M2 = abs(weightL_2 ./ classicParams.weightS_1);
elseif classicParams.weightL_1 == 0 
    classicParams.weight_M2 = abs(weightL_2 ./ classicParams.weightS_1);
elseif classicParams.weightS_1 == 0 
    classicParams.weight_M2 = abs(weightS_2 / classicParams.weightL_1);
else
    error('Check the weights!!!')
end

classicParams.minLag    = rotMParams.minLag;
classicParams.amplitude = rotMParams.amplitude;

end
