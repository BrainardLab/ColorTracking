function [PCdta,XstdUnq,XcmpUnq] = psyPercentChosen(Xstd,Xcmp,RcmpChs)

% function [PCdta,XstdUnq,XcmpUnq] = psyPercentChosen(Xstd,Xcmp,RcmpChs)
%
%   example call: % EXAMPLE CALL 1
%                 [PCdta,XstdUnq,XcmpUnq] = psyPercentChosen(S.stdX,S.cmpX,S.R==S.cmpIntrvl)
%
%                 % EXAMPLE CALL 2 
%                 [PCdta,XstdUnq,XcmpUnq] = psyPercentChosen(S.nseRMS,S.tgtRMS,S.RcmpChosen) 
%
% percent correct from raw psychometric data
%
% NOTE! assumes equal number of cmp values at each standard
%
% Xstd:     standard   values                     [ nTrl x 1 ]
% Xcmp:     comparison values                     [ nTrl x 1 ]
% RcmpChs:  response vector                       [ nTrl x 1 ]
%           1 -> cmp chosen
%           0 -> std chosen
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PCdta:    percent cmp chosen  by condition      [ nCmp x nStd ]
% XstdUnq:  unique  std values                    [  1   x nStd ]
% XcmpUnq:  unique  cmp values  for each standard [ nCmp x nStd ]

% INPUT HANDLING: HANDLES CASE WHERE Xstd IS A SCALAR
if numel(Xstd) == 1 && numel(Xcmp) > 1 
    Xstd = repmat(Xstd,size(Xcmp)); 
end

% STANDARD VALUES
XstdUnq = unique(Xstd(:))';
% LOOP OVER STANDARDS
for s = 1:length(XstdUnq)
    % INDICES FOR EACH STANDARD
    indS = Xstd == XstdUnq(s);
    % COMPARISON VALUES
    XcmpUnq(:,s) = unique(Xcmp(indS));
end

% NUMBER CHOSEN
[N1,~,N]=psyNumberChosen(Xstd,Xcmp,RcmpChs);

% PERCENT CHOSEN
PCdta = N1./N;
