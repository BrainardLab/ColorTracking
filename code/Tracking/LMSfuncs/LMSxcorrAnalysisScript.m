close all
clear all

%% LOAD DATA
subjID = 'BMC';
theRuns = 1:20;

figSavePath = '/Users/michael/labDropbox/CNST_analysis/ColorTracking/Results/';

if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end

Sall = loadPSYdataLMSall('TRK', subjID, 'CGB', {theRuns}, 'jburge-hubel', 'local');

%% SORT TRIALS BY COLOR ANGLE

% 0 DEG IN SL PLANE
ind1 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-0)<0.001;
% 90 DEG IN SL PLANE
ind2 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-90)<0.001;
% -45 DEG IN SL PLANE
ind3 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-(-45))<0.001;
% 45 DEG IN SL PLANE
ind4 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-(+45))<0.001;
% -75 DEG IN SL PLANE
ind5 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-(-75))<0.001;
% 75 DEG IN SL PLANE
ind6 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-(+75))<0.001;
S1 = structElementSelect(Sall,ind1,size(Sall.tgtXmm,2));
S2 = structElementSelect(Sall,ind2,size(Sall.tgtXmm,2));
S3 = structElementSelect(Sall,ind3,size(Sall.tgtXmm,2));
S4 = structElementSelect(Sall,ind4,size(Sall.tgtXmm,2));
S5 = structElementSelect(Sall,ind5,size(Sall.tgtXmm,2));
S6 = structElementSelect(Sall,ind6,size(Sall.tgtXmm,2));

%% LMS ANALYSIS TO ESTIMATE LAGS
plotRawData = 0;
[~,~,rParams(:,:,1)] = LMSxcorrAnalysis(S1,'LGS','bPLOTfitsAndRaw',plotRawData);
[~,~,rParams(:,:,2)] = LMSxcorrAnalysis(S2,'LGS','bPLOTfitsAndRaw',plotRawData);
[~,~,rParams(:,:,3)] = LMSxcorrAnalysis(S3,'LGS','bPLOTfitsAndRaw',plotRawData);
[~,~,rParams(:,:,4)] = LMSxcorrAnalysis(S4,'LGS','bPLOTfitsAndRaw',plotRawData);
[~,~,rParams(:,:,5)] = LMSxcorrAnalysis(S5,'LGS','bPLOTfitsAndRaw',plotRawData);
[~,~,rParams(:,:,6)] = LMSxcorrAnalysis(S6,'LGS','bPLOTfitsAndRaw',plotRawData);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%       Contrast vs Lag
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the lags from rParams
lags = flipud(squeeze(rParams(2,:,:)));

% Get the cone contrasts
MaxContrastLMS = LMSstimulusContrast('experiment','SLplane-Pos');

% Set the colors
plotColors = [230 172 178; ...
    194  171  253; ...
    36   210  201; ...
    32   140  163; ...
    253  182    44; ...
    252  153  233;...
    ]./255;

% Get the l2 norm of the cone contrasts
vecContrast = sqrt(MaxContrastLMS(:,1).^2+MaxContrastLMS(:,3).^2);
matrixContrasts_unsorted = reshape(vecContrast,size(lags));
matrixContrasts = matrixContrasts_unsorted(:,[1 2 6 5 4 3]);
% Names for plotting
plotNames.title  = 'Lag Vs. Contrast';
plotNames.xlabel  = 'Contrast (%)';
plotNames.ylabel = 'Lag (s)';
plotNames.legend = {'0°','90°','-45°','45°','-75°','75°'};

% Plot it!
[tcHndl] =plotParams(matrixContrasts,lags,plotColors',plotNames,'yLimVals', [0.3 .8]);

% Save it!
figureSizeInches = [8 8];
set(tcHndl, 'PaperUnits', 'inches');
set(tcHndl, 'PaperSize',figureSizeInches);
set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
figNameTc =  fullfile(figSavePath,[subjCode, '_LagVsContrast.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%       Contrast vs TIP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the temporal integration period
stds = flipud(squeeze(rParams(3,:,:)));
tips = exp(log(lags)+stds.*sqrt(log(4))) - exp(log(lags)-stds.*sqrt(log(4)));


plotNames.title  = 'TIP Vs. Contrast';
plotNames.ylabel = 'Temporal Integration Period (s)';

[tcHndl] = plotParams(matrixContrasts,tips,plotColors',plotNames,'yLimVals', [0 .8]);

set(tcHndl, 'Renderer', 'Painters');
figureSizeInches = [8 8];
set(tcHndl, 'PaperUnits', 'inches');
set(tcHndl, 'PaperSize',figureSizeInches);
set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
figNameTc =  fullfile(figSavePath,[subjCode, '_TipVsContrast.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%       Contrast vs Amp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
amps = flipud(squeeze(rParams(1,:,:)));

plotNames.title  = 'Amplitude Vs. Contrast';
plotNames.ylabel = 'Amplitude (a.u.)';

[tcHndl] = plotParams(matrixContrasts,amps,plotColors',plotNames,'yLimVals', [0 .4]);

set(tcHndl, 'Renderer', 'Painters');
figureSizeInches = [8 8];
set(tcHndl, 'PaperUnits', 'inches');
set(tcHndl, 'PaperSize',figureSizeInches);
set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
figNameTc =  fullfile(figSavePath,[subjCode, '_AmpVsContrast.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%          S/L+S
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S_over_LS =  MaxContrastLMS(:,3) ./ (abs(MaxContrastLMS(:,1))+abs(MaxContrastLMS(:,3)));
scaledContrasts = matrixContrasts./matrixContrasts(1,:);
matSContrast_unsorted = reshape(S_over_LS,size(lags));
matSContrast = matSContrast_unsorted(:,[1 2 6 5 4 3]);
plotNames.title  = 'Lag Vs. Proportion S';
plotNames.xlabel  = 'S / (S + L) (Proportion S)';
plotNames.ylabel = 'Lag (s)';

[tcHndl] = scatterParams(matSContrast,lags,plotColors',plotNames,'yLimVals', [.3 .8],'semiLog',false,'xTickVals',[],'sz',12.^2,'contrastAlpha',scaledContrasts);

set(tcHndl, 'Renderer', 'Painters');
figureSizeInches = [8 8];
set(tcHndl, 'PaperUnits', 'inches');
set(tcHndl, 'PaperSize',figureSizeInches);
set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
figNameTc =  fullfile(figSavePath,[subjCode, '_sOverLPlusS.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%          Lag vs TIP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotNames.title  = 'Lag Vs. TIP';
plotNames.xlabel  = 'Lag (s)';
plotNames.ylabel = 'Temporal Intergration Period (s)';

[tcHndl] = scatterParams(lags,tips,plotColors',plotNames,'yLimVals', [0.1 .40],'sz',12.^2,'contrastAlpha',scaledContrasts);

set(tcHndl, 'Renderer', 'Painters');
figureSizeInches = [8 8];
set(tcHndl, 'PaperUnits', 'inches');
set(tcHndl, 'PaperSize',figureSizeInches);
set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
figNameTc =  fullfile(figSavePath,[subjCode, '_lagVsTips.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%          Amp vs TIP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotNames.title  = 'Amplitude Vs. TIP';
plotNames.xlabel  = 'Amplitude (a.u.)';
plotNames.ylabel = 'Temporal Intergration Period (s)';

[tcHndl] = scatterParams(amps,tips,plotColors',plotNames,'yLimVals', [0.15 .35],'xTickVals',0:0.02:.2,'sz',12.^2,'contrastAlpha',scaledContrasts);

set(tcHndl, 'Renderer', 'Painters');
figureSizeInches = [8 8];
set(tcHndl, 'PaperUnits', 'inches');
set(tcHndl, 'PaperSize',figureSizeInches);
set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
figNameTc =  fullfile(figSavePath,[subjCode, '_ampsVsTips.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%          Lag vs Amp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotNames.title  = 'Lag Vs. Amplitude';
plotNames.xlabel  = 'Lag (s)';
plotNames.ylabel = 'Amplitude (a.u.)';

[tcHndl] = scatterParams(lags,amps,plotColors',plotNames,'yLimVals', [0 .20],'sz',12.^2,'contrastAlpha',scaledContrasts);

set(tcHndl, 'Renderer', 'Painters');
figureSizeInches = [8 8];
set(tcHndl, 'PaperUnits', 'inches');
set(tcHndl, 'PaperSize',figureSizeInches);
set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
figNameTc =  fullfile(figSavePath,[subjCode, '_ampsVsLag.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    Lag vs L-cone Contrast
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% % MAKE 3D SCATTER PLOT
%
% figure;hold on;
% scatter3(MaxContrastLMS(1:6,1),MaxContrastLMS(1:6,3),lags(:,1))
%
% scatter3(MaxContrastLMS(7:12,1),MaxContrastLMS(7:12,3),lags(:,2))
%
% scatter3(MaxContrastLMS(13:18,1),MaxContrastLMS(13:18,3),lags(:,6))
%
% scatter3(MaxContrastLMS(19:24,1),MaxContrastLMS(19:24,3),lags(:,5))
%
% scatter3(MaxContrastLMS(25:30,1),MaxContrastLMS(25:30,3),lags(:,4))
%
% scatter3(MaxContrastLMS(31:36,1),MaxContrastLMS(31:36,3),lags(:,3))
% grid on
% set(gca,'LineWidth',1.5)
