function [Agd,ind] = arrayIndSzUnknown(A,dim,indGd)

% function ind = arrayIndSzUnknown(A,dim,indGd)
% 
% A      :  multidimensional array of unknown size
% dim    :  dimension to which indexing is applied
% indGd  :  indices in dimension dim to select
%%%%%%%%%
% ind    :  comma-separated argument list for accessing required elements from A
% Agd    :  array with selected elements of A

ind(1:ndims(A)) = {':'};
ind(dim)       = {indGd};
Agd = A(ind{:});


