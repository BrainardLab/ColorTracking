%% Invert Weibull Test
% load the data
S = loadPSYdataLMSall('JND', 'MAB', 'LSD', 'CGB',{[1:24]}, 'blobfish', 'local');
[tFit,mFit,sFit,bFit,PCdta,cSpacing]= LSDthresholdAnalysis(S,1,'fitType','weibull','showPlot',false);

%% set up the weibull 
% set the x spacing
xSpacing = 0.0001:.01:cSpacing(end,1);

% make the weibull function 
pc = @(x) 1-exp(-1*(x/sFit(1)).^bFit(1));

% get the percent correct 
P = pc(xSpacing);


%% invert the weibull
% inverse cumulative weibull 
IP = @(P) sFit(1).*(-1*log(1-P)).^(1./bFit(1));

% see if you get them same output
xSpacingHat = IP(P)


