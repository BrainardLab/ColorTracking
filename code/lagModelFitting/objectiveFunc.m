function objVal = objectiveFunc(p,lags,cL,cS)

m1 =  abs(p(1).*cL + p(2).*cS);
m2 =  abs(p(3).*cL + p(4).*cS);

%% Contrast-Lag nonlinearity
Lag1 =  p(5) + p(6) .* exp(-1.*p(7).*m1);
Lag2 =  p(5) + p(6) .* exp(-1.*p(7).*m2);

lagEsts = min([Lag1'; Lag2'])';
%% objective function
objVal = sqrt(mean(lags(:) - lagEsts).^2);
end