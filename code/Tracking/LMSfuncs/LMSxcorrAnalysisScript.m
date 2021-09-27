%%

Sall = loadPSYdataLMSall('TRK', 'BMC', 'CGB', {[2:3]}, 'blobfish', 'local');

%%

ind1 = Sall.MaxContrastLMS(:,1)>0           & abs(Sall.MaxContrastLMS(:,2))<0.0001 & abs(Sall.MaxContrastLMS(:,3))<0.0001; 
ind2 = abs(Sall.MaxContrastLMS(:,1))<0.0001 & abs(Sall.MaxContrastLMS(:,2))<0.0001     & Sall.MaxContrastLMS(:,3)>0; 
ind3 = Sall.MaxContrastLMS(:,1)>0           & abs(Sall.MaxContrastLMS(:,2))<0.0001     & Sall.MaxContrastLMS(:,3)<0; 
ind4 = Sall.MaxContrastLMS(:,1)>0.0001           & abs(Sall.MaxContrastLMS(:,2))<0.0001     & Sall.MaxContrastLMS(:,3)>0; 
S1 = structElementSelect(Sall,ind1,size(Sall.tgtXmm,2));
S2 = structElementSelect(Sall,ind2,size(Sall.tgtXmm,2));
S3 = structElementSelect(Sall,ind3,size(Sall.tgtXmm,2));
S4 = structElementSelect(Sall,ind4,size(Sall.tgtXmm,2));

%%

LMSxcorrAnalysis(S2,'LGS')