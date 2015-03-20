function [minima, regions] = jh_regionMinima(im, regions, clearNearBorder)
%jh_regionMinima determins minima of regions for a supplied image
%
% SYNOPSIS
%   [minima, regions] = jh_regionMinima(im, regions)
%
% INPUT
%   im: The image
%   regions: The regions (have to be clearly separated)
%       note: 1 specifies position within a region, 0 specifies border
%
% OUTPUT
%   minima: The labeled minima of each region in a matrix
%   regions: The accordingly labeled regions

% Size of the image
n1 = size(im, 1);
n2 = size(im, 2);
n3 = size(im, 3);
n = n1*n2*n3;

largestLabel = 0;
labRegions = zeros(n1, n2, n3);
% This loop labels each region
for i = 1:n3
    % Label the regions of each slice individually
    TLabWS = bwlabeln(regions(:,:,i), 8);
    % Add the largest previously used label to get individual labels for
    % each slice
    TLabWS(TLabWS ~= 0) = TLabWS(TLabWS ~= 0) + largestLabel;
    labRegions(:,:,i) = TLabWS;
    largestLabel = max(max(labRegions(:,:,i)));
end

linCoordinates = 1:n;
linCoordinates = reshape(linCoordinates, n1, n2, n3);
minima = zeros(n1, n2, n3);
% This loop gets the minimum pixel of each region
for i = 1:largestLabel
     if ~isempty(find(labRegions == i, 1))
        
        % Get list of intensities for current region
        intensities = im(labRegions == i);
        % The according positions in linear coordinates
        positions = linCoordinates(labRegions == i);
        % Get the minimum of the intensities and its position
        minInt = min(intensities);
        minimum = positions(intensities == minInt);
        % Write the mimimum and its label at the correct position
        minima(minimum) = i; 

    end
end
% Clear everything near the borders
minima(1:clearNearBorder, :, :) = 0;
minima(end-clearNearBorder:end, :, :) = 0;
minima(:, 1:clearNearBorder, :) = 0;
minima(:, end-1:end, :) = 0;
minima(:, :, 1:clearNearBorder) = 0;
minima(:, :, end-1:end) = 0;

regions = labRegions;

end