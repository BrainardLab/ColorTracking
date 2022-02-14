function [Imean posBinCenters Inumel Istd Imeanlog Istdlog posRmat ind] = radialAvgOrSum(posXmat,posYmat,I,numBins,bExpSpacing,bRadialSum,upSampleFactor,bPLOT)

% function [Imean posBinCenters Inumel Istd Istdlog Igeomean posRmat ind] = radialAvgOrSum(posXmat,posYmat,I,numBins,bExpSpacing,bRadialSum,upSampleFactor,bPLOT)
%
%   example call: [Aavg B] = radialAvgOrSum(X,Y,A,16,1,0,0,0);
%
% compute radial sum of pixels within radial bands of matrix
%
% posXmat:          matrix of x positions
%                       if nx1 vector of positions, meshgrid is used to
%                       expand to matrix of x positions
% posYmat:          matrix of y positions
%                       if empty, meshgrid expands to matrix of y positions
% I:                nxn image matrix which we will average radially
% numBins:          number of bins over which to average radially
%                       WARNING! numBins should not exceed length(posXmat)
% bExpSpacing:      1 -> exponentially space the bins over which to average
%                   0 -> linear spacing
% bRadialSum:       1 -> multiply average by area of radial bin
%                   0 -> don't (yields straight average)
% bExcludeZero:     1 -> exclude zero as a bin limit (defaults to 1 if
% bExpSpacing == 1)
%                   0 -> do not exclude zero
% upSampleFactor:   0 or 1 or [] -> no upsampling
%                   2            -> increase dimensions by factor of 2
%                   4            -> increase dimensions by factor of 4 
%                   8            -> and so on...
% bPLOT:            1 -> plot, 0 -> don't
% bNoNewFigure:
%%%%%%%%%%%%%%%%%%%
% Imean:           mean   of radial bin
% posBinCenters:   centers of radial bins -> linear center = mean( [posBinLim(i:(i+1))] )
% Inumel:          number of elements in each bin
% Istd:            stddev of elements in each bin: std(data)
% Istdlog:         stddev of log elements in each bin: std(log(data))
% Igeomean:        
% posRmat:         radial distance from matrix center


% GENERATE posXmat & posYmat MATRICES IF NECESSARY

if min(size(posXmat)) == 1, [posXmat posYmat] = meshgrid(posXmat(1,:)); end
if isempty(posYmat),        [posXmat posYmat] = meshgrid(posXmat(1,:)); end
if numBins > .5*length(posXmat),
    disp(['Parameter numBins=' num2str(numBins) '. May not exceed length(posXmat)=' num2str(length(posXmat))]);
end
if ~exist('bExpSpacing','var')  bExpSpacing = 0; end
if ~exist('bRadialSum','var')  bRadialSum = 0; end
if ~exist('bExcludeZero','var') bExcludeZero = 0; end
if ~exist('upSampleFactor','var') || isempty(upSampleFactor)
    upSampleFactor = 0; 
elseif mod(upSampleFactor,2) ~= 0 && upSampleFactor ~= 1
    error(['radialAvgOrSum: WARNING! upSampleFactor must be a power of 2. Instead upSampleFactor =' num2str(upSampleFactor)]);
end
if ~exist('bPLOT','var') bPLOT = 0; end
if ~exist('bNoNewFigure','var') bNoNewFigure = 0; end

if bExpSpacing == 1
    bExcludeZero = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINE DISTANCES FROM ORIGIN %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
posRmat = sqrt(posXmat.^2 + posYmat.^2);

%%%%%%%%%%%%%%%%%%%%%%
% UPSAMPLE THE IMAGE % (if upSampleFactor says to)
%%%%%%%%%%%%%%%%%%%%%%
if upSampleFactor == 0 || upSampleFactor == 1
    Iup = I; % I used to remove z
    posRmatUp = posRmat;
elseif mod(upSampleFactor,2) == 0
    Iup = interp2(I,log(upSampleFactor)/log(2));                        % Divide by two because interp2(X,n) 
    posRmatUp = interp2(posRmat,log(upSampleFactor)/log(2));  %         increases each dim by 2^n 
else
    error(['radialAvgOrSum: WARNING! invalid upSampleFactor = ' num2str(upSampleFactor)]);
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REMOVE FREQUENCY AND POWERS AT POS = 0 % (especially when using 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if bExcludeZero
    indFreq0= find(posRmat == 0);
    posRmat(indFreq0) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET FREQ BINS ON THE INTERVAL BETWEEN THE MINIMUM RADIAL FREQ AND MAX(FREQ_X) % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if bExpSpacing == 0
    %%%%%%%%%%%%%%%%%%
    % LINEAR SPACING %
    %%%%%%%%%%%%%%%%%%
    posBinLims = linspace(min(posRmat(:)),max(posXmat(:)),numBins+1)';
    posBinCenters = mean([posBinLims(1:end-1) posBinLims(2:end)],2);
    % Area of bin == 2*pi*f*fDelta = pi(f+fDelta)^2 - pi(f-fDelta)^2
    multFactor = 2.*pi*(posBinCenters).*(diff(posBinLims(1:2))); 
elseif bExpSpacing == 1
    %%%%%%%%%%%%%%%%%%%%%%%
    % EXPONENTIAL SPACING %
    %%%%%%%%%%%%%%%%%%%%%%%
    posBinLims = expspace(min(posRmat(:)),max(posXmat(:)),numBins+1)';
    posBinCenters = mean([posBinLims(1:end-1) posBinLims(2:end)],2);
    % Area of bin == 2*pi*f^2*k = pi(f+kf)^2 - pi(f-kf)^2
    multFactor = 2.*pi*(posBinCenters.^2).*(diff(posBinLims)./posBinCenters); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPUTE MEAN AND STD FOR EACH RADIAL BIN %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for (r = 1:numBins)
    ind{r} = find(posRmatUp >= posBinLims(r) & posRmatUp < posBinLims(r+1));
    Imean(r,:) = mean(Iup(ind{r}));
    Istd(r,:)  = std(Iup(ind{r}),1);
    Inumel(r,:) = numel(Iup(ind{r}));
    if upSampleFactor >= 2
        Inumel(r,:) = Inumel(r,:)./(upSampleFactor^2); % to correct for upsampling
    end
    if bExpSpacing
    Imeanlog(r,:) = mean(log(Iup(ind{r})));
    Istdlog(r,:) = std(log(Iup(ind{r})),1); % only appropriate if using geometric mean
    end
end

if bRadialSum == 0 
    %%%%%%%%%%%%%%
    % DO NOTHING %
    %%%%%%%%%%%%%%
elseif bRadialSum == 1
    Imean = Imean.*multFactor; % compute 'expected' radial sum
    Istd = Istd.*multFactor;
    
    if exist('Imeanlog','var')
    Imeanlog = Imeanlog.*multFactor;
    Istdlog  = Istdlog.*multFactor;
    end
%     Imean = Imean.*Inumel;
%     Istd = Istd.*Inumel;
end
% REMOVE INDICES FOR WHICH THERE WAS NO POWER
indNaN = find(isnan(Imean));

Imean(indNaN) = [];
posBinCenters(indNaN) = [];
Inumel(indNaN) = [];
Istd(indNaN) = [];
try
Imeanlog(indNaN) = [];
Istdlog(indNaN) = [];
catch
Imeanlog=[];
Istdlog=[];
end
multFactor(indNaN) = [];

if bPLOT
    figure('position',[ 299        1077         850         900]); 
    subplot(2,2,1);
    try
        imagesc(posXmat(1,:),posYmat(:,1)',log(I)); hold on;
        caxis(minmax((I(I>min(I(:))))))
        formatFigure('Pos or Freq','Pos or Freq','Input');
    catch
        imagesc(posXmat(1,:),posYmat(:,1)',(I)); hold on;
        caxis(minmax(log(I(I>min(I(:))))))
        formatFigure('Pos or Freq','Pos or Freq','Log(Input)');
    end
    for b = 1:length(posBinLims)
        plotCircle(posBinLims(b),[0 0],'y')
    end
    
    axis square
    axis xy

    subplot(2,2,2); hold on;
    if upSampleFactor >= 2,  
        posMatXup = interp2(posXmat,log(upSampleFactor)/log(2));
        posMatYup = interp2(posYmat,log(upSampleFactor)/log(2));
        plot(posMatXup,posMatYup,'c.');
    end
    plot(posXmat,posYmat,'b.'); 
    for b = 1:length(posBinLims)
        plotCircle(posBinLims(b),[0 0],'k')
    end
        formatFigure('Pos or Freq','Pos or Freq','Sampled Pos or Freq');
    axis tight
    axis square

    
    subplot(2,2,3); hold on;
    plot([posBinCenters],Inumel,'o');
    plot(posBinCenters,multFactor,'k-')
    formatFigure('Pos|Freq','Area | Num Points','NumPoints: Pred vs Meas',1,1);
    legend({'NumPoints Meas','NumPoints Pred'},2);
    
    
    subplot(2,2,4); hold on;
    
    plot([posBinCenters],sqrt(Imean),'o')
    disp([' ']);
    disp(['radialAvgOrSum: WARNING! displaying sqrt of mean, not mean (to show amplitude when passing power)']);
    disp([' ']);    
    
    formatFigure('Pos or Freq','|Amplitude|',['bRadialSum=' num2str(bRadialSum)]);
    set(gca,'yscale','log'); set(gca,'xscale','log')
%     xlim([1 100])
%         ylim([.1 10])
    box on;
    
    suptitle(['UpSampleFactor=' num2str(upSampleFactor)]);
end

killer = 1;

