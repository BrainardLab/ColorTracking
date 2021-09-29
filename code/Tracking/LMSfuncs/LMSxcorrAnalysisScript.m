%% LOAD DATA

Sall = loadPSYdataLMSall('TRK', 'BMC', 'CGB', {[1:20]}, 'jburge-hubel', 'server');

%% SORT TRIALS BY COLOR ANGLE

% 0 DEG IN SL PLANE
ind1 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-0)<0.001;
% 90 DEG IN SL PLANE
ind2 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-90)<0.001; 
% -45 DEG IN SL PLANE
ind3 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-(-45))<0.001; 
% 45 DEG IN SL PLANE
ind4 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-(+45))<0.001;
% -75 DEG IN SL PLANE
ind5 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-(-75))<0.001;
% 75 DEG IN SL PLANE
ind6 = abs(atand(Sall.MaxContrastLMS(:,3)./Sall.MaxContrastLMS(:,1))-(+75))<0.001;
S1 = structElementSelect(Sall,ind1,size(Sall.tgtXmm,2));
S2 = structElementSelect(Sall,ind2,size(Sall.tgtXmm,2));
S3 = structElementSelect(Sall,ind3,size(Sall.tgtXmm,2));
S4 = structElementSelect(Sall,ind4,size(Sall.tgtXmm,2));
S5 = structElementSelect(Sall,ind5,size(Sall.tgtXmm,2));
S6 = structElementSelect(Sall,ind6,size(Sall.tgtXmm,2));

%% LMS ANALYSIS TO ESTIMATE LAGS

[~,~,rParams(:,:,1)] = LMSxcorrAnalysis(S1,'LGS');
close all
[~,~,rParams(:,:,2)] = LMSxcorrAnalysis(S2,'LGS');
close all
[~,~,rParams(:,:,3)] = LMSxcorrAnalysis(S3,'LGS');
close all
[~,~,rParams(:,:,4)] = LMSxcorrAnalysis(S4,'LGS');
close all
[~,~,rParams(:,:,5)] = LMSxcorrAnalysis(S5,'LGS');
close all
[~,~,rParams(:,:,6)] = LMSxcorrAnalysis(S6,'LGS');
close all

%% PLOT ALL LAGS ON SAME FIGURE

lags = squeeze(rParams(2,:,:));
MaxContrastLMS = LMSstimulusContrast('experiment','SLplane-Pos');

rgbMatrixForPlotting = [0.85 0.33 0.10; ...
                        0    0.45 0.74; ...
                        1    0    1; ...
                        0.93 0.69 0.13;                        
                        0.93 0.69 0.13; ...
                        0.49 0.18 0.56 ...
                        ];

figure;
hold on;
plot(sqrt(MaxContrastLMS(1:6,1).^2+MaxContrastLMS(1:6,3).^2),flipud(lags(:,1)),'o','MarkerSize',10,'Color',rgbMatrixForPlotting(1,:));
plot(sqrt(MaxContrastLMS(7:12,1).^2+MaxContrastLMS(7:12,3).^2),flipud(lags(:,2)),'o','MarkerSize',10,'Color',rgbMatrixForPlotting(2,:));
plot(sqrt(MaxContrastLMS(13:18,1).^2+MaxContrastLMS(13:18,3).^2),flipud(lags(:,6)),'o','MarkerSize',10,'Color',rgbMatrixForPlotting(3,:));
plot(sqrt(MaxContrastLMS(19:24,1).^2+MaxContrastLMS(19:24,3).^2),flipud(lags(:,5)),'o','MarkerSize',10,'Color',rgbMatrixForPlotting(4,:));
    plot(sqrt(MaxContrastLMS(25:30,1).^2+MaxContrastLMS(25:30,3).^2),flipud(lags(:,4)),'o','MarkerSize',10,'Color',rgbMatrixForPlotting(5,:));
plot(sqrt(MaxContrastLMS(31:36,1).^2+MaxContrastLMS(31:36,3).^2),flipud(lags(:,3)),'o','MarkerSize',10,'Color',rgbMatrixForPlotting(6,:));
axis square;
formatFigure('Contrast','Lag (ms)');
set(gca,'Xscale','log');
set(gca,'XTick',[0.03 0.1 0.3 1]);
legend('0°','90°','-45°','45°','-75°','75°');

%% MAKE 3D SCATTER PLOT

figure;hold on;
scatter3(MaxContrastLMS(1:6,1),MaxContrastLMS(1:6,3),lags(:,1))

scatter3(MaxContrastLMS(7:12,1),MaxContrastLMS(7:12,3),lags(:,2))

scatter3(MaxContrastLMS(13:18,1),MaxContrastLMS(13:18,3),lags(:,6))

scatter3(MaxContrastLMS(19:24,1),MaxContrastLMS(19:24,3),lags(:,5))

scatter3(MaxContrastLMS(25:30,1),MaxContrastLMS(25:30,3),lags(:,4))

scatter3(MaxContrastLMS(31:36,1),MaxContrastLMS(31:36,3),lags(:,3))
grid on
set(gca,'LineWidth',1.5)
