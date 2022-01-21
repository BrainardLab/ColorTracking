function [mFit,sFit,bFit,Tfit,PCdta,PCfit,negLL] = psyfitgengauss(Xstd,Xcmp,RcmpChs,mFix,sFix,bFix,DPcrt,nIntrvl,bPLOT,xLbl,yLbl,color,shape,figh)

% function [mFit,sFit,bFit,Tfit,PCdta,PCfit,negLL] = psyfitgengauss(Xstd,Xcmp,RcmpChs,mFix,sFix,bFix,DPcrt,nIntrvl,bPLOT,xLbl,yLbl,color,shape,figh)
%
%   example call:   % FIT SUBJECT DATA
%                   psyfitgengauss(abs(S.stdX),abs(S.cmpX),S.R == S.cmpIntrvl,[],[],[1],1,2,1);
%
%                   % FIT SIMULATED PSYCHOMETRIC DATA
%                   clear R; clear Xcmp;
%                   N = 50; Xlvl = -6:2:6; Xstd = 0; Xcmp = reshape(repmat(Xlvl,[N 1]),[N.*length(Xlvl) 1]);
%                   Rlvl = binornd(N,psyfuncgengauss([],Xlvl,0,1,1,1,2,0)');
%                   R    = zeros(N,length(Xlvl));
%                   for i = 1:length(Xlvl), R(1:Rlvl(i),i) = 1; end;
%                   psyfitgengauss(Xstd,Xcmp,R,[],[],[1],1,2,1);
%
%                   nTrlPerLvl = 200; Xstd = 0; Xcmp = repmat(-3:.5:3,nTrlPerLvl,1);
%                   RcmpChs = binornd(1,repmat(normcdf(unique(Xcmp)',0,2),nTrlPerLvl,1));
%                   psyfitgengauss(Xstd,Xcmp,RcmpChs,[],[],[1],1,2,1);
%
% fit generalized gaussian psychometric function to data
%
% Xstd:      std X values                    [nTrl x 1]
% Xcmp:      cmp X values                    [nTrl x 1]
% RcmpChs:   subject responses (0 or 1)      [nTrl x 1]
%            coded as cmp vs std chosen
%            1 -> cmp chosen
%            0 -> std chosen
% mFix:      fixed value of mu             default = []
% sFix:      fixed value of sigma          default = []
%            NOTE! sFix represents SD of underlying decision variable
% bFix:      fixed value of beta           default = []
% DPcrt:     criterion dprime corresponding to threshold
% nIntrvl:   number of intervals
% bPLOT:     1 -> plot
%            0 -> not
% xLbl:      plot x-label
% yLbl:      plot y-label
% color:     plot color
% shape:     plot shape
% figh:      plot figure handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mFit:     mean      fit
% sFit:     sigma     fit
% bFit:     beta      fit
% Tfit:     threshold fit (corresponding to criterion d')
% PCdta:    percent correct for the raw data
% PCfit:    percent correct for the fit at each Xcmp
% negLL:    negative log-likelihood of fit

% INPUT HANDLING
if ~exist('mFix','var')    || isempty(mFix);      mFix    =  []; end
if ~exist('sFix','var')    || isempty(sFix);      sFix    =  []; end
if ~exist('bFix','var')    || isempty(bFix);      bFix    =  []; end
if ~exist('DPcrt','var')   || isempty(DPcrt),     DPcrt   =   1; end
if ~exist('nIntrvl','var') || isempty(nIntrvl),   nIntrvl =   1; end
if ~exist('bPLOT','var')   || isempty(bPLOT),     bPLOT   =   0; end
if ~exist('xLbl','var');                          xLbl    =  []; end
if ~exist('yLbl','var');                          yLbl    =  []; end
if ~exist('color','var');                         color   = 'k'; end
if ~exist('shape','var');                         shape   = 'o'; end
if ~exist('figh','var');                          figh    =  []; end

if nIntrvl == 0, error(['psyfitgengauss: WARNING! nIntrvl = 0. Function call has probably not been updated to accommodate nIntrvl input param. CHECK CODE!!!']); end

% INPUT CHECKING
if size(Xstd,2)    ~= 1, Xstd    = Xstd(:);    end
if size(Xcmp,2)    ~= 1, Xcmp    = Xcmp(:);    end
if size(RcmpChs,2) ~= 1, RcmpChs = RcmpChs(:); end
if length(Xstd) ~= length(Xcmp)  && length(Xstd) ~= 1, error(['psyfitgengauss: WARNING! Xstd and Xcmp sizes do not match. Fix it!']); end
if length(Xcmp) ~= length(RcmpChs),                    error(['psyfitgengauss: WARNING! Xcmp and RcmpChs sizes do not match. Fix it!']); end

% SET LOWER AND UPPER BOUNDS ON PARAMETERS
pLB     = [2.0.*min(Xcmp(:)-mean(Xcmp(:)))+mean(Xcmp(:)) 0.02.*(max(Xcmp(:))-min(Xcmp(:))) 0.35];
pUB     = [2.0.*max(Xcmp(:)-mean(Xcmp(:)))+mean(Xcmp(:)) 2.00.*(max(Xcmp(:))-min(Xcmp(:))) 3.00];

% SET FMINCON OPTIONS
minFuncType = 'fmincon';
if strcmp(minFuncType,'fmincon')
    opts             = optimset('fmincon');
    opts.Algorithm   = 'active-set';
    opts.LargeScale  = 'off';
    opts.UseParallel = 'never';
    opts.Display     = 'none';
    opts.MaxIter     = 500;
elseif strcmp(minFuncType,'fminsearch')
    opts             = optimset('fminsearch');
    opts.UseParallel = 'never';
    opts.Display     = 'off';
    opts.MaxIter     = 500;
end

% SET INITIAL PARAMETER VALUES
m0  = mFix;
s0  = sFix;
b0  = bFix;
if isempty(m0); m0 = mean([min(Xcmp(:)) max(Xcmp(:))]); m0 = m0  + .1.*randn; end
if isempty(s0); s0 = diff(minmax(abs(Xcmp)))./6;        s0 = s0  + .1.*s0.*randn; end
if isempty(b0); b0 = 1;                                 b0 = b0  + .1.*b0.*randn; end
p0 = [m0 s0 b0];

% MINIMIZE NEGATIVE LOG-LIKELIHOOD
if strcmp(minFuncType,'fmincon')
    [pFit,negLL] = fmincon(   @(p) psyfitgengaussNegLL(p,Xcmp,RcmpChs,mFix,sFix,bFix,nIntrvl),p0,[],[],[],[],pLB,pUB,[],opts);
elseif strcmp(minFuncType,'fminsearch')
    [pFit,negLL] = fminsearch(@(p) psyfitgengaussNegLL(p,Xcmp,RcmpChs,mFix,sFix,bFix,nIntrvl),p0,opts);
end

% FINAL FIT PARAMETERS
if isempty(mFix); mFit = pFit(1); else; mFit = mFix; end
if isempty(sFix); sFit = pFit(2); else; sFit = sFix; end
if isempty(bFix); bFit = pFit(3); else; bFit = bFix; end

% FIT THE FUNCTION
XstdUnq = unique(Xstd);
XcmpUnq = unique(Xcmp);

% NEW FUNCTION... HANDLES nIntrvl
[PCfit,Tfit,DPfit] = psyfitgengaussfunc(XstdUnq,XcmpUnq,mFit,sFit,bFit,DPcrt,nIntrvl);

% OLD FUNCTION (DOES NOT HANDLE nIntrvl)
% [PCfit,Tfit,DPfit] = psyfuncgengauss(XstdUnq,XcmpUnq,mFit,sFit,bFit,DPcrt,0);

% RAW DATA- COMPUTE PERCENT COMPARISON CHOSEN
[PCdta,XstdUnq,XcmpUnq] = psyPercentChosen(Xstd,Xcmp,RcmpChs);

%%%%%%%%%%%%%%%%
% PLOT RESULTS %
%%%%%%%%%%%%%%%%
if bPLOT
    %% OPEN FIGURE
    if ~exist('figh','var') || isempty(figh)
    figure('position',[680   634   384   406]); hold on
    else
	figure(figh);  hold on
    end
    % PLOT FIT (IN HI-RES)
    XcmpPlt = linspace(1.5.*min(Xcmp-mean(Xcmp))+mean(Xcmp),1.5.*max(Xcmp-mean(Xcmp))+mean(Xcmp),201);
    [PCplt,T]=psyfitgengaussfunc(Xstd,XcmpPlt,mFit,sFit,bFit,DPcrt,nIntrvl,0); hold on;
    % [PCplt,T]=psyfuncgengauss(Xstd,XcmpPlt,mFit,sFit,bFit,DPcrt,0); hold on;
    plot(XcmpPlt,PCplt,'color',color,'linewidth',1.5);
    % PLOT DATA
    if strcmp(shape,'-') || strcmp(shape,'--') shape = 'o'; end
    plot(XcmpUnq,PCdta,shape,'color',color,'linewidth',2,'markersize',15,'markerface','w');
    % WRITE STUFF TO SCREEN
    if isempty(figh)
    writeText(1-.1,.1,{['n=' num2str(numel(RcmpChs))]},'ratio',18,'right')
    end
    formatFigure([xLbl],[yLbl],['T=' num2str(T,'%.2f') ': \mu=' num2str(mFit,'%1.2f') ',\sigma=' num2str(sFit,'%1.2f') ',\beta=' num2str(bFit,'%1.2f')]);
    xlim(minmax(Xcmp)+[-.1 .1]); ylim([0 1])
    axis square
end
