function [gamPix gamFnc gamInv]=gammaTableOpticalBenchRoom(gamPix,bNORM,bPLOT)

% function [gamPix gamFnc gamInv]=gammaTableOpticalBenchRoom(gamPix,bNORM,bPLOT)
% 
%   example call: [gamPix gamFnc gamInv]=gammaTableOpticalBenchRoom(0:255,1,1)
%
% raw pixel value vs luminance output of monitor in optical bench room
% with monitor settings: BRIGHTNESS = 25% & CONTRAST   = 100% 
%
% gamPix: input pixel values
% bNORM:  normalize max output gamma to [0 1]... psychtoolbox call
%         1 -> normalize to [ 0  1  ]
%         0 -> don't        [ 0 255 ]
% bPLOT:  1 -> plot
%         0 -> not
%%%%%%%%%%%%%%%%%%%%%%%
% gamPix:   linear input pixel value
% gamFnc:      output luminance value in cd/m^2
% gamInv:   inverse gamma function (to correct measured gamma)


if ~exist('bNORM','var') || isempty(bNORM) bNORM = 0; end
if ~exist('bPLOT','var') || isempty(bPLOT) bPLOT = 0; end

if exist('gamPix','var') && ~isempty(gamPix)
   if size(gamPix,2) > size(gamPix,1)
      gamPix = gamPix'; 
   end
end

% [PIXVAL M1 M2 M3 M4 M5]
GAMDATA = [
    0    .118  .1088 .1217 .0983 .0805;
    10   .1199 .1475 .1415 .1409 .1281;
    20   .2425 .2031 .1995 .1241 .1669;
    30   .4798 .4760 .3789 .4663 .3932;
    40   .9397 .9722 .9318 .8431 .8615;
    50   1.733 1.887 1.803 1.751 1.739;
    60   2.976 2.936 2.941 3.088 3.058;
    70   4.737 4.637 4.607 4.867 4.851;
    80   6.832 6.963 6.893 6.894 6.935;
    90   9.406 9.525 9.540 9.398 9.498;
    100  12.59 12.31 12.45 12.39 12.48;
    110  16.04 15.76 16.03 16.21 16.04;
    120  20.09 20.33 20.07 19.99 20.19;
    130  24.85 24.92 24.79 25.18 25.10;
    140  30.25 29.97 30.55 30.18 30.36;
    150  35.86 35.98 36.23 35.69 36.14;
    160  42.61 42.49 42.76 42.58 42.02;
    170  49.65 49.32 49.25 49.27 49.61;
    180  56.78 56.63 57.27 57.32 56.83;
    190  65.36 65.45 64.62 65.37 65.97;
    200  74.13 73.37 74.08 74.33 74.02;
    210  82.55 83.16 82.99 83.84 82.86;
    220  92.84 94.18 94.00 92.10 92.61;
    230  104.2 104.3 103.0 103.3 103.8;
    240  115.2 115.4 114.0 114.5 114.1;
    250  115.9 115.8 116.1 116.1 114.5;
    255  116.0 116.3 115.9 116.2 115.3
    ];

if ~exist('gamPix','var') || isempty(gamPix)
    gamPix = GAMDATA(:,1);
end
  
Gdata = [ max(gamPix).*GAMDATA(:,1)./max(GAMDATA(:,1)) mean(GAMDATA(:,2:end),2)] ;
gamFnc    = interp1(Gdata(:,1),Gdata(:,2),gamPix);

gamInv = interp1(gamFnc,gamPix,linspace(min(gamFnc),max(gamFnc),numel(gamPix))');

if bNORM
   gamInv = gamInv./max(gamInv); 
end

if bPLOT
    %%
    figure('position',[680         637        1022         461])
    subplot(1,2,1); hold on
    plot(gamPix,gamFnc,'k','linewidth',2);
    errorbar(Gdata(:,1),Gdata(:,2),std(GAMDATA(:,2:end),[],2), 'ko','linewidth',2);
    formatFigure(['Pixel Value'],'Luminance');
    xlim([minmaxLocal(Gdata(:,1))])
    axis square;
    
    subplot(1,2,2);
    plot(gamFnc,gamPix,'k','linewidth',2);
    formatFigure('Luminance',['Pixel Value']);
    xlim([minmaxLocal(Gdata(:,2))])
    axis square;
    ylim(minmaxLocal(gamPix));
end