function md_volwrite(volume, outputPath, compression, clearDir, ...
                     prefix, form, suffix, extension)
%MD_VOLWRITE Write a 3D array to a directory as a numbered 2D image stack
%
% v2.0
%
% To read its output into Matlab again, you can use md_volread, available at:
%  https://github.com/brainmaps/Scripts/blob/master/autosegmentation/fileIO/md_volread.m
% All array types supported by the built-in "imwrite" function
%  (double, uint8, logical ...) are supported by md_volwrite.
%
% SYNOPSIS
%   md_volwrite(volume, outputPath, compression, clearDir, ...
%               prefix, form, suffix, extension)
%   (...)
%   md_volwrite(volume, outputPath)
%
% INPUT
%   volume (double): 3D array that should be written to the disk.
%   outputPath (string): Path that the volume should be written into. (The files
%       will have names like "0000.tif", "0001.tif", and so on by default.) If
%       the directory that the path points to does not exist, it is created
%       automatically. The (0-based) numbers refer to XY planes in Z direction.
%
% INPUT (optional)
%   compression: Compression algorithm. See "imwrite" documentation for
%       further info. In most cases, compression is either ineffective or
%       creates other problems.
%       Default: 'none'
%   clearDir (logical): If true, remove all files from the directory before
%       writing into it. Be VERY careful with this option!
%       Default: false
%   prefix (string): Prefix string that is added to all output file names.
%       Default: '' (no prefix)
%   form (string): Format of the number in the file name. For more details,
%       look at the documentation of the Matlab sprintf function.
%       Default: '%04u' ( --> e.g. ['0000.tif', '0001.tif', ... '9999.tif'])
%   suffix (string): Suffix string that is added to all output file names.
%       Default: '' (no suffix)
%   extension (string): File name extension. The file type is derived from it
%       automatically. For a list of supported types / extensions, look at
%       the "imwrite" documentation in Matlab.
%       Default: 'tif'
%
% EXAMPLE
%   "md_volwrite(vol, 'D:\im', 'none', true, 'pre_', '%03u', '_suf', 'tif');"
%       deletes all files in 'D:\im' and then writes the 3D array 'vol' to the
%       path 'D:\im' as TIF files without compression. Resulting file names:
%       ['pre_000_suf.tif', 'pre_001_suf.tif', ... 'pre_345_suf.tif', ...]

% defaults
if ~exist('compression', 'var'), compression = 'none'; end
if ~exist('clearDir', 'var'), clearDir = false; end
if ~exist('prefix', 'var'), prefix = ''; end
if ~exist('form', 'var'), form = '%04u'; end
if ~exist('suffix', 'var'), suffix = ''; end
if ~exist('extension', 'var'), extension = 'tif'; end

% prepare path
if exist(outputPath, 'dir') ~= 7
    mkdir(outputPath);
elseif clearDir
    delete([outputPath, filesep, '*']);
end

% write files
for k = 1:size(volume, 3)
    fullFileName = [outputPath, filesep, prefix, ...
                    sprintf(form, (k - 1)), suffix, '.', extension];
    imwrite(volume(:,:,k), fullFileName, 'Compression', compression);
end

end
