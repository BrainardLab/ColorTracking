function [] = generateDetectionCachedData(subjID)
%
% This function is the top level call to read in and do
% some massaging and initial fitting of th detection
% experiment.
%
% You need to have your Matlab preference file set up
% to point to teh folder containing the raw data - see
% config/ColorTrackingLocalHookTemplate.m for how you
% set that up.  Then execute the three lines below to
% produce the cached data files used for further fitting.
% The cached data is put into a filename
% with pcCache as part of it, where pc is supposed to make
% you think of percent correct.
%
% This didn't previously produce bootstrapped data, but I added
% the 'nBoots',100 key/value pair to the call to LSDthresholdAnalysis
% and fixed the hard coded directory there to respect the project
% preference.  Also had to pass subjNum into that routine to get the
% filename right.

%{
    % Check that the setting of CORRECTED in getContrastLSD is as you want
    it.
    generateDetectionCachedData('MAB');
    generateDetectionCachedData('BMC');
    generateDetectionCachedData('KAS');
%}

% Clear out figures
close all

% Get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
    subjNum = 1;
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
    subjNum = 2;
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
    subjNum = 3;
end

% Burge lab functions used to read and sort the data, etc.
S = loadPSYdataLMSall('JND', subjID, 'LSD', 'CGB',{[1:48]}, 'blobfish', 'local');

% The S structure comes from the stored data files.  If we are correcting
% for the slightly messed up stimulus specification, need to rewrite that
% with the corrected information, which we can get out the getContrastLSD
% function, when its CORRECTED flag is set to true.
CORRECTED = true;
DEBUG_CORRECTION = false;
[targetContrast,targetAngles,targetContrastOrig,targetAnglesOrig] = getContrastLSD(subjID,'combined',CORRECTED);

% Get angles and contrast and convert to L and S cone contrast.
% We need to get the S structure corrected, as the original code
% then builds on a combination of that and the targetContrast, targetAngles
% variables above.
if (CORRECTED)
    % Correct angles
    %
    % This could probably be a little more efficient/clear, but it works.
    theUniqueAnglesOrig = unique(S.targetContrastAngle)';
    theUniqueAngles = NaN(size(theUniqueAnglesOrig));
    for ii = 1:length(theUniqueAngles )
        index(ii) = find(theUniqueAnglesOrig(ii) == targetAnglesOrig);
        if (isempty(index(ii)))
            error('Logic error');
        end
        theUniqueAngles (ii) = targetAngles(index(ii));
    end
    if (any(isempty(theUniqueAngles )))
        error('Failed to update some angles(s)');
    end

    STargetContrastAngleOrig = S.targetContrastAngle;
    S.targetContrastAngle = NaN*ones(size(STargetContrastAngleOrig));
    for ii = 1:length(S.targetContrastAngle(:))
        index1 = find(STargetContrastAngleOrig(ii) == theUniqueAnglesOrig);
        if (length(index1) ~= 1)
            error('Logic error');
        end
        newAngle = theUniqueAngles(index1);
        S.targetContrastAngle(ii) = newAngle;
    end
    if (DEBUG_CORRECTION)
        figure; clf; hold on;
        plot(STargetContrastAngleOrig(:),S.targetContrastAngle(:)-STargetContrastAngleOrig(:),'ro','MarkerSize',12);
        plot(theUniqueAnglesOrig(:),theUniqueAngles (:)-theUniqueAnglesOrig(:),'bo','MarkerSize',8,'MarkerFaceColor','b');
    end
    if (any(isnan(S.targetContrastAngle)))
        error('Oops');
    end

    % Contrasts
    %
    % This could probably be a little more efficient/clear, but it works.
    theUniqueContrastOrig = unique(S.targetContrast)';
    theUniqueContrast = NaN(size(theUniqueContrastOrig));

    % Find maximum contrast for each angle.  We need to do this to figure
    % out what we need to correct from.  And we have to do this because
    % for some subjects, what is in the data file does not match what
    % was in the tables.
    STargetContrastOrig = S.targetContrast;
    for aa = 1:length(theUniqueAnglesOrig)
        theAngleToAnalyze = theUniqueAnglesOrig(aa);
        index = find(theAngleToAnalyze == STargetContrastAngleOrig);
        targetAnglesFixed(aa) = theAngleToAnalyze;
        targetContrastFixed(aa) = max(STargetContrastOrig(index));
    end
    
    % Ideally the orig variables below would match the fixed versions.
    % This was true for MAB and BMC, but not for KAS until we updated
    % GetContrastLSD with what we figured out here.
    % targetAnglesOrig'
    % targetAnglesFixed
    % max(targetContrastOrig)
    % targetContrastFixed
    if (any(max(abs(targetAnglesOrig'-targetAnglesFixed)) > 1e-8))
        error('Bookkeeping error in getContrastLSD vis-a-vis data files');
    end
    if (any(max(abs(max(targetContrastOrig)-targetContrastFixed)) > 1e-10))
        error('Bookkeeping error in getContrastLSD vis-a-vis data files');
    end

    % Have to worry about the fact that the contrasts in S are signed, but
    % those in targetContrast and targetContrastOrig are not.
    for ii = 1:length(theUniqueContrast)
        indexAll = find(abs(theUniqueContrastOrig(ii)) == abs(targetContrastOrig(:)));
        index(ii) = indexAll(1);
        if (isempty(index(ii)))
            error('Logic error');
        end
        theUniqueContrast(ii) = sign(theUniqueContrastOrig(ii))*abs(targetContrast(index(ii)));
    end
    if (any(isnan(theUniqueContrast)))
        error('Failed to update some contrast(s)');
    end

    S.targetContrast = NaN*ones(size(STargetContrastOrig));
    for ii = 1:length(S.targetContrast(:))
        index1 = find(STargetContrastOrig(ii) == theUniqueContrastOrig);
        if (length(index1) ~= 1)
            error('Logic error');
        end
        newContrast = theUniqueContrast(index1);
        S.targetContrast(ii) = newContrast;
    end
    if (DEBUG_CORRECTION)
        figure; clf; hold on;
        plot(STargetContrastOrig(:),S.targetContrast(:)-STargetContrastOrig(:),'ro','MarkerSize',12);
        plot(theUniqueContrastOrig(:),theUniqueContrast(:)-theUniqueContrastOrig(:),'bo','MarkerSize',8,'MarkerFaceColor','b');
        figure; clf; hold on;
        plot(STargetContrastOrig(:),S.targetContrast(:),'ro','MarkerSize',12);
        plot(theUniqueContrastOrig(:),theUniqueContrast(:),'bo','MarkerSize',8,'MarkerFaceColor','b');
    end
    if (any(isnan(S.targetContrast)))
        error('Oops');
    end
    
    % Let's not confuse the correction with the original code below
    clear newAngle index index1 theUniqueAnglesOrig theUniqueAngles STargetContrastAngleOrig targetAnglesOrig;
    clear newContrast index index1 indexAll theUniqueContrastOrig STargetContrastOrig targetContrastOrig


end

% This is the original code.  It mixes and matches the angles pulled
% out of the datafiles and those returned by generateContrastLSD, which
% is not great coding style but they did match up in the original
% version so it is OK.
theAngles = unique(S.targetContrastAngle)';
targetContrast = flipud(targetContrast);
anglesMat = repmat(theAngles,[size(targetContrast,1),1]);
cS = targetContrast.*sind(anglesMat);
cL = targetContrast.*cosd(anglesMat);

% Burge lab functions used to do more stuff.  It looks like
% our main purpose here is to get the percent correct data
% out for each stimulus level.
[tFit,mFit,sFit,bFit,PCdta] = LSDthresholdAnalysis(S,1,'bPLOTpsfs',1,'fitType','weibull','showPlot',false,'nBoot',100,'subjNum',subjNum);
pcData = flipud(PCdta);
infoParams.computeDate = date;

%% Save out what we need for more fitting
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
paramsCacheFileName     = fullfile(paramsCacheFolder,'detection',[subjCode '_pcCache.mat']);
save(paramsCacheFileName,'infoParams','pcData','targetContrast','cL','cS','theAngles')

end