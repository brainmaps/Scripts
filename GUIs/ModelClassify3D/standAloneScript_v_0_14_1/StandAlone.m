% standAloneScript v0.14.1
%
% Differences to standAloneScript v0.14.0:
%
%   Model can be performed on large datasets by cropping and stitching
%
%   Select cubes [from to]: Select the whole image that will be processed
%   Cut data into sections: 
%       Specify the size of each section, overlap with the neighboring
%       section and an offset.
%       The offset should be either zero or (-overlap/2), otherwise
%       errors may occur.
%
% Dependencies:
%
%   Specify path below:
%       DIPimage library
%
%   Load to workspace:
%       .../Functions/v1
%       pwd/functions
%       pwd/sa_functions

%% Inputs go here: ########################################################
% #########################################################################

%% Select cubes [from to] 
rangeX = [1 4];
rangeY = [1 4];
rangeZ = [1 4];
cubeSize = [128, 128, 128];

%% Cut data into sections
% noOfSections = [2 1 1]; % [x y z]
secSize = [304 304 272]; % [x y z] voxels
overlap = [48 48 16];    % [x y z] voxels
offset = [-24 -24 -8];  % [x y z] voxels

%% Specify locations
% Model file
modelFile = 'D:\Julian\ModelClassify3D\v_0_14a\saves\membraneStriatum\140814_2DWS_x1y2z0_4.sa.mat';
% Data set
dataFolder = 'D:\Julian\Synapse segmentation\Datasets\20130410.membrane.striatum.10x10x30nm';
% Folder for results (this folder has to exist!)
saveFolder = 'D:\Julian\Develop\Matlab\150429.ModelClassifyForLargeDatasets\Results';

%% Name of the run
nameRun = '150506.3.vc_MembraneStriatum.x1-2.y1-2.z1-1.140814_2DWS_x1y2z0_4';

%% Stuff to save
% Specify which calculated matrices will be saved from jh_synapseSeg3D:
%   Possible values:
%       'result', 'WS', 'features', 'classification', and 'postProcessing'
%       See jh_synapseSeg3D for explanation
%   Note that especially the features take up a significant amount of disc
%       space (no of features*imSize*2 in single precision)
saveAlso = {};
% saveAlso = {'result', 'WS', 'features', 'classification', 'postProcessing'};
% Save overlay matrix
saveOverlays = true;

%% DIPimage library
dipPath = 'C:\Program Files\DIPimage 2.5.1\';

% #########################################################################
%% ########################################################################

%%

fprintf('\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n')
fprintf(  '>>> StandAlone script: ModelClassify3D >>>>>>>>>>>>>>>>>>>>>\n')
fprintf(  '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n')
fprintf('\nVersion: 0.14.1\n')
fprintf(  'By Julian Hennies, MPI Heidelberg\n')
fprintf('\nStiching by Nasim Rahaman\n')
fprintf('\nFor non-commercial use only\n')
fprintf('\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n')

%%

fprintf('\nLoading model file...\n')
disp(['    ' modelFile])

load(modelFile);

fprintf(  '    ... Done!\n')
fprintf(  'Creating target directory...\n');
disp(['    ' saveFolder filesep nameRun])

if exist([saveFolder filesep nameRun filesep 'prediction'], 'dir') == 7
    fprintf('    ... Already exists!\n');
else
    mkdir([saveFolder filesep nameRun filesep 'prediction']);
    fprintf(  '    ... Done!\n');
end

%% Create settings structure

fprintf(  'Setting up settings structure...')

try
    settings.range = [rangeX; rangeY; rangeZ];
%     settings.noOfSections = noOfSections;
    settings.secSize = secSize;
    settings.overlap = overlap;
    settings.offset = offset;
    settings.cubeSize = cubeSize;
    settings.data = saveStuff.data;
    settings.pWS = saveStuff.pWS;
    settings.pFeatures = saveStuff.pFeatures;
    settings.pClassification = saveStuff.pClassification;
    settings.pPP = saveStuff.pPP;
    settings.saveFolder = [saveFolder filesep nameRun];
    settings.nameRun = 'prediction';
    settings.dataFolder = dataFolder;
    settings.saveAlso = saveAlso;
    settings.saveOverlays = saveOverlays;
    fprintf(' Done!\n')
catch
    fprintf(' Failed!\n')
    fprintf('\nError: Input variable(s) missing.\n')
    fprintf('\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n')
    return
end

fprintf(  'Saving settings...')

currentDir = pwd;
cd([saveFolder filesep nameRun filesep 'prediction'])

save([nameRun '.mat'], 'settings');

cd(currentDir)

fprintf(  ' Done!\n')


%%

fprintf(  'Initializing DIPimage library... ')
% Try to initialize the Dip library
% Abort if it fails
if ~initDipImage(dipPath)
    fprintf('\nError: DIPimage Library not found.\n')
    fprintf('\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n')
    return
end

%% Do the calculation for each section

fprintf('\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n')

calculateSections(settings);

%% Perform stitching to get consistent labels

fprintf('\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n')
fprintf('\nStitching... \n\n')

stitch([saveFolder filesep nameRun filesep 'prediction']);

fprintf('\n    ... Done\n')

%%

fprintf('\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n')
fprintf(  '<<< StandAlone script: ModelClassify3D <<<<<<<<<<<<<<<<<<<<<\n')
fprintf(  '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n')

    
    