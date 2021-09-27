function negLL = xcorrFitMLEnegLL(rParam,modelType,rLagVal,rLagValLog,r,rStd,rStdK)

% function negLL = xcorrFitMLEnegLL(rParam,modelType,rLagVal,rLagValLog,r,rStd,rStdK)
%
%   example call: 
% 
% negative log-likelihood 
% 
% rParam:        correlation fit parameters
% modelType:     type of  xcorr function
%               'GSS' -> gaussian
%               'LGS' -> log-gaussian
%               'AGS' -> assymetric gaussian
%               'GLG' -> gaussian + log-gaussian
%               'GS2' -> mixture of two gaussians
%               'LG2' -> mixture of two log-gaussians
%               'GMA' -> gamma w. delay
%               'GM2' -> mixture of two gammas w. delays
% rLagVal:       lag values           (e.g. time lag in secs)
% rLagValLog:    lag values logged... enter to improve fitting speed 
% r:             correlation values to fit
% rStd:          standard deviation of fits
% rStdK:         factor by which standard deviation is multiplied...
%                time points ignored when if correlation is <= rStd.*rStdK 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% negLL:      negative log-likelihood

% INPUT HANDLING
if ~exist('rStd','var') || isempty(rStd) rStd = 1; end

% FUNCTION FIT
rFit = xcorrFitMLEfunc(rLagVal,rLagValLog,modelType,rParam);

% GOOD INDICES
if     strcmp(modelType,'LGS') || strcmp(modelType,'GLG') || strcmp(modelType,'LG2') || ...
       strcmp(modelType,'GMA') || strcmp(modelType,'GM2')
   indGd = rLagVal > 0; 
elseif strcmp(modelType,'GSS') || strcmp(modelType,'AGS') || strcmp(modelType,'GS2') 
   indGd = true(size(rLagVal));
else
    error(['xcorrFitMLEnegLL: WARNING! unhandled modelType=' modelType]);
end

% NOISE STANDARD DEVIATION
if  isscalar(rStd)                    nseStd=rStd.*ones(size(rLagVal));
elseif numel(rStd) == numel(rLagVal)  nseStd=rStd;
else error(['xcorrFitMLEnegLL: WARNING! something wrong with rStd input parameter']);
end

% AVERAGE NOISE STANDARD DEVIATION
nseStdAvg = sqrt(mean(nseStd.^2))./100;
indGd = indGd & abs(r) > nseStdAvg.*rStdK;

% NEGATIVE LOG-LIKELIHOOD ASSUMING INDEPENDENT CORRELATION NOISE
negLL = -sum( -0.5.*( (rFit(indGd(:)) - r(indGd(:)))./nseStd(indGd(:)) ).^2 );