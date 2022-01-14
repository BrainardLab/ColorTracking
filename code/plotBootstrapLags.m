% test the tfeCTM
subjID = 'MAB';
%% Load the data
projectName = 'CorticalColorMapping';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
bootParamsCacheFolder = getpref(projectName,'bootParamsCacheFolder');
% get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
    yLimVals = [0.2 0.9];
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
    yLimVals = [0.2 0.6];
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
     yLimVals = [0.2 0.8];
end

load(fullfile(paramsCacheFolder,[subjCode '_paramsCache.mat']));
load(fullfile(bootParamsCacheFolder,[subjCode '_bootParamsCache.mat']));
figSavePath = '/Users/michael/labDropbox/CNST_analysis/ColorTrackingTask/Results/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%       Contrast vs Lag
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the l2 norm of the cone contrasts
MaxContrastLMSvec= [];
for ii = 1:size(MaxContrastLMS,3)
    MaxContrastLMSvec = [MaxContrastLMSvec; MaxContrastLMS(:,:,ii)];
end
vecContrast = sqrt(MaxContrastLMSvec(:,1).^2+MaxContrastLMSvec(:,3).^2);
matrixContrasts = reshape(vecContrast,size(meanLagBtstrpLagMat));

[upperCI, lowerCI] = computeCiFromBootSruct(rParamsBtstrpStruct, 68)

% Names for plotting
plotNames.title  = 'Lag Vs. Contrast';
plotNames.xlabel  = 'Contrast (%)';
plotNames.ylabel = 'Lag (s)';
numExp = length(infoBootParams.expNames);
nDirPerExp = length(uniqueColorDirs(:))./numExp;
starts = 1:nDirPerExp:length(uniqueColorDirs(:));
stops  = nDirPerExp:nDirPerExp:length(uniqueColorDirs(:));

% plot colors
plotColors = [230 172 178; ...
    194  171  253; ...
    36   210  201; ...
    32   140  163; ...
    253  182    44; ...
    252  153  233;...
    127  201  127;...
    190  174  212;...
    253  192  134;...
    255  255  153;...
    56   108  176;...
    240    2  127;...
    179  226  205;...
    253  205  172;...
    203  213  232;...
    237  248  177;...
    127  205  187;...
    44   127  184;...
    ]./255;

for jj = 1:numExp
    
    colorDirs = uniqueColorDirs(starts(jj):stops(jj));
    for kk = 1:length(colorDirs)
        plotNames.legend{kk} = sprintf('%s°',num2str(colorDirs(kk)));
    end
    % Plot it!
    CIs.upper = abs(upperCI(:,starts(jj):stops(jj)) - meanLagBtstrpLagMat(:,starts(jj):stops(jj)));
    CIs.lower = abs(meanLagBtstrpLagMat(:,starts(jj):stops(jj)) - lowerCI(:,starts(jj):stops(jj)));
    
    [tcHndl] =plotParams(matrixContrasts(:,starts(jj):stops(jj)),meanLagBtstrpLagMat(:,starts(jj):stops(jj)),...
                         plotColors(starts(jj):stops(jj),:)',plotNames,'yLimVals', yLimVals,'semiLog',false,...
                         'errorBarsCI',CIs);
    expName = infoBootParams.expNames{jj};
    % Save it!
    figureSizeInches = [8 8];
    set(tcHndl, 'PaperUnits', 'inches');
    set(tcHndl, 'PaperSize',figureSizeInches);
    set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
    % Full file name
    figNameTc =  fullfile(figSavePath,[subjCode, '_LagVsContrastBoot_' expName '.pdf']);
    % Save it
    print(tcHndl, figNameTc, '-dpdf', '-r300');
end

