%% Clear and close
clear; close all;

%% Load the data
subjID = 'BMC';
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');

% get subject code
if strcmp(subjID,'MAB')
    subjCode = 'Subject1';
elseif strcmp(subjID,'BMC')
    subjCode = 'Subject2';
elseif strcmp(subjID,'KAS')
    subjCode = 'Subject3';
end

projectName = 'ColorTracking';
plotInfo.figSavePath = getpref(projectName,'figureSavePath');
plotInfo.subjCode    = subjCode;

load(fullfile(paramsCacheFolder,'detection',[subjCode '_pcCache.mat']));

theDirections = unique(atand(cS(:)./cL(:)))';

% Loop over directions and fit each individually
for whichDirection = 1:length(theDirections)
    %% If the direction is 0, routine tfeCTMParseDirections throws an error
    % because it requires at least one direciton whose angle is not zero.
    % I am not sure why.  To handle this, if the angle is 0, we tack on the
    % next direction and fit two directions. This will work as long as the
    % zero direction is not the last in the list.
    if (theDirections(whichDirection) == 0)
        extraDirs = 1;
    else
        extraDirs = 0;
    end
    nContrastsPerDirection = 6;
    
    % Get indices for just the directions we're fitting, and make it a
    % column vector.
    dirIndices = (whichDirection-1)*nContrastsPerDirection+1:(whichDirection+extraDirs)*nContrastsPerDirection;
    dirIndices = dirIndices(:);

    %% Make fit obj
    pcObjIndiv = tfeLSDIndiv(theDirections(whichDirection:whichDirection+extraDirs),nContrastsPerDirection,'verbosity','none','dimension',2, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

    %% Make the packet
    pcVec = pcData(dirIndices)';
    timebase = 1:length(pcVec);

    % Initialize the packet
    thePacket.response.values   = pcVec;
    thePacket.response.timebase = timebase;

    % The stimulus
    thePacket.stimulus.values   = [cL(dirIndices),cS(dirIndices)]';
    thePacket.stimulus.timebase = timebase;

    % The kernel
    thePacket.kernel.values = [];
    thePacket.kernel.timebase = [];

    % The Meta Data
    thePacket.metaData.stimDirections = atand(cS(dirIndices)./cL(dirIndices));
    thePacket.metaData.stimContrasts  = vecnorm([cS(dirIndices),cL(dirIndices)]')';

    %% Fit it
    %
    % The needed fitErrorScalar varies not only by subject but also by
    % direction.  What a pain.  Could handle this automatically by trying
    % a whole list of scalars and picking the one where fit error divided
    % by scalar is the smallest.  May need to do this for the bootstrapping
    % and cross-validation cases, to make sure the right scalar value is
    % picked independent of the detail of the data.  I don't really
    % understand why it is so fussy in this way.  There might be a smarter
    % way to pick initial parameters that would also solve this problem.
    defaultParamsInfo = [];
    % get subject specific error scalar
    if strcmp(subjID,'MAB')
        if (whichDirection == 6)
            fitErrorScalar = 1000;
        else
            fitErrorScalar = 100;
        end
    elseif strcmp(subjID,'BMC')
        if (whichDirection == 11)
            fitErrorScalar = 100;
        else
            fitErrorScalar = 1000;
        end
    elseif strcmp(subjID,'KAS')
        if (whichDirection == 5)
            fitErrorScalar = 1;
        else
            fitErrorScalar = 10;
        end
    end

    nParamsPerDirection = 2;
    [pcParams,fVal,pcFromFitParams] = pcObjIndiv.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
        'initialParams',[], 'fitErrorScalar',fitErrorScalar);

    % Store parameters for each direction as we fit 
    pcParamsAll(whichDirection) = pcParams(1);

    % Plot for fit direction.
    figure; hold on;
    plot(pcFromFitParams.values,'r')
    plot(thePacket.response.values,'k--')
    legend('Indiv. Fit','Orig. PC')
end

% Could take all parameters, compute for all directions, and check 
% here that fit looks good. Could also do joint fit here, starting with
% the individual direction parameters that come back. 