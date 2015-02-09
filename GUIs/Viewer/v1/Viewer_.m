%% Set path

% Determine the path of this script
t = mfilename('fullpath');
posSlash = find(t == filesep, 1, 'last');
posSlash = posSlash(1);
thisPath = t(1:posSlash);

% Add all folders within the main path
addpath(genpath(thisPath));


%% Start viewer

h = Viewer('name', 'TestName');
