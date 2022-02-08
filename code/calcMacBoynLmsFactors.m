function [LMSfactors] = calcMacBoynLmsFactors(T_cones,T_lum)
% Examples:
%{
load T_cones_ss2
load T_CIE_Y2
%}

% Find the factors such that:
%   factorsLM(1)*T_cones(1,:) + factorsLM(2)*T_cones(2,:)= T_lum
factorsLM = (T_cones(1:2,:)'\T_lum');
% Find the factor S
factorS = 1/max(T_cones(3,:)./(factorsLM(1)*T_cones(1,:) + factorsLM(2)*T_cones(2,:)));

LMSfactors = [factorsLM,factorS];