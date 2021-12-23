function [P,PcrdRC] = cropImage(I,PcrdRC,PszXY,indChnl,bPLOT)

% function [P,PcrdRC] = cropImage(I,PcrdRC,PszXY,indChnl,bPLOT)
%
%   example call: % CROP IMAGE AND VIEW IT
%                 P = cropImage(I,[475 1625],[128 128],[1],1); 
% 
%                 % COMPARE COLOR CHANNELS OF CROPPED IMAGE  
%                 P = cropImage(I,[875 1625],[128 128],[],1); 
% 
% crops patch from image based input coordinates in row-column form 
% specifying the upper left corner of a patch of size PszXY
%
% I:                full size image or image sequence
%                   [n x m x 1]     -> gray scale image
%                   [n x m x 3]     -> full color image
%                   [n x m x 1 x t] -> gray scale movie
% PcrdRC:           patch coordinates (row, column) of 
%                   upper left hand corner of patch
%                   [] -> defaults to center pixel
% PszXY:            patch size in pixels [1x2] vector storing X,Y sizes
%                   [] -> defaults to full image 
% indChnl:          color channel index
%                   [] -> defaults to all channels
% bPLOT:            plot or not
%                   1 -> plot
%                   0 -> not
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P:                image patch
% PcrdRC:           patch coordinates

% 
if ~exist('PszXY','var')  || isempty(PszXY)    PszXY = [size(I,2) size(I,1)]; end   
if length(PszXY) == 1                          PszXY = [PszXY PszXY];         end
if ~exist('PcrdRC','var') || isempty(PcrdRC) 
                                               PcrdRC(1) = ceil((size(I,1) - PszXY(2))/2 + 1);
                                               PcrdRC(2) = ceil((size(I,2) - PszXY(1))/2 + 1);
end
if ~exist('indChnl','var') || isempty(indChnl) indChnl = 1:size(I,3);         end
if ~exist('bPLOT','var')   || isempty(bPLOT)   bPLOT = 0;                     end
% CROP IMAGE
try
P = I(PcrdRC(1):(PcrdRC(1)+PszXY(2)-1), ...
      PcrdRC(2):(PcrdRC(2)+PszXY(1)-1), ...
      indChnl,:);
catch
    error(['cropImage: WARNING! area to crop extends outside of image to crop from or crop location is NaN. Check inputs!']);
end


if bPLOT
   if size(P,3) == 1 & size(P,4) == 1
       figure;
       imagesc(P.^.5); 
       axis image; colormap gray; axis off;
   elseif   size(P,3) == 3 & size(P,4) == 1
       figure('position',[168 185 580 886]); 
       % PLOT FULL COLOR IMAGE
       subplot(3,1,[1 2]); 
       imagesc( (P./max(P(:))).^.4 ); axis image; title('Color Image'); axis off;
       % PLOT CHANNEL 1
       subplot(3,3,7); 
       imagesc(  P(:,:,1).^.4 ); axis image; title('Chnl 1'); axis off;
       % PLOT CHANNEL 2
       subplot(3,3,8); 
       imagesc(  P(:,:,2).^.4 ); axis image; title('Chnl 2'); axis off;
       % PLOT CHANNEL 3
       subplot(3,3,9); 
       imagesc(  P(:,:,3).^.4 ); axis image; title('Chnl 3'); axis off; colormap gray;
   end
end