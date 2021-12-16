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
p.addParameter('plotRawData',false,@islogical);
p.parse(subjID,expNameCell,varargin{:});

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
    MaxContrastLMS = LMSstimulusContrast('experiment',expCode);
    cL = MaxContrastLMS(:,1);
    cS = MaxContrastLMS(:,3);
    colorDirs = round(atand(cS./cL),2);
    uniqueColorDirs = unique(colorDirs,'stable');
    
    
    for jj = 1:length(uniqueColorDirs)
        
        % 0 DEG IN SL PLANE
        ind = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-uniqueColorDirs(jj))<0.001;
        
        S = structElementSelect(Sall,ind,size(Sall.tgtXmm,2));
        % LMS ANALYSIS TO ESTIMATE LAGS
        
        if p.Results.isBootstrap
           [~, ~, rParams(:,:,jj), ~, ~, btstrpStruct(jj)] = LMSxcorrAnalysis(S,p.Results.fitMethod,'bPLOTfitsAndRaw',p.Results.plotRawData,'nBootstrapIter',5);
        else
            [~,~,rParams(:,:,jj)] = LMSxcorrAnalysis(S,p.Results.fitMethod,'bPLOTfitsAndRaw',p.Results.plotRawData);
        end
    end
    
    for kk = 1:length(btstrpStruct)
        rParamsBtstrp(:,:,:,kk) = btstrpStruct(kk).rParamBtstrp;
    end
    
    % Calculate the lags
    if strcmp(p.Results.fitMethod,'LGS')
        lags = flipud(squeeze(rParams(2,:,:)));
        if p.Results.isBootstrap
        lagsBtstrp = flipud(squeeze(rParamsBtstrp(2,:,:,:)));
        meanBtstrpLag(:,:,ii) = squeeze(mean(lagsBtstrp,2));
        sDevBtstrpLag(:,:,ii) = squeeze(std(lagsBtstrp,0,2));
        end
    elseif strcmp(p.Results.fitMethod,'GMA')
        lags = flipud((squeeze(rParams(3,:,:))-1).*squeeze(rParams(2,:,:))+ squeeze(rParams(4,:,:)));
    else
        error('Fit Method Unknown')
    end
    
end