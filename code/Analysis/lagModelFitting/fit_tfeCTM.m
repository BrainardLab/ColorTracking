%%%%%%% Do the CTM for the 1 and 2 mech models %%%%%%%
%
%% Load the data  
subjID = 'KAS';
projectName = 'ColorTracking';
paramsCacheFolder = getpref(projectName,'paramsCacheFolder');
bootParamsCacheFolder = getpref(projectName,'bootParamsCacheFolder');
plotInfo.figSavePath = getpref(projectName,'figureSavePath');

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
% Get the CIs
[upperCI, lowerCI] = computeCiFromBootSruct(rParamsBtstrpStruct, 68);

%% Make the packet
lagVec = lagsMat(:)';
timebase = 1:length(lagVec);

% Initialize the packet
thePacket.response.values   = lagVec;
thePacket.response.timebase = timebase;

% The stimulus
thePacket.stimulus.values   = [cL(:),cS(:)]';
thePacket.stimulus.timebase = timebase;

% The Kernel 
thePacket.kernel.values = [];
thePacket.kernel.timebase = [];

% The Meta Data 
thePacket.metaData.stimDirections = atand(cS(:)./cL(:));
thePacket.metaData.stimContrasts  = vecnorm([cS(:),cL(:)]')';

matrixContrasts = reshape(thePacket.metaData.stimContrasts,size(lagsMat));

%% Make the fit one mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJmechOne = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 1 ,'fminconAlgorithm','active-set');

%% Make the fit two mechanism object
theDimension= size(thePacket.stimulus.values, 1);
ctmOBJmechTwo = tfeCTM('verbosity','none','dimension',theDimension, 'numMechanism', 2 ,'fminconAlgorithm','active-set');

%% Fit it
defaultParamsInfo = [];
fitErrorScalar    = 1000;

% One mechanism
[fitParamsOneMech,~,~] = ctmOBJmechOne.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);
lagsFromFitOneMech = ctmOBJmechOne.computeResponse(fitParamsOneMech,thePacket.stimulus,thePacket.kernel);
lagsFromFitMat = reshape(lagsFromFitOneMech.values,size(lagsMat));

% Two Mechanism
[fitParamsTwoMech,fVal,objFitResponses] = ctmOBJmechTwo.fitResponse(thePacket,'defaultParamsInfo',defaultParamsInfo,...
    'initialParams',[], 'fitErrorScalar',fitErrorScalar);
lagsFromFitTwoMech = ctmOBJmechTwo.computeResponse(fitParamsTwoMech,thePacket.stimulus,thePacket.kernel);
lagsFromFitMat = reshape(lagsFromFitTwoMech.values,size(lagsMat));

%% Print the params
fprintf('\ntfeCTM One Mechanism Parameters:\n');
ctmOBJmechOne.paramPrint(fitParamsOneMech)
fprintf('\ntfeCTM Two Mechanism Parameters:\n');
ctmOBJmechTwo.paramPrint(fitParamsTwoMech)

%% Do the isolag contours -- one mechanism 
targetLags = [0.3,0.35,0.4,0.45,0.5];
measuredDirections = uniqueColorDirs(:)';
contourColors = [242,240,247;...
203,201,226;...
158,154,200;...
117,107,177;...
84,39,143]./255;

% plot the isolag contour
figHndl = figure;
hold on;

% get current axes
axh = gca;

% plot axes
line([-20 20], [0 0], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);
line([0 0], [-6 6], 'Color', [.3 .3 .3], 'LineStyle', ':','LineWidth', 2);


% plot contour
for ii =1:length(targetLags)
[C_1, sampleBaseTheta_1, targetL_1, targetS_1,expDirPoints] = generateIsorepsoneContour(fitParamsOneMech, targetLags(ii), 1,...
    'dataDirections',measuredDirections);

p1{ii} = line(targetL_1.pos,targetS_1.pos,'color', contourColors(ii,:), 'LineWidth', 2);
p2 = line(targetL_1.neg,targetS_1.neg,'color', contourColors(ii,:), 'LineWidth', 2);

end
%scatter the experimental directions intesect with contour
% sz = 30;
% scatter(expDirPoints(1,:),expDirPoints(2,:),sz,'MarkerEdgeColor',[0.3 .3 .3],...
%     'MarkerFaceColor',[0.75,0.5,0.5],...
%     'LineWidth',1.5)

%% Get the null direction
nullDirection = atand(fitParamsOneMech.weightL ./ fitParamsOneMech.weightS);

fprintf('The null direction is: %1.2f\n',nullDirection)
% nullPoint = 1.5*[cosd(nullDirection) sind(nullDirection)];
% spt = plot(nullPoint(1),nullPoint(2),'bo','MarkerFaceColor','b','MarkerSize',8);

% set axes and figure labels
hXLabel = xlabel('L Contrast');
hYLabel = ylabel('S Contrast');
hTitle  = title('Isoresponse Contour');
set(gca,'FontSize',12);
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 12);
set( hTitle, 'FontSize', 14,'FontWeight' , 'bold');
xlim([-4 4]); ylim([-4 4]); axis('square');


legend([p1{:}],num2str(targetLags(:)))
axis square

manTicks =  [-4:1:4];

set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'FontSize'    , 16        , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'off'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , manTicks, ...
    'XTick'       , manTicks,...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );


% Save it!
figureSizeInches = [8 8];
% set(tcHndl, 'PaperUnits', 'inches');
% set(tcHndl, 'PaperSize',figureSizeInches);
figHndl.Units  = 'inches';
figHndl.PaperUnits  = 'inches';
figHndl.PaperSize = figureSizeInches;
figHndl.OuterPosition = [0 0 figureSizeInches(1) figureSizeInches(2)];
figHndl.InnerPosition = [.5 .5 figureSizeInches(1)-.5 figureSizeInches(2)-.5];

figNameTc =  fullfile(plotInfo.figSavePath,[subjCode, '_isolag_1mech.pdf']);
% Save it
print(figHndl, figNameTc, '-dpdf', '-r300');

% plotInfo.title  = 'Lag Vs. Contrast';
% plotInfo.xlabel  = 'Contrast (%)';
% plotInfo.ylabel = 'Lag (s)';
% plotInfo.figureSizeInches = [20 11];
% plotInfo.subjCode    = subjCode;
% 
% if strcmp(subjID,'MAB')
%     directionGroups = {[0,90],[75, -75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.6,88.6, 87.6],[22.5,-1.4,-22.5]};
%     yLimVals = [0.2 0.9];
% elseif strcmp(subjID,'BMC')
%     directionGroups = {[0,90],[75, -75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.1,88.1,87.1],[22.5,-0.9,-22.5]};
%     yLimVals = [0.2 0.6];
% elseif strcmp(subjID,'KAS')
%     directionGroups = {[0,90],[75, -75],[45,-45],[78.75,-78.75],[82.5,-82.5],[86.2,-86.2],[89.1,88.1,87.1],[22.5,-1.9,-22.5]};
%     yLimVals = [0.2 0.8];
% end

CIs.upper = abs(upperCI - meanLagBtstrpLagMat);
CIs.lower = abs(meanLagBtstrpLagMat - lowerCI);

% plotColors = [230 172 178; ...
%     194  171  253; ...
%     36   210  201; ...
%     32   140  163; ...
%     253  182    44; ...
%     252  153  233;...
%     127  201  127;...
%     190  174  212;...
%     253  192  134;...
%     255  255  153;...
%     56   108  176;...
%     240    2  127;...
%     179  226  205;...
%     253  205  172;...
%     203  213  232;...
%     237  248  177;...
%     127  205  187;...
%     44   127  184;...
%     ]./255;
% 
% plotDirectionPairs(matrixContrasts,lagsMat,lagsFromFitMat,uniqueColorDirs(:), directionGroups, plotInfo,'plotColors',plotColors','errorBarsCI',CIs,'yLimVals',yLimVals)
% 
