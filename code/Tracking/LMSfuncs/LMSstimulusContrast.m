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
    case 'SLplane-Full'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %    Experiment-1 Stim     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
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