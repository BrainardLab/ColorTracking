function [a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,modelType)

% function [a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,modelType)
%
%   example calls: % GAUSSIAN FIT
%                  [a1,m1,s1,d1] = xcorrFitMLEparamUnpack(rParam,'GSS')
%                  % LOG-GAUSSIAN FIT
%                  [a1,m1,s1,d1] = xcorrFitMLEparamUnpack(rParam,'LGS')
%                  % ASSYMETRIC GAUSSIAN FIT
%                  [a1,m1,s1,d1 ~, ~,s2,d2] = xcorrFitMLEparamUnpack(rParam,'AGS')  
%                  % MIXTURE OF GAUSSIAN AND LOG-GAUSSIAN
%                  [a1,m1,s1,d1,a1,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,'GLG')  
%                  % MIXTURE OF TWO GAUSSIANS FIT
%                  [a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,'GS2')    
%                  % MIXTURE OF TWO LOG-GAUSSIANS FIT
%                  [a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,'LG2')    
%                  % GAMMA FIT W. DELAY
%                  [a1,m1,s1,d1] = xcorrFitMLEparamUnpack(rParam,'GMA')    
%                  % MIXTURE OF TWO GAMMAS W. DELAY
%                  [a1,m1,s1,d1,a2,m2,s2,d2] = xcorrFitMLEparamUnpack(rParam,'GM2')  
%
% rParam:   parameter vector
% modelType:  type of  xcorr function
%          'GSS' -> gaussian
%          'LGS' -> log-gaussian
%          'AGS' -> assymetric gaussian
%          'GLG' -> gaussian + log-gaussian
%          'GS2' -> mixture of two gaussians
%          'LG2' -> mixture of two log-gaussians
%          'GMA' -> gammas w. delay
%          'GM2' -> mixture of two gammas w. delays
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a1:       amplitude of function 1
% m1:       mean      of function 1 (or tau param... if GMA or GM2)
% s1:       std dev   of function 1 (or shp param... if GMA or GM2)
% d1:       delay     of function 1 
% a2:       amplitude of function 2 
% m2:       mean      of function 2
% s2:       std dev   of function 2
% d1:       delay     of function 2 

if strcmp(modelType,'GSS')
    % UNPACK PARAMETERS
    a1 = rParam(1); m1 = rParam(2); s1 = rParam(3); d1 = [];
    a2 = [];        m2 = [];        s2 = [];      ; d2 = [];
elseif strcmp(modelType,'LGS')
    a1 = rParam(1); m1 = rParam(2); s1 = rParam(3); d1 = [];
    a2 = [];        m2 = [];        s2 = [];        d2 = [];
%     a1 = rParam(1); m1 = rParam(2); s1 = rParam(3); d1 = rParam(4);
%     a2 = [];        m2 = [];        s2 = [];        d2 = [];
elseif strcmp(modelType,'AGS')
    % UNPACK PARAMETERS
    a1 = rParam(1); m1 = rParam(2); s1 = rParam(3); d1 = [];
    a2 = [];        m2 = [];        s2 = rParam(4); d2 = [];
elseif strcmp(modelType,'GLG')
    % UNPACK PARAMETERS
    a1 = rParam(1); m1 = rParam(2); s1 = rParam(3); d1 = [];
    a2 = rParam(4); m2 = rParam(5); s2 = rParam(6); d2 = [];
elseif strcmp(modelType,'GS2')
    % UNPACK PARAMETERS
    a1 = rParam(1); m1 = rParam(2); s1 = rParam(3); d1 = [];
    a2 = rParam(4); m2 = rParam(5); s2 = rParam(6); d2 = [];
elseif strcmp(modelType,'LG2') 
    % UNPACK PARAMETERS
    a1 = rParam(1); m1 = rParam(2); s1 = rParam(3); d1 = [];
    a2 = rParam(4); m2 = rParam(5); s2 = rParam(6); d2 = [];
elseif strcmp(modelType,'GMA')
    % UNPACK PARAMETERS
    a1 = rParam(1); m1 = rParam(2); s1 = rParam(3); d1 = rParam(4);
    a2 = [];        m2 = [];        s2 = [];        d2 = [];        
elseif strcmp(modelType,'GM2')
    % UNPACK PARAMETERS
    a1 = rParam(1); m1 = rParam(2); s1 = rParam(3); d1 = rParam(4);
    a2 = rParam(5); m2 = rParam(6); s2 = rParam(7); d2 = rParam(8);
else
    error(['xcorrFitMLMEparamUnpack: WARNING! unhandled modelType=' modelType]);
end
