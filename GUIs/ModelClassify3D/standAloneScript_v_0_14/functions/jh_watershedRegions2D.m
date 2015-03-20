function ws = jh_watershedRegions2D(im, varargin)
%jh_watershedRegions2D gets watershed borders or regions
%
% SYNOPSIS
%   ws = jh_watershedRegions2D(im)
%   ws = jh_watershedRegions2D(im, connectivity)
%   ws = jh_watershedRegions2D(im, connectivity, max_depth)
%   ws = jh_watershedRegions2D(im, connectivity, max_depth, max_size)
%   ws = jh_watershedRegions2D(im, connectivity, max_depth, max_size, type)
%
% INPUT
%   im: The image used to calculate the WS-regions
%   connectivity: 
%       1 for 4-connectivity 
%       2 for 8-connectivity (default)
%   max_depth, max_size: Determine merging of regions
%       A region up to 'max_size' pixels and up to 'max_depth' grey-value
%       difference will be merged
%       Defaults: 
%           max_depth = 0 (only merge within plateaus) 
%           max_size = 0 (any size);
%   type: 'inv' (default) to get the regions, any other string to get the 
%       borders
%
% OUTPUT
%   ws: Regions or borders, depending on type

%% Check input

% Defaults
connectivity = 2; % 8-connectivity
max_depth = 0;
max_size = 0;
type = 'inv';
% Check input
if ~isempty(varargin)
    % varargin is not empty
    % First input: connectivity
    connectivity = varargin{1};
    % Second input: maximum depth
    if length(varargin) >= 2
        max_depth = varargin{2};
    end
    % Third input: maximum size
    if length(varargin) >= 3
        max_size = varargin{3};
    end
    % Fourth input: type
    if length(varargin) == 4
        type = varargin{4};
    end
end

%% 

% Size of the image
n1 = size(im, 1);
n2 = size(im, 2);
n3 = size(im, 3);

% Get the watershed borders
ws = zeros(n1,n2,n3);
for i = 1:n3
    image_out = watershed(im(:,:,i), connectivity, max_depth, max_size);
    ws(:,:,i) = im2mat(image_out);
end

% Invert to get the regions
if strcmp(type, 'inv')
    ws = 1 - ws;
end

end