function thePacketDetect = makeDetectionPacket(subjID)
% This function loads the data and returns the packet for the detection task.

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


%% Make the packet
pcVec = pcData(:)';
timebase = 1:length(pcVec);

% Initialize the packet
thePacketDetect.response.values   = pcVec;
thePacketDetect.response.timebase = timebase;

% The stimulus
thePacketDetect.stimulus.values   = [cL(:),cS(:)]';
thePacketDetect.stimulus.timebase = timebase;

% The Kernel 
thePacketDetect.kernel.values = [];
thePacketDetect.kernel.timebase = [];

% The Meta Data 
thePacketDetect.metaData.fValWeight = [];
thePacketDetect.metaData.stimDirections = atand(cS(:)./cL(:));
thePacketDetect.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';
thePacketDetect.metaData.dirPlotColors  = [230 172 178; ...
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
    ]./255;