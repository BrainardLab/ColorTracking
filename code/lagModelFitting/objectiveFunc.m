function objVal = objectiveFunc(p,lags,cL,cS)

m1 =  abs(p(1).*cL + p(2).*cS);
m2 =  abs(p(3).*cL + p(4).*cS);
%m1 =  sqrt(p(1).*cL.^2 + p(2).*cS.^2);
%m2 =  sqrt(p(3).*cL.^2 + p(4).*cS.^2);
% Contrast-Lag nonlinearity
Lag1 =  p(5) +  p(6).*exp(-1.*m1);
Lag2 =  p(5) +  p(6).*exp(-1.*m2);
%Lag1 =  p(5) + p(6)./m1;
%Lag2 =  p(5) + p(6)./m2;

lagEsts = min([Lag1'; Lag2'])';
%lagEsts = p(7).*Lag1 - p(8).*Lag2;

%% objective function
objVal = 1000*sqrt(mean((lags(:) - lagEsts).^2));
end