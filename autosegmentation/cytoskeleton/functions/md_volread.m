function volume = md_volread(inputPath,arrayType)
%MD_VOLREAD Create a 3D array from a directory containing numbered TIFs. 
%
% v1.0
%
% Supports output as double or uint8 arrays (default is double).
%
% "double" means that intensity values are doubles between 0 and 1.
% "uint8" means that intensity values are unsigned integers between 0 and 255.
%
% SYNOPSIS
%   volume = md_volread(inputPath,arrayType)
%   volume = md_volread(inputPath)
%
% INPUT
%   inputPath (string): Path that contains the data in TIF format. (The files
%       should have names like "0000.tif", "0001.tif", and so on.)
%   arrayType (string): Data type for the volume. Only "double" and "uint8"
%       are supported. Set it to "uint8" to get a uint8 array. Default: double.
%
% OUTPUT
%   volume: 3D volume array

% defaults
if ~exist('arrayType','var'), arrayType = 'double'; end

% check if path is valid
if exist(inputPath,'dir') ~= 7
    error(['"',inputPath,'" is not a valid path.']);
end

% read all TIF file names from inputPath
files = dir([inputPath,'/*.tif']);

% read volume from TIF files
if strcmp(arrayType,'double')
    volume = zeros(512,512,length(files));
    for k = 1:length(files)
        volume(:,:,k) = im2double(imread(fullfile(inputPath,files(k).name)));
    end
elseif strcmp(arrayType,'uint8')
    volume = zeros(512,512,length(files),'uint8');
    for k = 1:length(files)
        volume(:,:,k) = imread(fullfile(inputPath,files(k).name));
    end
else
    error(['"',arrayType,'" is not a supported array type. ',...
        'Try "double" or "uint8".']);
end

end
