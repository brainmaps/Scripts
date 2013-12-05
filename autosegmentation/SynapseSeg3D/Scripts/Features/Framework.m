%% Creates a feature matrix
asdf
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Number of features (this has to be consistent with the number of included
% features below!)
fNumber = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For debugging (when set to true each feature matrix is individually saved
% as TIFF file)
debug = true;
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
to = 10;

cube.data = cube.data(from:to, from:to, from:to);
cube.normData = cube.normData(from:to, from:to, from:to);
cube.normInvData = cube.normInvData(from:to, from:to, from:to);
%}

%% The algorithm starts here
% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
disp('>>> START >>>');
disp(' ');
overallElapsedTimerValue = tic;

%% Pre-definitions

% Size of the image
n1 = size(cube.normData, 1);
n2 = size(cube.normData, 2);
n3 = size(cube.normData, 3);
n = n1*n2*n3;

% This will be the feature matrix
features = zeros(n1, n2, n3, fNumber);

% To count every feature
fCount = 0;

%% Pre-modification of the image

%G = fspecial('gaussian',[5 5], 2);
%cube.gaussian = imfilter(cube.normInvData,G,'same');
for i = 1:size(cube.normData,3)
    cube.median(:,:,i) = medfilt2(cube.data(:,:,i),[2 2]);
    
    %e = strel('disk', 5);
    %cube.tophat(:,:,i) = imtophat(cube.gaussian(:,:,i),se);
    %figure(8) 
    %imagesc(cube.tophat(:,:,i)), colormap('gray');
    %figure(9)
    %imagesc(cube.normData(:,:,i)), colormap('gray');
    %cube.subtract(:,:,i) = cube.normInvData(:,:,i) - cube.tophat(:,:,i);
end

% Define which image will be used
im = cube.normData;

%% Calculations
% Insert the needed calculations here

Calc_Hessian
Calc_Gradient
Calc_HMaxOfGradient
Calc_GradientExcludeSmallMagnitude
Calc_DivGradientExclSmMag
Calc_NormalizedGradientExclSmMag
Calc_DivNormalizedGradientExclSmMag
Calc_DivNormGradient
Calc_GradDivNormGradient
Calc_DivGradDivNormGradient


%% Features
% Insert the desired features here (some features cannot stand alone!)

Feat_ImageIntensities

%% The algorithm ends here 

overallElapsedTime = toc(overallElapsedTimerValue);
disp(' ');
fprintf('    Overall elapsed time: %.2G seconds\n', overallElapsedTime);
disp(' ');
disp('<<< DONE <<<');
disp(' ');

% <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




















