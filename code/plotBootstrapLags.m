% test the tfeCTM
subjID = 'BMC';
%% Load the data
projectName = 'CorticalColorMapping';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
bootParamsCacheFolder = getpref(projectName,'bootParamsCacheFolder');
% get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end
load(fullfile(paramsCacheFolder,[subjCode '_paramsCache.mat']));
load(fullfile(bootParamsCacheFolder,[subjCode '_bootParamsCache.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%       Contrast vs Lag
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the colors
plotColors = [230 172 178; ...
    194  171  253; ...
    36   210  201; ...
    32   140  163; ...
    253  182    44; ...
    252  153  233;...
    ]./255;

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
starts = 1:nDirPerExp:length(uniqueColorDirs);
stops  = nDirPerExp:nDirPerExp:length(uniqueColorDirs);

for jj = 1:length(numExp)
    
    colorDirs = uniqueColorDirs(starts:stops);
    for jj = 1:length(colorDirs)
        plotNames.legend{jj} = sprintf('%s°',num2str(colorDirs(jj)));
    end
    % Plot it!
    [tcHndl] =plotParams(matrixContrasts(:,starts:stops),meanLagBtstrpLagMat(:,starts:stops),...
                         plotColors',plotNames,'yLimVals', [0.3 .8],'semiLog',false,...
                         'errorBars',sDevBtstrpLagMat(:,starts:stops));
    
    % Save it!
    figureSizeInches = [8 8];
    set(tcHndl, 'PaperUnits', 'inches');
    set(tcHndl, 'PaperSize',figureSizeInches);
    set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
    % Full file name
    figNameTc =  fullfile(figSavePath,[subjCode, '_LagVsContrast_' expName '.pdf']);
    % Save it
    print(tcHndl, figNameTc, '-dpdf', '-r300');
end

