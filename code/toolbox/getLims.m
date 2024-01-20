function [xlims ylims zlims] = getLims(dim)

% function [xlims ylims zlims] = getLims(dim)
%
%   x, y, and z axis limits of gca
% 
% dim: 1 -> returns x lims, 
%      2 -> returns y lims, 
%      3 -> returns z lims
%      [] or ~exist -> returns xlims, ylims, and zlims

if nargin < 1
    dim = 1;
end
if dim == 1
    xlims = [min(get(gca,'xlim')) max(get(gca,'xlim'))];
    ylims = [min(get(gca,'ylim')) max(get(gca,'ylim'))];
    zlims = [min(get(gca,'zlim')) max(get(gca,'zlim'))];
elseif dim == 2
    xlims = [min(get(gca,'ylim')) max(get(gca,'ylim'))];
elseif dim == 3
    xlims = [min(get(gca,'zlim')) max(get(gca,'zlim'))];
else
    error(['getLims: dim value (' num2str(dim) ') invalid']);
end