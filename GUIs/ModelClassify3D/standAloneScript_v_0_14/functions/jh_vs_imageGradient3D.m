function [GF, mag] = jh_vs_imageGradient3D(debug, nameRun, nameParam, im, sigma, varargin)
% 
% SYNOPSIS
%   [GF, mag] = jh_vs_imageGradient3D(debug, nameRun, nameParam, im, sigma)
%   [GF, mag] = jh_vs_imageGradient3D(debug, nameRun, nameParam, im, sigma, mult)
%   [GF, mag] = jh_vs_imageGradient3D(debug, nameRun, nameParam, im, sigma, mult, anisotropic)
%
% INPUT
%   im: image used to calculate the gradient
%   sigma: Gaussian sigma used for calculation of the derivatives
%   mult: Factor to determine the kernel size for the Gaussian; the kernel
%       size is calculated by mult*sigma+1
%       default: mult = 3
%   anisotropic: specifies anisotropic voxels; e.g., anisotropic = [1 1 3]
%       default: anisotropic = [1 1 1]
%
% OUTPUT
%   GF: gradient field
%   mag: the magnitude of the gradient field

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

fprintf('    Calculation: Gradient field... ');
tic;

[GF, mag] = jh_imageGradient3D(im, sigma, mult, anisotropic);
mag = jh_normalizeMatrix(mag);

% Debug
if debug
    saveImageAsTiff3D(mag, [nameRun '_' nameParam '.TIFF']);
end

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end

