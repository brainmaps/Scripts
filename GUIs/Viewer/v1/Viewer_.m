%% Set paths

% Determine the path of this script
t = mfilename('fullpath');
posSlash = find(t == filesep, 1, 'last');
posSlash = posSlash(1);
thisPath = t(1:posSlash);

% Add all folders within the main path
addpath(genpath(thisPath));

% Determine functions path
posSlash = find(thisPath == filesep, 3, 'last');
posSlash = posSlash(1);
functionsPath = [thisPath(1:posSlash) 'Functions' filesep 'v1'];

% Add functions path and subfolders
addpath(genpath(functionsPath));

clear t posSlash thisPath functionsPath;

%% Start viewer

h = Viewer('name', 'TestName');
