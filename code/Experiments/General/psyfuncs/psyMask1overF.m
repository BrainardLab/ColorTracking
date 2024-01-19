function [msk1oF,mskNoise,mskHole] = psyMask1overF(PszXY,diameterXYk,CctrXY,bPLOT,bSQR)

% function [msk1oF mskNoise mskHole] = psyMask1overF(PszXY,diameterXYk,CctrXY,bPLOT,bSQR)
%
%    example call:  % CIRCLE MASK
%                     msk1oF = psyMask1overF([500 500],0.5,[],1);
%
%                   % SQUARE MASK
%                     msk1oF = psyMask1overF([500 500],0.5,[],1,1);
%
% create 1/F texture mask stimulus for windowing displays in experiments
% run on psychtoolbox (PTB). the output is a RGBA texture bounded on [0 1]
% with size [ r x c x 4 ]. The last channel is the alpha channel which is
% fully transparent when equal to 0.0 and fully opaque when equal to 1.0
%
% TO CALL IN EXPERIMENT:
%    tex1oF = Screen('MakeTexture', D.wdwPtr, msk1oF,[],[],2);  % MAKE  TEXTURE TO MAP
%    Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix);    % DRAW  TEXTURE
%    Screen('Close', tex1oF);                                   % CLOSE TEXTURE
%
% PszXY:       patch size in pixels           [1 x 2]
% diameterXYk: fraction of min screen dimension to use for diameter of mask
% CctrXY:      circle center in pixels        [1 x 2]
% bPLOT:       plot or not
%              1 -> plot
%              0 -> not
% bSQR:        type of mask... square opening or not
%              1 -> square
%              0 -> circle (default)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% msk1oF:    RGBA texture bounded on [0 1] with size [ r x c x 4 ]
%            where the first three channels are RGB
%            and the last channel is transparency

% INPUT HANDLING
if ~exist('CctrXY','var') || isempty(CctrXY) CctrXY = [0 0]; end
if ~exist('bPLOT','var')  || isempty(bPLOT)  bPLOT = 0; end
if ~exist('bSQR','var')   || isempty(bSQR)   bSQR = 0; end

% INPUT CHECKING
if length(diameterXYk)==1 diameterXYk(2) = diameterXYk; end

% MAKE 1/F TEXTURE
mskNoise = coloredNoise(PszXY,-1);
% BOUND TEXTURE ON [0 1] (WRITE STAND-ALONE FUNCTION)
% CIsz = 99.9./100;
CIsz = 99./100;
[Qlohi]=quantile(mskNoise(:),[(1 - CIsz)./2  1-(1 - CIsz)./2]);
mskNoise = (mskNoise - Qlohi(1))./(Qlohi(2) - Qlohi(1)); 

% minmaxLocal(mskNoise)
bIndLo = mskNoise<0;
bIndHi = mskNoise>1;
mskNoise(bIndLo) = 0;
mskNoise(bIndHi) = 1;

Pclpd = 100.*sum([bIndLo(:); bIndHi(:)])./numel(mskNoise);

% MAKE CIRCLE FOR ALPHA CHANNEL
if     bSQR == 0
mskHole = ~circleImage(PszXY,0.5.*diameterXYk(1).*min(PszXY),CctrXY);
elseif bSQR == 1
mskHole = ~rectImage(PszXY,diameterXYk.*min(PszXY),CctrXY);
end
% 4-D CIRCLE MASK (4TH DIMENSION IS ALPHA CHANNEL)
msk1oF   = cat(3,repmat(mskNoise,[1 1 3]),mskHole);

if bPLOT
    % EXPONENT FOR UNDOING GAMMA
    expnt = .5;

    % PLOT RESULTS
    figure('position',[300 800 1000 400]);
    subplot(1,3,1); hold on;
    imagesc(mskNoise.^expnt); axis image; axis xy;
    [indLoRC(:,1),indLoRC(:,2)] = ind2sub(size(bIndLo),find(bIndLo(:)==1));
    [indHiRC(:,1),indHiRC(:,2)] = ind2sub(size(bIndHi),find(bIndHi(:)==1));
    plot(indLoRC(:,2),indLoRC(:,1),'r.');
    plot(indHiRC(:,2),indHiRC(:,1),'y.');
    formatFigure([],[],'1/F Noise'); caxis([0 1])

    % PLOT MASK
    subplot(1,3,2);
    imagesc(mskHole.^expnt); axis image;  axis xy
    formatFigure([],[],['Mask: x_0=[' num2str(CctrXY(1)) ' ' num2str(CctrXY(2)) ']']); caxis([0 1])
    set(gca,'ytick',[]); set(gca,'xtick',[]);

    % PLOT RESULTS
    subplot(1,3,3);
    mskPlt = mskNoise.*mskHole;
    mskPlt(mskPlt==0) = .5;
    imagesc(mskPlt.^expnt); axis image;  axis xy
    formatFigure([],[],'1/F Mask'); caxis([0 1])
    set(gca,'ytick',[]); set(gca,'xtick',[]);
    colormap gray;
end
