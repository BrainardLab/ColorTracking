function [] =  cacheDataForSubj(subjID, expNameCell, varargin)
% Takes in a subject name and cell array of ecperiments names and ouputs a
% singular cached form of the data.
%
% Syntax:
%   [C, sampleBaseTheta] = generateIsorepsoneContour(params, targetLag, numSamples)
%
% Description: Takes in the subject ID and a cell array of experiment code
%    names and saves out a cached version of the data which contains the
%    contrast on L, the contrast on S, the Lags, and the unique color
%    directions.
%
%
% Inputs:
%    subjId            - Subject ID
%    expNameCell       - Cell array of the experiment code names.
%
% Outputs:
%    None
%
% Optional key/value pairs:
%    fitMethod         - Method for fitting the xCorr functions (either
%                        'LGS' or 'GMA')
%    numRuns           - The number of runs (must be the smae for all
%                        experiemnts)

% MAB 11/18/21

%% Input Parser
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addRequired('subjID',@ischar);
p.addRequired('expNameCell',@iscell);
p.addParameter('fitMethod','LGS',@ischar);
p.addParameter('numRuns',20,@isnumeric);
p.addParameter('isBootstrap',false,@islogical);
p.addParameter('nBootIters',5,@isnumeric);
p.addParameter('plotRawData',false,@islogical);
p.parse(subjID,expNameCell,varargin{:});

% get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end


% get prefs
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
bootParamsCacheFolder = getpref(projectName,'bootParamsCacheFolder');
rParamsBtstrpStruct = struct;


%% Loop over the experiments
for ii = 1:length(expNameCell)
    
    % get the experimnent code name
    expName = expNameCell{ii};
    
    % Load the bulk raw data for that experiment
    theRuns = 1:p.Results.numRuns;
    Sall = loadPSYdataLMSall('TRK', subjID, expName, 'CGB', {theRuns}, 'jburge-hubel', 'local');
    
    % get the specific experiemtn code
    if strcmp(expName,'LS1')
        expCode = 'Experiment1-Pos';
    elseif strcmp(expName,'LS2')
        expCode = 'Experiment2-Pos';
    elseif strcmp(expName,'LS3')
        expCode = ['Experiment3-' subjID '-Pos'];
    end
    
    % load the stilumus L and S contrast used in the experiment
    MaxContrastLMS(:,:,ii) = LMSstimulusContrast('experiment',expCode);
    cL(:,ii) = MaxContrastLMS(:,1,ii);
    cS(:,ii) = MaxContrastLMS(:,3,ii);
    colorDirs = round(atand(cS(:,ii)./cL(:,ii)),2);
    uniqueColorDirs(:,ii) = unique(colorDirs,'stable');
    
    
    for jj = 1:size(uniqueColorDirs,1)
        
        % 0 DEG IN SL PLANE
        ind = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-uniqueColorDirs(jj,ii))<0.001;
        
        S = structElementSelect(Sall,ind,size(Sall.tgtXmm,2));
        % LMS ANALYSIS TO ESTIMATE LAGS
        
        if p.Results.isBootstrap
            [~, ~, rParams(:,:,jj), ~, btstrpStruct(jj)] = LMSxcorrAnalysis(S,p.Results.fitMethod,'bPLOTfitsAndRaw',p.Results.plotRawData,'nBootstrapIter',p.Results.nBootIters);
        else
            [~,~,rParams(:,:,jj)] = LMSxcorrAnalysis(S,p.Results.fitMethod,'bPLOTfitsAndRaw',p.Results.plotRawData);
        end
    end
    
    for kk = 1:length(btstrpStruct)
        rParamsBtstrp(:,:,:,kk) = btstrpStruct(kk).rParamBtstrp;
    end
    rParamsBtstrpStruct(ii).rParamsBtstrp = rParamsBtstrp;
    % Calculate the lags
    if strcmp(p.Results.fitMethod,'LGS')
        lags(:,:,ii) = flipud(squeeze(rParams(2,:,:)));
        if p.Results.isBootstrap
            lagsBtstrp = flipud(squeeze(rParamsBtstrp(2,:,:,:)));
            meanLagBtstrp(:,:,ii) = squeeze(mean(lagsBtstrp,2));
            sDevBtstrpLag(:,:,ii) = squeeze(std(lagsBtstrp,0,2));
        end
    elseif strcmp(p.Results.fitMethod,'GMA')
        lags = flipud((squeeze(rParams(3,:,:))-1).*squeeze(rParams(2,:,:))+ squeeze(rParams(4,:,:)));
    else
        error('Fit Method Unknown')
    end
    
end

% Reshape the parameters
lagsMat = reshape(lags,[size(lags,1) size(lags,2)*size(lags,3)]);
meanLagBtstrpLagMat = reshape(meanLagBtstrp,[size(meanLagBtstrp,1) size(meanLagBtstrp,2)*size(meanLagBtstrp,3)]);
sDevBtstrpLagMat    = reshape(sDevBtstrpLag,[size(sDevBtstrpLag,1) size(sDevBtstrpLag,2)*size(sDevBtstrpLag,3)]);

% create info struct for checks used in the dependant functions.
infoParams.computeDate = date;
infoParams.expNames = expNameCell;
infoParams.numRuns  = p.Results.numRuns;
infoParams.fitMethod  = p.Results.fitMethod;

if p.Results.isBootstrap
    infoBootParams.computeDate = date;
    infoBootParams.expNames    = expNameCell;
    infoBootParams.numRuns     = p.Results.numRuns;
    infoBootParams.fitMethod   = p.Results.fitMethod;
end

%% save out the params and the bootstrap params
paramsCacheFileName     = fullfile(paramsCacheFolder,[subjCode '_paramsCache.mat']);
save(paramsCacheFileName,'infoParams','lagsMat','MaxContrastLMS','cL','cS','uniqueColorDirs')

if p.Results.isBootstrap
    bootParamsCacheFileName = fullfile(bootParamsCacheFolder,[subjCode '_bootParamsCache.mat']);
    save(bootParamsCacheFileName,'infoBootParams','meanLagBtstrpLagMat','sDevBtstrpLagMat','rParamsBtstrpStruct');
end
