function [tFit,mFit,sFit,bFit,PCdta,cSpacing,tFitBoot,mFitBoot,targetContrastAngleUnq] = LSDthresholdAnalysis(S,DPcrt,varargin)

% function [tFit,mFit,sFit,bFit,PCdta,cSpacing,tFitBoot,mFitBoot,targetContrastAngleUnq] = LSDthresholdAnalysis(S,DPcrt,varargin)
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
p.addParameter('nBoot',0,@isnumeric);
p.addParameter('tFitBoot',[],@isnumeric);
p.addParameter('subjNum',[],@isnumeric);
p.parse(S,varargin{:});

nIntrvl = 2;

targetContrastAngleUnq = unique(S.targetContrastAngle);

nRepeats = 10;

if exist('p.Results.tFitBoot','var')
    bIncomingBoots = true;
else
    bIncomingBoots = false; 
end

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

tFitBoot = [];
mFitBoot = [];

if p.Results.nBoot>0
    for i = 1:p.Results.nBoot
        for j = 1:length(targetContrastAngleUnq)
           ind = abs(S.targetContrastAngle-targetContrastAngleUnq(j))<0.01;
           indBoot = randsample(find(ind),sum(ind),1);
           for k = 1:nRepeats
               if strcmp(p.Results.fitType,'weibull')
                  [mFitTmp(:,k),sFitTmp(:,k),bFitTmp(:,k),tFitTmp(:,k),PCdtaTmp(:,k),~,negLLtmp(:,k)] = psyfitWeibull(zeros(size(S.targetContrast(indBoot))),abs(S.targetContrast(indBoot)),S.R(indBoot) == S.cmpIntrvl(indBoot),0,[],[],DPcrt,nIntrvl,0);
                  cSpacing(:,j) = unique(abs(S.targetContrast(indBoot)));
               elseif strcmp(p.Results.fitType,'gaussian')
                  [mFitTmp(:,k),sFitTmp(:,k),bFitTmp(:,k),tFitTmp(:,k),PCdtaTmp(:,k),~,negLLtmp(:,k)] = psyfitgengauss(zeros(size(S.targetContrast(indBoot))),abs(S.targetContrast(indBoot)),S.R(indBoot) == S.cmpIntrvl(indBoot),0,[],[],DPcrt,nIntrvl,0);
                  cSpacing(:,j) = unique(abs(S.targetContrast(indBoot)));
               else
                  error('LSDthresholdAnalysis: fitType must either be ''weibull'' or ''gaussian'''); 
               end
           end
           indBestAll = find(abs(negLLtmp-min(negLLtmp))<0.001);
           indBest = indBestAll(1);
           tFitBoot(j,i) = tFitTmp(indBest);
           mFitBoot(j,i) = mFitTmp(indBest);
           sFitBoot(j,i) = sFitTmp(indBest);
           bFitBoot(j,i) = bFitTmp(indBest);
           PCdtaBoot(:,j,i) = PCdtaTmp(:,indBest);
           display([' Condition ' num2str(j) ' Boot ' num2str(i)]);
        end
        saveInterval = 10;
        if mod(i,saveInterval)==0
            if isfile(['/home/ben/Documents/ColorTracking/detectionBootsS' num2str(p.Results.subjNum) 'cache.mat'])
                tFitBootCurrent = tFitBoot;
                tFitBootNew = tFitBoot(:,(size(tFitBoot,2)-saveInterval+1):size(tFitBoot,2));
                sFitBootCurrent = sFitBoot;
                sFitBootNew = sFitBoot(:,(size(sFitBoot,2)-saveInterval+1):size(sFitBoot,2));
                bFitBootCurrent = bFitBoot;
                bFitBootNew = bFitBoot(:,(size(bFitBoot,2)-saveInterval+1):size(bFitBoot,2));                
                load(['/home/ben/Documents/ColorTracking/detectionBootsS' num2str(p.Results.subjNum) 'cache.mat'],'tFitBoot','sFitBoot','bFitBoot');
                tFitBootOld = tFitBoot;
                tFitBoot = cat(2,tFitBootOld,tFitBootNew);
                sFitBootOld = sFitBoot;
                sFitBoot = cat(2,sFitBootOld,sFitBootNew);        
                bFitBootOld = bFitBoot;
                bFitBoot = cat(2,bFitBootOld,bFitBootNew);                
                save(['/home/ben/Documents/ColorTracking/detectionBootsS' num2str(p.Results.subjNum) 'cache.mat'], ...
                     'tFitBoot','tFit','sFitBoot','sFit','bFitBoot','bFit','targetContrastAngleUnq');
                tFitBoot = tFitBootCurrent;
                sFitBoot = sFitBootCurrent;
                bFitBoot = bFitBootCurrent;
            else
                save(['/home/ben/Documents/ColorTracking/detectionBootsS' num2str(p.Results.subjNum) 'cache.mat'], ...
                     'tFitBoot','tFit','sFitBoot','sFit','bFitBoot','bFit','targetContrastAngleUnq');
            end
        end
    end
end

if p.Results.showPlot
    figure;
    set(gcf,'Position',[315 73 1240 863]);
    for i = 1:6
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
    if length(targetContrastAngleUnq)>6
        figure;
        set(gcf,'Position',[315 73 1240 863]);
        for i = 7:length(targetContrastAngleUnq)
            ind = abs(S.targetContrastAngle-targetContrastAngleUnq(i))<0.01;
            contrastMinMax = [min(abs(S.targetContrast(ind))) max(abs(S.targetContrast(ind)))];
            contrastUnq = unique(abs(S.targetContrast(ind)));
            contrasts4plot = (contrastMinMax(1)-diff(contrastMinMax)*0.1):0.0001:(contrastMinMax(2)+diff(contrastMinMax)*0.1);
            if strcmp(p.Results.fitType,'weibull')
                PCfit = psyfitWeibullfunc(zeros(size(contrasts4plot)),contrasts4plot,mFit(i),sFit(i),bFit(i),DPcrt,nIntrvl,0);
            elseif strcmp(p.Results.fitType,'gaussian')
                PCfit = psyfitgengaussfunc(zeros(size(contrasts4plot)),contrasts4plot,mFit(i),sFit(i),bFit(i),DPcrt,nIntrvl,0);
            end
            subplot(2,3,i-6);
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
    end
    
    if ~isempty(p.Results.tFitBoot)
        tFitCI = quantile(p.Results.tFitBoot,[0.16 0.84],2);
        for i = 1:length(targetContrastAngleUnq)
            if targetContrastAngleUnq(i) ==0
               tFitPlotLSci1(i,:) = tFitCI(i,1).*100.*[1 0];
               tFitPlotLSci2(i,:) = tFitCI(i,2).*100.*[1 0];
            elseif targetContrastAngleUnq(i)==90
               tFitPlotLSci1(i,:) = tFitCI(i,1).*100.*[0 1]; 
               tFitPlotLSci2(i,:) = tFitCI(i,2).*100.*[0 1]; 
            else
               tFitPlotLSci1(i,:) = tFitCI(i,1).*100.*[1 tand(targetContrastAngleUnq(i))]./norm([1 tand(targetContrastAngleUnq(i))]);
               tFitPlotLSci2(i,:) = tFitCI(i,2).*100.*[1 tand(targetContrastAngleUnq(i))]./norm([1 tand(targetContrastAngleUnq(i))]);
            end            
        end
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
    
    scaleThreshPlot = max(abs([tFitPlotLSci1(:,2); tFitPlotLSci2(:,2)]));
    
    figure;
    hold on;
    plot(scaleThreshPlot.*[-1.1 1.1],[0 0],'k-');
    plot([0 0],scaleThreshPlot.*[-1.1 1.1],'k-');    
    plot(tFitPlotLS(:,1),tFitPlotLS(:,2),'k.','MarkerSize',10,'MarkerFaceColor','w');
    for i = 1:length(targetContrastAngleUnq)
        plot([tFitPlotLSci1(i,1) tFitPlotLSci2(i,1)],[tFitPlotLSci1(i,2) tFitPlotLSci2(i,2)],'k-','LineWidth',1.5);
    end
    axis square;
    formatFigure('L','S');
    xlim(scaleThreshPlot.*[-1.1 1.1]);
    ylim(scaleThreshPlot.*[-1.1 1.1]);
end

end