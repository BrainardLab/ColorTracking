function [mCI,sCI,bCI,tCI,mFitDstb,sFitDstb,bFitDstb,tFitDstb] = psyfitgengaussBootstrap(Xstd,Xcmp,RcmpChs,mFix,sFix,bFix,DPcrt,nIntrvl,nBoot,CIsz,prcntUse,bPLOT,bQUIET)

% function psyfitgengaussBootstrap(Xstd,Xcmp,RcmpChs,mFix,sFix,bFix,DPcrt,nIntrvl,nBoot,CIsz,prcntUse,bPLOT)
%
%   example call: nTrlPerLvl = 100; Xstd = 0; Xcmp = repmat(-2:.5:2,nTrlPerLvl,1);
%                 RcmpChs = binornd(1,repmat(normcdf(unique(Xcmp)'),nTrlPerLvl,1));
%                 psyfitgengaussBootstrap(Xstd,Xcmp,RcmpChs,[],[],[1],1,2,1000,68,[],1);
%
%                 psyfitgengaussBootstrap(S.stdX,S.cmpX,S.RcmpChs,[],[],[1],1,2,1000,68,[],1);
%
%                 psyfitgengaussBootstrap(abs(S.stdX),abs(S.cmpX),S.R==S.cmpIntrvl,[],[],[ ],1,2,1000,68,[],1);
%
%                 psyfitgengaussBootstrap(abs(S.stdX),abs(S.cmpX),S.R==S.cmpIntrvl,[],[],[1],1,2,1000,68,[],1);
%
% fit generalized gaussian psychometric function to data
%
% Xstd:         std X values                [numTrials x 1]
% Xcmp:         cmp X values                [numTrials x 1]
% RcmpChs:      subject responses (0 or 1)  [numTrials x 1]
%               coded as cmp vs std chosen
%               1 -> cmp chosen
%               0 -> std chosen
% mFix:         fixed value of mFit          default = []
% sFix:         fixed value of sFitDstb          default = []
% bFix:         fixed value of bFitDstb          default = []
%               1 -> psychometric function = cumulative Gaussian
% DPcrt:        d-prime criterion to use
% nIntrvl:      number of intervals
% nBoot:        number of bootstrapped fits (default = 100)
%               1000 should be used for figures to publish
% CIsz:         size of confidence interval
%               95 -> 95% CIsz
%               68 -> 68% CIsz; default & apprx equal to standard error
% prcntUse:     percentage of data to use on each bootstrap
%               default -> 100%
% bPLOT:        1 -> plot
%               0 -> not
%%%%%%%%%%%%%%%%%%%%%%
% mCI:          confidence interval on mean    [ 1 x 2 ]
% sCI:          confidence interval on sigma   [ 1 x 2 ]
% bCI:          confidence interval on beta    [ 1 x 2 ]
% tCI           confidence interval on thresh  [ 1 x 2 ]
%             *** NOTE!  CIlo = CI(1) and CIhi = CI(2) ***
% mFitDstb:     bootstrapped distribution of mus
% sFitDstb:     bootstrapped distribution of sds
% bFitDstb:     bootstrapped distribution of betas
% tFitDstb:     bootstrapped distribution of thresholds (given DPcrt level)


if size(Xstd,2)    ~= 1, Xstd    = Xstd(:);    end
if size(Xcmp,2)    ~= 1, Xcmp    = Xcmp(:);    end
if size(RcmpChs,2) ~= 1, RcmpChs = RcmpChs(:); end
if length(Xstd) ~= length(Xcmp)  && length(Xstd) ~= 1, error(['psyfitgengauss: WARNING! Xstd and Xcmp sizes do not match. Fix it!']); end
if length(Xcmp) ~= length(RcmpChs),                    error(['psyfitgengauss: WARNING! Xcmp and RcmpChs sizes do not match. Fix it!']); end
if ~exist('mFix','var')        || isempty(mFix),        mFix        = [];  end
if ~exist('sFix','var')        || isempty(sFix),        sFix        = [];  end
if ~exist('bFix','var')        || isempty(bFix),        bFix        = [];  end
if ~exist('DPcrt','var')       || isempty(DPcrt),       DPcrt       = 1;   end
if ~exist('nIntrvl','var')     || isempty(nIntrvl),     nIntrvl     = 1;   end
if ~exist('nBoot','var')       || isempty(nBoot),       nBoot       = 100; end
if ~exist('CIsz','var')        || isempty(CIsz),        CIsz        = 68;  end
if ~exist('prcntUse','var')    || isempty(prcntUse),    prcntUse    = 100; end
if ~exist('bPLOT','var')       || isempty(bPLOT),       bPLOT       = 0;   end
if ~exist('bQUIET','var')      || isempty(bQUIET),      bQUIET      = 0;   end

if numel(Xstd) == 1, Xstd = Xstd*ones(numel(Xcmp),1); end
for i = 1:nBoot
    % PROGRESS REPORT
    if bQUIET~=1
        progressreport(i,100,nBoot)
    end
    % SAMPLE WITH REPLACEMENT
    [~,indSmp] = datasample(RcmpChs,round(numel(RcmpChs).*prcntUse./100));
    % REFIT
    [mFitDstb(i,1),sFitDstb(i,1),bFitDstb(i,1),tFitDstb(i,1)]=psyfitgengauss(Xstd(indSmp),Xcmp(indSmp),RcmpChs(indSmp),mFix,sFix,bFix,DPcrt,nIntrvl,0);
end
%%
% CONFIDENCE INTERVAL: LO & HI BOUNDS
CIlohi = 0.5*(1-CIsz/100) + [0 CIsz/100];
% BOOSTRAPPED CONFIDENCE INTERVALS
mCI = quantile(mFitDstb, CIlohi);
sCI = quantile(sFitDstb, CIlohi);
bCI = quantile(bFitDstb, CIlohi);
tCI = quantile(tFitDstb, CIlohi);
% BOOSTRAPPED STD ERR OF STATISTIC
mSE   = std(mFitDstb(~isnan(mFitDstb)));
sSE   = std(sFitDstb(~isnan(sFitDstb)));
bSE   = std(bFitDstb(~isnan(bFitDstb)));
tSE   = std(tFitDstb(~isnan(tFitDstb)));
% BOOSTRAPPED MEAN
mMU = mean(mFitDstb(~isnan(mFitDstb)));
sMU = mean(sFitDstb(~isnan(sFitDstb)));
bMU = mean(bFitDstb(~isnan(bFitDstb)));
tMU = mean(tFitDstb(~isnan(tFitDstb)));

if bPLOT
    % FIT RAW DATA
    [mDta,sDta,bDta,tDta]=psyfitgengauss(Xstd,Xcmp,RcmpChs,mFix,sFix,bFix,DPcrt,nIntrvl,0);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PLOT ESTIMATE HISTOGRAM %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure('position',[201         492        1849         464])
	% UNIQUE COMPARISON VALUES
    XcmpUnq = unique(Xcmp)';
    % PROPORTION CMP CHOSEN
    for i = 1:length(XcmpUnq)
        ind = Xcmp(:) == XcmpUnq(i);
        PcmpDta(i) = mean(RcmpChs(ind));
    end
    % PSYCHOMETRIC FUNCTION FIT
    subplot(1,4,1);
    XcmpPlt = linspace(min(minmax(Xcmp)),max(minmax(Xcmp)),101);
    % PchsPlt = psyfuncgengauss([],XcmpPlt,mDta,sDta,bDta,DPcrt,0);
    PchsPlt = psyfitgengaussfunc([],XcmpPlt,mDta,sDta,bDta,DPcrt,nIntrvl,0);
    plot(XcmpPlt,PchsPlt,'k'); hold on;
    plot(XcmpUnq,PcmpDta,'ko','markerface','w','markersize',12);
    formatFigure('X','Proportion Cmp Chosen');
    formatFigure('Mu','Num Samples',['\mu=' num2str(mDta,'%2.2f') ',\sigma=' num2str(sDta,'%2.2f') ',\beta=' num2str(bDta,'%2.2f') ]);
    writeText(.75,.1,{['N=' num2str(numel(RcmpChs))]},'ratio');
    axis square

    % DISTRIBUTION OF MU    ESTIMATES
    subplot(1,4,2);
    [Hm,Bm] = hist(mFitDstb,21);
    bar(Bm,Hm,1,'facecolor','w');
    formatFigure('Mu','Num Samples',['\mu=' num2str(mMU,    '%2.2f') ', CI^{' num2str(CIsz) '}=[' num2str(mCI(1),   '%2.2f') ',' num2str(mCI(2),'%2.2f')    ']']);
    writeText(.1,.9,{[num2str(prcntUse) '% Data Used']},'ratio',18)
    axis square
    % DISTRIBUTION OF SIGMA ESTIMATES
    subplot(1,4,3);
    [Hs,Bs]=hist(sFitDstb,21);
    bar(Bs,Hs,1,'facecolor','w');
    formatFigure('Sigma','Num Samples',['\sigma=' num2str(sMU,'%2.2f') ', CI^{' num2str(CIsz) '}=[' num2str(sCI(1),'%2.2f') ',' num2str(sCI(2),'%2.2f') ']']);
    writeText(.1,.9,{[num2str(prcntUse) '% Data Used']},'ratio',18)
    axis square
    % DISTRIBUTION OF BETA  ESTIMATES
    subplot(1,4,4);
    [Hb,Bb]=hist(bFitDstb,21);
    bar(Bb,Hb,1,'facecolor','w');
    formatFigure('Beta','Num Samples',['\beta=' num2str(bMU,  '%2.2f') ', CI^{' num2str(CIsz) '}=[' num2str(bCI(1), '%2.2f') ',' num2str(bCI(2),'%2.2f')  ']']);
    writeText(.1,.9,{[num2str(prcntUse) '% Data Used']},'ratio',18)
    axis square
end
