function mitos = md_mitos3(volume,hsize,sigma,threshold,minPx)
%MD_MITOS3 Roughly detects mitochondria by using their relative darkness in EM images.
%
% v2.0
%
% Based on 3D gaussian blur, intensity thresholding and region size limits.
%
% Similar to md_mitos2, but it uses a 3D gaussian blur and 3D opening instead
% and it handles 3D image volumes instead of just 2D images.
% It is potentially more accurate than md_mitos2, but it takes much more
% time to calculate.
%
% Note that this function actually detects large dark structures in general
% and does not take the specific form of mitochondria into account, so it is
% currently not very reliable, e.g. PSDs are often mistaken for mitochondria.
%
% SYNOPSIS
%   mitos = md_mitos3(volume,hsize,sigma,threshold,minPx)
%   mitos = md_mitos3(volume,hsize,sigma,threshold)
%   mitos = md_mitos3(volume,hsize,sigma)
%   mitos = md_mitos3(volume,hsize)
%   mitos = md_mitos3(volume)
%
% INPUT
%   volume (double): Image volume that should be processed, e.g. one loaded
%       by md_readvol (grayscale, values between 0 and 1).
%   hsize (uint8): "hsize" argument for the gaussian blur filter.
%       Note that this argument is a vector that can determine the filter size
%       in X,Y and Z direction independently. Consider changing the
%       relative values to adapt to non-isometric datasets. Default: [5,5,5].
%   sigma (double): "sigma" argument for the gaussian blur filter. Default: 2.
%   threshold (double): intensity threshold for the distinction of mitochondria
%       from other image contents. Default: 0.25
%   minPx (uint8): Determines the minimum size of connected volumes.
%       Can reduce false positives, but if set too high, it can lead to
%       false negatives. Default: 561
%
% OUTPUT
%   mitos: binary map of the mitochondria (currently not very reliable)

%defaults
if ~exist('hsize','var'), hsize = [5,5,5]; end
if ~exist('sigma','var'), sigma = 2; end
if ~exist('threshold','var'), threshold = .25; end
if ~exist('minPx','var'), minPx = 561; end % Smallest mito found in dataset is 561 px


% apply a 3D gaussian blur filter.
volumeBlur = smooth3(volume,'gaussian',hsize,sigma);
% NOTE: "smooth3" is very slow. Maybe there is a faster implementation.

% make a binary map of all the pixels below the threshold found in the blurred volume
mitosT = volumeBlur < threshold;

% eliminate all objects smaller than minPx
mitosE = bwareaopen(mitosT,minPx);

% fill holes in marked regions
mitos = imfill(mitosE,'holes');

end
