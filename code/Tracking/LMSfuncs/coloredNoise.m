function I = coloredNoise(PszXY,exponent,bPLOT,rndSd)

% function I = coloredNoise(PszXY,exponent,bPLOT,rndSd)
%
%   example call: % NOISE WITH FALLOFF OF NATURAL STIMULI
%                   coloredNoise(512,-,1,[],1);
%
%                 % TO SAVE DATA
%                   coloredNoise(512,-1.2,1,[],1);
%
%                 % TO EXAMINE CAMOUFLAGE
%                   rmsFix = 0.2;
%                   for i = 1:5, 
%                       figure;  
%                       Ibig = coloredNoise([384 384],-1,0); Ibig = rmsFix.*Ibig./rmsDeviation(Ibig); 
%                       Isml = coloredNoise([128 128],-1,0); Isml = rmsFix.*Isml./rmsDeviation(Isml); 
%                       ind0 = sub2ind([384 384],129,129); ind0 = ind0:ind0+numel(Isml)-1; I=Ibig; 
%                       I(129:256,129:256) = Isml; imagesc(I); colormap gray; axis square; 
%                   end
%
%                 % TO CREATE STIMULUS SET FOR AMA
%                   rmsFix = 0.2; for i = 1:5000, Ibig = coloredNoise([8 16],-1,0); Ibig = rmsFix.*Ibig./rmsDeviation(Ibig); Isml = coloredNoise([8 16],-1,0); Isml = rmsFix.*Isml./rmsDeviation(Isml); Ione = coloredNoise([16 16],-1,0); I1(:,i) = rmsFix.*Ione(:)./rmsDeviation(Ione); I2(:,i)=reshape([Ibig Isml],[],1);  end
%
% create 2D noise image with 1/(f^x) frequency spectrum
%
% PszXY:       1x2 vector coding x,y image size
% exponent:       -1 -> 1/f noise,
%                  0 -> white noise
% bPLOT:           plot result?
% rndSd:           random seed
%%%%%%%%%%%%%%%%
% I:               noise image data

if length(PszXY) == 1
   PszXY = PszXY.*ones(1,2);
end
if ~mod(PszXY(1),2) == 0 || ~mod(PszXY(2),2) == 0
    error(['coloredNoise: WARNING! patchSizes must be even = [' num2str(PszXY(1)) ' ' num2str(PszXY(2)) ']']);
end
if ~exist('bPLOT','var')
    bPLOT = 0;
end
if exist('rndSd') && ~isempty(rndSd)
    rng(rndSd);
end

% CREATE WHITE NOISE IMAGE
image = randn(PszXY(2),PszXY(1));

% 2D FFT, AMP AND PHASE SPECTRUM
Ifft   = fftshift(fft2(ifftshift(image)));
Iphs   = angle(Ifft);
Iamp   = abs(Ifft);

% X,Y FREQUENCY COORDINATES (i.e. U,V)
[U,V] = meshgrid( smpFrq(PszXY(1),PszXY(1)), smpFrq(PszXY(1),PszXY(2)));
% RADIAL DISTANCE
R     = sqrt(U.^2 + V.^2);
% FILTER TO INTRODUCE PINKISH-NOISE
F         = R.^exponent;
indCtrX   = PszXY(1)/2+1;
indCtrY   = PszXY(2)/2+1;
F(indCtrY,indCtrX) = 1;

% RECOMBINE FFT-INFO
I = F.*Iamp.*[cos(Iphs) + 1i.*sin(Iphs)];

% Inverse 2D-FFT
I = real(fftshift(ifft2(ifftshift(I))));
% I = I - min(I(:));
% I = I./max(I(:));  % forces minmax to be [0 1]


if bPLOT
    % PLOT NOISE IMAGE
    figure('position',[203   331   961   453]);
    subplot(1,2,1);
    hImg = imagesc(I); colormap(gray); axis equal; hold on
    axis tight
    axis image
    title(['Colored Noise Image: 1/f^{' num2str(-exponent) '}'],'fontsize',15);

    formatFigure([],[],['1/f^{' num2str(-exponent) '} noise'],0,0,24,18);
    set(gca,'xtick',[]); set(gca,'ytick',[]);


    % Calculate amplitude spectrum of new image
    A = abs(fftshift(fft2(I)))./sqrt(numel(I));

    subplot(1,2,2);
    hold on
    % RADIAL AVERAGE
    [Aavg,B] = radialAvgOrSum(U,V,A,min(PszXY)/4-1,1,0,0,0);

    % PLOT RADIAL AVERAGE
    plot(B,Aavg,'k','linewidth',2);
    plot(A(indCtrY+1,indCtrX:PszXY(2)),'k'); %

    % PLOT 1/F LINE
    plot(expspace(1,100,11),fliplr(expspace(.1,10,11)).^-exponent,'k--')
    axis square

    % FORMAT FIGURE
    formatFigure('Frequency','|A|',['1/f^{' num2str(exponent) '} noise'],1,1,24,18);
    set(gca,'xscale','log'); set(gca,'yscale','log')
    writeText(10,1.2,{['1/f^{' num2str(exponent) '} noise']},'abs',15,'left',-30/abs(exponent),'bottom');
    legend({'Rad Avg','U,V=0'},'location','northeast')
end
