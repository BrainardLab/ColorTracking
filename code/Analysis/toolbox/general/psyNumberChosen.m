function [N1,N0,N] = psyNumberChosen(Xstd,Xcmp,RcmpChs)

% function [N1,N0,N] = psyNumberChosen(Xstd,Xcmp,RcmpChs)
%
%   example call: % EXAMPLE CALL 1               
%                 [N1,N0,N] = psyNumberChosen(S.nseRMS,S.tgtRMS,S.R==S.cmpIntrvl) 
%
%                 % EXAMPLE CALL 2               
%                 [N1,N0,N] = psyNumberChosen(S.stdX,S.cmpX,S.R==S.cmpIntrvl) 
%
% number chosen from raw psychometric data
%
% Xstd:     standard   values                     [ nTrl x 1 ]
% Xcmp:     comparison values                     [ nTrl x 1 ]
% RcmpChs:  response vector                       [ nTrl x 1 ]   
%           1 -> cmp chosen
%           0 -> std chosen
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% N1:       number  cmp chosen  by condition   [ nCmp x nStd ]
% N0:       number  std chosen  by condition   [ nCmp x nStd ]
% N:        total number trials by condition   [ nCmp x nStd ]

% INPUT HANDLING: HANDLES CASE WHERE Xstd IS A SCALAR
if numel(Xstd) == 1 && numel(Xcmp) > 1 
    Xstd = repmat(Xstd,size(Xcmp)); 
end

% STANDARD VALUES
XstdUnq = unique(Xstd);

% LOOP OVER STANDARDS
for s = 1:length(XstdUnq)
    % INDICES FOR EACH STANDARD
    indS = Xstd == XstdUnq(s);
    % COMPARISON VALUES
    XcmpUnq(:,s) = unique(Xcmp(indS));
    % LOOP OVER COMPARISONS
    for c = 1:length(XcmpUnq(:,s))
        % INDICES IN STD / CMP CONDITION
        indCnd  = Xstd==XstdUnq(s) & Xcmp==XcmpUnq(c,s);
        % TOTAL NUMBER OF TRIALS IN CONDITION
        N(c,s)  = sum( indCnd );
        % TOTAL NUMBER OF CMP CHOSEN IN CONDITION
        N1(c,s) = sum( RcmpChs(indCnd)==1 );
        % TOTAL NUMBER OF STD CHOSEN IN CONDITION
        N0(c,s) = sum( RcmpChs(indCnd)==0 );
    end
end