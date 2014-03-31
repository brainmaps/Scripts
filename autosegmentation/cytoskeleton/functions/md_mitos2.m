function mitos = md_mitos2(image,hsize,sigma,threshold,minPx)
%MD_MITOS2 Roughly detects mitochondria by using their relative darkness in EM images.
%
% v1.0
%
% Based on 2D gaussian blur, intensity thresholding and noise reduction by opening.
%
% It is quite inaccurate but very fast. For more precision in 3D data, use md_mitos3.
%
% SYNOPSIS
%   mitos = md_elim_mitos2(image,hsize,sigma,threshold)
%   mitos = md_elim_mitos2(image,hsize,sigma)
%   mitos = md_elim_mitos2(image,hsize)
%   mitos = md_elim_mitos2(image)
%
% INPUT
%   image (double):"hsize" argument for the gaussian blur filter. Default: 20.
%   sigma (double): "sigma" argument for the gaussian blur filter Default: 2.
%   threshold (double): intensity threshold for the distinction of mitochondria from
%       other image contents. Default: 0.25
%   minPx (uint8): Determines the minimum size of connected areas.
%       Can reduce false positives, but if set too high, it can lead to
%       false negatives. Default: 40
%
% OUTPUT
%   mitos: binary map of the mitochondria

%defaults
if ~exist('hsize','var'), hsize = 20; end
if ~exist('sigma','var'), sigma = 2; end
if ~exist('threshold','var'), threshold = .25; end
if ~exist('minPx','var'), minPx = 40; end % not well tested

% apply gaussian blur filter
filter = fspecial('gaussian', hsize,sigma);
imageBlur = imfilter(image, filter);

% make a binary map of all the pixels below the threshold found in the
% blurred image
mitosT = imageBlur < threshold;

% eliminate all objects smaller than minPx
mitosE = bwareaopen(mitosT,minPx);

% fill holes in marked regions
mitos = imfill(mitosE,'holes');

end
