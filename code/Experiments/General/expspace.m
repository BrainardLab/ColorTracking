function y = expspace(x1,x2,n)

% function y = expspace(x1,x2,n)
% 
%   generates vector of n expontially spaced points between x1 and x2
% 
% x1: limit 1
% x2: limit 2
% n:  number of points (default 10)
% %%%%%%%%%%%%%%%%%%%%%%
% y:  exponentially spaced points (linear on a log axis)

if nargin == 2, n = 10; end

y = exp(linspace(log(x1),log(x2),n));