function S = psyCollectResponse(S,t,chsIntrvl,magORval)

% function S = psyCollectResponse(S,t,chsIntrvl,magORval)
%
%   example call;   
%
% collect and code responses
%
% S             subject/stim structure
% t:            trial number
% chsIntrvl:    chosen interval
%               0 -> 1st interval chosen
%               1 -> 2nd interval chosen
% magORval:     string indicating whether correct response determined by
%               stim w larger (mag)nitude or more positive value
%               'mag' -> larger magnitude correct
%               'val' -> larger value correct     (default)
%%%%%%%%%%%%%%%%%%%
% S:            subject/stim structure updated with fields
%               .R          -> chose which interval?   [0 1]
%               .Rcorrect   -> chose correct interval? [0 1]
%               .RcmpChosen -> chose comparison?       [0 1]

if ~exist('magORval','var') || isempty(magORval) magORval = 'val'; end

% INTERVAL SELECTED?
S.R(t,1) = chsIntrvl;
% CHOSE COMPARISON?
S.RcmpChosen(t,1) = psyResponseCmpChosen(S.R(t,1),S.cmpIntrvl(t));
% CHOSE CORRECTLY?
S.Rcorrect(t,1)   = psyResponseCorrect(S.R(t,1),S.stdX(t),S.cmpX(t),S.cmpIntrvl(t),magORval);


