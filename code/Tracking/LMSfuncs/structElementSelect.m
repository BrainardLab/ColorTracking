function Sgd = structElementSelect(S,indGd,dimLength)

%function Sgd = structElementSelect(S,indGd,dimLength)
%
%   example call:
%
% S:         input  structure
% indGd:     indices in dimension dim to select
% dimLength: length of dimension from which to select
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sgd:   output structure

if nargin < 3
    disp(['structElementSelect: WARNING! risky call. Add in 3rd input argument if possible']);
end
% GET ALL FIELD NAMES
fieldNames = fieldnames(S);

for i = 1:length(fieldNames)
    % CURRENT FIELD VALUES
    F = S.(fieldNames{i});
    % CURRENT FIELD SIZE
    Fsz = size(F);
	% DIMENSION TO SELECT FROM
    if ~exist('dimLength','var') || isempty(dimLength)
	% INDEX TO LARGEST FIELD DIMENSION
        [~,indMax] = max(Fsz);
    else
	% INDEX TO THE USER-SPECIFIED FIELD DIMENSION
        indMax = find(Fsz==dimLength);
    end
    %SHARED/GENERIC FIELDS
    if (Fsz(indMax) < max(indGd)) | isempty(indMax)
        Sgd.(fieldNames{i}) = F;
    %MULTIDIMENSIONAL FIELDS
    else
        % SELECT ONLY GOOD INDICES IN LARGEST DIMENSION
        [Fgd,~] = arrayIndSzUnknown(F,indMax,indGd);
        % KEEP ONLY THE ENTRIES WITH THE GOOD INDICES IN THE NEW STRUCTURE
        Sgd.(fieldNames{i}) = Fgd;
    end
end
