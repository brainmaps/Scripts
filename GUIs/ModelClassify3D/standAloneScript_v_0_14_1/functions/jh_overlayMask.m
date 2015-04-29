function overlayImage = jh_overlayMask(image, mask)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[nr, nc, nd] = size(image);

% The image has to be normalized
if nd == 1
    % 2D
    image = image/max(max(image));
elseif nd > 1
    % 3D 
    image = image/max(max(max(image)));
end

% Initialize overlayImage as the original image
overlayImage = image;

% for 2D image
if nd == 1
    % Overlay the mask using dimension channel 2 and 3
    ch23 = overlayImage(:,:,1);
    ch23(mask ~= 0) = 1;
    ch23 = ch23(:,:,ones(2,1));
    overlayImage(:,:,2:3) = ch23(:,:,ones(2,1));
    % Overlay channel 1
    ch1 = overlayImage(:,:,1);
    ch1(mask ~= 0) = 0;
    overlayImage(:,:,1) = ch1;

% for 3D image
elseif size(image, 3) > 1
    % Overlay the mask using dimension channel 2 and 3
    ch23 = overlayImage(:,:,:,1);
    ch23(mask ~= 0) = 1;
    ch23 = ch23(:,:,:,ones(2,1));
    overlayImage(:,:,:,2:3) = ch23(:,:,:,ones(2,1));
    % Overlay channel 1
    ch1 = overlayImage(:,:,:,1);
    ch1(mask ~= 0) = 0;
    overlayImage(:,:,:,1) = ch1;
    
end

end

