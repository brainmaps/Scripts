function volume = md_volread(inputPath,arrayType)
%MD_VOLREAD Create a 3D array from a directory containing numbered TIFs.
%
% v2.0
%
% X and Y dimensions have to be consistent within the TIF stack.
% Supports input as double, uint8 or logical arrays (default is double).
%
% - "double" means that intensity values are doubles between 0 and 1.
% - "uint8" means that intensity values are unsigned integers between 0 and 255.
% - "logical" means that all intensity values are logical values (0 or 1).
%
% SYNOPSIS
%   volume = md_volread(inputPath,arrayType)
%   volume = md_volread(inputPath)
%
% INPUT
%   inputPath (string): Path that contains the data in TIF format. (The files
%       should have names like e.g. "0000.tif", "0001.tif", and so on.)
%   arrayType (string): Data type for the volume. Supported values are
%       "double", "uint8" and "logical". Default: double.
%
% OUTPUT
%   volume: 3D volume array that stores the individual 2D images along the
%       third dimension, ordered by their original filename.

% defaults
if ~exist('arrayType','var'), arrayType = 'double'; end

% check if path is valid
if exist(inputPath,'dir') ~= 7
    error(['"',inputPath,'" is not a valid path. Aborting...']);
end

% read all TIF file names from inputPath
files = dir([inputPath,'/*.tif']);

% abort if there are no TIFs in the directory
if size(files,1) == 0
    error(['"',inputPath,'" does not contain any TIF images! Aborting...']);
end

% determine the X and Y dimensions of the TIF stack by checking the first image
[xSize,ySize] = size(imread(fullfile(inputPath,files(1).name)));

% read volume from TIF files
if strcmp(arrayType,'double')
    volume = zeros(xSize,ySize,length(files));
    for k = 1:length(files)
        volume(:,:,k) = im2double(imread(fullfile(inputPath,files(k).name)));
    end
elseif strcmp(arrayType,'uint8')
    volume = zeros(xSize,ySize,length(files),'uint8');
    for k = 1:length(files)
        volume(:,:,k) = imread(fullfile(inputPath,files(k).name));
    end
elseif strcmp(arrayType,'logical')
    volume = false(xSize,ySize,length(files));
    for k = 1:length(files)
        volume(:,:,k) = imread(fullfile(inputPath,files(k).name));
    end
else
    error(['"',arrayType,'" is not a supported array type. ',...
        'Try "double", "uint8" or "logical". Aborting...']);
end

end
