function [r, rSmooth, rParam] = LMSxcorrAnalysis(Sall,modelType)
%
% function [r, rSmooth, rParam] = LMSxcorrAnalysis(Sall,modelType)
%
% example calls:
%                 % LOAD DATA
%                 % MICHAEL 4 CPD, CONTRAST 0.015-0.15
%                 Sall = loadPSYdataLMSall('TRK', 'MAB', 'CGB', {[1:3]}, 'jburge-hubel', 'local');
%                 % MICHAEL 2 CPD, CONTRAST 0.02-0.07
%                 Sall = loadPSYdataLMSall('TRK', 'MAB', 'CGB', {[4:6]}, 'jburge-hubel', 'local');
%                 % BEN 2C CPD CONTRAST 0.02-0.07
%                 Sall = loadPSYdataLMSall('TRK', 'BMC', 'CGB', {[2:4]}, 'jburge-hubel', 'local');
%                 % MICHAEL 2 CPD, CONTRAST 0.02-0.04
%                 Sall = loadPSYdataLMSall('TRK', 'MAB', 'CGB', {[7:10]}, 'jburge-hubel', 'local');
%                 % BEN 2 CPD, M AND S CONTRAST
%                 Sall = loadPSYdataLMSall('TRK', 'BMC', 'CGB', {[5:9]}, 'jburge-hubel', 'server');
%                 % BEN 1 CPD, 6 DIRECTIONS IN SL PLANE
%                 Sall = loadPSYdataLMSall('TRK', 'BMC', 'CGB', {[1:10]}, 'jburge-hubel', 'server');
%
% analyzes data from LMS tracking experiment

% CONVERT MaxContrastLMS MATRIX TO ANGLE AND CONTRAST IN COLOR SPACE
colorAngle = round(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1)));
colorContrast = round(sqrt(Sall.MaxContrastLMS(:,3).^2+Sall.MaxContrastLMS(:,1).^2),3);
% OBTAIN UNIQUE COMBINATIONS OF ANGLE AND CONTRAST
colorAngleContrastUnq = unique([colorAngle colorContrast],'rows');
% THIS IS NOT USED RIGHT NOW
MaxContrastLMSunq = unique(Sall.MaxContrastLMS,'rows');

% ----------- BEGIN SECTION 1 ----------------------------
% -------------------------------------------------------------------
% THIS SECTION IS A MESS RIGHT NOW--DOES TWO THINGS. IT PLOTS THE RAW 
% CROSS-CORRELATION FUNCTIONS AND FITS THE FUNCTIONS SIMULTANEOUSLY. BEN
% WILL CLEAN IT UP AT SOME POINT
% -------------------------------------------------------------------
figure; hold on;
legendLMS = {''};
xlim([-0.5 1.5]); ylim([-.1 .25]); plot([0 0],ylim,'k--');
for i = 1:size(colorAngleContrastUnq,1) % LOOP OVER UNIQUE CONDITIONS
%     ind =   abs(Sall.MaxContrastLMS(:,1)-MaxContrastLMSunq(i,1))<0.001 ...
%           & abs(Sall.MaxContrastLMS(:,2)-MaxContrastLMSunq(i,2))<0.001 ...
%           & abs(Sall.MaxContrastLMS(:,3)-MaxContrastLMSunq(i,3))<0.001;
    % COMPUTE INDICES FOR EACH CONDITION, AND CREATE NEW STRUCT CONTAINING
    % ONLY THOSE CONDITIONS
    ind =   abs(colorAngle-colorAngleContrastUnq(i,1))<0.001 ...
          & abs(colorContrast-colorAngleContrastUnq(i,2))<0.001;      
    S = structElementSelect(Sall,ind,size(Sall.MaxContrastLMS,1));
    % PARAMETERS FOR PLOTTING--PASSED INTO xcorrEasy
    maxLagSec = 2;
    smpBgnEnd = 1;
    bPLOTxcorr = 0;
%     MaxContrastLMStitle = ['LMS = ' '[' num2str(MaxContrastLMSunq(i,1),3) ...
%                                   ' '   num2str(MaxContrastLMSunq(i,2),3) ...
%                                   ' '   num2str(MaxContrastLMSunq(i,3),3) ']'];
    MaxContrastLMStitle = ['Angle = ' num2str(colorAngleContrastUnq(i,1),3) ...
                           ', Contrast = '   num2str(colorAngleContrastUnq(i,2),3)];  
    % CROSS-CORRELATION FUNCTION
    [r(:,i), rLagVal(:,i),rAll] = xcorrEasy(diff(S.tgtXmm),diff(S.rspXmm),[S.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr);
    % FIT CROSS CORRELATION FUNCTION
    if strcmp(modelType,'FLT') % FLAT-TOP COSINE FILTER IN FOURIER DOMAIN
       rSmooth(:,i) = filterTRKdataFlattopCos(r(:,i),rLagVal(:,i),[5 10],0);
    else % OTHERWISE, FIT WITH xcorrFitMLE
       rStdK = 1.5;
       initType = 'RND';
       rhoXXstd = std(rAll,[],2);
       [rSmooth(:,i),rParam(:,i),tSecFit(:,i)] = xcorrFitMLE(rLagVal(:,i),r(:,i),rhoXXstd,rStdK,modelType,initType);
    end
    % PLOT CROSS-CORRELATION FUNCTIONS
    plot(rLagVal(:,i),r(:,i),'LineWidth',1);
%    text(0.5,0.2,MaxContrastLMStitle,'FontSize',15);
    legendLMS{end+1} = MaxContrastLMStitle;
    if ~strcmp(modelType,'LGS') % IF FITS WERE NOT DONE WITH LOG-GAUSSIAN
        % NUMERICALLY READ OUT LAG VALUES 
        [~,rSmoothMaxInd] = max(rSmooth(:,i));
        lagXXms(i) = tSecFit(rSmoothMaxInd,i);
    end
    if strcmp(modelType,'LGS') % IF FITS WERE DONE WITH LOG-GAUSSIAN
%        FWHH(i) = lognFWHH(rParam(2,i),rParam(3,i));
        FWHH(i) = exp(log(rParam(2,i))+rParam(3,i).*sqrt(log(4))) - exp(log(rParam(2,i))-rParam(3,i).*sqrt(log(4)));
    end
end
tLbl='X'; rLbl='X';
axis square;
formatFigure(['Lag (sec)'],['Correlation'],['Q=' num2str(S.sigmaQmm(1)) '; Tgt' tLbl ' vs Rsp' rLbl]); set(gcf,'position',[35  386 476 420]);
legend(legendLMS);
if strcmp(modelType,'LGS')
   lagXXms = rParam(2,:);
end
% maxLagSec = 2;
% smpBgnEnd = 1;
% bPLOTxcorr = 1;
% tLbl='X'; rLbl='X'; xcorrEasy(diff(S.tgtXmm),diff(S.rspXmm),[S.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr); xlim([-0.5 1.5]); ylim([-.1 .25]); plot([0 0],ylim,'k--'); formatFigure(['Lag (sec)'],['Correlation'],['Q=' num2str(S.sigmaQmm(1)) '; Tgt' tLbl ' vs Rsp' rLbl]); set(gcf,'position',[35  386 476 420]);
% tLbl='Z'; rLbl='Z'; xcorrEasy(diff(S.tgtZmm),diff(S.rspZmm),[S.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr); xlim([-0.5 1.5]); ylim([-.1 .25]); plot([0 0],ylim,'k--'); formatFigure(['Lag (sec)'],['Correlation'],['Q=' num2str(S.sigmaQmm(1)) '; Tgt' tLbl ' vs Rsp' rLbl]); set(gcf,'position',[479 386 476 420]);
% tLbl='X'; rLbl='Z'; xcorrEasy(diff(S.tgtXmm),diff(S.rspZmm),[S.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr); xlim([-0.5 1.5]); ylim([-.1 .25]); plot([0 0],ylim,'k--'); formatFigure(['Lag (sec)'],['Correlation'],['Q=' num2str(S.sigmaQmm(1)) '; Tgt' tLbl ' vs Rsp' rLbl]); set(gcf,'position',[917 386 476 420]);

% ----------------------- END SECTION 1 --------------------------

% PLOTS ALL CROSS-CORRELATION FITS ONLY
figure;
ylim([-.1 .25]); plot([0 0],ylim,'k--');
hold on;
for i = 1:size(rSmooth,2)
    if strcmp(modelType,'FLT')
       plot(rLagVal(:,i),rSmooth(:,i),'LineWidth',1);
    else
       plot(tSecFit(:,i),rSmooth(:,i),'LineWidth',1);
    end
end
axis square;
formatFigure('Lag (ms)','Response');
xlim([-0.5 1.5]);
legend(legendLMS);

%%

% PLOTS BOTH FITS AND RAW CROSS-CORRELATION FUNCTIONS--FOR EXAMINING
% QUALITY OF FIT
figure;
set(gcf,'Position',[303 242 1687 990]);
for i = 1:size(rSmooth,2)
    subplot(3,4,i);
    ylim([-.1 .25]); plot([0 0],ylim,'k--');
    hold on;
    plot(rLagVal(:,i),r(:,i),'LineWidth',1);
    if strcmp(modelType,'FLT')
       plot(rLagVal(:,i),rSmooth(:,i),'LineWidth',1); 
    else
       plot(tSecFit(:,i),rSmooth(:,i),'LineWidth',1);
    end
    axis square;
    formatFigure('Lag (ms)','Response');
    xlim([-0.5 1.5]);
end

% PLOT LAGS AND FULL WIDTH AT HALF HEIGHT
figure;
plot(sqrt(sum(colorAngleContrastUnq(:,2).^2,2)),lagXXms,'ko','LineWidth',1.5,'MarkerSize',10);
axis square;
formatFigure('Contrast','Lag (s)',['Angle = ' num2str(unique(colorAngle))]);
ylim([0 0.6]);

figure;
plot(sqrt(sum(colorAngleContrastUnq(:,2).^2,2)),FWHH,'ko','LineWidth',1.5,'MarkerSize',10);
axis square;
formatFigure('Contrast','Integration period (s)');
% ylim([0 0.6]);

end
