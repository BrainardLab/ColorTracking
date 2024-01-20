function formatFigure(xlbl,ylbl,ttl,bLogX,bLogY,fsLbl,fsTck,xtck,ytck,xtckSgDg,ytckSgDg)

% function formatFigure(xlbl,ylbl,ttl,bLogX,bLogY,fsLbl,fsTck,xtck,ytck,xtckSgDg,ytckSgDg)
%
%   example call: formatFigure('X','Y','Data Plot',1,1,22,18,xtck,ytck,xtckSgDg,ytckSgDg))
%
% automatically format figure with axis labels, title, log/linear scaling, and specified fontsize
%
% xlbl:     x-axis label
% ylbl:     y-axis label
% ttl:      title
% bLogX:    log scale x-axis
%           0 -> linear scale (default)
%           1 -> log    scale
% bLogX:    log scale y-axis
%           0 -> linear scale (default)
%           1 -> log    scale
% fsLbl:   fontsize for labels
% fsTck:   fontsize for ticks
% xtck:    x tick values
% ytck:    y tick values
% xtckSgDg:  number of significant digits for xtck values
% ytckSgDg:  number of significant digits for ytck values

if ~exist('ttl','var')     || isempty(ttl),    ttl = [];    end
if ~exist('h','var')       || isempty(h)       h = gca;     end
if ~exist('bLogX','var')   || isempty(bLogX)   bLogX = 0;   end
if ~exist('bLogY','var')   || isempty(bLogY)   bLogY = 0;   end
if ~exist('fsLbl','var')   || isempty(fsLbl)   fsLbl = 22;  end
if ~exist('fsTck','var')   || isempty(fsTck)   fsTck = 18;  end


try xlabel(xlbl,'fontsize',fsLbl); catch, end
try ylabel(ylbl,'fontsize',fsLbl); catch, end
title(ttl,'fontsize',fsLbl);
if bLogX == 1
    set(h,'xscale','log');
end
if bLogY == 1
    set(h,'yscale','log');
end
set(gca,'fontsize',fsTck);
set(gca,'fontWeight','normal');
try set(gca,'XColor','k'); catch, end
try set(gca,'YColor','k'); catch, end
set(gcf,'color','w');
box on

% SET TICKS AND SINGIFICANT DIGITS
if exist('xtck','var')   & ~isempty(xtck)   set(gca,'xtick',[xtck]); end
if exist('ytck','var')   & ~isempty(ytck)   set(gca,'ytick',[ytck]); end
if exist('xtckSgDg','var') & ~isempty(xtckSgDg) set(gca,'xticklabel',num2str(get(gca,'xtick')',['%.' num2str(xtckSgDg) 'f'] )); end
if exist('ytckSgDg','var') & ~isempty(ytckSgDg) set(gca,'yticklabel',num2str(get(gca,'ytick')',['%.' num2str(ytckSgDg) 'f'] )); end

% UNBOLD TITLE DEFAULTS FROM MATLABv2015 or later
v = version('-release');
if str2num(v(1:4)) >= 2015
    set(gca,'TitleFontWeight','normal');
end
