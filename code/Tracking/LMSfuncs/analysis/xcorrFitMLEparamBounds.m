function [LB,UB] = xcorrFitMLEparamBounds(modelType,rLagVal)

% function [LB,UB] = xcorrFitMLEparamBounds(modelType,rLagVal)
%
%   example call: xcorrFitMLEparamBounds('LGS',linspace(-5,5,1201))
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LB:       lower bound
% UB:       upper bound

% MIN AND MAX LAGS
rLagValMin = min(rLagVal);
rLagValMax = max(rLagVal);
% LOWER & UPPER BOUND ON AMPLITUDE
LBa = 0;               UBa = 1;
% LOWER & UPPER BOUND ON MAX
LBm = 0.25.*rLagValMin; UBm = 0.25.*rLagValMax;
LBmLog = .0001;

% LOWER & UPPER BOUND ON STD
LBs = 0.00001;         UBs = rLagValMax;
if strcmp(modelType,'GMA') || strcmp(modelType,'GM2')
	LBs = LBs.*10;         UBs = rLagValMax.*20;
end

% LOWER & UPPER BOUND ON DELAY
LBd = 0;         UBd = 1;

if strcmp(modelType,'GSS')
    LB = [LBa LBm LBs];
    UB = [UBa UBm UBs];
elseif strcmp(modelType,'LGS')
    LB = [LBa LBmLog LBs];
    UB = [UBa UBm    UBs];
    % LB = [LBa LBmLog LBs LBd];
    % UB = [UBa UBm    UBs UBd];
elseif strcmp(modelType,'AGS')
    LB = [LBa LBm    LBs            LBs];
    UB = [UBa UBm    UBs            UBs];
elseif strcmp(modelType,'GLG')
    LB = [LBa LBm    LBs LBa LBmLog LBs];
    UB = [UBa UBm    UBs UBa UBm    UBs];
elseif strcmp(modelType,'GS2')
    LB = [LBa LBm    LBs LBa LBm    LBs];
    UB = [UBa UBm    UBs UBa UBm    UBs];
elseif strcmp(modelType,'LG2') 
    % UNPACK PARAMETERS
    LB = [LBa LBmLog LBs LBa LBmLog LBs];
    UB = [UBa UBm    UBs UBa UBm    UBs];
elseif strcmp(modelType,'GMA') 
    % UNPACK PARAMETERS
    LB = [LBa LBmLog LBs LBd ];
    UB = [UBa UBm    UBs UBd ];
elseif strcmp(modelType,'GM2') 
    % UNPACK PARAMETERS
    LB = [LBa LBmLog LBs LBd LBa LBmLog LBs LBd];
    UB = [UBa UBm    UBs UBd UBa UBm    UBs UBd];
else
    error(['xcorrFitMLEparamBounds: WARNING! unhandled modelType=' modelType]);
end