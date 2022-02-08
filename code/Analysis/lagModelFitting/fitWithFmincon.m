function [p_hat,lagsFromFit,m1_hat,m2_hat,Lag1_hat,Lag2_hat] = fitWithFmincon(lags,stimuli)

%% set up the mechanisms
%initial weight estimates [0.7 0.3 0.997 0.003 2.5/1000 0.3];
a1 = 50;
b1 = 2;
a2 = 0;
b2 = 0;
minLag1 = 0.3;
decay1 = 0.2;
% c1 = .5;
% c2 = .5;

%p = [a1,b1,a2,b2,minLag1,decay1,c1,c2];
p = [a1,b1,a2,b2,minLag1,decay1];

%% Search for it
A =[];
aa = [];
Aeq =[];%[0,0,0,0,0,0,1,1];
aaeq =[];%[1];
nlcon =[];

% lb =[0,0,0,0,0,0,0,0];
% ub = [100,0,0,100,5,100,1,1];
lb =[0,0,0,0,0,0];
ub = [100,100,0,0,5,100];

options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','iter','LargeScale','off','Algorithm','active-set');

cL = stimuli(1,:);
cS = stimuli(2,:);

p_hat = fmincon(@(p) objectiveFunc(p,lags(:)',cL,cS),p,A,aa,Aeq,aaeq,lb,ub,nlcon,options);

%% break up p
a1_hat      = p_hat(1);
b1_hat      = p_hat(2);
a2_hat      = p_hat(3);
b2_hat      = p_hat(4);
minLag1_hat = p_hat(5);
decay1_hat  = p_hat(6);
% c1_hat      = p_hat(7);
% c2_hat      = p_hat(8);

%% Use the recovered weights
% m1_hat =  sqrt(a1_hat.*cL.^2 + b1_hat.*cS.^2);
% m2_hat =  sqrt(a2_hat.*cL.^2 + b2_hat.*cS.^2);
m1_hat =  abs(a1_hat.*cL - b1_hat.*cS);
m2_hat =  abs(a2_hat.*cL - b2_hat.*cS);

%% Contrast-Lag nonlinearity
Lag1_hat =  minLag1_hat +  decay1_hat.* exp(-1.*m1_hat);
Lag2_hat =  minLag1_hat +  decay1_hat.* exp(-1.*m2_hat);
%Lag1_hat =  minLag1_hat + decay1_hat./m1_hat;
%Lag2_hat =  minLag1_hat + decay1_hat./m2_hat;


%% objective function
lagsFromFit = min([Lag1_hat; Lag2_hat]);
%lagsFromFit = c1_hat.*Lag1_hat - c2_hat.*Lag2_hat;
