function [cL,cM,cS,stimCombinations] = generateStimContrasts(azi,ele,C)
%
% For the L S plane
%   azi = 0; L+S ele = 45; L-S ele = -45;
% For the L M plane
%   ele = 0; L+M azi = 45; L-M azi = -45 
% For the M S plane
%   azi = 90; M+S ele = 45; M-S ele = -45;


% get the direction
[cL,cM,cS] = sph2cart(deg2rad(azi),deg2rad(ele),1);

stimDirs = [cL',cM',cS'];


% % Apply the max contrast to each direction coding column
% maxContDir   = bsxfun(@times,stimDirs,maxContrastPerDir);

% Make matricies the the size of the total desired stim.
fullContDir  = repelem(stimDirs,length(C),1);
fullContCode = repmat(C',length(azi),1);

% apply the constrast spacining to the constast directions 
stimCombinations = bsxfun(@times,fullContDir,fullContCode);
