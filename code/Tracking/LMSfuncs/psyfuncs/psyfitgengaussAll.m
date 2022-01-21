function [mFit,sFit,bFit,tFit,DPfit,DPdta,negLL] = psyfitgengaussAll(Xstd,Xcmp,RcmpChsn,mFix,sFix,bFix,DPcrt,nIntrvl,bPLOT,nBoot,CIsz,prcntUse,xLbl,yLbl,color,shape,bPLOTindi)

% function [mFit,sFit,bFit,tFit,DPfit,DPdta,negLL] = psyfitgengaussAll(Xstd,Xcmp,RcmpChsn,mFix,sFix,bFix,DPcrt,nIntrvl,bPLOT,nBoot,CIsz,prcntUse,xLbl,yLbl,color,shape,bPLOTindi)
% 
%   example call: % FIT ALL PSYCHOMETRIC FUNCTIONS
%                 psyfitgengaussAll(abs(S.stdX),abs(S.cmpX),S.R==S.cmpIntrvl,[],[],[1],1,2,1,250,68,[],'Speed (deg/sec)','Threshold (deg/sec)','k','s',1)
% 
% fit multiple psychometric functions at once and plot trends
%  
% Xstd:        standard   values                     [ nTrl x 1 ]
% Xcmp:        comparison values                     [ nTrl x 1 ]
% RcmpChsn:    subject responses                     [ nTrl x 1 ]
%              1 -> subj chose cmp
%              0 -> subj chose std
% mFix:        mu                                    [ 1 x nStdUnq ] 
% sFix:        sigma                                 [ 1 x nStdUnq ] 
% bFix:        beta                                  [ 1 x nStdUnq ]  
% DPcrt:       criterion d-prime defining threshold
% nIntrvl:     number of intervals
% bPLOT:       plot or not
%              1 -> plot
%              0 -> not
% bBootStraps: number of bootstraps to run
% CIsz:        confidence interval size (default: 
% xLbl:        x-axis label
% yLbl:        y-axis label
% color:       color of plots   (if entered)
% shapes:      symbol for plots (if entered)
% shapes:      symbol for plots (if entered)
% bPLOTindi:   plot or not individual psychometric functions
%              1 -> plot indi
%              0 -> not
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mFit:     mean      fit                            [  1   x nStd ] 
% sFit:     sigma     fit                            [  1   x nStd ] 
% bFit:     beta      fit                            [  1   x nStd ] 
% tFit:     threshold fit (w. d' of fixed criterion) [  1   x nStd ]
% DPfit:    d-prime of the best fitting gen gauss    [ nCmp x nStd ]
% DPdta:    d-prime of the raw  data                 [ nCmp x nStd ]
% negLL:    negative log-likelihood of data under model parameters

% INPUT HANDLING
if ~exist('nIntrvl','var')   || isempty(nIntrvl)   nIntrvl = 1;        end
if ~exist('bPLOT','var')     || isempty(bPLOT)     bPLOT = 0;          end
if ~exist('nBoot','var')     || isempty(nBoot)     nBoot = 1;          end
if ~exist('CIsz','var')      || isempty(CIsz)      CIsz = 68;          end
if ~exist('prcntUse','var')  || isempty(prcntUse)  prcntUse = 100;     end
if ~exist('xLbl','var')      || isempty(xLbl)      xLbl = 'X';         end
if ~exist('yLbl','var')      || isempty(yLbl)      yLbl = 'Threshold'; end
if ~exist('color','var')     || isempty(color)     color = 'k';        end
if ~exist('shape','var')     || isempty(shape)     shape = 's';        end
if ~exist('bPLOTindi','var') || isempty(bPLOTindi) bPLOTindi = 0;      end

if nIntrvl == 0, error(['psyfitgengaussAll: WARNING! nIntrvl = 0. Function call has probably not been updated to accommodate nIntrvl input param. Check code!!!']); end

% UNIQUE STANDARDS
XstdUnq = unique(Xstd);

% SETUP FIXED PARAM VECTORS
if ~isempty(mFix) & isscalar(mFix) mFix = repmat(mFix,1,length(XstdUnq)); end
if ~isempty(sFix) & isscalar(sFix) sFix = repmat(sFix,1,length(XstdUnq)); end
if ~isempty(bFix) & isscalar(bFix) bFix = repmat(bFix,1,length(XstdUnq)); end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIT PSYCHOMETRIC FUNCTIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(XstdUnq)
    % FIT EACH PSYCHOMETRIC 
    indCnd  = Xstd==XstdUnq(i);
    mInd = intersect(i,1:length(mFix));
    sInd = intersect(i,1:length(sFix));
    bInd = intersect(i,1:length(bFix));
    [mFit(i),sFit(i),bFit(i),tFit(i),PCdta(:,i),PCfit(:,i),negLL(i)]  = psyfitgengauss(         Xstd(indCnd),Xcmp(indCnd),RcmpChsn(indCnd),mFix(mInd),sFix(sInd),bFix(bInd),DPcrt,nIntrvl,bPLOTindi,xLbl,[],color,shape);
    % BOOTSTRAP EACH PSYCHOMETRIC
    if nBoot > 1
    [~,sCI(i,:),bCI(i,:),tCI(i,:),~,sDstb(:,i),bDstb(:,i),Tdstb(:,i)] = psyfitgengaussBootstrap(Xstd(indCnd),Xcmp(indCnd),RcmpChsn(indCnd),mFix(mInd),sFix(sInd),bFix(bInd),DPcrt,nIntrvl,nBoot,CIsz,prcntUse,0);
    end
    DPdta(:,i)  = percentCorrect2dprime(PCdta(:,i),nIntrvl);
    DPfit(:,i)  = percentCorrect2dprime(PCfit(:,i),nIntrvl);
end
%%
% PLOT RESULTS
if bPLOT
    % PLOT THRESHOLDS
    figure(101); 
    set(gcf,'position',[ 882   550   968   500]);
    subplot(1,2,1); hold on
    plot(XstdUnq,tFit,shape,'color',color,'linewidth',2,'markersize',18,'MarkerFaceColor','w');
    formatFigure(xLbl,yLbl,['Threshold @ d''=' num2str(DPcrt,'%.2f')]);
    xlim([0 6])
    ylim([.03 3]);
    axis square;
    set(gca,'ytick',[.03 .1 .3 1 3]);
    set(gca,'yscale','log')
    % PLOT ERRORBARS
    if exist('tCI','var') && ~isempty(tCI(i,:))
    for i = 1:length(XstdUnq)
       errorbar(XstdUnq(i),tFit(i),tFit(i)-tCI(i,1),tFit(i)-tCI(i,2),'k')
    end
    % writeText(.1,.65,{[num2str(CIsz)      '%CI']},'ratio',18);
    % writeText(.1,.5,{[num2str(prcntUse) '%data used']},'ratio',18);
    % plotfillederror(XstdUnq,tCI(:,1)',tCI(:,2)','k',0)
    end
    
    %% PLOT WEBER FRACTIONS
    subplot(1,2,2); hold on
    plot(XstdUnq,tFit./XstdUnq',shape,'color',color,'linewidth',2,'markersize',18);
    formatFigure(xLbl,'\DeltaSpeed/Speed',['Threshold @ d''=' num2str(DPcrt,'%.2f')]);
    xlim([0 6])
    ylim([0 .5]);
    axis square;
    % PLOT ERRORBARS
    if exist('tCI','var') && ~isempty(tCI(i,:))
        for i = 1:length(XstdUnq)
           errorbar(XstdUnq(i),tFit(i)./XstdUnq(i)',(tFit(i)-tCI(i,1))./XstdUnq(i)',(tFit(i)-tCI(i,2))./XstdUnq(i)','k')
        end
        writeText(.1,.9,{[num2str(CIsz)     '% CI'        ]},'ratio',18);
        writeText(.1,.8,{[num2str(prcntUse) '% data used']},'ratio',18);
    % plotfillederror(XstdUnq,tCI(:,1)',tCI(:,2)','k',0)
    end

    %%
    % PLOT PSYCHOMETRIC DATA TRANSFORMED TO DPRIME
    figure(102); set(gcf,'position',[147   541   532   500]); 
    hold on; 
    colordp = get(gca,'colororder');
    for i = 1:size(DPdta,2)
        indCnd = Xstd==XstdUnq(i);
        plot(unique(Xcmp(indCnd)),DPdta(:,i),shape,'color',colordp(i,:),'linewidth',2,'markersize',18);
    end
    formatFigure(xLbl,'D Prime');
    axis square;
    ylim([-8 8]);
    plot(xlim,[0 0],'k--')
    set(gca,'ytick',[-8:2:8]);
    set(gca,'yticklabel',abs([-8:2:8]));
    legend(legendLabel('S_{std}=',unique(abs(unique(XstdUnq)))',1,3),'Location','SouthEast')
    
    % PLOT BETA
    if isempty(bFix)
        figure(103); set(gcf,'position',[147   21   432   400]); hold on
        plot(XstdUnq,bFit,shape,'color',color,'linewidth',2,'markersize',18);
        formatFigure(xLbl,'Beta'); axis square
        if exist('bCI','var') && ~isempty(bCI(i,:))
            for i = 1:length(XstdUnq), 
                errorbar(XstdUnq(i),bFit(i),bFit(i)-bCI(i,1),bFit(i)-bCI(i,2),'k'); 
            end; 
            
        end
        xlim([0 6]); ylim([0 2]); 
        plot(xlim,[1 1],'k--'); 
        writeText(.5,.5,{'Gaussian CDF'},'ratio',16,'center',0,'bottom')
    end

end
killer = 1;