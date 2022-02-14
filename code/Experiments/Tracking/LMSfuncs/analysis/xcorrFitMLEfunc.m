function rFit = xcorrFitMLEfunc(rLagVal,rLagValLog,modelType,rParam,bPLOT)

% function rFit = xcorrFitMLEfunc(rLagVal,rLagValLog,modelType,rParam,bPLOT)
%
%   example call: % LOG-GAUSSIAN FUNCTION
%                 xcorrFitMLEfunc([0:1000]./1000,[],'LGS',[.2,.24,.2,.1],1)
%
%                 % GAMMA FUNCTION
%                 xcorrFitMLEfunc([0:1000]./1000,[],'GMA',[.04 .05 4 .05],1)
%
%                 % GAMMA FUNCTION (TO IMPROVE SPEED WHEN FITTING)
%                 xcorrFitMLEfunc([0:1000]./1000,log([0:1000]./1000),'GMA',[.04 .05 4 .05],1)
%
% rLagVal:      lag values           (e.g. time lag in secs)
% rLagValLog:   lag values logged... enter to improve fitting speed 
% modelType:    type of  xcorr function
%               'GSS' -> gaussian
%               'LGS' -> log-gaussian
%               'AGS' -> assymetric gaussian
%               'GLG' -> gaussian + log-gaussian
%               'GS2' -> mixture of two gaussians
%               'LG2' -> mixture of two log-gaussians
%               'GMA' -> gamma w. delay
%               'GM2' -> mixture of two gammas w. delays
% rParam:       parameters of function that define the fit
% bPLOT:        plot or not
%               1 -> plot
%               0 -> not
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rFit:     function defined by fitted parameters for modelType

% INPUT HANDLING
if ~exist('bPLOT',     'var') || isempty(bPLOT)      bPLOT      =            0; end

if strcmp(modelType,'GSS')
    % UNPACK PARAMETERS
    [a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,modelType);
    % FUNCTION
    rFit = a1.*exp(-0.5.*((rLagVal - m1)./s1).^2);
elseif strcmp(modelType,'LGS')
    % LOG LAGS (IF NECESSARY)
    if ~exist('rLagValLog','var') || isempty(rLagValLog) 
        rLagValLog = log(rLagVal); 
    end
    % UNPACK PARAMETERS
    [a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,modelType);
    % INDICTES OF NEGATIVE AND POSITIVE VALUES GIVEN DELAY
    indNeg = find( (rLagVal) <=0);
    indPos = find( (rLagVal) > 0);
    % FUNCTION (GOOFY)
    rFit = a1.*exp(-0.5.*((rLagValLog - log(m1))./s1).^2);
    % FUNCTION (CORRECT)
    % rFit = a1.*exp(-0.5.*((rLagValLog - m1)./s1).^2);
    % % INDICTES OF NEGATIVE AND POSITIVE VALUES GIVEN DELAY
    % indNeg = find( (rLagVal-d1) <=0);
    % indPos = find( (rLagVal-d1) > 0);
    % rFit(indPos,1)  = a1.*exp(-0.5.*((log((rLagVal(indPos)-d1)) - log(m1))./s1).^2);
elseif strcmp(modelType,'AGS')
    % UNPACK PARAMETERS
    [a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,modelType);
    % INDICES   LESS  THAN MEAN
    ind1 = rLagVal<= m1;
    % INDICES GREATER THAN MEAN
    ind2 = rLagVal>  m1;
    % FUNCTION LESS    THAN MEAN
    rFit(ind1,1) = a1.*exp(-0.5.*((rLagVal(ind1) - m1)./s1).^2);
    % FUNCTION GREATER THAN MEAN
    rFit(ind2,1) = a1.*exp(-0.5.*((rLagVal(ind2) - m1)./s2).^2);
elseif strcmp(modelType,'GLG')
    % LOG LAGS (IF NECESSARY)
    if ~exist('rLagValLog','var') || isempty(rLagValLog) 
        rLagValLog = log(rLagVal); 
    end
    % UNPACK PARAMETERS
    [a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,modelType);
    % FUNCTION 1
    rFunc1 = a1.*exp(-0.5.*((rLagVal - m1)./s1).^2);
    % FUNCTION 2
    rFunc2 = a2.*exp(-0.5.*((rLagValLog - log(m2))./s2).^2);
    % FUNCTION
    rFit = rFunc1 + rFunc2;
elseif strcmp(modelType,'GS2')
    % UNPACK PARAMETERS
    [a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,modelType);
    % FUNCTION 1
    rFunc1 = a1.*exp(-0.5.*((rLagVal - m1)./s1).^2);
    % FUNCTION 2
    rFunc2 = a2.*exp(-0.5.*((rLagVal - m2)./s2).^2);
    % FUNCTION
    rFit = rFunc1 + rFunc2;
elseif strcmp(modelType,'LG2') 
    % LOG LAGS (IF NECESSARY)
    if ~exist('rLagValLog','var') || isempty(rLagValLog) 
        rLagValLog = log(rLagVal); 
    end
    % UNPACK PARAMETERS
    [a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,modelType);
    % FUNCTION 1
    rFunc1 = a1.*exp(-0.5.*((rLagValLog - log(m1))./s1).^2);
    % FUNCTION 2
    rFunc2 = a2.*exp(-0.5.*((rLagValLog - log(m2))./s2).^2);
    % FUNCTION
    rFit   = rFunc1 + rFunc2;
elseif strcmp(modelType,'GMA') 
  	% UNPACK PARAMETERS
    [a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,modelType);
    % INDICTES OF NEGATIVE AND POSITIVE VALUES GIVEN DELAY
    indNeg = find( (rLagVal-d1) <=0);
    indPos = find( (rLagVal-d1) > 0);
    % FUNCTION 1
    rFit(indPos,1) =  a1.*( ( ((rLagVal(indPos)-d1).^(s1-1))./(m1.^s1) )./gamma(s1) ) .* exp(-(rLagVal(indPos)-d1)./m1) ;
elseif strcmp(modelType,'GM2') 
  	% UNPACK PARAMETERS
    [a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,modelType);
    indPos = find( (rLagVal-d1) > 0);
    % FUNCTION 1
    rFunc1(indPos,1) =  a1.*( ( ((rLagVal(indPos)-d1).^(s1-1))./(m1.^s1) )./gamma(s1) ) .* exp(-(rLagVal(indPos)-d1)./m1) ;%     % FUNCTION 1
    % FUNCTION 2
    rFunc2(indPos,1) =  a2.*( ( ((rLagVal(indPos)-d2).^(s2-1))./(m2.^s2) )./gamma(s2) ) .* exp(-(rLagVal(indPos)-d2)./m2) ;%     % FUNCTION 2
    % FUNCTION
	rFit   = rFunc1 + rFunc2;
else
    error(['xcorrMLEfunc: unhandled modelType=' modelType]);
end

if bPLOT == 1
    figure; hold on
    plot(rLagVal,rFit,'k'); 
    try
    formatFigure('Lag','Correlation',[modelType ': [' num2str(a1,'%.2f') ' ' num2str(m1,'%.3f') ' ' num2str(s1,'%.2f') ' ' num2str(d1,'%.2f') ' ' num2str(a2,'%.2f') ' ' num2str(m2,'%.3f') ' ' num2str(s2,'%.2f') ' ' num2str(d2,'%.2f')   ']']);
%     catch
% 	formatFigure('Lag','Correlation',[modelType ': [' num2str(a1,'%.2f') ' ' num2str(m1,'%.3f') ' ' num2str(s1,'%.2f') ' ' num2str(d1,'%.2f') ' ' num2str(a2,'%.2f') ' ' num2str(m2,'%.3f') ' ' num2str(s2,'%.2f') ' ' num2str(d2,'%.2f')   ']']);
    end
    axis square; 
    xlim([-0.125 1.375]);
    ylim([-0.025 0.225])
    % GUIDE LINES
    plot(xlim,[0 0],'k--','linewidth',0.5);
    plot([0 0],ylim,'k--','linewidth',0.5);
end
