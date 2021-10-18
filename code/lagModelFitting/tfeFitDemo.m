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
plotRawData = 0;
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
%initial weight estimates
a1 = 0;
b1 = 1;
a2 = 1;
b2 = 0;
minLag1 = .300;
Amp1 = 1;
decay1 = .5;

p = [a1,b1,a2,b2,minLag1,Amp1,decay1];

%% Search for it
A =[];
aa = [];
Aeq =[];%[1,1,0,0,0,0,0;0,0,1,1,0,0,0];
aaeq =[];%[1;1];
nlcon =[];

lb =[0,0,0,0,.2,0,0];
ub = [1,1,1,1,.5,10,100];

options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','iter','LargeScale','off','Algorithm','active-set');

p_hat = fmincon(@(p) objectiveFunc(p,lags(:),cL,cS),p,A,aa,Aeq,aaeq,lb,ub,nlcon,options);

%% break up p
a1_hat = p_hat(1);
b1_hat = p_hat(2);
a2_hat = p_hat(3);
b2_hat = p_hat(4);
minLag1_hat = p_hat(5);
Amp1_hat = p_hat(6);
decay1_hat = p_hat(7);

%% Use the recovered weights
m1_hat =  abs(a1_hat.*cL + b1_hat.*cS);
m2_hat =  abs(a2_hat.*cL + b2_hat.*cS);

%% Contrast-Lag nonlinearity
Lag1_hat =  minLag1_hat + Amp1_hat .* exp(-1.*decay1_hat.*m1_hat);
Lag2_hat =  minLag1_hat + Amp1_hat .* exp(-1.*decay1_hat.*m2_hat);

%% objective function
lagsFromFit = min([Lag1_hat'; Lag2_hat'])';
reshape(lagsFromFit,size(lags))

%% PLOT IT

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
matrixContrasts_unsorted = reshape(vecContrast,size(lags));
matrixContrasts = matrixContrasts_unsorted(:,[1 2 6 5 4 3]);
% Names for plotting
plotNames.title  = 'Lag Vs. Contrast';
plotNames.xlabel  = 'Contrast (%)';
plotNames.ylabel = 'Lag (s)';
plotNames.legend = {'0°','90°','75°','-75°','45°','-45°'};

% Plot it!
[tcHndl] =plotParams(matrixContrasts,reshape(lagsFromFit,size(lags)),plotColors',plotNames,'yLimVals', [0 1]);
hold on 
% Save it!
figureSizeInches = [8 8];
set(tcHndl, 'PaperUnits', 'inches');
set(tcHndl, 'PaperSize',figureSizeInches);
set(tcHndl, 'PaperPosition', [0 0 figureSizeInches(1) figureSizeInches(2)]);
% Full file name
%figNameTc =  fullfile(figSavePath,[subjCode, '_LagVsContrast.pdf']);
% Save it
%print(tcHndl, figNameTc, '-dpdf', '-r300');


