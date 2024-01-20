function [upperCI, lowerCI] = computeCiFromBootSruct(bootParamsStruct, CIint)
% Computes the confidence intervals for thne lags from a given percentile
%
% Syntax:
%    [upperCI, lowerCI] = computeCiFromBootSruct(bootParamsStruct, CIint)
%
% Description: Takes struct of bootstrap params from cacheDataForSubj.m and
%    from the rParamsBtstrpStruct saved variable computes the CI. 
%
% Inputs:
%    bootParamsStruct  - struct of bootstrap iteration parameters
%    CIint             - Confidence interval percentile
%
% Outputs:
%    upperCI           - the upper confidence interval
%    lowerCI           - the lower confidence interval
%
% Optional key/value pairs:
%    None

% MAB & BMC 12/20/21
upperCI = [];
lowerCI = [];
for ii = 1:length(bootParamsStruct)
    rParamsBtstrp = bootParamsStruct(ii).rParamsBtstrp;
    lagsBtstrp = flipud(squeeze(rParamsBtstrp(2,:,:,:)));
    
    CIrange = [(100-CIint)/2, CIint+((100 - CIint)/2)];
    ciBtstrpLag = prctile(lagsBtstrp,CIrange,2);
    
    upperCI = [upperCI,squeeze(ciBtstrpLag(:,2,:))];
    lowerCI = [lowerCI,squeeze(ciBtstrpLag(:,1,:))];
    
end


end