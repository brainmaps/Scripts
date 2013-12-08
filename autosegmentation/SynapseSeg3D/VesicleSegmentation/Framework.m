%% Creates a feature matrix

%% User input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Comment out if not desired
clear;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select the path of the cubed data set
dataSet.path = 'D:\Julian\Synapse segmentation\Datasets\20130410.membrane.striatum.10x10x30nm\';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the name of the date set
dataSet.name = '20130410.membrane.striatum.10x10x30nm';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select the coordinates of the desired cube (format: '####')
dataSet.coord.x = '0000'; 
dataSet.coord.y = '0000';
dataSet.coord.z = '0000';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set for anisotropic voxels (format: [row, column, depth)
anisotropic = [10,10,30];
% Set true when the image is to be resized (decreases performance!)
imresize = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For debugging (when set to true each feature matrix is individually saved
% as TIFF file)
debug = true;
nameRun = '!var_1'; % (name of the run)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load and normalize the image data

% Create path name of the desired cube
cube.path = [dataSet.path 'x' dataSet.coord.x '\y' dataSet.coord.y '\z' ...
    dataSet.coord.z '\' dataSet.name '_x' dataSet.coord.x '_y' ...
    dataSet.coord.y '_z' dataSet.coord.z '.raw'];
% Open cube
cube.data = at_openCube(cube.path);
% Normalize image
cube.normData = cube.data / max(max(max(cube.data)));
cube.normInvData = 1 - cube.normData;

%% Define a subset for debug purposes

%{

from = 1;
to = 100;

cube.data = cube.data(from:to, from:to, from:to);
cube.normData = cube.normData(from:to, from:to, from:to);
cube.normInvData = cube.normInvData(from:to, from:to, from:to);

%}

%% For anisotropic voxels

% Resize image
if imresize
    anisotropic = anisotropic / min(anisotropic);
    resizeFactor(1) = anisotropic(1) * size(cube.normData,1);
    resizeFactor(2) = anisotropic(2) * size(cube.normData,2);
    resizeFactor(3) = anisotropic(3) * size(cube.normData,3);
    cube.resizedNormData = imresize3d(cube.normData, [], resizeFactor, 'linear', 'symmetric');
    anisotropic = [1,1,1];
    im = cube.resizedNormData;
else
    im = cube.normData;
end

% Debug
if debug
    saveImageAsTiff3D(im, [nameRun '_im.TIFF']);
end

%% The algorithm starts here
% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
disp('>>> START >>>');
disp(' ');
overallElapsedTimerValue = tic;

%% Pre-definitions

% Size of the image
n1 = size(im, 1);
n2 = size(im, 2);
n3 = size(im, 3);
n = n1*n2*n3;

%% Pre-modification of the image

%G = fspecial('gaussian',[5 5], 2);
%cube.gaussian = imfilter(cube.normInvData,G,'same');
for i = 1:size(im,3)
    cube.median(:,:,i) = medfilt2(im(:,:,i),[2 2]);
    
    %e = strel('disk', 5);
    %cube.tophat(:,:,i) = imtophat(cube.gaussian(:,:,i),se);
    %figure(8) 
    %imagesc(cube.tophat(:,:,i)), colormap('gray');
    %figure(9)
    %imagesc(cube.normData(:,:,i)), colormap('gray');
    %cube.subtract(:,:,i) = cube.normInvData(:,:,i) - cube.tophat(:,:,i);
end

% Define which image will be used
%im = cube.median;

% Debug
if debug
    saveImageAsTiff3D(im, [nameRun '_imPreMod.TIFF']);
end

%% Calculations
% Insert the needed calculations here

[cube.GF, cube.magGF] = jh_vs_imageGradient(im, 1, debug, nameRun, 'magGF');
cube.divGF = jh_vs_divergence(cube.GF, 2, debug, nameRun, 'divGF');
cube.hMaxDivGF = jh_vs_hMax(cube.divGF, 0.5, 18, true, debug, nameRun, 'hMaxDivGF');
%cube.nm2HMaxDivGF = jh_vs_neighborhoodMean(cube.hMaxDivGF, 2, 2, anisotropic, debug, nameRun, 'nm2HMaxDivGF');
%cube.nv2HMaxDivGF = jh_vs_neighborhoodVar(cube.hMaxDivGF, 2, 2, anisotropic, debug, nameRun, 'nv2HMaxDivGF');
%cube.hMaxNv2HMaxDivGF = jh_vs_hMax(cube.nv2HMaxDivGF, 0.2, 18, false, debug, nameRun, 'hMaxNv2HMaxDivGF');

cube.gaussDivGF = jh_vs_subtractGaussianStructElement(cube.divGF, 1, 1, 0, 0, debug, nameRun, 'gaussDifGF');

cube.segHMaxDivGF = (1-cube.gaussDivGF) .* (cube.hMaxDivGF);
if debug
    saveImageAsTiff3D(cube.segHMaxDivGF, [nameRun '_' 'segHMaxDivGF' '.TIFF']);
end

cube.segDivGF = (1-cube.gaussDivGF) .* (1-cube.divGF);
if debug
    saveImageAsTiff3D(cube.segDivGF, [nameRun '_' 'segDivGF' '.TIFF']);
end

%% The algorithm ends here 

overallElapsedTime = toc(overallElapsedTimerValue);
disp(' ');
fprintf('    Overall elapsed time: %.2G seconds\n', overallElapsedTime);
disp(' ');
disp('<<< DONE <<<');
disp(' ');

% <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




















