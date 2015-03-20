global data

%{
data structure
    .image
    .prefType
    .defaultFolder
    .folder
    .name
    .disp
        .X
        .Y
        .Z
    .anisotropic
    .folders
        .main
        .features
        .visualization
        .watershed
        .postProcessing
    .currentStep
%}

data.prefType = 'single';
if strcmp(filesep, '\');
    data.defaultFolder = 'D:\Julian\Synapse segmentation\Datasets';
else
    data.defaultFolder = '/~';
end
data.folder = data.defaultFolder;
data.name = '';
data.disp.X = 0;
data.disp.Y = 0;
data.disp.Z = 0;

data.anisotropic = [1 1 3];

thisPath = mfilename('fullpath');
posSlash = find(thisPath == filesep, 2, 'last');
posSlash = posSlash(1);
thisPath = thisPath(1:posSlash);
data.folders.main = thisPath;
data.folders.features = ['scripts' filesep 'features' filesep];
data.folders.visualization = ['scripts' filesep 'visualization' filesep];
data.folders.watershed = ['scripts' filesep 'watershed' filesep];
data.folders.postProcessing = ['scripts' filesep 'postProcessing' filesep];

data.currentStep = 0; % The highest step for which calculations are available

