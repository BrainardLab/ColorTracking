function [targetContrast,targetAngles] = getContrastLSD(subjName,expName)

% Corrected set to true returns stimulus values corrected for ambient light
% and back to T_cones_ss2, but no correction for display quantization.  See
% makeMonitorGamutFigure.  We ran that by hand with nBits = 20 for each
% subject and copied over the resulting mean stimuus angles and maximum
% contrasts.
CORRECTED = true;

nContrasts = 6;
if strcmp(subjName,'BMC')
    if strcmp(expName,'Exp1')
        if (~CORRECTED)
            targetAngles   = [-75, -45,0, 45, 75, 90];
            maxContrasts= ([0.04, 0.0125 ,0.01 ,0.0125,0.04,0.09])';
        else
            error('Need to tabulate corrected stimulus values for Exp1');
        end
    elseif strcmp(expName,'Exp2')
        if (~CORRECTED)
            targetAngles   = [-86.25, -82.5,-78.75, 78.75, 82.5, 86.25];
            maxContrasts= [0.10, 0.07, 0.05, 0.05, 0.07, 0.10]';
        else
            error('Need to tabulate corrected stimulus values for Exp2');
        end
    elseif strcmp(expName,'combined')
        if (~CORRECTED)
            targetAngles = [-86.25, -82.5,-78.75, -75, -45,0, 45, 75, 78.75, 82.5, 86.25, 90]';
            maxContrasts = [0.10, 0.07, 0.05, 0.04, 0.0125 ,0.01 ,0.0125, 0.04,0.05, 0.07, 0.10, 0.09]';
        else
            targetAngles = [ -86.1700  -82.3600  -78.5600  -74.7600  -44.5500   -0.0083   44.5633   74.7983   78.6000   82.4083   86.2100   90.0200];
            maxContrasts = [0.0968    0.0678    0.0484    0.0388    0.0122    0.0098    0.0122    0.0388    0.0484    0.0678    0.0968    0.0871];
        end
    else
        error('Exp. code not known')
    end
elseif strcmp(subjName,'MAB')
    if strcmp(expName,'Exp1')
        if (~CORRECTED)
            targetAngles   = [-75, -45,0, 45, 75, 90];
            maxContrasts = [0.06, 0.025, 0.0175, 0.02, 0.07, 0.18]';
        else
            error('Need to tabulate corrected stimulus values for Exp1');
        end
    elseif strcmp(expName,'Exp2')
        if (~CORRECTED)
            targetAngles   = [-86.25, -82.5,-78.75, 78.75, 82.5, 86.25];
            maxContrasts = [0.14, 0.10, 0.09, 0.07, 0.10, 0.18]';
        else
            error('Need to tabulate corrected stimulus values for Exp1');
        end
    elseif strcmp(expName,'combined')
        if (~CORRECTED)
            targetAngles   = [-86.25, -82.5,-78.75, -75,   -45,    0,    45,   75, 78.75, 82.5, 86.25, 90]';
            maxContrasts= [0.14,    0.10, 0.09, 0.06, 0.025, 0.0175, 0.02, 0.07, 0.07, 0.10, 0.18, 0.18]';
        else
            targetAngles = [-86.1700  -82.3600  -78.5600  -74.7617  -44.5533   -0.0233   44.5600   74.8000   78.6000   82.4083   86.2100   90.0200];
            maxContrasts = [0.1356    0.0969    0.0872    0.0582    0.0244    0.0172    0.0195    0.0678    0.0678    0.0968    0.1743    0.1743];
        end
    else
        error('Exp. code not known')
    end
elseif strcmp(subjName,'KAS')
    if strcmp(expName,'Exp1')
        if (~CORRECTED)
            targetAngles   = [-75, -45,0, 45, 75, 90];
            maxContrasts= [0.06, 0.015, 0.01, 0.015, 0.04, 0.09]';
        else
            error('Need to tabulate corrected stimulus values for Exp1');
        end
    elseif strcmp(expName,'Exp2')
        if (~CORRECTED)
            targetAngles   = [-86.25, -82.5,-78.75, 78.75, 82.5, 86.25];
            maxContrasts= [0.10, 0.08, 0.055, 0.055, 0.08, 0.10]';
        else
            error('Need to tabulate corrected stimulus values for Exp2');
        end
    elseif strcmp(expName,'combined')
        if (~CORRECTED)
            targetAngles   = [-86.25, -82.5,-78.75,  -75,   -45,    0,    45,   75, 78.75, 82.5, 86.25,  90]';
            maxContrasts= [0.10,    0.08, 0.055, 0.06, 0.015, 0.01, 0.015, 0.04, 0.055, 0.08, 0.10, 0.09]';
        else
            targetAngles = [-86.1700  -82.3600  -78.5600  -74.7617  -44.5567   -0.0083   44.5617   74.7983   78.6017   82.4083   86.2100   90.0200];
            maxContrasts = [0.0968    0.0775    0.0533    0.0582    0.0146    0.0098    0.0146    0.0388    0.0533    0.0775    0.0968    0.0871];
        end 
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

