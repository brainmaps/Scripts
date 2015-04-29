function [gradient, magnitude] = jh_imageGradient2D(image, sigma)
%jh_imageGradient calculates the gradient of an image
%
% SYNOPSIS
%   [gradient, magnitude] = jh_imageGradient(image, sigma)
%
% INPUT
%   image: the original image
%   sigma: Gaussian sigma used to calculate the derivatives
%
% OUTPUT
%   gradient: the image gradient
%   magnitude: matrix containing the magnitude of the gradient field

% Make kernel coordinates
mult = 1;
[X,Y] = ndgrid(-round(mult*sigma):round(mult*sigma));

% Calculate Gaussian filter mask
Dx = -(X.*exp(-(X.^2 + Y.^2)/(2*sigma^2))) / (2*pi*sigma^4);
Dy = -(Y.*exp(-(X.^2 + Y.^2)/(2*sigma^2))) / (2*pi*sigma^4);

% Calculate image derivatives
Ix = imfilter(image,Dx,'conv','symmetric' );
Iy = imfilter(image,Dy,'conv','symmetric' );

% Return the gradient
gradient(:,:,1) = Ix;
gradient(:,:,2) = Iy;

% Calculate the magnitude
magnitude = ( gradient(:,:,1).^2 + gradient(:,:,2).^2 ) .^ (1/2);
end

