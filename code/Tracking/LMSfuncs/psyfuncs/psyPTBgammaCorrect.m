function D = psyPTBgammaCorrect(D)

% function psyPTBgammaCorrect(D)
%
%   example call: 
% 
% correct gamma for gamma lookup table
%
% D:        display structure
%             .gammaCorrectionType
%%%%%%%%%%%%%%%%
% D:        updated display sutrcture
% 
%  *** See psyPTBgammaCorrectSetup.m ***

if strcmp(D.gammaCorrectionType,'LookupTable');
    % LOOKUP TABLE
    PsychColorCorrection('SetLookupTable', D.wdwPtr, D.gamInv);
elseif strcmp(D.gammaCorrectionType,'SimpleGamma');
     % SIMPLE GAMMA
    PsychColorCorrection('SetEncodingGamma', D.wdwPtr, 1./D.gamFncExponent);
    disp(['PsychColorCorrection: WARNING! correcting gamma via SimpleGamma. This is not advised!']);
elseif strcmp(D.gammaCorrectionType,'Standard');
    error(['psyPTBgammaCorrect: WARNING! unhandled D.gammaCorrectionType: ' D.gammaCorrectionType '. Write Code!?!']); 
else
    error(['psyPTBgammaCorrect: WARNING! unhandled D.gammaCorrectionType: ' D.gammaCorrectionType ]); 
end

disp(['psyPTBgammaCorrect: Using ' D.gammaCorrectionType ' to correct gamma']);