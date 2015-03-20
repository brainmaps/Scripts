function gauss = jh_dip_gaussianXsq3D(im, sigma, varargin)
%
% SYNOPSIS
%   gauss = jh_gaussianFilter3D(im, sigma)
%   gauss = jh_gaussianFilter3D(im, sigma, mult)
%   gauss = jh_gaussianFilter3D(im, sigma, mult, anisotropic)
%   gauss = jh_gaussianFilter3D(im, sigma, mult, anisotropic, maxKernel)
%   gauss = jh_gaussianFilter3D(___, 'normalizeKernel')
%
% INPUT
%   im: the original image
%   sigma: Gaussian sigma
%   mult: Factor to determine the kernel size for the Gaussian; the kernel
%       size is calculated by mult*sigma+1
%       default: mult = 3
%   anisotropic: specifies anisotropic voxels; e.g., anisotropic = [1 1 3]
%       default: anisotropic = [1 1 1]
%   maxKernel: the maximum of the Gaussian function; when set to 0 the
%       standard Gaussian function is used
%       default: maxKernel = 0;
%   additional parameters:
%       'normalizeKernel': The kernel is normalized to 1
%
% OUTPUT
%   gauss: Gaussian smoothed image

%% Check input

% Defaults
mult = 3;
anisotropic = [1 1 1];
maxKernel = 0;
normalizeKernel = false;
% Check input
if ~isempty(varargin)
    
    i = 0;
    while i < length(varargin)
        i = i+1;
        
        if ~isa(varargin{i}, 'string')
            if strcmp(varargin{i}, 'normalizeKernel')
                normalizeKernel = true;
            end
        else
            if i == 1
                mult = varargin{i};
            elseif i == 2
                anisotropic = varargin{i};
            elseif i == 3
                maxKernel = varargin{i};
            end
        end
        
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
G = (r.^2 + c.^2 + d.^2)/((2*pi*sigma^2)^(3/2)) .* exp(-(r.^2+c.^2+d.^2)/(2*sigma^2));

% Modify the kernel according to the input
if maxKernel ~= 0
    G = G / G((size(G,1) * size(G,2) * size(G,3) + 1) / 2) * maxKernel;
end
if normalizeKernel
    G = G / sum(sum(sum(G)));
end

% Convolution
gauss = im2mat(convolve(im, G));

end

