function y = gammaGenerate(x,a,m,s,d)

% function y = gammaGenerate(x,a,m,s,d)
%
% example call: 
%
% generates a gamma distribution
%
% x: x values                               [nSamplesInTime x nInstancesOfDistribution]
% a: amplitude                              [1 x nInstancesOfDistribution]
% m: one of the gamma-specific parameters   [1 x nInstancesOfDistribution]
% s: the other gamma-specific parameter     [1 x nInstancesOfDistribution]
% d: delay                                  [1 x nInstancesOfDistribution]

    y =  a.*( ( ((x-d).^(s-1))./(m.^s) )./gamma(s) ) .* exp(-(x-d)./m) ;  
    % ACCOUNT FOR THE FACT THAT THE GAMMA DISTRIBUTION TENDS TOWARDS
    % VERY LARGE UNSTABLE VALUES AT NEGATIVE VALUES OF X
    y(x-d < 0)=0;
end