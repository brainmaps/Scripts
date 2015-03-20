
% #########################################################################
%% Select cubes [from to] 
rangeX = [1 2];
rangeY = [1 2];
rangeZ = [1 1];
% #########################################################################
%% Specify locations
% Model file
modelFile = 'D:\Julian\ModelClassify3D\v_0_14a\saves\membraneStriatum\140814_2DWS_x1y2z0_4.sa.mat';
% Data set
loadFolder = 'D:\Julian\Synapse segmentation\Datasets\20130410.membrane.striatum.10x10x30nm';
% Folder for results (this folder has to exist!)
saveFolder = 'D:\Julian\ModelClassify3D\standAloneScript_v_0_14\Results';
%% Name of the run
nameRun = '140815_vc_MembraneStriatum_x1-2_y1-2_z1-1_best';
% #########################################################################

%%
% loadFolder = uigetdir(pwd, 'Data set');
% saveFolder = uigetdir(pwd, 'Folder for results');

addpath(genpath(pwd))

load(modelFile);

mkdir([saveFolder filesep nameRun]);

pWS = saveStuff.pWS;
pFeatures = saveStuff.pFeatures;
pClassification = saveStuff.pClassification;
pPP = saveStuff.pPP;
data = saveStuff.data;

pWS.scriptPath = [pwd filesep data.folders.watershed];
pFeatures.scriptPath = [pwd filesep data.folders.features];
pPP.scriptPath = [pwd filesep data.folders.postProcessing];


%%

% Try to initialize the Dip library
% If this fails the GUI will not be opened
try
    
    warning off
    try
        addpath('C:\Program Files\DIPimage 2.5.1\common\dipimage');
    catch
    end
    warning on
    evalc('dip_initialise;');
    
    fprintf('Dip library found and loaded successfully.\n\n');
    
catch
    
    close(handles.figMain);
    
    fprintf('\nERROR: Dip library not found. \n');
    fprintf('    Consider loading Dip library manually before starting ModelClassify3D.\n\n');
    return
    
end

%%

data.image = jh_openCubeRange([loadFolder, filesep], '', ...
    'range', rangeX, rangeY, rangeZ, ...
    'cubeSize', [128 128 128], ...
    'dataType', 'single');

result.result = jh_synapseSeg3D( ...
    data, pWS, pFeatures, pClassification, pPP, ...
    'save', {'WS', 'features', 'classification', 'postProcessing'}, saveFolder, nameRun, ...
    'prefType', 'single', ...
    'anisotropic', data.anisotropic);
%     'output', {'WS', 'features', 'classification', 'postProcessing'}, ...

result.modelFile = modelFile;
result.loadFolder = loadFolder;
result.saveFolder = saveFolder;
result.nameRun = nameRun;
save([saveFolder filesep nameRun filesep 'result'], 'result');

saveImageAsTiff3D( ...
    jh_overlayLabels( ...
        jh_normalizeMatrix(data.image), ...
        result.result, ...
        'type', 'colorize', ...
        'range', [0 .33], ...
        'gray', 'randomizeColors'), ...
    [saveFolder filesep nameRun filesep 'result_Overlay.TIFF'], ...
    'rgb');
    
    
    
rmpath(genpath(pwd))

    
    
    