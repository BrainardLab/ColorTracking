function rhoFilteredTime = filterTRKdataFlattopCos(rho,tSec,cosRmpRangeCps,bPLOT)

% function rhoFilteredTime = filterTRKdataFlattopCos(rho,tSec,cosRmpRangeCps,bPLOT)
%
% analysis function for TRK experiments. Filters a cross-correlation signal
% from TRK data using a flat-top cosine filter in the Fourier domain.
%
% example calls: 
%                tSec = -3:0.01:3;
%                rho = normpdf(tSec,0,0.1);
%                rho = rho./max(rho);
%                rho = rho + normrnd(0,0.1,size(rho));
%                cosRmpRangeCps = [10 30];
%                rhoFilteredTime = filterTRKdataFlattopCos(rho,tSec,cosRmpRangeCps,1);
%
% inputs: 
%         rho           : cross-correlation signal from TRK data to filter
%                          [nSmp x 1]
%         tSec          : support over which rho is defined
%                          [nSmp x 1]
%         cosRmpRangeCpd: range of temporal frequencies over which cosine
%                         ramp is defined. First entry is lowest frequency,
%                         second entry is highest.
%                          [1 x 2]

% FOURIER TRANSFORM CROSS-CORRELATION SIGNAL
rhoFft = ifftshift(fft(fftshift(rho)));

% FREQUENCIES OF FOURIER TRANSFORM
tHtzRho = smpPos2smpFrq(tSec);

% MAKE A FLAT TOP COSINE FILTER IN THE FOURIER DOMAIN
krnFft = zeros(size(rho));
krnFft(abs(tHtzRho)<cosRmpRangeCps(1)) = 1;
krnFft(tHtzRho>cosRmpRangeCps(1) & tHtzRho<=cosRmpRangeCps(2)) = 0.5.*(1+cos(2*pi.*linspace(0,0.5,sum(tHtzRho>=cosRmpRangeCps(1) & tHtzRho<=cosRmpRangeCps(2)))));
krnFft(tHtzRho<-cosRmpRangeCps(1) & tHtzRho>=-cosRmpRangeCps(2)) = fliplr(0.5.*(1+cos(2*pi.*linspace(0,0.5,sum(tHtzRho>=cosRmpRangeCps(1) & tHtzRho<=cosRmpRangeCps(2))))));

% FILTER IN FOURIER DOMAIN
rhoFilteredFourier = rhoFft.*krnFft;

% TRANSFORM BACK TO TIME SIGNAL
rhoFilteredTime = real(ifftshift(ifft(fftshift(rhoFilteredFourier))));

if bPLOT==1
   figure;
   plot(tSec,rho); hold on;
   plot(tSec,rhoFilteredTime);
   axis square;
   formatFigure('Time (s)','Response');
end

end