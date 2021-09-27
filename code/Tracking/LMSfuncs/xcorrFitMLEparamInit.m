function [param0] = xcorrFitMLEparamInit(modelType,rLagVal,r,initType)

% function [LB,UB] = xcorrFitMLEparamInit(modelType,rLagVal,r,initType)
%
%   example call: % RANDOM INITIALIZATION
%                   xcorrFitMLEparamInit('LGS',linspace(-5,5,1201),'RND')
%
%                 % MOMENT-BASED INITIALIZATION
%                   xcorrFitMLEparamInit('LGS',linspace(-5,5,1201),'MMT')
%
% unpack parameter vector for function fitted to cross-correlation
% 
% modelType:  type of function to fit to xcorr
%          'GSS' -> gaussian
%          'LGS' -> log-gaussian
%          'AGS' -> assymetric gaussian
%          'GLG' -> gaussian + log-gaussian
%          'GS2' -> mixture of gaussians
%          'LG2' -> mixture of log-gaussians
%          'GMA' -> gamma w. delay
%          'GM2' -> mixture of two gammas w. delays
% rLagVal:  values of lags (e.g. time lag in secs)
% r:        correlation values
% initType: type of initialization
%          'RND' -> random initialization (default)
%          'MMT' -> moment initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LB:       lower bound
% UB:       upper bound

% INPUT HANDLING
if ~exist('initType','var') || isempty(initType) initType = 'RND'; end

% LOWER AND UPPER BOUNDS
[LB,UB] = xcorrFitMLEparamBounds(modelType,rLagVal);

if strcmp(initType,'RND')
	param0 = randInterval([LB; UB]).*1/4;
elseif strcmp(initType,'MMT')
    % CONVERT CORRELATION TO PSEUDO-PROBABILITY 
    p  = abs(r)./sum(abs(r(:)));
    % PSEUDO-MEAN
    MU = sum(p.*rLagVal(:));
    % PSEUDO-STANDARD DEVIATION
    SD = sqrt( sum(p.*rLagVal(:).^2) - MU.^2 );
    % AMPLITUDE
    MX = max(r(:));
    % DELAY
    DL = MU./2;
    % MOMENT BASED INITIALIZATION
    param0 = xcorrFitMLEparamPack(MX,MU,SD,DL,MX,MU,SD,DL,modelType);
    param0 = param0 + randn(size(param0));
end