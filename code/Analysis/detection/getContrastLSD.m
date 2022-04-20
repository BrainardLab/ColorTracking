function [targetContrast,targetAngles] = getContrastLSD(subjName,expName)

nContrasts = 6;
if strcmp(subjName,'BMC')
    if strcmp(expName,'Exp1')
        targetAngles   = [-75, -45,0, 45, 75, 90];
        maxContrasts= ([0.04, 0.0125 ,0.01 ,0.0125,0.04,0.09])';
    elseif strcmp(expName,'Exp2')
        targetAngles   = [-86.25, -82.5,-78.75, 78.75, 82.5, 86.25];
        maxContrasts= [0.10, 0.07, 0.05, 0.05, 0.07, 0.10]';
    elseif strcmp(expName,'combined')
        targetAngles = [-86.25, -82.5,-78.75, -75, -45,0, 45, 75, 78.75, 82.5, 86.25, 90]';
        maxContrasts= [0.10, 0.07, 0.05, 0.04, 0.0125 ,0.01 ,0.0125, 0.04,0.05, 0.07, 0.10, 0.09]';
    else
        error('Exp. code not known')
    end
elseif strcmp(subjName,'MAB')
    if strcmp(expName,'Exp1')
        targetAngles   = [-75, -45,0, 45, 75, 90];
        maxContrasts = [0.06, 0.025, 0.0175, 0.02, 0.07, 0.18]';
    elseif strcmp(expName,'Exp2')
        targetAngles   = [-86.25, -82.5,-78.75, 78.75, 82.5, 86.25];
        maxContrasts = [0.14, 0.10, 0.09, 0.07, 0.10, 0.18]';
    elseif strcmp(expName,'combined')
        targetAngles   = [-86.25, -82.5,-78.75, -75,   -45,    0,    45,   75, 78.75, 82.5, 86.25, 90]';
        maxContrasts= [0.14,    0.10, 0.09, 0.06, 0.025, 0.0175, 0.02, 0.07, 0.07, 0.10, 0.18, 0.18]';
    else
        error('Exp. code not known')
    end
elseif strcmp(subjName,'KAS')
    if strcmp(expName,'Exp1')
        targetAngles   = [-75, -45,0, 45, 75, 90];
        maxContrasts= [0.06, 0.015, 0.01, 0.015, 0.04, 0.09]';
    elseif strcmp(expName,'Exp2')
        targetAngles   = [-86.25, -82.5,-78.75, 78.75, 82.5, 86.25];
        maxContrasts= [0.10, 0.08, 0.055, 0.055, 0.08, 0.10]';
    elseif strcmp(expName,'combined')
        targetAngles   = [-86.25, -82.5,-78.75,  -75,   -45,    0,    45,   75, 78.75, 82.5, 86.25,  90]';
        maxContrasts= [0.10,    0.08, 0.055, 0.06, 0.015, 0.01, 0.015, 0.04, 0.055, 0.08, 0.10, 0.09]';
    else
        error('Exp. code not known')
    end
else
    error('Subject not known')
end

targetContrast= zeros(nContrasts,length(maxContrasts));

for ii = 1:length(maxContrasts)
    targetContrast(:,ii) = linspace(maxContrasts(ii)/nContrasts,maxContrasts(ii),nContrasts);
end

