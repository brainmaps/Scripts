function md_volwrite(volume,outputPath,compression,clearDir)
%MD_VOLWRITE Write a 3D array to a directory as a numbered TIF stack.
%
% v1.0
%
% All 2D array types supported by the builtin "imwrite" function
% (double, uint8, logical ...) are also supported by md_volwrite.
%
% SYNOPSIS
%   md_volwrite(volume,outputPath,compression,clearDir)
%   md_volwrite(volume,outputPath,compression)
%   md_volwrite(volume,outputPath)
%
% INPUT
%   volume (double): 3D array that should be written to the disk.
%   outputPath (string): Path that the volume should be written into. (The files
%       will have names like "0000.tif", "0001.tif", and so on.) If the
%       directory that the path points to does not exist, it is created
%       automatically.
%   compression: Compression algorithm. See "imwrite" documentation for
%       further info. In most cases, compression is either ineffective or
%       creates other problems. Default: none
%   clearDir (logical): If true, remove all TIF files from the directory before
%       writing into it. Be careful with this option! Default: 0

% defaults
if ~exist('compression','var'), compression = 'none'; end
if ~exist('clearDir','var'), clearDir = 0; end

% prepare path
if exist(outputPath,'dir') ~= 7
    mkdir(outputPath);
elseif clearDir
    delete([outputPath,'/*.tif']);
end

% write files
for k = 1:size(volume,3)
    fullFileName = [outputPath,'/',sprintf('%04d',(k-1)),'.tif'];
    imwrite(volume(:,:,k),fullFileName,'Compression',compression);
end

end
