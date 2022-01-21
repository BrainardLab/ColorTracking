function writeText(xPositions,yPositions,txtStrings,ratioORabs,fs,hPos,rotDeg,vPos,textColor,zPositions)
 
% function writeText(xPositions,yPositions,txtStrings,ratioORabs,fs,hPos,rotDeg,vPos,textColor,zPositions)
%
%   example call: writeText(.1,.9,{['R^{2} = .5']}) 
%
% writes txtStrings at specified location in figure window
%
% xPositions: scalar between 0 and 1 that determines position text will
%             appear in x (1xn)
% yPositions: scalar between 0 and 1 that determines position text will
%             appear in y (1xn)
% txtStrings: cell array of strings that get written at location
%             (xPositions,yPositions,zPositions)
% ratioORabs: indicates whether xPositions & yPositions indicate text
%             position in the current window as percentage of window size or in
%             absolute x or y positions
% fs:         fontsize
% hPos:      'left','center', 'right' alignment
% rotDeg:     orientation of text in degrees
% vPos:       'top', 'bottom', 'middle'
% textColor:  default: black, [0 0 0]
% zPositions: 

if (length(xPositions) ~= length(yPositions) | length(xPositions) ~= length(txtStrings))
    error('writeText: all three variables [xPositions,yPositions,txtStrings] must have same number of elements');
end
if (~iscell(txtStrings))
    error('writeText: txtStrings must be of type cell');
end
if (~exist('ratioORabs','var') | isempty(ratioORabs))
    ratioORabs = 'ratio';
end
if (~exist('fs','var') || isempty(fs))
    fs = 18;
end
if (~exist('hPos','var'))
    hPos = 'left';
end
if (~exist('vPos','var'))
    vPos = 'middle';
end
if (~exist('rotDeg','var') || isempty(rotDeg))
    rotDeg = 0;
end
if ~exist('textColor','var') || isempty(textColor)
    textColor = [ 0 0 0];
end
if ~exist('zPositions','var') || isempty(zPositions)
    if strcmp(ratioORabs,'ratio')
       zPositions = .5*ones(size(xPositions));
    elseif strcmp(ratioORabs,'abs')
       zPositions = 0*ones(size(xPositions));
    end
end
% GET AXIS LIMITS
[xlims ylims] = getLims;

if (strcmp(ratioORabs,'abs'))
    xPos = xPositions;
    yPos = yPositions;
    zPos = zPositions;
elseif (strcmp(ratioORabs,'ratio'))
    xPos = xlims(1) + xPositions.*diff(xlims);
    yPos = ylims(1) + yPositions.*diff(ylims);
    zlims = get(gca,'zlim');
    zPos = zlims(1) + zPositions.*diff(zlims);
else
    error(['writeText(): invalid ratioORabs value. choose ratio OR abs.']);
end

% WRITE TEXT AT INDICATED POSITIONS
for (s = 1:length(txtStrings))
    text(xPos(s),yPos(s),zPos(s),txtStrings{s},'HorizontalAlignment',hPos,'VerticalAlignment',vPos,'fontsize',fs,'rotation',rotDeg,'color',textColor);
end


