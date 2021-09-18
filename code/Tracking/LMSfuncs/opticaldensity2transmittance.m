function T = opticaldensity2transmittance(OD,bPLOT)

% function T = opticaldensity2transmittance(OD,bPLOT)
%
%   example call: T=opticaldensity2transmittance(0:.01:1,1);
%
% convert optical density to transmittance
%
% OD:    optical density 
% bPLOT: plot or not
%        1 -> plot
%        0 -> not
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% T:     transmittance, the proportion of transmitted light 
%        through filter with the specified optical density
%
%        *** see transmittance2opticaldensity.m ***

% INPUT HANDLING
if ~exist('bPLOT','var') || isempty(bPLOT) bPLOT = 0; end

% TRANSMITTANCE
T = 10.^(-OD);

if bPLOT == 1
   if numel(OD)<=1
       disp(['opticaldensity2transmittance: WARNING! ']);
   else
       figure;
       plot(OD,T,'k','linewidth',2);
       formatFigure('Optical Density','Transmittance');
       axis square;
   end
end