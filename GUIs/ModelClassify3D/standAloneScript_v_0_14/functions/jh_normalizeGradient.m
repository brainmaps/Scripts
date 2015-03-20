function nGF = jh_normalizeGradient(GF, varargin)
%jh_normalizeGradient calculates a normalized gradient field
%
% SYNOPSIS
%   nGF = jh_normalizeGradient(GF)
%   nGF = jh_normalizeGradient(GF, magnitude)
%
% INPUT
%   GF: The gradient field which will be normalized
%   magnitude: The magnitude of the gradient field
%
% OUTPUT
%   nGF: The normalized gradient field

%% Check input

% Defaults
mag = [];
% Check input
if ~isempty(varargin)
    % varargin is not empty
    % The first position defines the magnitude
    mag = varargin{1};
else
    
end

%% The function

if size(GF, 2) > 1 && size(GF, 3) == 2
    if isempty(mag)
        mag = sqrt( GF(:,:,1).^2 + GF(:,:,2).^2 );
    end
    mag(:,:,1) = mag;
    mag(:,:,2) = mag(:,:,1);
    nGF = GF ./ mag;
elseif size(GF, 3) > 1 && size(GF, 4) == 3
    if isempty(mag)
        mag = sqrt( GF(:,:,:,1).^2 + GF(:,:,:,2).^2 + GF(:,:,:,3).^2 );
    end
    mag(:,:,:,1) = mag;
    mag(:,:,:,2) = mag(:,:,:,1);
    mag(:,:,:,3) = mag(:,:,:,1);
    nGF = GF ./ mag;
else
    nGF = [];
end

end

