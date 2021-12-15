close all
clear all

%% LOAD DATA
subjID  = 'BMC';
expName = 'LS3';
theRuns = 1:20;

figSavePath = '/Users/michael/labDropbox/CNST_analysis/ColorTracking/Results/';

if strcmp(expName,'LS1')
    expCode = 'Experiment1-Pos';
elseif strcmp(expName,'LS2')
    expCode = 'Experiment2-Pos';
elseif strcmp(expName,'LS3')
    expCode = ['Experiment3-' subjID '-Pos'];
end

if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end


Sall = loadPSYdataLMSall('TRK', subjID, expName, 'CGB', {theRuns}, 'jburge-hubel', 'local');

%% SORT TRIALS BY COLOR ANGLE
plotRawData = 1;

% Get the cone contrasts MaxContrastLMS
MaxContrastLMS = LMSstimulusContrast('experiment',expCode);
uniqColorDirs = unique(round(atand(MaxContrastLMS(:,3)./MaxContrastLMS(:,1)),2),'stable');

for ii = 1:length(uniqColorDirs)
    
    % 0 DEG IN SL PLANE
    ind = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-uniqColorDirs(ii))<0.001;
    
    S = structElementSelect(Sall,ind,size(Sall.tgtXmm,2));
    % LMS ANALYSIS TO ESTIMATE LAGS
    [~,~,rParams(:,:,ii)] = LMSxcorrAnalysis(S,'LGS','bPLOTfitsAndRaw',plotRawData);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%       Contrast vs Lag
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the lags from rParams
lags = flipud(squeeze(rParams(2,:,:)));
%lags = flipud((squeeze(rParams(3,:,:))-1).*squeeze(rParams(2,:,:))+ squeeze(rParams(4,:,:)));

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
matrixContrasts = reshape(vecContrast,size(lags));

% Names for plotting
plotNames.title  = 'Lag Vs. Contrast';
plotNames.xlabel  = 'Contrast (%)';
plotNames.ylabel = 'Lag (s)';
for jj = 1:length(uniqColorDirs)
    plotNames.legend{jj} = sprintf('%s°',num2str(uniqColorDirs(jj)));
end
% Plot it!
[tcHndl] =plotParams(matrixContrasts,lags,plotColors',plotNames,'yLimVals', [0.3 .8],'semiLog',false);

% Save it!
figureSizeInches = [8 8];
set(tcHndl, 'PaperUnits', 'inches');
set(tcHndl, 'PaperSize',figureSizeInches);
set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
figNameTc =  fullfile(figSavePath,[subjCode, '_LagVsContrast_' expName '.pdf']);
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
figNameTc =  fullfile(figSavePath,[subjCode, '_TipVsContrast_' expName '.pdf']);
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
figNameTc =  fullfile(figSavePath,[subjCode, '_AmpVsContrast_' expName '.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%          S/L+S
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S_over_LS =  MaxContrastLMS(:,3) ./ (abs(MaxContrastLMS(:,1))+abs(MaxContrastLMS(:,3)));
scaledContrasts = matrixContrasts./matrixContrasts(1,:);
matSContrast = reshape(S_over_LS,size(lags));

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
figNameTc =  fullfile(figSavePath,[subjCode, '_sOverLPlusS_' expName '.pdf']);
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
figNameTc =  fullfile(figSavePath,[subjCode, '_lagVsTips_' expName '.pdf']);
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
figNameTc =  fullfile(figSavePath,[subjCode, '_ampsVsTips_' expName '.pdf']);
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
figNameTc =  fullfile(figSavePath,[subjCode, '_ampsVsLag_' expName '.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    Lag vs L-cone Contrast
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotNames.title  = 'Lag Vs. L Cone Contrast';
plotNames.xlabel =  'L Cone Contrast (%)';
plotNames.ylabel = 'Lag (s)';

coneContrastLvec = MaxContrastLMS(:,1);
coneContrastSvec = MaxContrastLMS(:,3);

coneContrastL = reshape(coneContrastLvec,size(lags));
coneContrastS = reshape(coneContrastSvec,size(lags));

aa = 0.4;
bb = 1;
alphaValsS = (bb-aa) .* ((coneContrastS - min(coneContrastS(:)))./ (max(coneContrastS(:)) -min(coneContrastS(:))) ) + aa;

[tcHndl] = scatterParams(coneContrastL,lags,plotColors',plotNames,'yLimVals', [.3 .80],'sz',12.^2,'contrastAlpha',alphaValsS, 'semiLog', false);

set(tcHndl, 'Renderer', 'Painters');
figureSizeInches = [8 8];
set(tcHndl, 'PaperUnits', 'inches');
set(tcHndl, 'PaperSize',figureSizeInches);
set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
figNameTc =  fullfile(figSavePath,[subjCode, '_L-Cone_contrastVsLag_' expName '.pdf']);
% Save it
print(tcHndl, figNameTc, '-dpdf', '-r300');




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
