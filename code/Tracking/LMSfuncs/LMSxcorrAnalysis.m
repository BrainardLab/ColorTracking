function [r, rSmooth, rParam, negLL, FWHH, btstrpStruct] = LMSxcorrAnalysis(Sall,modelType,varargin)
%
% function [r, rSmooth, rParam, negLL, FWHH, btstrpStruct] = LMSxcorrAnalysis(Sall,modelType)
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

% Input Parser
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('Sall',@isstruct);
p.addRequired('modelType',@ischar);
p.addParameter('bPLOTrawXCORR',0,@isnumeric);
p.addParameter('bPLOTfitsOnly',0,@isnumeric);
p.addParameter('bPLOTfitsAndRaw',0,@islogical);
p.addParameter('bPLOTlags',0,@isnumeric);
p.addParameter('bPLOTfwhh',0,@isnumeric);
p.addParameter('nBootstrapIter',0,@isnumeric);
p.addParameter('sizeCI',68,@isnumeric);
p.parse(Sall,modelType,varargin{:});

% CONVERT MaxContrastLMS MATRIX TO ANGLE AND CONTRAST IN COLOR SPACE
colorAngle = round(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1)));
colorContrast = round(sqrt(Sall.MaxContrastLMS(:,3).^2+Sall.MaxContrastLMS(:,1).^2),3);
% OBTAIN UNIQUE COMBINATIONS OF ANGLE AND CONTRAST
colorAngleContrastUnq = unique([colorAngle colorContrast],'rows');
% THIS IS NOT USED RIGHT NOW
MaxContrastLMSunq = unique(Sall.MaxContrastLMS,'rows');

%------------ BEGIN MAIN ANALYSIS SECTION -------------------------

legendLMS = {''};
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
    if p.Results.nBootstrapIter == 0
        [r(:,i), rLagVal(:,i),rAll] = xcorrEasy(diff(S.tgtXmm),diff(S.rspXmm),[S.tSec; 15],maxLagSec,'coeff',smpBgnEnd,bPLOTxcorr);
    elseif  p.Results.nBootstrapIter > 0
        [r(:,i),rCI,rLagVal(:,i),rAll,rDSTB(:,:,i),rSD(:,i)] = xcorrEasyBootstrap(diff(S.tgtXmm),diff(S.rspXmm),[S.tSec; 15],...
            maxLagSec,'coeff',smpBgnEnd,p.Results.nBootstrapIter,p.Results.sizeCI,bPLOTxcorr);
    end
    % FIT CROSS CORRELATION FUNCTION
    if strcmp(modelType,'FLT') % FLAT-TOP COSINE FILTER IN FOURIER DOMAIN
        rSmooth(:,i) = filterTRKdataFlattopCos(r(:,i),rLagVal(:,i),[5 10],0);
    else % OTHERWISE, FIT WITH xcorrFitMLE
        rStdK = 1.5;
        initType = 'RND';
        rhoXXstd = std(rAll,[],2);
        [rSmooth(:,i),rParam(:,i),tSecFit(:,i),negLL(:,i)] = xcorrFitMLE(rLagVal(:,i),r(:,i),rhoXXstd,rStdK,modelType,initType);
        if p.Results.nBootstrapIter >0
            for jj = 1:p.Results.nBootstrapIter
                [rSmoothBtstrp(:,i,jj),rParamBtstrp(:,i,jj),tSecFitBtstrp(:,i,jj),negLLBtstrp(:,i,jj)] = xcorrFitMLE(rLagVal(:,i),rDSTB(:,jj,i),rhoXXstd,rStdK,modelType,initType);
            end
        end
    end
    %    text(0.5,0.2,MaxContrastLMStitle,'FontSize',15);
    legendLMS{end+1} = MaxContrastLMStitle;
    if strcmp(modelType,'GMA')
        [rSmoothMax,rSmoothMaxInd] = max(rSmooth(:,i));
        [~,hh1ind] = min(abs(rSmooth(tSecFit(:,i)>tSecFit(rSmoothMaxInd),i)-rSmoothMax./2));
        hh1 = tSecFit(hh1ind+rSmoothMaxInd,i);
        [~,hh2ind] = min(abs(rSmooth(tSecFit(:,i)<tSecFit(rSmoothMaxInd),i)-rSmoothMax./2));
        hh2 = tSecFit(hh2ind,i);
        FWHH(i) = hh1-hh2;
    end
    if ~strcmp(modelType,'LGS') || ~strcmp(modelType,'GMA') % IF FITS WERE NOT DONE WITH LOG-GAUSSIAN
        % NUMERICALLY READ OUT LAG VALUES
        [~,rSmoothMaxInd] = max(rSmooth(:,i));
        lagXXms(i) = tSecFit(rSmoothMaxInd,i);
    end
end

if strcmp(modelType,'LGS') % IF FITS WERE DONE WITH LOG-GAUSSIAN
    % LAG = MEAN OF LOG-GAUSSIAN FIT
    lagXXms = rParam(2,:);
    FWHH = exp(log(rParam(2,:))+rParam(3,:).*sqrt(log(4))) - exp(log(rParam(2,:))-rParam(3,:).*sqrt(log(4)));
elseif strcmp(modelType,'GMA')
    lagXXms = (rParam(3,:)-1).*rParam(2,:)+rParam(4,:);
end

btstrpStruct = struct;
if p.Results.nBootstrapIter>0
    btstrpStruct.rSmoothBtstrp = rSmoothBtstrp;
    btstrpStruct.rParamBtstrp  = rParamBtstrp;
    btstrpStruct.tSecFitBtstrp = tSecFitBtstrp;
    btstrpStruct.negLLBtstrp   = negLLBtstrp;
end
% ---------------- END MAIN ANALYSIS SECTION -------------------

if p.Results.bPLOTrawXCORR
    % PLOT RAW CROSS-CORRELATION FUNCTIONS
    figure; hold on;
    xlim([-0.5 1.5]); ylim([-.1 .25]); plot([0 0],ylim,'k--');
    for i = 1:size(rSmooth,2)
        % PLOT CROSS-CORRELATION FUNCTIONS
        plot(rLagVal(:,i),r(:,i),'LineWidth',1);
    end
    tLbl='X'; rLbl='X';
    axis square;
    formatFigure(['Lag (sec)'],['Correlation'],['Q=' num2str(S.sigmaQmm(1)) '; Tgt' tLbl ' vs Rsp' rLbl]); set(gcf,'position',[35  386 476 420]);
    legend(legendLMS);
end

if p.Results.bPLOTfitsOnly
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
end

if p.Results.bPLOTfitsAndRaw
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
end

if p.Results.bPLOTlags
    % PLOT LAGS AT HALF HEIGHT
    figure;
    plot(sqrt(sum(colorAngleContrastUnq(:,2).^2,2)),lagXXms,'ko','LineWidth',1.5,'MarkerSize',10);
    axis square;
    formatFigure('Contrast','Lag (s)',['Angle = ' num2str(unique(colorAngle))]);
    ylim([0 0.6]);
end

if p.Results.bPLOTfwhh
    % PLOT FULL WIDTHS AT HALF HEIGHT
    figure;
    plot(sqrt(sum(colorAngleContrastUnq(:,2).^2,2)),FWHH,'ko','LineWidth',1.5,'MarkerSize',10);
    axis square;
    formatFigure('Contrast','Integration period (s)');
    % ylim([0 0.6]);
end

end
