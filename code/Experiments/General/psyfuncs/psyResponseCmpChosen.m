function RcmpChosen = psyResponseCmpChosen(R,cmpIntrvl)

% function RcmpChosen = psyResponseCmpChosen(R,cmpIntrvl)
% 
%   example call: psyResponseCmpChosen(1,5,10,1)
%
% codes whether the comparison was chosen (1) or not (0)
%
% R:         response interval chosen
%            0 -> 1st interval satisfied task (e.g. which interval faster)
%            1 -> 2nd interval satisfied task (e.g. which interval faster)
% cmpIntrvl: interval in which comparison was shown
%            0 -> 1st interval showed comparison
%            1 -> 2nd interval showed comparison
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RcmpChosen:  response correct or incorrect
%            0 -> response incorrect
%            1 -> response incorrect

% INPUT HANDLING
if         R ~= 0 &&         R~= 1, error(['psyResponseCmpChosen: WARNING! unhandled response   interval. R='         num2str(R)        ]); end
if cmpIntrvl ~= 0 && cmpIntrvl~= 1, error(['psyResponseCmpChosen: WARNING! unhandled comparison interval. cmpIntrvl=' num2str(cmpIntrvl)]); end

% EFFICIENT BUT HARDER TO READ
% RcmpChosen = R == cmpInterval;

% LESS EFFICIENT, BUT EASIER TO READ
if R == cmpIntrvl
    RcmpChosen = 1;
elseif R ~= cmpIntrvl
    RcmpChosen = 0; 
end
