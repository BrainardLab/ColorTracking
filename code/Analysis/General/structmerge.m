function S = structmerge(S1,S2,dimLength)

% function S = structmerge(S1,S2,dimLength)
%
%   example call:
%
% merges two structs by concatenating fields...
% current implementation requires that structs have
% same field names
%
% S1:        structure 1
% S2:        structure 2
% dimLength: length of dimension from which to select
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% S:          merged struct

if isempty(S1), S = S2; return; end

S1 = orderfields(S1,S2);
fieldNames1 = fieldnames((S1));
fieldNames2 = fieldnames((S2));

if isequal(fieldNames1,fieldNames2)
   S = [];
   for f = 1:length(fieldNames1)
       % STRUCT 2 FIELD VALUES
       F1 = S1.(fieldNames1{f});
       % STRUCT 1 FIELD VALUES
       F2 = S2.(fieldNames2{f});
       % SIZE OF FIELD
       Fsz = size(F2);
       % DIMENSION TO SELECT FROM
       if ~exist('dimLength','var') || isempty(dimLength)
       % INDEX TO LARGEST FIELD DIMENSION
           [~,indMax] = max(Fsz);
       else
       % INDEX TO THE USER-SPECIFIED FIELD DIMENSION
           indMax = find(Fsz==dimLength);
       end
       if Fsz(1) ~= 1 && ~isempty(indMax)
       S = setfield(S,fieldNames1{f}, cat(indMax,F1,F2));
       elseif Fsz(1) == 1 || isempty(indMax)
       S = setfield(S,fieldNames1{f}, F1);
       end
   end
else
    error(['structmerge: WARNING! struct 1 and 2 fieldnames are not equal']);
end


