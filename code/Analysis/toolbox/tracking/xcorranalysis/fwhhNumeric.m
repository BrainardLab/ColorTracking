function fwhh = fwhhNumeric(x,y)

% function fwhh = fwhhNumeric(x,y)
%
% example calls: 
%                 % COMPUTE FWHH FOR A BUNCH OF REGULAR GAUSSIANS
%               
%                 % X SUPPORT
%                 x = -1:0.0005:1;
% 
%                 % MAKE A BUNCH OF GAUSSIANS
%                 for i = 1:100
%                    y(:,i) = normpdf(x,rand-0.5,0.1)'; 
%                 end
%                 fwhh = fwhhNumeric(x,y);
%
%                 % COMPUTE FWHH FOR A BUNCH OF GAMMA DISTRIBUTIONS
%
%                 % AN ARRAY OF GAMMA PARAMETER VALUES (4 parameters x 7
%                 % samples)
%                 rParamTest = [0.0253    0.0243    0.0254    0.0224    0.0236    0.0241    0.0211; ...
%                               0.0898    0.0519    0.0581    0.1252    0.0834    0.1169    0.0867; ...
%                               4.8726   10.4862    8.7897    2.6691    4.1854    2.9814    3.4575; ...
%                               0.1587    0.0073    0.0555    0.2627    0.2227    0.2354    0.2837];
%                 % X SUPPORT
%                 x = [0:0.01:4]';
%                 % MAKE A BUNCH OF GAMMA DISTRIBUTIONS
%                 y = gammaGenerate([0:0.01:4]',rParamTest(1,:),rParamTest(2,:),rParamTest(3,:),rParamTest(4,:));
%                 figure; plot(x,y); ylim([0 0.07]);
%                 fwhh = fwhhNumeric(x,y);
%
% numerically computes full width at half maximum for a curve defined by x
% and y. 
%
% inputs: 
%         x: support over curve y   [nSamplesInX x 1]
%         y: curve                  [nSamplesInX x nInstances]
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
