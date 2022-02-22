function [tFit,mFit,sFit,bFit,PCdta,cSpacing] = LSDthresholdAnalysis(S,DPcrt,varargin)

% function [tFit,mFit,sFit,bFit,PCdta] = LSDthresholdAnalysis(S,DPcrt,varargin)
%
% example call: 
%
% analyzes LSD detection experiment data and plots psychometric functions
%
% inputs:
%         S: data struct from experiment
%         DPcrt: d-prime at which threshold is defined. 
%                DPcrt=1.00 -> 76% correct
%                DPcrt=1.41 -> 84% correct

p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('S',@isstruct);
p.addParameter('showPlot',true,@islogical);
p.addParameter('bPLOTthresholds',0,@isnumeric);
p.addParameter('fitType','weibull',@ischar);
p.parse(S,varargin{:});

nIntrvl = 2;

targetContrastAngleUnq = unique(S.targetContrastAngle);

nRepeats = 10;

for i = 1:length(targetContrastAngleUnq)
   ind = abs(S.targetContrastAngle-targetContrastAngleUnq(i))<0.01;
   for j = 1:nRepeats
       if strcmp(p.Results.fitType,'weibull')
          [mFitTmp(:,j),sFitTmp(:,j),bFitTmp(:,j),tFitTmp(:,j),PCdtaTmp(:,j),~,negLLtmp(:,j)] = psyfitWeibull(zeros(size(S.targetContrast(ind))),abs(S.targetContrast(ind)),S.R(ind) == S.cmpIntrvl(ind),0,[],[],DPcrt,nIntrvl,0);
          cSpacing(:,i) = unique(abs(S.targetContrast(ind)));
       elseif strcmp(p.Results.fitType,'gaussian')
          [mFitTmp(:,j),sFitTmp(:,j),bFitTmp(:,j),tFitTmp(:,j),PCdtaTmp(:,j),~,negLLtmp(:,j)] = psyfitgengauss(zeros(size(S.targetContrast(ind))),abs(S.targetContrast(ind)),S.R(ind) == S.cmpIntrvl(ind),0,[],[],DPcrt,nIntrvl,0);
          cSpacing(:,i) = unique(abs(S.targetContrast(ind)));
       else
          error('LSDthresholdAnalysis: fitType must either be ''weibull'' or ''gaussian'''); 
       end
       display(['Iteration ' num2str(j)]);
   end
   indBestAll = find(abs(negLLtmp-min(negLLtmp))<0.001);
   indBest = indBestAll(1);
   tFit(i) = tFitTmp(indBest);
   mFit(i) = mFitTmp(indBest);
   sFit(i) = sFitTmp(indBest);
   bFit(i) = bFitTmp(indBest);
   PCdta(:,i) = PCdtaTmp(:,indBest);
end

if p.Results.showPlot
    figure;
    set(gcf,'Position',[315 73 1240 863]);
    for i = 1:length(targetContrastAngleUnq)
        ind = abs(S.targetContrastAngle-targetContrastAngleUnq(i))<0.01;
        contrastMinMax = [min(abs(S.targetContrast(ind))) max(abs(S.targetContrast(ind)))];
        contrastUnq = unique(abs(S.targetContrast(ind)));
        contrasts4plot = (contrastMinMax(1)-diff(contrastMinMax)*0.1):0.0001:(contrastMinMax(2)+diff(contrastMinMax)*0.1);
        if strcmp(p.Results.fitType,'weibull')
            PCfit = psyfitWeibullfunc(zeros(size(contrasts4plot)),contrasts4plot,mFit(i),sFit(i),bFit(i),DPcrt,nIntrvl,0);
        elseif strcmp(p.Results.fitType,'gaussian')
            PCfit = psyfitgengaussfunc(zeros(size(contrasts4plot)),contrasts4plot,mFit(i),sFit(i),bFit(i),DPcrt,nIntrvl,0);
        end
        subplot(2,3,i);
        hold on;
        plot(contrasts4plot.*100,PCfit,'k-');
        plot(contrastUnq.*100,PCdta(:,i),'ko','MarkerSize',10,'MarkerFaceColor','w');
        xlimTmp = xlim;
        plot([tFit(i)*100 tFit(i)*100],[0.4 normcdf(0.5.*sqrt(nIntrvl).*DPcrt)],'k--');
        plot([xlimTmp(1) tFit(i)*100],[normcdf(0.5.*sqrt(nIntrvl).*DPcrt) normcdf(0.5.*sqrt(nIntrvl).*DPcrt)],'k--');
        text(xlimTmp(2)*0.65,0.5,['nTrials=' num2str(sum(ind))]);
        ylim([0.4 1]);
        xlim(xlimTmp);
        axis square; 
        formatFigure('Michelson Contrast (%)','Proportion Correct',[num2str(targetContrastAngleUnq(i)) 'deg, T=' num2str(tFit(i)*100,2) '%']);
    end
    
    for i = 1:length(targetContrastAngleUnq)
        if targetContrastAngleUnq(i) ==0
           tFitPlotLS(i,:) = tFit(i).*100.*[1 0];
        elseif targetContrastAngleUnq(i)==90
           tFitPlotLS(i,:) = tFit(i).*100.*[0 1]; 
        else
           tFitPlotLS(i,:) = tFit(i).*100.*[1 tand(targetContrastAngleUnq(i))]./norm([1 tand(targetContrastAngleUnq(i))]);
        end
    end

    figure;
    plot(tFitPlotLS(:,1),tFitPlotLS(:,2),'kx','MarkerSize',10);
    hold on;
    plot([-5 5],[0 0],'k-');
    plot([0 0],[-5 5],'k-');
    axis square;
    formatFigure('L','S');
    xlim([-5 5]);
    ylim([-5 5]);
end

end