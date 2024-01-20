function [sigmaDeg, sigmaCpd] = bandwidthOct2sigma(f0cpd, BWoct)
  
% function [sigmaDeg, sigmaCpd] = bandwidthOct2sigma(f0cpd, BWoct)
%
%   example call: sigmaDeg = bandwidthOct2sigma(4, 1.5)
%
% see derivation in Proof_GaussianBandwidth_*.doc in ../VisionNotes/
% 
% returns the gaussian standard deviation in the space domain OR 
% in the frequency domain, given the carrier frequency and the 
% octave bandwidth of a gabor function 
%
% f0cpd:    carrier frequency in cycles/deg
% BWoct:    octave bandwidth is given by log2( fLo/fHi ) 
%           of the gabor's amplitude spectrum
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sigmaDeg: gaussian standard deviation in SPACE     domain (deg) 
% sigmaCpd: gaussian standard deviation in FREQUENCY domain (cpd) 
%
%             *** see sigma2bandwidthOct.m ***

% STANDARD DEVIATION IN FREQUENCY DOMAIN
sigmaCpd = f0cpd.*(2.^BWoct-1)./( sqrt(log(4)).*(2.^BWoct + 1) );

% STANDARD DEVIATION IN SPACE DOMAIN
sigmaDeg = 1./(2.*pi.*sigmaCpd);