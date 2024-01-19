function [MinMax] = minmax(X)

% function [MinMax] = minmax(X)
% 
%   example call: minmax(1:5)
%
% returns min and max values of vector or matrix
%
% X:        vector or matrix
% %%%%%%%%%%%%%%%%%%%%
% MinMax:   min and max values in X [ 1 x 2]

MinMax(1) = min(X(:));
MinMax(2) = max(X(:));