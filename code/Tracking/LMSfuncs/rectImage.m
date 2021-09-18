function I = rectImage(PszXY,TszXY,TctrXY,bPLOT)

% function I = rectImage(PszXY,TszXY,TctrXY,bPLOT)
%
%   example call: rectImage([500 500],[100 200],[0 0],1);
%
% create rectangle with arbitrary dimensions and center with values 0 and 1
%
% PszXY:  patch size in pixels          [1 x 2]
% TszXY:  rect size  in pixels          [1 x 2]
% TctrXY: circle center in pixels       [1 x 2]
% bPLOT:  plot or not
% %%%%%%%%%%%%%%%%%%
% I:      rect image

if ~exist('TctrXY','var') || isempty(TctrXY) TctrXY = [0 0]; end
if ~exist('bPLOT','var')  || isempty(bPLOT)  bPLOT  =  0; end
if numel(TctrXY) == 1, error(['rectImage: WARNING! invalid TctrXY=' num2str(TctrXY) '. Must be [1 x 2]']); end

if size(PszXY,1) == 1 && size(PszXY,2) == 1
    [X,Y] = meshgrid(smpPos(1,PszXY));
elseif size(PszXY,1) == 1 && size(PszXY,2) > 1
    [X,Y] = meshgrid(smpPos(1,PszXY(1)),smpPos(1,PszXY(2)));
end

% R = sqrt((X-TctrXY(1)).^2 + (Y-TctrXY(2)).^2);

I = zeros(fliplr(PszXY));

indX = X(1,:)-TctrXY(1) > -TszXY(1)/2 & X(1,:)-TctrXY(1) <= TszXY(1)/2;
indY = Y(:,1)-TctrXY(2) > -TszXY(2)/2 & Y(:,1)-TctrXY(2) <= TszXY(2)/2;
I(indY',indX) = 1;

if bPLOT
   figure; 
   imagesc(X(1,:),Y(:,1)',I); 
   axis image; 
   formatFigure([],[],['TszXY=' num2str(TszXY(1)) 'x' num2str(TszXY(2)) 'pix']);
   axis xy
end