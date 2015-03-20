function imMex = jh_mexicanHat2D(image, sigma)
%jh_imageGradient calculates the second derivative of an image
%
% SYNOPSIS
%   [gradient, magnitude] = jh_mexicanHat2D(image, sigma)
%
% INPUT
%   image: the original image
%   sigma: Gaussian sigma used to calculate the derivatives
%
% OUTPUT
%   gradient: the image gradient
%   magnitude: matrix containing the magnitude of the gradient field

% Make kernel coordinates
mult = 3;
[x,y] = ndgrid(-round(mult*sigma):round(mult*sigma));

% Gauss and its derivatives:
% G = 1/(2*pi*sigma^2) * exp(-(x^2+y^2)/(2*sigma^2))
% Gx = -x/(2*pi*sigma^4) * exp(-(x^2+y^2)/(2*sigma^2))
% Gxx = (x^2-sigma^2) / (2*pi*sigma^6) * exp(-(x^2+y^2)/(2*sigma^2))

% Calculate Gaussian filter mask
Dxx = (x.^2-sigma^2) / (2*pi*sigma^6) .* exp(-(x.^2+y.^2)/(2*sigma^2));
Dyy = (y.^2-sigma^2) / (2*pi*sigma^6) .* exp(-(x.^2+y.^2)/(2*sigma^2));

%Calculate the mexican hat kernel
mex = Dxx + Dyy;

% Calculate image derivatives
imMex = imfilter(image,mex,'conv','symmetric' );

end

