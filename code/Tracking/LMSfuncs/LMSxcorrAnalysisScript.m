%%

Sall = loadPSYdataLMSall('TRK', 'JNK', 'CGB', {[1:2]}, 'jburge-hubel', 'server');

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
S5 = structElementSelect(Sall,ind3,size(Sall.tgtXmm,2));
S6 = structElementSelect(Sall,ind4,size(Sall.tgtXmm,2));

%%

LMSxcorrAnalysis(S1,'LGS')