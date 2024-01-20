function [xL,xR,xLR] = screenXfromRangeXZ(tgtXZ,scrZ,IPD,bPLOT,bCHECK)

% function [xL xR xLR] = screenXfromRangeXZ(tgtXZ,scrZ,IPD,bPLOT,bCHECK)
%
%   example call: % EXAMPLE POINT
%                   [xL,xR]=screenXfromRangeXZ([40 120],100,65,1);
%
%                 % EXAMPLE RANDOM TRAJECTORY
%                   screenXfromRangeXZ(cumsum([0 50; 4.*randn(25-1,2)]),50,65,1)
%
% left and right eye X-projections in arbitrary distance units from XZ target positions 
%
% tgtXZ:    target position in x and z         [ N x 2 ]
% scrZ:     screen distance in       z         [ 1 x 1 ]
% IPD:      interpupillary distance            [ 1 x 1 ]
% bPLOT:    plot or not
%           1 -> plot
%           0 -> not
% bCHECK:   a sanity check for moving targets... N must be >= 2
%           1 -> plot
%           0 -> not
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% xL:       left         eye image position in x      [ N x 1 ]
% xR:       right        eye image position in x      [ N x 1 ]
% xLR:      left & right eye image position in x      [ N x 2 ]

% INPUT HANDLING
if ~exist('bPLOT', 'var') || isempty(bPLOT)  bPLOT  = 0; end
if ~exist('bCHECK','var') || isempty(bCHECK) bCHECK = 0; end

% SIMPLER TARGET VARIABLES
I  = IPD;
xT = tgtXZ(:,1);
zT = tgtXZ(:,2);
zS = scrZ;

% LEFT AND RIGHT EYE SCREEN POSITIONS
xL = xT.*(zS./zT) - (I/2).*(1-zS./zT);
xR = xT.*(zS./zT) + (I/2).*(1-zS./zT);

% IF NUMBER OF OUTPUT ARGUMENTS IS GREATER THAN 2
if nargout > 2
xLR = [xL(:) xR(:)];
end

%% PLOT STUFF
if bPLOT == 1
   indPlt = 1:min([length(xT) 300]);
    
   figure; hold on;
   % PLOT SCREEN
   plot([-1 1].*I,[zS zS],'k-');
   % PLOT LINES OF SIGHT
   plot([-I/2     xT(indPlt(end))],[0  zT(indPlt(end))],'k'); % LE
   plot([ I/2     xT(indPlt(end))],[0  zT(indPlt(end))],'k'); % RE
   plot([ xL(end) xT(indPlt(end))],[zS zT(indPlt(end))],'k');
   plot([ xR(end) xT(indPlt(end))],[zS zT(indPlt(end))],'k');
   % PLOT  TARGET
   plot(xT,zT,'ko-','markerface','w','markersize',8);
   % PLOT LEFT AND RIGHT EYE SCREEN POINTS
   h(1)=plot([xL(indPlt)],repmat(zS,size(indPlt)),'ro','markerface','w','markersize',8,'linewidth',2);
   h(2)=plot([xR(indPlt)],repmat(zS,size(indPlt)),'bo','markerface','w','markersize',8,'linewidth',2);
   % PLOT LEFT EYE & RIGHT EYE
   plot(-I/2,0,'ko','markerface','w','markersize',12);
   plot(+I/2,0,'ko','markerface','w','markersize',12);
   legend(h,{'LE','RE'},'location','southwest')
   axis square
   xlim([-I I]); ylim([0 2.*I]);
   formatFigure('X-position','Z-position')
end


if bCHECK == 1
    try
        % ANALYTIC EXPRESSION OF SCREEN POSITION VELOCITY
        indGd = 2:length(zT);

        % LEFT AND RIGHT EYE SCREEN VELOCITIES
        vL = diff(xL);
        vR = diff(xR);
        vLchk = zS.*( (diff(xT).*zT(indGd) - xT(indGd).*diff(zT)) - (I/2).*diff(zT) )./( zT(indGd).^2 );
        vRchk = zS.*( (diff(xT).*zT(indGd) - xT(indGd).*diff(zT)) + (I/2).*diff(zT) )./( zT(indGd).^2 );
        figure; 
        subplot(2,1,1); hold on; 
        plot(vL); plot(vLchk); 
        formatFigure([],[],['vL; corr=' num2str(corr(vL,vLchk),'%.2f')]); xlim([0 100]); 
        subplot(2,1,2); hold on; 
        plot(vR); plot(vRchk); 
        formatFigure([],[],['vR; corr=' num2str(corr(vR,vRchk),'%.2f')]); xlim([0 100]); 
    catch
        disp(['screenXfromRangeXZ: WARNING! bCheck == 1 only valid for more than one target position']);
    end
end