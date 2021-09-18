function I = circleImage(PszXY,radius,PctrXY,bPLOT)

% function I = circleImage(PszXY,radius,PctrXY,bPLOT)
%
%   example call: circleImage([500 500],200,[0 0],1);
%
% create circle with arbitrary radius and center with values 0 and 1
%
% PszXY:  patch size in pixels          [1 x 2]
% radius: radius in pixels
% PctrXY: circle center in pixels       [1 x 2]
% bPLOT:  plot or not
% %%%%%%%%%%%%%%%%%%
% I:      circle image

if ~exist('PctrXY','var') || isempty(PctrXY) PctrXY = [0 0]; end
if ~exist('bPLOT','var')  || isempty(bPLOT)  bPLOT  =  0; end
if numel(PctrXY) == 1, error(['circleImage: WARNING! invalid PctrXY=' num2str(PctrXY) '. Must be [1 x 2]']); end

if size(PszXY,1) == 1 && size(PszXY,2) == 1
    [X,Y] = meshgrid(smpPos(1,PszXY));
elseif size(PszXY,1) == 1 && size(PszXY,2) > 1
    [X,Y] = meshgrid(smpPos(1,PszXY(1)),smpPos(1,PszXY(2)));
end
R = sqrt((X-PctrXY(1)).^2 + (Y-PctrXY(2)).^2);

I = zeros(fliplr(PszXY));
I(R <= radius) = 1;

if bPLOT
   figure; 
   imagesc(I); 
   axis image; 
   formatFigure([],[],['Radius=' num2str(radius) 'pix']);
   axis xy
end