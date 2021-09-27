function [r,rCI,rLagVal,rAll,rDSTB,rSD] = xcorrEasyBootstrap(x,y,smpVal,maxLagVal,scaleopt,smpBgnEnd,nBoot,CIsz,bPLOT,bPLOTall)

% function [r,rCI,rLagVal,rAll,rDSTB,rSD] = xcorrEasyBootstrap(x,y,smpVal,maxLagVal,scaleopt,smpBgnEnd,nBoot,CIsz,bPLOT,bPLOTall)
%
%   example call: xcorrEasyBootstrap(bsxfun(@plus,cosd(0:359)',2.*randn(360,1000)),bsxfun(@plus,sind(0:359)',2.*randn(360,1000)),[],[],[],[],100,68, 1)
%
% x:         time series number 1                             [ N x nTrl ]
% y:         time series number 2                             [ N x nTrl ]
% smpVal:    values at which time series are sampled          [ N x  1   ]
% maxLagVal: maxlag (in units of smpVal)
% scaleopt:  'coeff' -> normalized cross correlation (default)
% smpBgnEnd: indices to be used for computing xcorr
% nBoot:     number of bootstraps
% CIsz:      confidence interval size 
%            68 -> 68% confidence interval (i.e. ~+/- standard error)
%            95 -> 95% confidence interval 
% bPLOT:     plot or not
%            1 -> plot
%            0 -> not
% bPLOTall:  plot each run or not
%            1 -> plot each run
%            0 -> not
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% r:        mean cross-correlation
% rCI:      confidence interval
% rLagVal:  values of lags (e.g. time lag in secs)
% rAll:     all             cross-correlations (for each run)
% rDSTB:    distribution of cross-correlations (for each bootstrap)
% rSD:      stddev of correlation across repeats

% INPUT HANDLING
if ~exist('y',     'var')    || isempty(y)         y         = x;               end
if ~exist('smpVal','var')    || isempty(smpVal)    smpVal    = [1:size(x,1)]';  end
if ~exist('maxLagVal','var') || isempty(maxLagVal) maxLagVal = size(x,1)-1;     end
if ~exist('scaleopt','var')  || isempty(scaleopt)  scaleopt  = 'coeff';         end
if ~exist('smpBgnEnd','var') || isempty(smpBgnEnd) smpBgnEnd = [1 max(smpVal)]; end
if numel(smpBgnEnd) == 1,                          smpBgnEnd(2) = max(smpVal);  end
if ~exist('CIsz','var')      || isempty(CIsz)      CIsz      =  95;             end
if ~exist('bPLOT','var')     || isempty(bPLOT)     bPLOT     = 0;               end
if ~exist('bPLOTall','var')  || isempty(bPLOTall)  bPLOTall  = 0;               end

% TIME SAMPLES TO USE IN COMPUTING CCG
indGd = smpVal(:) >= smpBgnEnd(1) & smpVal(:) <= smpBgnEnd(2);
% CHECK THAT INDICES ARE MATCHED TO SAMPLE
indGd = indGd(1:size(x,1));
% MAX LAG
maxLagSmp = find(smpVal < maxLagVal,1,'last');

%% XCORR (USING BUILT IN MATLAB FUNCTIONS
for i = 1:size(x,2)
rAll(:,i)  = flipud(xcorr(x(indGd,i),y(indGd,i),maxLagSmp,scaleopt));
end

% MEAN CORRELATION
r = mean(rAll,2);

% STANDARD DEVIATION OF CORRELATION REPEATS
rSD = std(rAll,[],2);

% BOOTSTRAP CORRELATION
for i = 1:nBoot
    indBoot = randsample(size(rAll,2),size(rAll,2),'true');
    rDSTB(:,i) = mean(rAll(:,indBoot),2);
end

% CONFIDENCE INTERVAL LO AND HI
CIlohi = [0.5.*(1-CIsz/100) 1-0.5.*(1-CIsz/100)];

% CONFIDENCE INTERVAL
rCI = quantile(rDSTB,CIlohi,2);

% LAG VALUES
rLagVal = smpPos(1./diff(smpVal(1:2)),size(r,1))';

if bPLOT == 1
   %%
   figure; hold on
   if bPLOTall == 1
   plot(rLagVal,rAll,'linewidth',0.5);
   end
   plotfillederror(rLagVal',rCI(:,1)',rCI(:,2)');
   plot(rLagVal,mean(r,2),'k','linewidth',1);
   formatFigure('Lag','Correlation');
   axis square; 
   if strcmp(scaleopt,'coeff') 
   ylim([-1 1]); 
   plot([0 0],ylim,'k--');
   end
end