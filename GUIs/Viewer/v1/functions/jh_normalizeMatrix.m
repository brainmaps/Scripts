function nM = jh_normalizeMatrix(M, minValue, maxValue, typeOut)
%jh_normalizeMatrix normalizes a matrix of any dimension
%
% SYNOPSIS
%   nM = jh_normalizeMatrix(M)
%   nM = jh_normalizeMatrix(M, minValue, maxValue);
%   nM = jh_normalizeMatrix(M, minValue, maxValue, typeOut);
%
% INPUT
%   M: the matrix
%   minValue, maxValue: the range of the output image
%   typeOut: defines the data type for the output
%       'same' (default): input and output have the same data type
%
% DEFAULTS
%   minValue = 0
%   maxValue = 1
%   typeOut = 'same'
%
% OUTPUT
%   nM: the normalized matrix

%% Check input

if nargin == 1
    typeOut = 'same';
    minValue = 0;
    maxValue = 1;
elseif nargin == 3
    typeOut = 'same';
elseif nargin == 4
    
else
    disp('jh_normalizeMatrix: Invalid parameters, default used');
    minValue = 0;
    maxValue = 1;
    typeOut = 'same';
end

if strcmp(typeOut,'same')
    typeOut = class(M);
    if isa(M, 'uint8')
        minValue = 0;
        maxValue = 255;
    end
end

%%

minM = M;
while ~isequal(size(minM), [1,1])
    minM = min(minM);
end
M = M - minM;

maxM = M;
while ~isequal(size(maxM), [1,1])
    maxM = max(maxM);
end
% nM = cast(M,typeOut) * cast((maxValue / maxM),typeOut) + minValue;

corrType = class(M);
if isa(M, 'uint8')
    corrType = 'single';
end


nM = cast(cast(M,corrType) / double(maxM) * (maxValue-minValue) + minValue, typeOut); 

end

