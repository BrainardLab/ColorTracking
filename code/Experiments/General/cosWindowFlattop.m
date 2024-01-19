function W = cosWindowFlattop(WszRC,dskDmPix,rmpDmPix,bSym,bPLOT)

% function W = cosWindowFlattop(WszRC,dskDmPix,rmpDmPix,bSym,bPLOT)
% 
%   example call: w = cosWindowFlattop([300 500],96,32,1,1)
%
% build cosine window with a flatop
% 
% WszRC:    size of window in X, Y
% dskDmPix:      diameter of disk (flattop) in pixels
% rmpDmPix: diameter of ramp in pixels (i.e. twice the ramp radius)
% bSym:          if numPix is even, boolean to make symmetric flattop cos
%                window profile on either side of zero
% %%%%%%%%%%%%%%%%%%%
% W:             flattop cosine window
%       ______
%      /      \
%     /        \
% ___/          \___
%

% if length(numPix)==1
%    numPix = numPix*ones(1,2); 
% end

numPix = max(WszRC); 

if dskDmPix + rmpDmPix > numPix(1)
   disp(['cosWindowFlattop: WARNING! disk + ramp radius exceeds image size']);
end
if ~exist('bSym','var') || isempty(bSym)
    bSym = 0;
end
if ~exist('bPLOT','var') || isempty(bPLOT)
   bPLOT = 0; 
end


% CONVERT DIAMETER TO RADIUS
dskRadiusPix = dskDmPix/2;
rmpRadiusPix = rmpDmPix/2;

% MESHGRID LOCATIONS
if bSym == 0
    [X Y] = meshgrid(samplePositions(1,numPix));
elseif bSym == 1 && mod(numPix,2)==0
    x = samplePositions(1,numPix);
    x = x+diff(x(1:2))/2;
    [X Y] = meshgrid(x); 
else
    error(['cosWindowFlattop: WARNING! unhandled bSym and numPix values']);
end
x = X(1,:);
R = sqrt(X.^2 + Y.^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD FLATTOP COSINE WINDOW %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
W = ones(numPix);
% MAKE RAMP
freqcpp = 1./(2*rmpRadiusPix); % cycles per pixel
W(R>dskRadiusPix) = 0.5.*(1 + cos(2.*pi.*freqcpp*(R(R>dskRadiusPix)-dskRadiusPix)));
% SET VALUES OUTSIDE OF RAMP TO ZERO
W(R>(dskRadiusPix+rmpRadiusPix))= 0;

W = cropImage(W,[],fliplr(WszRC));
X = cropImage(X,[],fliplr(WszRC));
Y = cropImage(Y,[],fliplr(WszRC));
if bPLOT
   figure('position',[680   666   805   368]); 
   subplot(1,2,1)
   imagesc(X(1,:),Y(:,1)',W);
   axis square
   formatFigure([],[],'2D');
   % set(gca,'xtick',get(gca,'ytick'))

   
   subplot(1,2,2)
   plot(X(floor(size(W,1)/2+1),:) , W(floor(size(W,1)/2+1),:),'k','linewidth',2)
   axis square;
   axis([minmaxLocal(X) -.1 1.1]);
   formatFigure([],[],'1D');
end
