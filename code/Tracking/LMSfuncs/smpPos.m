function posUnt = smpPos(smpPerUnt,nSmp,bStartAtZero)

% function posUnt = smpPos(smpPerUnt,nSmp,bStartAtZero)
%
%   example call: posUnt = smpPos(128,128)
% 
% spatial positions of samples given a sampling rate and a patch
% spatial positions are always sampled at zero
%
% smpPerUnt:    sampling rate (e.g. smp/deg, smp/sec, etc)
% nSmp:         number of samples
% bStartAtZero: boolean determining how samples are positioned
%               0 -> best for space sampling: e.g. [-3 -2 -1  0  1  2] (default)
%               1 -> best for time  sampling: e.g. [ 0  1  2  3  4  5] 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% posUnt:       spatial positions of sample in units
%
%                      *** see smpFrq.m ***

if ~exist('bStartAtZero','var') || isempty(bStartAtZero)
   bStartAtZero = 0; 
end

% IF NUM PIX IS EVEN
if mod(nSmp,2) == 0 
    posMinUnt = -0.5*max(nSmp)./smpPerUnt;
    posMaxUnt =  0.5*max(nSmp)./smpPerUnt - 1/smpPerUnt;
elseif mod(nSmp,2) == 1
    posMinUnt = -0.5*(nSmp-1)./smpPerUnt;
    posMaxUnt =  0.5*(nSmp-1)./smpPerUnt;
else
    error(['smpPos: WARNING! num pix must be integer valued. nSmp = ' num2str(nSmp)]);
end
posUnt    = linspace(posMinUnt,posMaxUnt,max(nSmp));

if bStartAtZero == 1
   posUnt = posUnt-posMinUnt; 
end