function [overlay, boundaries] = jh_createEdgeOverlay(image, mask, diameter, dimensions)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Size of mask and image must be the same, otherwise return null
if size(mask) ~= size(image)
    overlay = [];
    boundaries = [];
    return;
end

% For 2D or 3D images
boundaries = zeros(size(mask));

% One step to the right
tMask1 = [mask(:,1,:), mask];
tMask2 = [mask, mask(:,end,:)];
rBoundaries = tMask1 - tMask2;
rBoundaries = rBoundaries(:, 1:end-1, :);


if dimensions <= 2

    % One step down
    tMask1 = [mask(1,:,:); mask];
    tMask2 = [mask; mask(1,:,:)];
    dBoundaries = tMask1-tMask2;
    dBoundaries = dBoundaries(1:end-1, :, :);

end

% Combine
boundaries(rBoundaries ~= 0 | dBoundaries ~= 0) = 1;

if dimensions <= 3
    
    % Perform for left, up, and foreward as well
    
end

overlay = jh_overlayMask(image,boundaries);

end

