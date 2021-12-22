function Rcorrect = psyResponseCorrect(R,stdX,cmpX,cmpIntrvl,magORval)

% function Rcorrect = psyResponseCorrect(R,stdX,cmpX,cmpIntrvl,magORval)
% 
%   example call: psyResponseCorrect(1,5,10,1)
%
% codes whether a given response was correct (1) or not (0)
%
% R:          response interval chosen
%             0 -> 1st interval satisfied task (e.g. which interval faster)
%             1 -> 2nd interval satisfied task (e.g. which interval faster)
% stdX:       standard   value of task relevant variable 
% cmpX:       comparison value of task relevant variable 
% cmpIntrvl:  interval in which comparison was shown
%             0 -> 1st interval showed comparison
%             1 -> 2nd interval showed comparison
% bMagnitude: codes whether correct response determined by magnitude
%             or by which stimulus has a more positive value
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rcorrect:   response correct or incorrect
%             0 -> response incorrect
%             1 -> response incorrect

if ~exist('magORval','var') || isempty(magORval) magORval = 'val'; end

if strcmp(magORval,'mag')
    cmpX = abs(cmpX);
    stdX = abs(stdX);
elseif ~strcmp(magORval,'val')
    error(['psyResponseCorrect: WARNING! unhandled magORval=' num2str(magORval)]);
end

if      (cmpX > stdX)
    % CMP VALUE GREATER THAN STD VALUE
    if      cmpIntrvl == 1 && R == 1, Rcorrect = 1;
    elseif  cmpIntrvl == 0 && R == 0, Rcorrect = 1;
    elseif  cmpIntrvl == 1 && R == 0, Rcorrect = 0;
	elseif  cmpIntrvl == 0 && R == 1, Rcorrect = 0;
    else    error(['psyResponseCorrect: WARNING! unhandled condition. R=' num2str(R) ', cmpIntrvl=' num2str(cmpIntrvl) '. Write code?']);
    end
elseif  (cmpX < stdX)
    % CMP VALUE   LESS  THAN STD VALUE
    if      cmpIntrvl == 0 && R == 1, Rcorrect = 1;
    elseif  cmpIntrvl == 1 && R == 0, Rcorrect = 1;
    elseif  cmpIntrvl == 1 && R == 1, Rcorrect = 0;
	elseif  cmpIntrvl == 0 && R == 0, Rcorrect = 0;
    else    error(['psyResponseCorrect: WARNING! unhandled condition. R=' num2str(R) ', cmpIntrvl=' num2str(cmpIntrvl) '. Write code?']);
    end
elseif  cmpX == stdX
    % ASSIGN CORRECT RANDOMLY ('correct' answer not well-defined)
    Rcorrect = rand>0.5;
else
    error('psyResponseCorrect: WARNING! unhandled scenario. Write code?');
end