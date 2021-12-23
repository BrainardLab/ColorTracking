function pos = samplePositions(smpPerUnit,numSmp,bStartAtZero)

% function pos = samplePositions(smpPerUnit,numSmp,bStartAtZero)
%
%   example call: posDeg = samplePositions(128,128)
% 
% spatial positions of samples given a sampling rate and a patch
% spatial positions are always sampled at zero
% also see:         *** sampleFrequency.m ***
%
% smpPerUnit:   sampling rate
% numSmp:       number of samples
% bStartAtZero: boolean determining how samples are positioned
%               0 -> best for space sampling: e.g. [-3 -2 -1  0  1  2] (default)
%               1 -> best for time  sampling: e.g. [ 0  1  2  3  4  5] 
%%%%%%%%%%%
% pos:          spatial positions of sample 

if ~exist('bStartAtZero','var') || isempty(bStartAtZero)
   bStartAtZero = 0; 
end

% IF NUM PIX IS EVEN
if mod(numSmp,2) == 0 
    minPos = -0.5*max(numSmp)./smpPerUnit;
    maxPos =  0.5*max(numSmp)./smpPerUnit - 1/smpPerUnit;
elseif mod(numSmp,2) == 1
    minPos = -0.5*(max(numSmp)-1)./smpPerUnit;
    maxPos =  0.5*(max(numSmp)-1)./smpPerUnit;
else
    error(['samplePositions: WARNING! num pix must be integer valued. numSmp = ' num2str(numSmp)]);
end
pos    = linspace(minPos,maxPos,max(numSmp));

if bStartAtZero == 1
   pos = pos-minPos; 
end