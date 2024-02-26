function psyPTBgammaCorrectSetup(gammaCorrectType)

% function psyPTBgammaCorrectSetup(gammaCorrectType)
%
%   example call: % STANDARD GAMMA CORRECTION (MODIFY IMAGE DATA B4 PRESENTATION) 
%                   psyPTBgammaCorrectSetup('LookupTable')
%
%                  % SIMPLE     GAMMA CORRECTION (POWER OF POWER-FUNCTION)
%                   psyPTBgammaCorrectSetup('SimpleGamma')
%
%                   % STANDARD GAMMA CORRECTION (NOT WORKING)
%                   psyPTBgammaCorrectSetup('Standard')
%
% sets up psychtoolbox gamma correction strategy 
%
% gammaCorrectType: selects method for correcting monitor gamma function
%                   'SimpleGamma' -> inverse gamma function 
%                   'LookupTable' -> lookup table
%                   
%              *** see psyPTBgammaCorrect.m ***

if strcmp(gammaCorrectType,'LookupTable')
    % LOOKUP TABLE
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'LookupTable');
elseif strcmp(gammaCorrectType,'Standard')
    % STANDARD GAMMA CORRECTION APPLIES INVERSE MONITOR GAMMA TO IMAGE DATA DIRECTLY BEFORE PRESENTATION
    error(['psyPTBgammaCorrectSetup: WARNING! gammaCorrectType = ' num2str(gammaCorrectType) ' not working and not tested']);
elseif strcmp(gammaCorrectType,'SimpleGamma')
    % GAMMA FUNCTION EXPONENT
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
else
    error(['psyPTBsetup: WARNING! unhandled gammaCorrectionType. gamCrctType=' gammaCorrectType]);
end
