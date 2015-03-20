function nData = jh_normalizeData(data, minValue, maxValue, typeOut)
%jh_normalizeMatrix normalizes a matrix of any dimension
%
% SYNOPSIS
%   nM = jh_normalizeMatrix(M)
%   nM = jh_normalizeMatrix(M, minValue, maxValue);
%   nM = jh_normalizeMatrix(M, minValue, maxValue, typeOut);
%
% INPUT
%   data: cell array containing several matrices
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
    typeOut = class(data{1});
    if isa(data, 'uint8')
        minValue = 0;
        maxValue = 255;
    end
end

%%

min(cat(1,data)) ;



minM = data;
while ~isequal(size(minM), [1,1])
    minM = min(minM);
end
data = data - minM;

maxM = data;
while ~isequal(size(maxM), [1,1])
    maxM = max(maxM);
end
% nM = cast(M,typeOut) * cast((maxValue / maxM),typeOut) + minValue;

corrType = class(data);
if isa(data, 'uint8')
    corrType = 'single';
end


nData = cast(cast(data,corrType) / double(maxM) * (maxValue-minValue) + minValue, typeOut); 

end

function gMin = getGlobalMin(M)

    gMin = M;
    while ~isequal(size(gMin), [1,1])
        gMin = min(gMin);
    end

end

function gMax = getGlobalMax(M)

    gMax = M;
    while ~isequal(size(gMax), [1,1])
        gMax = max(gMax);
    end
    
end

