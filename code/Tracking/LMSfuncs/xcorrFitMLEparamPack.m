function [rParam] = xcorrFitMLEparamPack(a1,m1,s1,d1,a2,m2,s2,d2,modelType)

% function [rParam] = xcorrFitMLEparamPack(a1,m1,s1,d1,a2,m2,s2,d2,modelType)
%
%   example calls: % GAUSSIAN FIT
%                  [rParam] = xcorrFitMLEparamPack(a1,m1,s1,d1,'GSS')
%                  % MIXTURE OF TWO GAUSSIANS FIT
%                  [rParam] = xcorrFitMLEparamPack(a1,m1,s1,d1,a2,m2,s2,d2,'GS2') 
%                  % LOG-GAUSSIAN FIT
%                  [rParam] = xcorrFitMLEparamPack(a1,m1,s1,d1,'LGS')
%                  % MIXTURE OF GAUSSIAN AND LOG-GAUSSIAN
%                  [rParam] = xcorrFitMLEparamPack(a1,m1,s1,[],a1,m2,s2,[],'GLG')     
%                  % ASSYMETRIC GAUSSIAN FIT
%                  [rParam] = xcorrFitMLEparamPack(a1,m1,s1,[],[],s2,[],'AGS')  
%                  % MIXTURE OF TWO LOG-GAUSSIANS FIT
%                  [rParam] = xcorrFitMLEparamPack(a1,m1,s1,d1,a2,m2,s2,d2,'LG2')    
%                  % GAMMA FIT W. DELAY
%                  [a1,m1,s1,d1] = xcorrFitMLEparamPack(a1,m1,s1,d1,[],[],[],[],'GMA')    
%                  % MIXTURE OF TWO GAMMAS W. DELAY
%                  [rParam] = xcorrFitMLEparamPack(a1,m1,s1,d1,a2,m2,s2,d2,'GM2')  
%
% modelType:  type of  xcorr function
%          'GSS' -> gaussian
%          'LGS' -> log-gaussian
%          'AGS' -> assymetric gaussian
%          'GLG' -> gaussian + log-gaussian
%          'GS2' -> mixture of two gaussians
%          'LG2' -> mixture of two log-gaussians
%          'GMA' -> gammas w. delay
%          'GM2' -> mixture of two gammas w. delays
% a1:       amplitude of function 1
% m1:       mean      of function 1 (or tau param... if GMA or GM2)
% s1:       std dev   of function 1 (or shp param... if GMA or GM2)
% d1:       delay     of function 1 
% a2:       amplitude of function 2 
% m2:       mean      of function 2
% s2:       std dev   of function 2
% d1:       delay     of function 2 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rParam:   parameter vector

if strcmp(modelType,'GSS')
    % UNPACK PARAMETERS
    rParam(1) = a1; rParam(2) = m1; rParam(3) = s1; d1 = [];
    a2 = [];        m2 = [];        s2 = [];        d2 = [];
elseif strcmp(modelType,'LGS')
    rParam(1) = a1; rParam(2) = m1; rParam(3) = s1; d1 = [];
    a2 = [];        m2 = [];        s2 = [];        d2 = [];
%     rParam(1) = a1; rParam(2) = m1; rParam(3) = s1; rParam(4) = d1;
%     a2 = [];        m2 = [];        s2 = [];        d2 = [];
elseif strcmp(modelType,'AGS')
    % UNPACK PARAMETERS
    rParam(1) = a1; rParam(2) = m1; rParam(3) = s1; d1 = [];
    a2 = [];        m2 = [];        rParam(4) = s2; d2 = [];
elseif strcmp(modelType,'GLG')
    % UNPACK PARAMETERS
    rParam(1) = a1; rParam(2) = m1; rParam(3) = s1; d1 = [];
    rParam(4) = a2; rParam(5) = m2; rParam(6) = s2; d2 = [];
elseif strcmp(modelType,'GS2')
    % UNPACK PARAMETERS
    rParam(1) = a1; rParam(2) = m1; rParam(3) = s1; d1 = [];
    rParam(4) = a2; rParam(5) = m2; rParam(6) = s2; d2 = [];
elseif strcmp(modelType,'LG2') 
    % UNPACK PARAMETERS
    rParam(1) = a1; rParam(2) = m1; rParam(3) = s1; d1 = [];
    rParam(4) = a2; rParam(5) = m2; rParam(6) = s2; d2 = [];
elseif strcmp(modelType,'GMA')
    % UNPACK PARAMETERS
    rParam(1) = a1; rParam(2) = m1; rParam(3) = s1; rParam(4) = d1;
    a2 = [];        m2 = [];        s2 = [];        d2 = [];        
elseif strcmp(modelType,'GM2')
    % UNPACK PARAMETERS
    rParam(1) = a1; rParam(2) = m1; rParam(3) = s1; rParam(4) = d1;
    rParam(5) = a2; rParam(6) = m2; rParam(7) = s2; rParam(8) = d2;
else
    error(['xcorrFitMLMEparamUnpack: WARNING! unhandled modelType=' modelType]);
end
