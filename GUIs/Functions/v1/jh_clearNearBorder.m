function cleared = jh_clearNearBorder(M, varargin)
%jh_clearNearBorder sets pixels near the border of a matrix to zero
%
% SYNOPSIS
%   cleared = jh_clearNearBorder(M)
%   cleared = jh_clearNearBorder(M, b)
%   cleared = jh_clearNearBorder(M, bR, bC)
%   cleared = jh_clearNearBorder(M, bR, bC, bD)
%
% INPUT
%   M: and 2D or 3D matrix
%   b: border size (the same for each dimension)
%   bR, bC, bD: border sizes for each dimension (R = row, C = column, 
%       D = depth)
%
% DEFAULTS
%   b = 1
%   bR, bC, bD = 1
%
% OUTPUT
%   cleared: all pixels at the borders are set to zero

%% Check input

% Defaults
b = 1;
bR = 1;
bC = 1;
bD = 1;
type = 0;
% Check input
if ~isempty(varargin)
    % varargin is not empty
    if length(varargin) == 1
        b = varargin{1};
    elseif length(varargin) > 1
        type = 1;
        bR = varargin{1};
        bC = varargin{2};
        if length(varargin) == 3
            bD = varargin{3};
        end
    end
end

% Check dimensions
if size(M, 2) > 1 && size(M, 3) == 1
    dimensions = 2;
elseif size(M, 3) > 1 && size(M, 4) == 1
    dimensions = 3;
end

%%

if type == 0 
    
    if dimensions == 2
        M(1:b, :) = 0;
        M(end-(b-1):end, :) = 0;
        M(:, 1:b) = 0;
        M(:, end-(b-1):end) = 0;
    else
        M(1:b, :, :) = 0;
        M(end-(b-1):end, :, :) = 0;
        M(:, 1:b, :) = 0;
        M(:, end-(b-1):end, :) = 0;
        M(:, :, 1:b) = 0;
        M(:, :, end-(b-1):end) = 0;
    end
    
else
    
    if dimensions == 2
        M(1:bR, :) = 0;
        M(end-(bR-1):end, :) = 0;
        M(:, 1:bC) = 0;
        M(:, end-(bC-1):end) = 0;
    else
        M(1:bR, :, :) = 0;
        M(end-(bR-1):end, :, :) = 0;
        M(:, 1:bC, :) = 0;
        M(:, end-(bC-1):end, :) = 0;
        M(:, :, 1:bD) = 0;
        M(:, :, end-(bD-1):end) = 0;
    end
    
end

cleared = M;
end