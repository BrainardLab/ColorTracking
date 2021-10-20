%% LOAD DATA
subjID = 'BMC';
theRuns = 1:20;


figSavePath = fullfile(getpref('CorticalColorMapping','dropboxPath'),'CNST_analysis','ColorTracking','Results'); %'/Users/michael/labDropbox/CNST_analysis/ColorTracking/Results/';

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
ind3 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-(+75))<0.001;
% 45 DEG IN SL PLANE
ind4 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-(-75))<0.001;
% -75 DEG IN SL PLANE
ind5 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-(+45))<0.001;
% 75 DEG IN SL PLANE
ind6 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-(-45))<0.001;

S1 = structElementSelect(Sall,ind1,size(Sall.tgtXmm,2));
S2 = structElementSelect(Sall,ind2,size(Sall.tgtXmm,2));
S3 = structElementSelect(Sall,ind3,size(Sall.tgtXmm,2));
S4 = structElementSelect(Sall,ind4,size(Sall.tgtXmm,2));
S5 = structElementSelect(Sall,ind5,size(Sall.tgtXmm,2));
S6 = structElementSelect(Sall,ind6,size(Sall.tgtXmm,2));

%% LMS ANALYSIS TO ESTIMATE LAGS
plotRawData = 1;
[~,~,rParams(:,:,1)] = LMSxcorrAnalysis(S1,'LGS','bPLOTfitsAndRaw',plotRawData);
[~,~,rParams(:,:,2)] = LMSxcorrAnalysis(S2,'LGS','bPLOTfitsAndRaw',plotRawData);
[~,~,rParams(:,:,3)] = LMSxcorrAnalysis(S3,'LGS','bPLOTfitsAndRaw',plotRawData);
[~,~,rParams(:,:,4)] = LMSxcorrAnalysis(S4,'LGS','bPLOTfitsAndRaw',plotRawData);
[~,~,rParams(:,:,5)] = LMSxcorrAnalysis(S5,'LGS','bPLOTfitsAndRaw',plotRawData);
[~,~,rParams(:,:,6)] = LMSxcorrAnalysis(S6,'LGS','bPLOTfitsAndRaw',plotRawData);

%% Get the lags from rParams
lags = flipud(squeeze(rParams(2,:,:)));

% Get the cone contrasts
MaxContrastLMS = LMSstimulusContrast('experiment','SLplane-Pos');
cL = MaxContrastLMS(:,1);
cS = MaxContrastLMS(:,3);

%% set up the mechanisms
%initial weight estimates [0.7 0.3 0.997 0.003 2.5/1000 0.3];
a1 = 0.7;
b1 = 0.3;
a2 = 0.997;
b2 = 0.003;
minLag1 = 0.3;
decay1 = .25;
% c1 = .5;
% c2 = .5;

%p = [a1,b1,a2,b2,minLag1,decay1,c1,c2];
p = [a1,b1,a2,b2,minLag1,decay1];

%% Search for it
A =[];
aa = [];
Aeq =[];%[0,0,0,0,0,0,1,1];
aaeq =[];%[1];
nlcon =[];

% lb =[0,0,0,0,0,0,0,0];
% ub = [100,100,100,100,5,100,1,1];
lb =[0,0,0,0,0,0];
ub = [1000,1000,1000,1000,5,100];

options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','iter','LargeScale','off','Algorithm','active-set');

p_hat = fmincon(@(p) objectiveFunc(p,lags(:),cL,cS),p,A,aa,Aeq,aaeq,lb,ub,nlcon,options);

%% break up p
a1_hat      = p_hat(1);
b1_hat      = p_hat(2);
a2_hat      = p_hat(3);
b2_hat      = p_hat(4);
minLag1_hat = p_hat(5);
decay1_hat  = p_hat(6);
% c1_hat      = p_hat(7);
% c2_hat      = p_hat(8);

%% Use the recovered weights
% m1_hat =  sqrt(a1_hat.*cL.^2 + b1_hat.*cS.^2);
% m2_hat =  sqrt(a2_hat.*cL.^2 + b2_hat.*cS.^2);
m1_hat =  abs(a1_hat.*cL + b1_hat.*cS);
m2_hat =  abs(a2_hat.*cL + b2_hat.*cS);
%% Contrast-Lag nonlinearity
 Lag1_hat =  minLag1_hat +  decay1_hat.* exp(-1.*m1_hat);
 Lag2_hat =  minLag1_hat +  decay1_hat.* exp(-1.*m2_hat);
%Lag1_hat =  minLag1_hat + decay1_hat./m1_hat;
%Lag2_hat =  minLag1_hat + decay1_hat./m2_hat;


%% objective function
lagsFromFit = min([Lag1_hat'; Lag2_hat'])';
%lagsFromFit = c1_hat.*Lag1_hat - c2_hat.*Lag2_hat;
lagsFromFitMat = reshape(lagsFromFit,size(lags));
%% PLOT IT

% Set the colors
plotColors = [230 172 178; ...
    194  171  253; ...
    36   210  201; ...
    32   140  163; ...
    253  182    44; ...
    252  153  233;...
    ]'./255;

% Get the l2 norm of the cone contrasts
vecContrast = sqrt(MaxContrastLMS(:,1).^2+MaxContrastLMS(:,3).^2);
matrixContrasts_unsorted = reshape(vecContrast,size(lags));
matrixContrasts = matrixContrasts_unsorted(:,[1 2 6 5 4 3]);
% Names for plotting
plotNames.title  = 'Lag Vs. Contrast';
plotNames.xlabel  = 'Contrast (%)';
plotNames.ylabel = 'Lag (s)';
plotNames.legend = {'0°','90°','75°','-75°','45°','-45°'};

% Plot it

sz = 12;
yLimVals = [0.2 0.6];
semiLog = true;
legendLocation = 'northeastoutside';

%% init the plot
tcHndl = figure;
hold on;

% get the number of lines to plot
numLines = size(lagsFromFitMat,1);


% Loop over the lines
for ii = 1:numLines
    
    scatter(matrixContrasts(:,ii),lags(:,ii),sz.^2, ...
         'MarkerEdgeColor',.3*plotColors(:,ii),...
         'MarkerFaceColor',plotColors(:,ii),...
         'LineWidth',2);
    
end     
% Loop over the lines
for ii = 1:numLines
    
    plot(matrixContrasts(:,ii),lagsFromFitMat(:,ii),'--', ...
        'Color',plotColors(:,ii),...
        'LineWidth',2);

end        

axis square;

if semiLog
    set(gca,'Xscale','log');
end

set(gca,'XTick',[0.03 0.1 0.3 1]);

ylim(yLimVals)

autoTicksY = yLimVals(1):(yLimVals(2)-yLimVals(1))/4:yLimVals(2);

set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'FontSize'    , 16        , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , autoTicksY, ...
    'LineWidth'   , 2         , ...
    'ActivePositionProperty', 'OuterPosition');

set(gcf, 'Color', 'white' );


%% Add labels
if isfield(plotNames,'title')
    hTitle  = title (plotNames.title);
end
if isfield(plotNames,'xlabel')
    hXLabel = xlabel(plotNames.xlabel);
end
if isfield(plotNames,'ylabel')
    hYLabel = ylabel(plotNames.ylabel);
end

%% Add Legend
if isfield(plotNames,'legend')
    legend(plotNames.legend,'Location',legendLocation);
end
%% Format fonts
set([hTitle, hXLabel, hYLabel],'FontName', 'Helvetica');
set([hXLabel, hYLabel,],'FontSize', 18);
set( hTitle, 'FontSize', 18,'FontWeight' , 'bold');

% Save it!
figureSizeInches = [8 8];
set(tcHndl, 'PaperUnits', 'inches');
set(tcHndl, 'PaperSize',figureSizeInches);
set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
%figNameTc =  fullfile(figSavePath,[subjCode, '_LagVsContrast.pdf']);
% Save it
%print(tcHndl, figNameTc, '-dpdf', '-r300');


