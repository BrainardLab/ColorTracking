function [rFit,rParam,rLagFit] = xcorrFitMLE(rLagVal,r,rStd,rStdK,modelType,initType,bPLOT,bPLOTrpt)

% function [rFit,rParam] = xcorrFitMLE(rLagVal,r,rStd,rStdK,modelType,initType,bPLOT,bPLOTrpt)
%    
%   example call: xcorrFitMLE(S.tSecRho,S.rhoXX(:,1),1,[],'GSS','MMT',1)
%
% rLagVal:    values of lags (e.g. time lag in secs)
% r:          cross-correlation
% rStd:       standard deviation of cross correlation values at baseline
%             at which the expected cross correlation values equal zero
% rStdK:      multiplier on average SD to ignore data within during fits
% modelType:  type of function to fit to xcorr
%            'GSS' -> gaussian
%            'LGS' -> log-gaussian
%            'AGS' -> assymetric gaussian
%            'GLG' -> gaussian + log-gaussian
%            'GS2' -> mixture of gaussians
%            'LG2' -> mixture of log-gaussians
%            'GMA' -> gamma w. delay
%            'GM2' -> mixture of gammas w. delay
% initType:   initialization type
%            'RND' -> random       initialization (based on bounds)
%            'MMT' -> moment-based initialization (plus random num)
% bPLOT:      plot or not
%             1 -> plot
%             0 -> not  (default)
% bPLOTrpt:   plot or not all repeats of fitting procedure
%             1 -> plot 
%             0 -> not  (default)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rFit:       fit to cross-correlation
% rParam:     parameters of fit to cross-correlation
% rLagFit:    lags associated with fitted function

% INPUT HANDLING
if isscalar(modelType) error(['xcorrFitMLE: WARNING! modelType is a scalar']); end
if ~exist('bPLOT','var')    || isempty(bPLOT) bPLOT = 0; end
if ~exist('bPLOTrpt','var') || isempty(bPLOTrpt) bPLOTrpt = 0; end

% INPUT CHECKING
if sum(isnan(r))>0, error(['xcorrFitMLE: WARNING! trying to fit function to NaNs']); end

% PARAMETER BOUNDS
[LB,UB] = xcorrFitMLEparamBounds(modelType,rLagVal);

% MINIMIZATION OPTIONS
minimizationRoutine = 'fmincon';
opts = optimset(minimizationRoutine);
opts.Algorithm      = 'active-set';
opts.LargeScale     = 'off';
opts.UseParallel = 'never';
opts.Display        = 'off';
opts.MaxIter        = 250;
% opts.MaxFunEvals  = opts.MaxIter*10;
opts.TolFun         = 1e-6;
opts.TolX           = 1e-6;
opts.TolCon         = 1e-6;

%%%%%%%%%%%%%%%%%%%%%%%
% OPTIMIZE PARAMETERS %
%%%%%%%%%%%%%%%%%%%%%%%
% NUMBER OF REPEATS
nRpt = 200;
for i = 1:nRpt % LOOP OVER RANDOM STARTS (TO PROTECT AGAINST LOCAL OPTIMA)
    % INITIAL PARAMETERS
    % rParam0  = randInterval([LB; UB]).*1/4;
    rParam0 = xcorrFitMLEparamInit(modelType,rLagVal,r,initType);
    % OPTIMIZE FIT WITH xcorrFitMLEnegLL.m
    [rParamAll(i,:),negLLall(i)] = fmincon(@(param) xcorrFitMLEnegLL(param,modelType,rLagVal,log(rLagVal),r,rStd,rStdK),rParam0,[],[],[],[],LB,UB,[],opts);
end
% SELECT BEST FIT
indMin = find(negLLall==min(negLLall),1); 
% MINIMUM COST
negLL  = negLLall( indMin  );
% MINIMUM COST PARAMETERS
rParam = rParamAll(indMin,:);

% CHECK THAT BEST-FIT PARAMETERS DON'T EQUAL BOUNDS
if sum(abs(rParam-LB)<opts.TolCon)>0 
    LB = LB, rParam = rParam
    disp(['xcorrFitMLE: WARNING! best fit parameters equal lower bounds. Expand bounds!']); 
end
if sum(abs(rParam-UB)<opts.TolCon)>0 
    UB = UB, rParam = rParam
    disp(['xcorrFitMLE: WARNING! best fit parameters equal upper bounds. Expand bounds!']); 
end

% UNPACK FINAL PARAMETERS
[a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,modelType);

% GOOD INDICES
if     strcmp(modelType,'LGS') || strcmp(modelType,'GLG') || strcmp(modelType,'LG2') || strcmp(modelType,'GMA') || strcmp(modelType,'GM2') 
    indGd = rLagVal > 0; 
elseif strcmp(modelType,'GSS') || strcmp(modelType,'AGS') || strcmp(modelType,'GS2')
    indGd = true(size(rLagVal));
end
% LAGS ASSOCIATED WITH FITS
rLagFit = rLagVal(indGd);
% BEST FIT FUNCTION
rFit = xcorrFitMLEfunc(rLagFit,log(rLagFit),modelType,rParam);
 
% PLOT RESULTS
if bPLOT == 1
    figure; hold on;
    xLim=minmax(rLagVal);
    % DATA
    h(1)=plot(rLagVal,r,   'k--','linewidth',1);
    % FIT
    h(2)=plot(rLagFit,rFit,'k-' ,'linewidth',2);
    % MAKE PRETTY
    formatFigure('Lag','Correlation',[modelType ': [' num2str(a1,'%.2f') ' ' num2str(m1,'%.3f') ' ' num2str(s1,'%.2f') ' ' num2str(d1,'%.2f') ' ' num2str(a2,'%.2f') ' ' num2str(m2,'%.3f') ' ' num2str(s2,'%.2f') ' ' num2str(d2,'%.2f') ']']);
    legend(h,{'Data' 'Fit'});
    axis square; 
    xlim([-0.125 1.375]);
    ylim([-0.025 0.225])
    % GUIDE LINES
    plot(xLim,[0 0],'k--','linewidth',0.5);
    plot([0 0],ylim,'k--','linewidth',0.5);
    writeText(.075,.9,{['negLL=' num2str(negLL,'%.4f') ]},'ratio',18,'left')
    killer = 1;
    if bPLOTrpt == 1
       figure;  
       plot(negLLall,'k','linewidth',2);
       formatFigure('Minimization Repeat','NegLL');
       axis square;
    end
end
