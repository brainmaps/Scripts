function mitos = md_mitos3(inputPath,outputPath,hsize,sigma,threshold,minPx)
%MD_MITOS3 Roughly detects mitochondria by using their relative darkness in EM images.
%
% v1.0
%
% Based on 3D gaussian blur, intensity thresholding and noise reduction by opening.
%
% Similar to md_mitos2, but it uses a 3D gaussian blur and 3D opening instead
% and it handles stacks of TIF images instead of just 2D images.
% It is potentially more accurate than md_mitos2, but it takes much more
% time to calculate.
%
% SYNOPSIS
%   mitos = md_mitos3(inputPath,outputPath,hsize,sigma,threshold,minPx)
%   mitos = md_mitos3(inputPath,outputPath,hsize,sigma,threshold)
%   mitos = md_mitos3(inputPath,outputPath,hsize,sigma)
%   mitos = md_mitos3(inputPath,outputPath,hsize)
%   mitos = md_mitos3(inputPath,outputPath)
%   mitos = md_mitos3(inputPath)
%
% INPUT
%   inputPath (string): Path that contains the data in TIF format. (The files
%       should have names like "0000.tif", "0001.tif", and so on.)
%   outputPath (string): Directory that the results should be written into.
%       If you do not want the function to write any files, use 'none' as
%       its value. Default: 'none'
%   hsize (uint8): "hsize" argument for the gaussian blur filter.
%       Note that this argument is a vector that can determine the filter size
%       in X,Y and Z direction independently. Consider changing the
%       relative values to adapt to non-isometric datasets. Default: [5,5,5].
%   sigma (double): "sigma" argument for the gaussian blur filter. Default: 20.
%   threshold (double): intensity threshold for the distinction of mitochondria from
%       other image contents. Default: 0.25
%   minPx (uint8): Determines the minimum size of connected volumes.
%       Can reduce false positives, but if set too high, it can lead to
%       false negatives. Default: 600
%
% OUTPUT
%   mitos: binary map of the mitochondria

%defaults
if ~exist('outputPath','var'), outputPath = 'none'; end
if ~exist('hsize','var'), hsize = [5,5,5]; end
if ~exist('sigma','var'), sigma = 20; end
if ~exist('threshold','var'), threshold = .25; end
if ~exist('minPx','var'), minPx = 600; end % Smallest mito found in dataset is 561 px

% read all TIF filenames from inputPath
fileNames = dir(strcat(inputPath,'/*.tif'));

% read volume from TIF files, convert to double precision for better filter accuracy
volume = zeros(512,512,length(fileNames));
for k = 1:length(fileNames)
    volume(:,:,k) = im2double(imread(fullfile(inputPath,fileNames(k).name)));
end

% apply a 3D gaussian blur filter.
volumeBlur = smooth3(volume,'gaussian',hsize,sigma);
% NOTE: "smooth3" is very slow. Maybe there is a faster implementation.

% make a binary map of all the pixels below the threshold found in the blurred volume
mitosT = volumeBlur < threshold;

% eliminate all objects smaller than minPx
mitosE = bwareaopen(mitosT,minPx);

% fill holes in marked regions
mitos = imfill(mitosE,'holes');

if (~strcmp(outputPath,'none')) % write results to outputPath if it is not 'none'
    for k = 1:length(fileNames)
        imwrite(mitos(:,:,k),fullfile(outputPath,fileNames(k).name),'Compression','none')
        % using no compression because ImageJ currently cannot read compressed binary TIFs
    end
end

end
