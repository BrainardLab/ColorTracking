function vec = paramsToVecCombo(params)

%% The CTM Params
        x(1) = params.angle;
        x(2) = params.minAxisRatio;
        x(3) = params.scale;
        x(4) = params.minLag;
        x(5) = params.amplitude;
        
%% The Dectection Params
        x(6) = params.angle;
        x(7) = params.minAxisRatio;
        x(8) = params.lambda;
        x(9) = params.exponent;