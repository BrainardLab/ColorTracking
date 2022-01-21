function negLL = psyfitgengaussNegLL(param,Xcmp,RcmpChs,mFix,sFix,bFix,nIntrvl)

% function negLL = psyfitgengaussNegLL(param,Xcmp,RcmpChs,mFix,sFix,bFix,nIntrvl)
%
%   example call:
%
% computes negative log likelihood
%
% param:          parameters for gengaussfunc
% Xcmp:           comparison values
% RcmpChs:        responses
%                 1 -> comparison chosen
%                 0 -> standard   chosen
% mFix:           fixed mean  parameter value
% sFix:           fixed sigma parameter value
% bFix:           fixed beta  parameter value
% nIntrvl:        number of intervals
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% negLL:          negative log-likelihood


if  exist('mFix','var')    && ~isempty(mFix)    param(1) = mFix; end
if  exist('sFix','var')    && ~isempty(sFix)    param(2) = sFix; end
if  exist('bFix','var')    && ~isempty(bFix)    param(3) = bFix; end
if ~exist('nIntrvl','var') ||  isempty(nIntrvl) nIntrvl  =    1; end
 
% NEGATIVE LOG LIKELIHOOD GIVEN BINOMIAL MODEL OF RESPONSE VARIABILITY
% negLL = -sum( Ncmp(:).*log(Pcmp(:)) + Nstd(:).*log(  Pstd(:)) );
% negLL = -sum( Ncmp(:).*log(Pcmp(:)) + Nstd(:).*log(1-Pcmp(:)) );

% NEW FUNCTION... ACCEPTS nIntrvl INPUT
negLL = -(sum(log(     psyfitgengaussfunc([],Xcmp(RcmpChs==1),param(1),param(2),param(3),[],nIntrvl) )) + ...
          sum(log( 1 - psyfitgengaussfunc([],Xcmp(RcmpChs==0),param(1),param(2),param(3),[],nIntrvl) )) );      


% OLD FUNCTION... DOES NOT ACCEPT nIntrvl INPUT
% negLL = -(sum(log(     psyfuncgengauss([],Xcmp(RcmpChs==1),param(1),param(2),param(3)) )) + ...
%           sum(log( 1 - psyfuncgengauss([],Xcmp(RcmpChs==0),param(1),param(2),param(3)) )) );
      
killer = 1;
