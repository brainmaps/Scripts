%% Set path

% Determine the path of this script
t = mfilename('fullpath');
posSlash = find(t == filesep, 1, 'last');
posSlash = posSlash(1);
thisPath = t(1:posSlash);

% Add all folders within the main path
addpath(genpath(thisPath));

% Add path containing the viewer class
addpath(genpath('D:\Julian\GitHub\Scripts\GUIs\Viewer\v1'));
% And the functions folder
addpath(genpath('D:\Julian\GitHub\Scripts\GUIs\Functions\v1'));

clear t posSlash thisPath;


%% Start viewer

h = VolumeDetector( ...
    'image', { ...
        'name', 'ImageData1', ...
        'cubeRange', {[3 6], [3 6], [0 3]}, ...
        'cubeSize', [128 128 128], ...
        'bufferType', 'whole', ...
        'dataType', 'single', ...
        'sourceType', 'cubed', ...
        'sourceFolder', 'D:\Julian\Datasets\20130410.membrane.striatum.10x10x30nm', ...
        'anisotropic', [1 1 3], ...
        'position', [0 0 0] ...
    });
