%%

Sall = loadPSYdataLMSall('TRK', 'BMC', 'CGB', {[1:10]}, 'jburge-hubel', 'server');

%%

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

%%

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

lags = squeeze(rParams(2,:,:));
MaxContrastLMS = LMSstimulusContrast('experiment','SLplane-Pos');

figure;hold on;
scatter3(MaxContrastLMS(1:6,1),MaxContrastLMS(1:6,3),lags(:,1))

scatter3(MaxContrastLMS(7:12,1),MaxContrastLMS(7:12,3),lags(:,2))

scatter3(MaxContrastLMS(13:18,1),MaxContrastLMS(13:18,3),lags(:,6))

scatter3(MaxContrastLMS(19:24,1),MaxContrastLMS(19:24,3),lags(:,5))

scatter3(MaxContrastLMS(25:30,1),MaxContrastLMS(25:30,3),lags(:,4))

scatter3(MaxContrastLMS(31:36,1),MaxContrastLMS(31:36,3),lags(:,3))
grid on
set(gca,'LineWidth',1.5)
