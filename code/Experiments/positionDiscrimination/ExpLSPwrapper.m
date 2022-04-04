%%

targetContrastAngle1 = [-86.25 -82.5 -78.75 -75 -45 0 45 75 78.75 82.5 86.25 90];
targetContrast1 = 2*[0.04 0.025 0.02 0.018 0.007 0.0035 0.007 0.018 0.02 0.025 0.04 0.044];
targetContrast2 = targetContrast1*3;
targetContrastAngle = [targetContrastAngle1; targetContrastAngle1];
targetContrastAngle = targetContrastAngle(:);
targetContrast = [targetContrast1; targetContrast2];
targetContrast = targetContrast(:);

maxPosPix = 24*ones([size(targetContrast,1) 1]);

trialsPerPos = 5;
trialsPerBlock = 70;
nPos = 6;

indRnd = [];
posXoffsetPix = [];

for i = 1:length(targetContrast)
    indRnd(:,i) = i.*ones([trialsPerBlock 1]);
    posXoffsetPixTmp = repmat([-maxPosPix(i):maxPosPix(i)/nPos:-maxPosPix(i)/nPos 0 0 maxPosPix(i)/nPos:maxPosPix(i)/nPos:maxPosPix(i)],[trialsPerPos 1]);
    posXoffsetPixTmp = posXoffsetPixTmp(:);
    posXoffsetPixTmp = posXoffsetPixTmp(randperm(length(posXoffsetPixTmp)));
    posXoffsetPix(:,i) = posXoffsetPixTmp;
end

indShuffle = randperm(size(indRnd,2));
indRnd = indRnd(:,indShuffle);
posXoffsetPix = posXoffsetPix(:,indShuffle);
cmpIntrvl = ones(size(indRnd));

%%

clear;
