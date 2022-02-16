function [PC,T,DP] = psyfitgengaussfunc(Xstd,Xcmp,mFit,sFit,bFit,DPcrt,nIntrvl,bPLOT,xLbl,yLbl,color,figh)

% function [PC,T,DP] = psyfitgengaussfunc(Xstd,Xcmp,mFit,sFit,bFit,DPcrt,nIntrvl,bPLOT,xLbl,yLbl,color,figh)
%
%   example call: % SAME    TAILS AS   GAUSSIAN (cause it's gaussian)
%                   PC = psyfitgengaussfunc([],[-5:.1:5],0,1,1.0,1,1,1)
%
%                 % HEAVIER TAILS THAN GAUSSIAN
%                   PC = psyfitgengaussfunc([],[-5:.1:5],0,1,0.5,1,1,1)
%
%                 % LIGHTER TAILS THAN GAUSSIAN
%                   PC = psyfitgengaussfunc([],[-5:.1:5],0,1,2.0,1,1,1)
%
% plot generalized gaussian fit to psychometric data
%
% Xstd:      standard   values                           [ 1 x  1   ]
% Xcmp:      comparison values                           [ 1 x nCmp ]
% mFit:      mean of fit                                 [ 1 x  1   ]
%            represents MU of underlying standard
%            decision variable distribution
% sFit:      standard deviation of fit...                [ 1 x  1   ]
%            represents SD of underlying 
%            decision variable distribution
% bFit:      exponent of fit...                          [ 1 x  1   ]
%            if beta == 1, fit is cumulative gaussian
% DPcrt:     criterion dprime corresponding to threshold
% nIntrvl:   number of intervals with which data was collected
% bPLOT:     1 -> plot
%            0 -> not
%%%%%%%%%%%%%%%%%%%%%%
% PC:        percent correct                              [ 
% T:         threshold corresponding to criterion d'
% DP:        d-prime at corresponding to each percent correct

if ~exist('DPcrt','var') || isempty(DPcrt), DPcrt = 1;                     end
if ~exist('bPLOT','var') || isempty(bPLOT), bPLOT = 0;                     end
if ~exist('xLbl','var')  || isempty(xLbl),  xLbl  = 'X';                   end
if ~exist('yLbl','var')  || isempty(yLbl),  yLbl  = '% Comparison Chosen'; end
if ~exist('color','var') || isempty(color), color = 'k';                   end
if ~exist('figh','var')  || isempty(figh),  figh = [];                     end

% D-PRIMEs 
DP = sign(Xcmp-mFit).*(abs(Xcmp-mFit)./sFit).^bFit; % abs() prevent complex numbers w. some betas 

% CDF 
PC = normcdf( 0.5.*sqrt(nIntrvl).*DP,0,1); % sign() reinstates sign of Xcmp-mFit 

% SIGNAL AT THRESHOLD
T  = sFit.*DPcrt.^(1/bFit);

if bPLOT
    % OPEN FIGURE
    if ~exist('figh','var') || isempty(figh)
    figure('position',[680   634   384   406]); hold on
    else
	figure(figh);  hold on
    end

    % PLOT STUFF
    plot(Xcmp,PC,'color',color,'linewidth',2);
    formatFigure([xLbl],[yLbl],['T=' num2str(T,'%.2f') ': \mu=' num2str(mFit,'%1.2f') ',\sigma=' num2str(sFit,'%1.2f') ',\beta=' num2str(bFit,'%1.2f') ',nIntrvl=' num2str(nIntrvl)]);
    xlim(minmax(Xcmp)+[-.1 .1]); ylim([0 1])
    axis square

    % WRITE STUFF TO SCREEN
    if isempty(figh)
        % WRITE PARAMETER VALUES AND N SMP TO SCREEN
        writeText(.075,.900,{['d''= ( | x - \mu| / \sigma )^{\beta}' ]},'ratio',20)
        writeText(.075,.775,{['d''_{crit}=' num2str(DPcrt,'%.2f')]},'ratio',20)

        % THRESHOLD LINES
        plot(mFit*[1 1],        [0                  0.5],'color',color,'linewidth',1);
        plot((mFit+T)*[1 1],    [0     normcdf(0.5.*sqrt(nIntrvl).*DPcrt)],'color',color,'linewidth',1);
        plot([min(xlim) mFit],  [0.5                0.5],'color',color,'linewidth',1);
        plot([min(xlim) mFit+T],[normcdf(0.5.*sqrt(nIntrvl).*DPcrt)*[1 1]],'color',color,'linewidth',1);
    end
end
