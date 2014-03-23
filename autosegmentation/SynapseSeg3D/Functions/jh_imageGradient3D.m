function [gradient, magnitude] = jh_imageGradient3D(image, sigma, varargin)
%jh_imageGradient calculates the gradient of an image
%
% SYNOPSIS
%   [gradient, magnitude] = jh_imageGradient3D(image, sigma)
%   [gradient, magnitude] = jh_imageGradient3D(image, sigma, mult)
%   [gradient, magnitude] = jh_imageGradient3D(image, sigma, mult, anisotropic)
%
% INPUT
%   image: the original image
%   sigma: Gaussian sigma used to calculate the derivatives
%   mult: Factor to determine the kernel size for the Gaussian; the kernel
%       size is calculated by mult*sigma+1
%       default: mult = 3
%   anisotropic: specifies anisotropic voxels; e.g., anisotropic = [1 1 3]
%       default: anisotropic = [1 1 1]
%
% OUTPUT
%   gradient: the image gradient
%   magnitude: matrix containing the magnitude of the gradient field

%% Check input

% Defaults
mult = 3;
anisotropic = [1 1 1];
% Check input
if ~isempty(varargin)
    % varargin is not empty
    % First input: mult
    mult = varargin{1};
    % Second input: for anisotropic voxels
    if length(varargin) == 2
        anisotropic = varargin{2};
    end
end

%% 

% Make kernel coordinates
r_1 = floor(-mult*sigma/anisotropic(1)); r_end = ceil(mult*sigma/anisotropic(1));
c_1 = floor(-mult*sigma/anisotropic(2)); c_end = ceil(mult*sigma/anisotropic(2));
d_1 = floor(-mult*sigma/anisotropic(3)); d_end = ceil(mult*sigma/anisotropic(3));
[r,c,d] = ndgrid(r_1:r_end, c_1:c_end, d_1:d_end);
r = r * anisotropic(1);
c = c * anisotropic(2);
d = d * anisotropic(3);

% Gauss and its derivatives:
% G = 1/((2*pi*sigma^2)^(1/2))^3 * exp(-(x^2+y^2+z^2)/(2*sigma^2))
% Gx = -x/((2*pi)^(3/2)*sigma^5) * exp(-(x^2+y^2+z^2)/(2*sigma^2))
% Gxx = (x^2-sigma^2) / ((2*pi)^(3/2)*sigma^7) * exp(-(x^2+y^2+z^2)/(2*sigma^2))

% Calculate Gaussian filter mask
Dx = -r/((2*pi)^(3/2)*sigma^5) .* exp(-(r.^2+c.^2+d.^2)/(2*sigma^2));
Dy = -c/((2*pi)^(3/2)*sigma^5) .* exp(-(r.^2+c.^2+d.^2)/(2*sigma^2));
Dz = -d/((2*pi)^(3/2)*sigma^5) .* exp(-(r.^2+c.^2+d.^2)/(2*sigma^2));

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

