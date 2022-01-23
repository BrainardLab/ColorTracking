function [tFit,mFit,sFit,bFit,PCdta] = LSDthresholdAnalysis(S,DPcrt,varargin)

p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('S',@isstruct);
p.addParameter('bPLOTpsfs',0,@isnumeric);
p.addParameter('bPLOTthresholds',0,@isnumeric);
p.parse(S,varargin{:});

targetContrastAngleUnq = unique(S.targetContrastAngle);

nRepeats = 10;

for i = 1:length(targetContrastAngleUnq)
   ind = abs(S.targetContrastAngle-targetContrastAngleUnq(i))<0.01;
   for j = 1:nRepeats
       [mFitTmp(:,j),sFitTmp(:,j),bFitTmp(:,j),tFitTmp(:,j),PCdtaTmp(:,j),~,negLLtmp(:,j)] = psyfitgengauss(abs(S.stdX(ind)),abs(S.targetContrast(ind)),S.R(ind) == S.cmpIntrvl(ind),0,[],[],DPcrt,2,0);
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

if p.Results.bPLOTpsfs
    figure;
    set(gcf,'Position',[315 73 1240 863]);
    for i = 1:length(targetContrastAngleUnq)
        ind = abs(S.targetContrastAngle-targetContrastAngleUnq(i))<0.01;
        contrastMinMax = [min(S.targetContrast(ind)) max(S.targetContrast(ind))];
        contrastUnq = unique(S.targetContrast(ind));
        contrasts4plot = (contrastMinMax(1)-diff(contrastMinMax)*0.1):0.0001:(contrastMinMax(2)+diff(contrastMinMax)*0.1);
        PCfit = psyfitgengaussfunc(zeros(size(contrasts4plot)),contrasts4plot,mFit(i),sFit(i),bFit(i),DPcrt,2,0);
        subplot(2,3,i);
        hold on;
        plot(contrasts4plot.*100,PCfit,'k-');
        plot(contrastUnq.*100,PCdta(:,i),'ko','MarkerSize',10,'MarkerFaceColor','w');
        ylim([0.4 1]);
        axis square; 
        formatFigure('Michelson Contrast (%)','Proportion Correct',['Angle = ' num2str(targetContrastAngleUnq(i))]);
    end
end

end