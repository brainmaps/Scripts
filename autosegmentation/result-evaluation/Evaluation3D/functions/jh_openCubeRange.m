function data = jh_openCubeRange(path, name, varargin)
%jh_openCubeRange opens a range of cubes stored as raw or tiff files
%
% DATA STRUCTURE
%   \mainFolder
%       \x0000\y0000\z0000\file_x0000_y0000_z0000.raw
%           ...
%       \xnnnn\ynnnn\znnnn\file_xnnnn_ynnnn_znnnn.raw
%
% SYNOPSIS
%   data = jh_openCubeRange(path, name)
%   data = jh_openCubeRange(___, 'cubeSize', cubeSize)
%   data = jh_openCubeRange(___, 'range', rangeX, rangeY, rangeZ)
%   data = jh_openCubeRange(___, 'range', 'complete')
%   data = jh_openCubeRange(___, 'range', 'oneCube', coordinates)
%   data = jh_openCubeRange(___, 'dataType', dataType)
%   data = jh_openCubeRange(___, 'ouputType', ouputType)
%   data = jh_openCubeRange(___, 'fileType', fileType)
%
% INPUT
%   path: the path of the main folder containing the desired data
%       (including the folder)
%   name: the name of the dataSet (usually consistent with the folder name)
%       set name = '' to use any raw or tiff file which is located in the
%       respective folders
%       Note: name != '' only works for raw files!
%   fileType: specifies the type of data file
%       'raw': *.raw
%       'tiff': *.tif, *.tiff
%       'auto' (default): any of the above is recognized
%   'range'
%       rangeX, rangeY, rangeZ: the range in respective dimension 
%       'complete' (default): loads the whole data set
%       'oneCube': loads only one cube specified in coordinates [x y z]
%   cubeSize: the size of the cubes as vector [rows colums depth]
%       Default = [128 128 128]
%   dataType: defines the data type of the output
%       'uint8'
%       'single'
%       'double' (default)
%   outputType: defines the output
%       'one' (default): data is one image
%       'cubed': all cubes are returned individually
%
% OUTPUT
%   data: the loaded data

%% Check input

% Defaults
dataType = 'double';
outputType = 'one';
complete = true;
cubeSize = [128 128 128];
fileType = 'auto';
% Check input
if ~isempty(varargin)
    i = 0;
    while i < length(varargin)
        i = i+1;
        
        if strcmp(varargin{i}, 'range')
            if strcmp(varargin{i+1}, 'complete')
                complete = true;
                i = i+1;
            elseif strcmp(varargin{i+1}, 'oneCube')
                complete = false;
                rangeX = [varargin{i+2}(1), varargin{i+2}(1)];
                rangeY = [varargin{i+2}(2), varargin{i+2}(2)];
                rangeZ = [varargin{i+2}(3), varargin{i+2}(3)];
                i = i+2;
            else
                complete = false;
                rangeX = varargin{i+1};
                rangeY = varargin{i+2};
                rangeZ = varargin{i+3};
                i = i+3;
            end
            
        elseif strcmp(varargin{i}, 'cubeSize')
            cubeSize = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'dataType')
            dataType = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'outputType')
            outputType = varargin{i+1};
            i = i+1;
        elseif strcmp(varargin{i}, 'fileType')
            fileType = varargin{i+1};
            i = i+1;
        end
    end
end


if ~(strcmp(dataType, 'double') || strcmp(dataType, 'single') || strcmp(dataType, 'uint8'))
    disp('jh_openCubeRange: Invalid input, dataType set to "double"');
end

if ~strcmp(path(end), filesep)
    path = [path filesep];
end

%% Determine range for complete image

if complete
    
    % rangeX
    %   Get list of folders in the main folder (define the range for x)
    d = dir(path);
    isub = [d(:).isdir]; % returns logical vector
    nameFoldsX = {d(isub).name}';
    nameFoldsX(ismember(nameFoldsX,{'.','..'})) = [];
    %   Get range
    rangeX = [str2double(nameFoldsX{1}(2:end)), str2double(nameFoldsX{end}(2:end))];
    
    % rangeY
    d = dir([path, nameFoldsX{1}]);
    isub = [d(:).isdir]; % returns logical vector
    nameFoldsY = {d(isub).name}';
    nameFoldsY(ismember(nameFoldsY,{'.','..'})) = [];
    %   Get range
    rangeY = [str2double(nameFoldsY{1}(2:end)), str2double(nameFoldsY{end}(2:end))];
    
    % rangeZ
    d = dir([path, nameFoldsX{1}, filesep, nameFoldsY{1}]);
    isub = [d(:).isdir]; % returns logical vector
    nameFoldsZ = {d(isub).name}';
    nameFoldsZ(ismember(nameFoldsZ,{'.','..'})) = [];
    %   Get range
    rangeZ = [str2double(nameFoldsZ{1}(2:end)), str2double(nameFoldsZ{end}(2:end))];
    
    clear nameFoldsX nameFoldsY nameFoldsZ

end

%%

width = rangeX(2) - rangeX(1) + 1;
height = rangeY(2) - rangeY(1) + 1;
depth = rangeZ(2) - rangeZ(1) + 1;

if strcmp(outputType, 'one');
    
    % Stores the complete image
    data = zeros(height*cubeSize(1), width*cubeSize(2), depth*cubeSize(3), dataType);

    for x = rangeX(1):rangeX(2)

        for y = rangeY(1):rangeY(2)

            for z = rangeZ(1):rangeZ(2)
                
                xs = sprintf('%04d', x);
                ys = sprintf('%04d', y);
                zs = sprintf('%04d', z);

                % Find the name of the data file if none is specified
                if strcmp(name, '')
                    switch fileType
                        case 'raw'
                            files = dir([path 'x' xs filesep 'y' ys filesep 'z' zs filesep '*.raw']);
                        case 'tiff'
                            files = [dir([path 'x' xs filesep 'y' ys filesep 'z' zs filesep '*.tiff']) ...
                                dir([path 'x' xs filesep 'y' ys filesep 'z' zs filesep '*.tif'])];
                        case 'auto'
                            files = [dir([path 'x' xs filesep 'y' ys filesep 'z' zs filesep '*.raw']) ...
                                dir([path 'x' xs filesep 'y' ys filesep 'z' zs filesep '*.tiff']) ...
                                dir([path 'x' xs filesep 'y' ys filesep 'z' zs filesep '*.tif'])];
                    end
                    fileNames = {files.name};
                    thisName = fileNames{1};
                else
                    thisName = [name '_x' xs '_y' ys '_z' zs '.raw'];
                end

                % Create path name of the desired cube
                p = [path 'x' xs filesep 'y' ys filesep 'z' zs filesep thisName];
                dy(1) = (y-rangeY(1))*cubeSize(1)+1;
                dy(2) = (y-rangeY(1)+1)*cubeSize(1);
                dx(1) = (x-rangeX(1))*cubeSize(2)+1;
                dx(2) = (x-rangeX(1)+1)*cubeSize(2);
                dz(1) = (z-rangeZ(1))*cubeSize(3)+1;
                dz(2) = (z-rangeZ(1)+1)*cubeSize(3);
                
                if strcmp(thisName(end-3:end), '.raw') || strcmp(thisName(end-3:end), '.RAW')
                    data(dy(1):dy(2), dx(1):dx(2), dz(1):dz(2)) ...
                        = openCube(p, cubeSize, dataType);
                elseif strcmp(thisName(end-3:end), '.tif') || ...
                        strcmp(thisName(end-3:end), 'tiff') || ...
                        strcmp(thisName(end-3:end), '.TIF') ||...
                        strcmp(thisName(end-3:end), 'TIFF')
                    data(dy(1):dy(2), dx(1):dx(2), dz(1):dz(2)) ...
                        = openTiffCube(p, cubeSize, dataType);
                end

            end

        end

    end
    
elseif strcmp(outputType, 'cubed')
    
    data = cell(height, width, depth);
    
    % Stores the image into a cell containing each cube individually
    for x = rangeX(1):rangeX(2)

        for y = rangeY(1):rangeY(2)

            for z = rangeZ(1):rangeZ(2)

                xs = sprintf('%04d', x);
                ys = sprintf('%04d', y);
                zs = sprintf('%04d', z);

                % Find the name of the data file if none is specified
                if strcmp(name, '')
                    switch fileType
                        case 'raw'
                            files = dir([path 'x' xs filesep 'y' ys filesep 'z' zs filesep '*.raw']);
                        case 'tiff'
                            files = [dir([path 'x' xs filesep 'y' ys filesep 'z' zs filesep '*.tiff']) ...
                                dir([path 'x' xs filesep 'y' ys filesep 'z' zs filesep '*.tif'])];
                        case 'auto'
                            files = [dir([path 'x' xs filesep 'y' ys filesep 'z' zs filesep '*.raw']) ...
                                dir([path 'x' xs filesep 'y' ys filesep 'z' zs filesep '*.tiff']) ...
                                dir([path 'x' xs filesep 'y' ys filesep 'z' zs filesep '*.tif'])];
                    end
                    fileNames = {files.name};
                    thisName = fileNames{1};
                else
                    thisName = name;
                end

                % Create path name of the desired cube
                p = [path 'x' xs filesep 'y' ys filesep 'z' zs filesep ...
                    thisName '_x' xs '_y' ys '_z' zs '.raw'];
                
                data{y+1, x+1, z+1} = openCube(p, cubeSize, dataType);

            end

        end

    end

    
end

end

function cube = openCube(path,cubeSize,dataType)

fid=fopen(path,'r');
dataType = ['uint8=>' dataType];
cube=fread(fid,cubeSize(1)*cubeSize(2)*cubeSize(3), dataType);
fclose(fid);
cube = permute(reshape(cube, cubeSize(1), cubeSize(2), cubeSize(3)), [2 1 3]);

end

function cube = openTiffCube(path, cubeSize, dataType)

cube = zeros(cubeSize, dataType);
for i = 1:cubeSize(3)
    if strcmp(dataType, 'single') || strcmp(dataType, 'double')
        cube(:,:,i) = cast(imread(path, i), dataType) / 255;
    else
        cube(:,:,i) = imread(path, i);
    end
end

end

