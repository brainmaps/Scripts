function [regions, seeds] = jh_waterseeds3D(im, varargin)
%jh_waterseeds3D gets watershed borders or regions by applying a 3D
%watershed to the whole volume or a 2D watershed to each slice individually
%
% SYNOPSIS
%   [regions, seeds] = jh_waterseeds3D(im)
%   [regions, seeds] = jh_waterseeds3D(___, 'outType', outType)
%   [regions, seeds] = jh_waterseeds3D(___, 'connectivity', conn)
%   [regions, seeds] = jh_waterseeds3D(___, 'maxDepth', maxDepth)
%   [regions, seeds] = jh_waterseeds3D(___, 'maxSize', maxSize)
%   [regions, seeds] = jh_waterseeds3D(___, 'calcType', calcType)
%
% INPUT
%   im: greyscale image
%   outType:
%       'bin' (default): returnes binary result, regions are set to 1
%       'inv': returnes binary result, borders are set to 1
%       'lab': returnes labeled result
%   conn: connectivity
%       1 for 4-connectivity 
%       2 for 8-connectivity (default)
%   maxDepth, maxSize: Determine merging of regions;
%       A region up to maxSize pixels and up to maxDepth grey-value
%       difference will be merged
%   calcType: 
%       '3D' (default): 3D watershed to the whole volume
%       '2D': 2D watershed to each slice
%
% DEFAULTS
%   type = 'bin'
%   conn = 2
%   maxDepth = 0 (only merging within plateaus)
%   maxSize = 0 (any size)
%
% OUTPUT
%   ws: Regions or borders, depending on type

%% Check input

% Defaults
conn = 2; % 8-connectivity
maxSize = 0;
maxDepth = 0;
outType = 'bin';
calcType = '3D';
% Check input
i = 0;
while i < length(varargin)
    i = i+1;
    
    if strcmp(varargin{i}, 'outType')
        outType = varargin{i+1};
        i = i+1;
    elseif strcmp(varargin{i}, 'connectivity')
        conn = varargin{i+1};
        i = i+1;
    elseif strcmp(varargin{i}, 'maxDepth')
        maxDepth = varargin{i+1};
        i = i+1;
    elseif strcmp(varargin{i}, 'maxSize')
        maxSize = varargin{i+1};
        i = i+1;
    elseif strcmp(varargin{i}, 'calcType')
        calcType = varargin{i+1};
        i = i+1;
    end
    
end

if strcmp(outType, 'lab')
    binOut = 0;
else
    binOut = 1;
end

%% 

% Size of the image
n1 = size(im, 1);
n2 = size(im, 2);
n3 = size(im, 3);

if isa(im, 'single')
    outType = 'int32';
else
    outType = class(im);
end

%% 2D watershed
if strcmp(calcType, '2D')
    
    % Get the watershed borders
    maxLabel = 0;
    regions = zeros(n1,n2,n3, outType);
    seeds = zeros(n1,n2,n3, outType);
    for i = 1:n3
        dipSeeds = minima(im(:,:,i), conn, binOut);
        image_out = jh_dip_waterseed(dipSeeds, im(:,:,i), conn, maxDepth, maxSize);
        r = im2mat(image_out);
        r(r > 0) = r(r > 0) + maxLabel; 
        regions(:,:,i) = r;
        s = im2mat(dipSeeds);
        s(s > 0) = s(s > 0) + maxLabel;
        maxLabel = max(max(s));
        seeds(:,:,i) = s;
    end
    
end

%% 3D watershed

if strcmp(calcType, '3D')
    
    dipSeeds = minima(im, conn, binOut);
    image_out = jh_dip_waterseed(dipSeeds, im, conn, maxDepth, maxSize);
    seeds = im2mat(dipSeeds);
    regions = im2mat(image_out);
    
end

%%
% Invert to get the regions
if strcmp(outType, 'inv')
    regions = 1 - regions;
end

end