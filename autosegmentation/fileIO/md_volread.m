function volume = md_volread(inputPath, arrayType)
%MD_VOLREAD Create a 3D array from a directory containing a numbered 2D image stack.
%
% v3.0
%
% The expected directory / file structure can be produced by md_volwrite:
%   https://github.com/brainmaps/Scripts/blob/master/autosegmentation/fileIO/md_volwrite.m
%
% Please make sure that the specified directory contains no other files than
%   the images of one single dataset, ordered by their file name.
%
% X and Y dimensions have to be consistent within the image stack.
%
% Supports input as double, uint8 or logical arrays (default is double).
% - "double" means that intensity values are doubles between 0 and 1.
% - "uint8" means that intensity values are unsigned integers between 0 and 255.
% - "logical" means that all intensity values are logical values (0 or 1).
%
% SYNOPSIS
%   volume = md_volread(inputPath, arrayType)
%   volume = md_volread(inputPath)
%
% INPUT
%   inputPath (string): Path that contains the images. (The files
%       should have names like e.g. "0000.tif", "0001.tif", and so on.)
%   arrayType (string): Data type of the produced 3D array. Supported values
%       are "double", "uint8" and "logical".
%       Default: double.
%
% OUTPUT
%   volume: 3D matlab array that stores the individual 2D images along the
%       third dimension, ordered by their original filename.

% defaults
if ~exist('arrayType', 'var'), arrayType = 'double'; end

% check if path is valid
if exist(inputPath, 'dir') ~= 7
    error(['"', inputPath, '" is not a valid path. Aborting...']);
end

% read all file names from inputPath
filesWithDots = dir(inputPath);
files = filesWithDots(3:end); % remove '.' and '..' from dir output

% abort if there are no files in the directory
if size(files, 1) == 0
    error(['"', inputPath, '" does not contain any files! Aborting...']);
end

% determine the X and Y dimensions of the TIF stack by checking the first image
[xSize, ySize] = size(imread(fullfile(inputPath, files(1).name)));

% read volume from files
if strcmp(arrayType, 'double')
    volume = zeros(xSize, ySize, length(files));
    for k = 1:length(files)
        volume(:,:,k) = im2double(imread(fullfile(inputPath, files(k).name)));
    end
elseif strcmp(arrayType, 'uint8')
    volume = zeros(xSize, ySize, length(files), 'uint8');
    for k = 1:length(files)
        volume(:,:,k) = imread(fullfile(inputPath, files(k).name));
    end
elseif strcmp(arrayType, 'logical')
    volume = false(xSize, ySize, length(files));
    for k = 1:length(files)
        volume(:,:,k) = imread(fullfile(inputPath, files(k).name));
    end
else
    error(['"', arrayType, '" is not a supported array type. ', ...
        'Try "double", "uint8" or "logical". Aborting...']);
end

end
