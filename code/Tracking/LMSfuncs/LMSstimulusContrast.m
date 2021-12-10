function MaxContrastLMS = LMSstimulusContrast(varargin)
%% Provide the stilumus conditions defined by cone contrasts
%
% Synopsis
%   MaxContrastLMS = LMSstimulusContrast(varargin)
%
% Description
%  This function smooths function data with the burred mask seperatly in
%  the left and right hemispere and combines the hemis.
%
% Inputs
%  none
%
% Key/val pairs
%  experiment:     A string that defines the particular set of LMS contrasts
%                  set as a case swtich.
%
% Output
%  MaxContrastLMS:

% BMC & MAB 09/--/21 -- started
% MAB       09/18/21 -- added cases to switch between experiments

% Input Parser
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addParameter('experiment','SLplane-Full', @ischar);
p.parse(varargin{:});

switch p.Results.experiment
    %% Set the stimulus conditions for a specfifc experiment here
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    Experiment-1 Stim     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'Experiment1-Pos'
        % l isolating
        [lIso]      = generateStimContrasts(0,0,expspace(.18,.02,6));
        % s isolating
        [sIso]      = generateStimContrasts(0,90,expspace(.85,.18,6));
        % L+S 45
        [lPlusS45]  = generateStimContrasts(0,45,expspace(.25,.03,6));
        % L-S 45
        [lMinS45]   = generateStimContrasts(0,-45,expspace(.26,.03,6));
        % L+S 75
        [lPlusS75]  = generateStimContrasts(0,75,expspace(.65,.06,6));
        % L-S 75
        [lMinS75]   = generateStimContrasts(0,-75,expspace(.78,.06,6));
        
        MaxContrastLMS = [lIso; sIso; lPlusS75; lMinS75; lPlusS45; lMinS45];
    case 'Experiment1-Neg'
        % l isolating
        [lIso]      = -1.*generateStimContrasts(0,0,expspace(.18,.02,6));
        % s isolating
        [sIso]      = -1.*generateStimContrasts(0,90,expspace(.85,.18,6));
        % L+S 45
        [lPlusS45]  = -1.*generateStimContrasts(0,45,expspace(.25,.03,6));
        % L-S 45
        [lMinS45]   = -1.*generateStimContrasts(0,-45,expspace(.26,.03,6));
        % L+S 75
        [lPlusS75]  = -1.*generateStimContrasts(0,75,expspace(.65,.06,6));
        % L-S 75
        [lMinS75]   = -1.*generateStimContrasts(0,-75,expspace(.78,.06,6));
        
        MaxContrastLMS = [lIso; sIso; lPlusS75; lMinS75; lPlusS45; lMinS45];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %    Experiment-2 Stim     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'Experiment2-Pos'
        % 78.75 degree
        [lPlusS78]      = generateStimContrasts(0,78.75,expspace(.83,.13,6));
        % 82.50 degree
        [lPlusS82]      = generateStimContrasts(0,82.5, expspace(.85,0.14,6));
        % 86.20 degree
        [lPlusS86]  = generateStimContrasts(0,86.2,     expspace(.85,0.18,6));
        % -78.75 degree
        [lMinS78]   = generateStimContrasts(0,-78.75,   expspace(.84,.13,6));
        % -82.50 degree
        [lMinS82]  = generateStimContrasts(0,-82.5,     expspace(.84,.15,6));
        % -86.20 degree
        [lMinS86]   = generateStimContrasts(0,-86.2,    expspace(.84,.18,6));
        
        MaxContrastLMS = [lPlusS78; lPlusS82; lPlusS86; lMinS78; lMinS82; lMinS86];
    case 'Experiment2-Neg'
        % 78.75 degree
        [lPlusS78]      = -1.*generateStimContrasts(0, 78.75, expspace(.83,.13,6));
        % 82.50 degree
        [lPlusS82]      = -1.*generateStimContrasts(0, 82.5,  expspace(.85,0.14,6));
        % 86.20 degree
        [lPlusS86]      = -1.*generateStimContrasts(0, 86.2,  expspace(.85,0.18,6));
        % -78.75 degree
        [lMinS78]       = -1.*generateStimContrasts(0,-78.75, expspace(.84,.13,6));
        % -82.50 degre
        [lMinS82]       = -1.*generateStimContrasts(0,-82.5,  expspace(.84,.15,6));
        % -86.20 degree
        [lMinS86]       = -1.*generateStimContrasts(0,-86.2,  expspace(.84,.18,6));
        
        MaxContrastLMS = [lPlusS78; lPlusS82; lPlusS86; lMinS78; lMinS82; lMinS86];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %           EXTRAS         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'directionCheck'
        [dir1] = generateStimContrasts(0,89.6,.85);%88.6
        
        [dir2] = generateStimContrasts(0,88.6,.85);
        
        [dir3] = generateStimContrasts(0,87.6,.85);
        
        [dir4] = generateStimContrasts(0,22.5,.19);
        
        [dir5] = generateStimContrasts(0,-1.4,.18);
        
        [dir6] = generateStimContrasts(0,-22.5,.19);
        
        [dir7] = generateStimContrasts(0,89.1,.85);
        
        [dir8] = generateStimContrasts(0,88.1,.85);
                
        [dir9] = generateStimContrasts(0,87.1,.85);
        
        [dir10] = generateStimContrasts(0,-0.9,.18);
        
        [dir11] = generateStimContrasts(0,-1.9,.18);
        
        MaxContrastLMS = [dir1; dir2; dir3; dir4; dir5; dir6; dir7; dir8; dir9; dir10; dir11];
        
        
    case 'SLplane-Min'
        % l isolating
        [lIso]      = generateStimContrasts(0,0,.02);
        % s isolating
        [sIso]      = generateStimContrasts(0,90,.20);
        % L+S
        [lPlusS] = generateStimContrasts(0,45,.03);
        % L-S
        [lMinS]  = generateStimContrasts(0,-45,.03);
        MaxContrastLMS = [lIso; sIso; lPlusS; lMinS];
    case 'SLplane-Max'
        % l isolating
        [lIso]      = generateStimContrasts(0,0,.19);
        % s isolating
        [sIso]      = generateStimContrasts(0,90,.91);
        % L+S
        [lPlusS] = generateStimContrasts(0,45,.27);
        % L-S
        [lMinS]  = generateStimContrasts(0,-45,.285);
        MaxContrastLMS = [lIso; sIso; lPlusS; lMinS];
end

end