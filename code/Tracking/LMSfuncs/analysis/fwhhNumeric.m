function fwhh = fwhhNumeric(x,y)

% function fwhh = fwhhNumeric(x,y)
%
% example call: 
%                 x = -1:0.0005:1;
% 
%                 for i = 1:100
%                    y(:,i) = normpdf(x,rand-0.5,0.1)'; 
%                 end
%
% numerically computes full width at half maximum for a curve defined by x
% and y
%
% inputs: 
%         x: support over curve y
%         y: curve 
%
% outputs: 
%         fwhh: full width at half height 

% FIND MAXIMUM OF Y 
[mu,muInd] = max(y);

% GET THE HALF-HEIGHT POINT BEFORE THE MAXIMUM (CODE IS VECTORIZED)
indLT = bsxfun(@lt,[1:length(x)]',muInd);
indLT = indLT(1:max(sum(indLT,1)),:);
yLT = y(1:size(indLT,1),:);
yLT(~indLT)=0;
[~,hh1ind] = min(abs(bsxfun(@minus,yLT,mu./2)));

clear indLT; clear yLT; 

% GET THE HALF-HEIGHT POINT AFTER THE MAXIMUM 
indGT = bsxfun(@gt,[1:length(x)]',muInd);
indGT = indGT(min(sum(~indGT)):end,:);
yGT = y(size(y,1)-size(indGT,1)+1:size(y,1),:);
yGT(~indGT) = 0;
clear indGT; 
[~,hh2indTmp] = min(abs(bsxfun(@minus,yGT,mu./2)));
[~,muInd2GT] = max(yGT);
hh2ind = hh2indTmp-muInd2GT+muInd+1;

fwhh = x(hh2ind)-x(hh1ind);

end
