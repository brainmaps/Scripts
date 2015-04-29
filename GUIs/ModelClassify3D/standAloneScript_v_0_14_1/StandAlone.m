% standAloneScript v0.14.1
%
% Differences to standAloneScript v0.14.0:
%
%   Model can be performed on large datasets by cropping and stitching
%
%   Select cubes [from to]: Select the whole image that will be processed
%   Cut data into sections: 
%       Specify the number of sections the data set is cut into
%       Specify the amount of overlap in voxels

%% Inputs go here: ########################################################
% #########################################################################

%% Select cubes [from to] 
rangeX = [1 2];
rangeY = [1 1];
rangeZ = [1 1];
cubeSize = [128, 128, 128];

%% Cut data into sections
noOfSections = [2 1 1]; % [x y z]
overlap = [24 24 8];    % [x y z] voxels

%% Specify locations
% Model file
modelFile = 'D:\Julian\ModelClassify3D\v_0_14a\saves\membraneStriatum\140814_2DWS_x1y2z0_4.sa.mat';
% Data set
dataFolder = 'D:\Julian\Synapse segmentation\Datasets\20130410.membrane.striatum.10x10x30nm';
% Folder for results (this folder has to exist!)
saveFolder = 'D:\Julian\Develop\Matlab\150429.ModelClassifyForLargeDatasets\Results';

%% Name of the run
nameRun = '150429_vc_MembraneStriatum_x1-1_y1-1_z1-1_best';

% #########################################################################
%% ########################################################################

%%

load(modelFile);

mkdir([saveFolder filesep nameRun]);

%% Create settings structure

settings.range = [rangeX; rangeY; rangeZ];
settings.noOfSections = noOfSections;
settings.overlap = overlap;
settings.cubeSize = cubeSize;
settings.data = saveStuff.data;
settings.pWS = saveStuff.pWS;
settings.pFeatures = saveStuff.pFeatures;
settings.pClassification = saveStuff.pClassification;
settings.pPP = saveStuff.pPP;
settings.saveFolder = saveFolder;
settings.nameRun = nameRun;
settings.dataFolder = dataFolder;


%%

% Try to initialize the Dip library
% Abort if it fails
if ~initDipImage('C:\Program Files\DIPimage 2.5.1\')
    return
end

%% Do the calculation for each section

for x = 1:noOfSections(1)
    for y = 1:noOfSections(2)
        for z = 1:noOfSections(3)
                        
            calculateCurrentSection(x, y, z, settings)
            
        end
    end
end


    
    
    