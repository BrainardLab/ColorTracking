function smpFrqCpu = smpPos2smpFrq(smpPosUnt)

% function smpFrqCpu = smpPos2smpFrq(smpPosUnt)
%
%   example call: smpPos2smpFrq(smpPos(10,10))
% 
% convert sample positions to sample frequencies
%
% smpPosUnt:  sample positions in units (e.g. deg, pixels, etc.)
%%%%%%%%%%
% smpFrqCpu: corresponding samples in frequency units (e.g. cpd, cpp, etc.)



if numel(smpPosUnt)>1
    % SMP SEPARATION
    smpSepUnt = diff(smpPosUnt(1:2));   
    % SMP FREQUENCY
    smpFrqCpu = linspace(-.5./smpSepUnt,+.5./smpSepUnt-(1./smpSepUnt)./length(smpPosUnt),length(smpPosUnt));
else
    smpFrqCpu = 0; 
end