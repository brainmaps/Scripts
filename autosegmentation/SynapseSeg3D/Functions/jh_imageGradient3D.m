function [gradient, magnitude] = jh_imageGradient3D(image, sigma)
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
[X,Y,Z] = ndgrid(-round(mult*sigma):round(mult*sigma));

% Calculate Gaussian filter mask
Dx = -(X.*exp(-(X.^2 + Y.^2 + Z.^2)/(2*sigma^2)))/sigma^3;
Dy = -(Y.*exp(-(X.^2 + Y.^2 + Z.^2)/(2*sigma^2)))/sigma^3;
Dz = -(Z.*exp(-(X.^2 + Y.^2 + Z.^2)/(2*sigma^2)))/sigma^3;

% Calculate image derivatives
Ix = imfilter(image,Dx,'conv','symmetric' );
Iy = imfilter(image,Dy,'conv','symmetric' );
Iz = imfilter(image,Dz,'conv','symmetric' );

% Return the gradient
gradient(:,:,:,1) = Ix;
gradient(:,:,:,2) = Iy;
gradient(:,:,:,3) = Iz;

% Calculate the magnitude
magnitude = ( gradient(:,:,:,1).^2 + gradient(:,:,:,2).^2 + gradient(:,:,:,3).^2 ) .^ (1/2);
end
