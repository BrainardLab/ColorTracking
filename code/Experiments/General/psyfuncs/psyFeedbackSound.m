function psyFeedbackSound(Rcorrect)

% function psyFeedbackSound(Rcorrect)
%
%   example call: % PLAY  CORRECT  SOUND
%                   psyFeedbackSound(1)
%
%                 % PLAY INCORRECT SOUND
%                   psyFeedbackSound(0)
%
% plays sound as feedback depending on whether response was corerct
%
% Rcorrect: response correct variable
%           1 -> response correct
%           0 -> response correct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Rcorrect == 1;
    soundCorrect();
elseif Rcorrect == 0;
    soundIncorrect();
end