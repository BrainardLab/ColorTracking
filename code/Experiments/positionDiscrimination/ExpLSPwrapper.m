%%

targetContrastAngle1 = [-86.25 -82.5 -78.75 -75 -45 0 45 75 78.75 82.5 86.25 90];
targetContrast1 = [0.04 0.025 0.02 0.018 0.007 0.0035 0.007 0.018 0.02 0.025 0.04 0.044];
targetContrast2 = targetContrast1*3;
targetContrastAngle = [targetContrastAngle1; targetContrastAngle1];
targetContrastAngle = targetContrastAngle(:);
targetContrast = [targetContrast1; targetContrast2];
targetContrast = targetContrast(:);

%%

clear;