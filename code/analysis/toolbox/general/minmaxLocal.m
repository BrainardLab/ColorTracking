function [MinMax] = minmaxLocal(X)

% function [MinMax] = minmaxLocal(X)
% 
%   example call: minmaxLocal(1:5)
%
% returns min and max values of vector or matrix
%
% X:        vector or matrix
% %%%%%%%%%%%%%%%%%%%%
% MinMax:   min and max values in X [ 1 x 2]

MinMax(1) = min(X(:));
MinMax(2) = max(X(:));