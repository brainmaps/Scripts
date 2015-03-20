% ModelClassify3D
% version 0.14, 07.2014
%
% written by Julian Hennies
% Max Planck Institute for Medical Research, Heidelberg


function varargout = ModelClassify3D(varargin)
% MODELCLASSIFY3D MATLAB code for ModelClassify3D.fig
%      MODELCLASSIFY3D, by itself, creates a new MODELCLASSIFY3D or raises the existing
%      singleton*.
%
%      H = MODELCLASSIFY3D returns the handle to a new MODELCLASSIFY3D or the handle to
%      the existing singleton*.
%
%      MODELCLASSIFY3D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MODELCLASSIFY3D.M with the given input arguments.
%
%      MODELCLASSIFY3D('Property','Value',...) creates a new MODELCLASSIFY3D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ModelClassify3D_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ModelClassify3D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ModelClassify3D

% Last Modified by GUIDE v2.5 07-Aug-2014 12:12:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ModelClassify3D_OpeningFcn, ...
                   'gui_OutputFcn',  @ModelClassify3D_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before emsys3D is made visible.
function ModelClassify3D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to emsys3D (see VARARGIN)

handles.version = '0.14a';

fprintf(['\nModelClassify3D ' handles.version '\n']);

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

% Get this folder
thisPath = mfilename('fullpath');
posSlash = find(thisPath == filesep, 1, 'last');
posSlash = posSlash(1);
thisPath = thisPath(1:posSlash);
addpath(genpath(thisPath));


% Choose default command line output for emsys3D
handles.output = hObject;

% Set window properties.
sldrHorizontalPosition = get(handles.sldrHorizontal, 'Position');
mainPanelPosition = get(handles.panelMain, 'Position');
thisPosition = mainPanelPosition;
thisPosition(4) = thisPosition(4) + sldrHorizontalPosition(4);
set(hObject, 'Position', thisPosition);
sldrHorizontalPosition(1) = 0; % x
sldrHorizontalPosition(2) = thisPosition(2);
mainPanelPosition(2) = 0;
set(handles.panelMain, 'Position', mainPanelPosition);

% Mouse scroll and mouse move functions
set(gcf, 'WindowScrollWheelFcn', {@ImageScrollWheelCallback, handles});
% set(gcf, 'WindowButtonMotionFcn', {@MouseMoveCallback, handles});

% Initialize global structures
main_init;
visualization_init;
WS_init;
features_init;
classification_init;
postProcessing_init;
fixedModel_init;

setObjectValues(handles)
activateObjects(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes emsys3D wait for user response (see UIRESUME)
% uiwait(handles.figMain);

function setObjectValues(handles)

% Defaults
global data visualization WS features postProcessing classification;
set(handles.editAnisotropyX, 'String', num2str(data.anisotropic(2)));
set(handles.editAnisotropyY, 'String', num2str(data.anisotropic(1)));
set(handles.editAnisotropyZ, 'String', num2str(data.anisotropic(3)));

set(handles.textDataSet, 'String', data.name);
% set(handles.chbxWSOverlay, 'Value', visualization.pOverlay.bWS);
% set(handles.chbxManualOverlay, 'Value', visualization.pOverlay.bGT);

set(handles.popmS2SelectOverlay, 'String', {'< no additional overlay >'});

listUsedFeatures = [];
for i = 1:length(features.inUse)
    listUsedFeatures = [listUsedFeatures, features.available(features.inUse{i})];
end
set(handles.lstbS4InUse, 'String', listUsedFeatures);

updateParameterTable(handles);

visualization.pOverlay.bAdditional = false;
% set(handles.chbxS2AdditionalOverlay, 'Value', visualization.pOverlay.bAdditional);
% set(handles.popmS2SelectOverlay, 'Enable', 'off');

set(handles.popmS2SelectDisplayedImage, 'String', visualization.available);
value = get(handles.popmS2SelectDisplayedImage, 'Value');
set(handles.popmS2SelectDisplayedImageSub, 'String', visualization.subAvailable{value});
if length(get(handles.popmS2SelectDisplayedImageSub, 'String')) < get(handles.popmS2SelectDisplayedImageSub, 'Value')
    set(handles.popmS2SelectDisplayedImageSub, 'Value', length(get(handles.popmS2SelectDisplayedImageSub, 'String')));
end

set(handles.popmS5Classification, 'String', classification.available);
set(handles.popmS5Classification, 'Value', classification.inUse);

set(handles.chbxS2Invert, 'Value', visualization.pImage.bInvert);
set(handles.chbxS2InvertRaw, 'Value', visualization.pImage.bInvertRaw);

set(handles.chbxS3Invert, 'Value', WS.pWS.preStep.bInvert);
set(handles.chbxS3InvertRaw, 'Value', WS.pWS.preStep.bInvertRaw);

% parameters
%   Step 3
set(handles.popmS3Source, 'String', WS.available);
set(handles.popmS3Source, 'Value', WS.inUse);
set(handles.tbleS3Parameters, 'Data', ...
    [permute(WS.parameterNames{WS.inUse}, [2 1]), ...
     permute(WS.pWS.preStep.parameters, [2 1])]);
set(handles.editWSConn, 'String', num2str(WS.pWS.parameters.conn));
set(handles.editWSMaxDepth, 'String', num2str(WS.pWS.parameters.maxDepth));
set(handles.editWSMaxSize, 'String', num2str(WS.pWS.parameters.maxSize));
%   Step 4
set(handles.popmS4AvailableFeatures, 'String', [features.available]);
%   Step 6
set(handles.popmS6Method, 'String', postProcessing.available);
set(handles.popmS6Method, 'Value', postProcessing.inUse);
set(handles.tbleS6Parameters, 'Data', ...
    [permute(postProcessing.pPP.parameterNames, [2 1]), ...
     permute(postProcessing.pPP.parameters, [2 1])]);

setLstbS2SelectOverlay(handles)
displayCurrentSlice(visualization.currentSlice, handles);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Own functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [h, disabledObj] = computationStart(figureHandle)
% Turn off everything
disabledObj = findobj(figureHandle,'Enable','on');
set(disabledObj,'Enable','off');
% Start waitbar
h = waitbar(0, 'Working...');

function computationUpdate(h, value)
waitbar(value, h);

function computationEnd(h, disabledObj)
waitbar(1, h);
close(h);
set(disabledObj,'Enable','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function switchCube(handles)
global data visualization postProcessing features classification WS;

data.image = openCube(data, handles);
setCurrent(handles);
displayCurrentSlice(visualization.currentSlice, handles);

if isfield(WS, 'result')
    WS = rmfield(WS, 'result');
end
if isfield(classification, 'result')
    classification = rmfield(classification, 'result');
end
if isfield(features, 'result')
    features = rmfield(features, 'result');
end
if isfield(postProcessing, 'result')
    postProcessing = rmfield(postProcessing, 'result');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setRange(handles)

global data visualization

[data.range.X, data.range.Y, data.range.Z] = GUI_determineRange(data);

% Set the sliders
%   Slices
set(handles.sldrSlice, 'Value', 1);
set(handles.sldrSlice, 'Min', 1);
set(handles.sldrSlice, 'Max', size(visualization.output.image, 3));
set(handles.sldrSlice, 'sliderStep', [1/size(visualization.output.image, 3), 1/size(visualization.output.image, 3)]);
%   X
set(handles.sldrX, 'Value', data.disp.X);
set(handles.sldrX, 'Min', data.range.X(1));
set(handles.sldrX, 'Max', data.range.X(2));
set(handles.sldrX, 'sliderStep', ...
    [1/(data.range.X(2)-data.range.X(1)), 1/(data.range.X(2)-data.range.X(1))]);
%   Y
set(handles.sldrY, 'Value', data.disp.Y);
set(handles.sldrY, 'Min', data.range.Y(1));
set(handles.sldrY, 'Max', data.range.Y(2));
set(handles.sldrY, 'sliderStep', ...
    [1/(data.range.Y(2)-data.range.Y(1)), 1/(data.range.Y(2)-data.range.Y(1))]);
%   Z
set(handles.sldrZ, 'Value', data.disp.Z);
set(handles.sldrZ, 'Min', data.range.Z(1));
set(handles.sldrZ, 'Max', data.range.Z(2));
set(handles.sldrZ, 'sliderStep', ...
    [1/(data.range.Z(2)-data.range.Z(1)), 1/(data.range.Z(2)-data.range.Z(1))]);

% Set edits
set(handles.editX, 'String', num2str(data.range.X(1)));
set(handles.editY, 'String', num2str(data.range.Y(1)));
set(handles.editZ, 'String', num2str(data.range.Z(1)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function im = getCurrentImage(handles)

global visualization data

[h, disabledObj] = computationStart(handles.figMain);

% Get ID and feature name
ID = get(handles.popmS2SelectDisplayedImage, 'Value');
featureName = visualization.available{ID};
% Get path of the GUI
thispath = mfilename('fullpath');
posLastSlash = find(thispath == filesep, 1, 'last');
scriptName = [thispath(1:posLastSlash), 'scripts' filesep 'visualization' filesep, featureName, '.m'];

computationUpdate(h, .2);

% Invert raw image
if visualization.pImage.bInvertRaw
    usedImage = jh_invertImage(data.image);
else
    usedImage = data.image;
end

computationUpdate(h, .4);
   
% Store parameters in temporary field
visualization.this.parameters = visualization.pImage.parameters{ID};
visualization.this.mult = 3;
visualization.this.anisotropic = data.anisotropic;
visualization.this.image = usedImage;
% Run selected script
run(scriptName)
% Remove the temporary field
visualization = rmfield(visualization, 'this');

computationUpdate(h, .6);

% Determine and select feature for visualization
if strcmp(visualization.subAvailable{ID}, '')
    im = visualization.(featureName);
else
    subID = get(handles.popmS2SelectDisplayedImageSub, 'Value');
    subFeatureName = visualization.subAvailable{ID}{subID};
    im = visualization.(featureName).(subFeatureName);
end

computationUpdate(h, .8);

% Clear everything except the current
for i = 1:length(visualization.available)
    
    if ~strcmp(visualization.available{i}, featureName)
        if isfield(visualization, visualization.available{i})
            visualization = rmfield(visualization, visualization.available{i});
        end
    end
    
end

computationEnd(h, disabledObj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function im = openCube(data, handles)
global visualization

[h, disabledObj] = computationStart(handles.figMain);

try
    
    im = jh_openCubeRange(data.folder, '', ...
        'range', 'oneCube', [data.disp.X, data.disp.Y, data.disp.Z], ...
        'cubeSize', [128 128 128], ...
        'dataType', 'single', ...
        'fileType', 'auto');
    
catch EX
    
    unexpectedException(EX);
    computationEnd(h, disabledObj);
    im = [];
    return;
    
end

computationEnd(h, disabledObj);

for i = 2:length(visualization.available)
    try
        visualization = rmfield(visualization, visualization.available{i});
    catch
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setOverlaysForDisplay(handles)
global data visualization WS features classification postProcessing

% ----- Watershed
if get(handles.chbxWSOverlay, 'Value') && isfield(WS, 'result')
    visualization.output.overlay{1} = jh_normalizeMatrix(WS.result.matrixed{1});
    visualization.output.overlayMethod{1} = 'WS';
else
    visualization.output.overlay{1} = [];
    visualization.output.overlayMethod{1} = [];
end

% ----- Ground truth
if get(handles.chbxManualOverlay, 'Value') && isfield(classification, 'groundTruth')
    visualization.output.overlay{2} = classification.groundTruth.matrixed.class1;
    visualization.output.overlay{3} = classification.groundTruth.matrixed.class2;
    visualization.output.overlayMethod{2} = 'class1';
    visualization.output.overlayMethod{3} = 'class2';
else
    visualization.output.overlay{2} = [];
    visualization.output.overlay{3} = [];
    visualization.output.overlayMethod{2} = [];
    visualization.output.overlayMethod{3} = [];
end 

% ----- Additional
if get(handles.chbxS2AdditionalOverlay, 'Value')
    
    selectedValue = get(handles.popmS2SelectOverlay, 'Value');
    selectedName = get(handles.popmS2SelectOverlay, 'String');
    
    if ~strcmp(selectedName(selectedValue), '< no additional overlay >')
        selectedFeatureWS = [];
        selectedFeatureMatrix = [];
        selectedClassification = [];
        selectedPP = [];
        if isfield(features, 'result')
            selectedFeatureWS = find(cellfun(@(x) strcmp(x, selectedName{selectedValue}), features.result.names) == 1);
            selectedFeatureMatrix = find(cellfun(@(x) strcmp(x, selectedName{selectedValue}), features.result.namesCalculated) == 1);
        end
        if isfield(classification, 'result')
            selectedClassification = find(cellfun(@(x) strcmp(x, selectedName{selectedValue}), classification.result.names) == 1);
        end
        if isfield(postProcessing, 'result')
            selectedPP = find(cellfun(@(x) strcmp(x, selectedName{selectedValue}), postProcessing.result.names) == 1);
        end
        % Features (@WS)
        if ~isempty(selectedFeatureWS)
            calc = zeros(size(data.image), data.prefType);
            calc(WS.result.listed.seeds.positions) = features.result.listed(:,selectedFeatureWS);
            % Avoid zeros, the actual value is of no special interest anyway
            minAtPositions = min(calc(WS.result.listed.seeds.positions));
            calc(WS.result.listed.seeds.positions) = calc(WS.result.listed.seeds.positions) - minAtPositions + 0.01;

            nh = jh_getNeighborhoodFromConnectivity(WS.pWS.parameters.conn, WS.pWS.parameters.dimensions);
            calc = jh_regionGrowing3D( ... 
                calc, WS.result.matrixed{1}, nh, 0, 'l', ...
                'prefType', data.prefType, 'iterations', 0 ...
                );
            visualization.output.overlay{4} = jh_normalizeMatrix(calc);
            visualization.output.overlayMethod{4} = 'red2blue';
        
        % Features (calculated)
        elseif ~isempty(selectedFeatureMatrix) 
            visualization.output.overlay{4} = jh_normalizeMatrix(features.result.matrixed{selectedFeatureMatrix});
            visualization.output.overlayMethod{4} = 'red2blue';
        
        
        % Classfication
        elseif ~isempty(selectedClassification)
            visualization.output.overlay{4} = jh_normalizeMatrix(classification.result.matrixed{selectedClassification});
            if selectedClassification == 3
                visualization.output.overlay{4}(WS.result.matrixed{1} == 0) = 0;
            end
            if selectedClassification <= 2
                visualization.output.overlayMethod{4} = 'yellowPurple';
            else
                visualization.output.overlayMethod{4} = 'red2blue';
            end
        
        
        % PostProcessing
        elseif ~isempty(selectedPP)
            visualization.output.overlay{4} = jh_normalizeMatrix(postProcessing.result.matrixed{selectedPP});
            visualization.output.overlayMethod{4} = 'red2blue';
            
            
        else
            visualization.output.overlay{4} = [];
            visualization.output.overlayMethod{4} = [];
        end
        
    else
        visualization.output.overlay{4} = [];
        visualization.output.overlayMethod{4} = [];
    end
else
    visualization.output.overlay{4} = [];
    visualization.output.overlayMethod{4} = [];
end
% -----

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function displayCurrentSlice(slice, handles)
global visualization data

visualization.currentSlice = slice;
set(handles.editCurrentSlice, 'String', num2str(slice));
set(handles.sldrSlice, 'Value', slice);

if isempty(visualization.output.overlay)
    
    % Only show the current image
    imshow(visualization.output.image(:,:,slice), 'Parent', handles.axesCurrentSlice);

else
    
    showImage(:,:,1) = visualization.output.image(:,:,slice);
    showImage(:,:,2) = showImage(:,:,1);
    showImage(:,:,3) = showImage(:,:,1);
    
    
    % Create and show overlay
    for i = 1:length(visualization.output.overlay)
        
        if ~isempty(visualization.output.overlay{i})
            
            switch visualization.output.overlayMethod{i}
                case 'WS'
                    showImage = jh_overlayLabels( ...
                        showImage, ...
                        visualization.output.overlay{i}(:,:,slice), ...
                        'type', 'colorizeInv', ...
                        'oneColor', [0 .05 .2], ...
                        'rgb');
%                     showImage = jh_overlayLabels( ...
%                         showImage, ...
%                         visualization.output.overlay{i}(:,:,slice), ...
%                         'type', 'colorizeInv', ...
%                         'oneColor', [0 .1 .4], ...
%                         'rgb');
                case 'red2blue'
                    showImage = jh_overlayLabels( ...
                        showImage, ...
                        visualization.output.overlay{i}(:,:,slice), ...
                        'type', 'colorize', ...
                        'range', [0 .67], ...
                        'rgb', 'inv');
                case 'yellowPurple'
                    showImage = jh_overlayLabels( ...
                        showImage, ...
                        visualization.output.overlay{i}(:,:,slice), ...
                        'type', 'colorize', ...
                        'oneColor', [1 0 0], ...
                        'rgb');
%                     showImage = jh_overlayLabels( ...
%                         showImage, ...
%                         visualization.output.overlay{i}(:,:,slice), ...
%                         'type', 'colorize', ...
%                         'range', [0 .67], ...
%                         'rgb', 'inv');
                case 'class1'
                    showImage = jh_overlayLabels( ...
                        showImage, ...
                        visualization.output.overlay{i}(:,:,slice), ...
                        'type', 'colorize', ...
                        'oneColor', [.6 .0 .0], ...
                        'rgb');
                case 'class2'
                    showImage = jh_overlayLabels( ...
                        showImage, ...
                        visualization.output.overlay{i}(:,:,slice), ...
                        'type', 'colorize', ...
                        'oneColor', [.0 .5 .1], ...
                        'rgb');
                case 'else'
                    
            end
            
        end
        
    end
    
    if data.currentStep > 3 && data.currentStep < 7
        imageHandle = imshow(showImage, 'Parent', handles.axesCurrentSlice);
        clear showImage;
        set(imageHandle, 'ButtonDownFcn', {@ImageClickCallback, handles});
    else
        imshow(showImage, 'Parent', handles.axesCurrentSlice);
        clear showImage;
    end

    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function displayCurrentSlice2(slice, handles)
% 
% global data features WS postProcessing fixedModel visualization;
% 
% 
% visualization.currentSlice = slice;
% set(handles.editCurrentSlice, 'String', num2str(slice));
% set(handles.sldrSlice, 'Value', slice);
% 
% if data.currentStep == 1
%     imshow(visualization.output.image(:,:,slice), 'Parent', handles.axesCurrentSlice);
% end
% 
% if data.currentStep == 2
%     imshow(visualization.output.image(:,:,slice), 'Parent', handles.axesCurrentSlice);
% end
% 
% if data.currentStep >= 3
%     
%     if data.bWSOverlay
%         showImage = jh_overlayLabels( ...
%             visualization.output.image(:,:,slice), ...
%             WS.results{1}(:,:,slice), ...
%             'oneColor', [0 .05 .2], 'type', 'colorizeInv');
%         type = 'rgb';
%     else
%         showImage = visualization.output.image(:,:,slice);
%         type = 'gray';
%     end
%     
%     if data.bManualOverlay 
%         if jh_globalMax(data.WSVesicles(:,:,slice)) > 0
%             showImage = jh_overlayLabels( ...
%                 showImage, ...
%                 data.WSVesicles(:,:,slice), ...
%                 'oneColor', [.6 .0 .0], 'type', 'colorize', type);
%             type = 'rgb';
%         end
%         if jh_globalMax(data.WSNoVesicles(:,:,slice)) > 0
%             showImage = jh_overlayLabels( ...
%                 showImage, ...
%                 data.WSNoVesicles(:,:,slice), ...
%                 'oneColor', [.0 .5 .1], 'type', 'colorize', type);
%             type = 'rgb';
%         end
%     end
%     
% end
% 
% if data.currentStep >= 4 && data.currentStep < 7 && visualization.pOverlay.bAdditional
%     
%     overlayIndex = get(handles.popmS2SelectOverlay, 'Value');
%     
%     count = 1;
%     
%     for i = 1:length(features.matrixed.atPositions)
%         count = count + 1;
%         if overlayIndex == count 
%             % Create the matrix if it is empty
%             if isempty(features.matrixed.atPositions{i});
%                 features.matrixed.atPositions{i} = zeros(size(data.image), data.prefType);
%                 features.matrixed.atPositions{i}(WS.listedSeeds.positions) = features.listed(:,i);
%                 % Avoid zeros, the actual value is of no special interest anyway
%                 minAtPositions = min(features.matrixed.atPositions{i}(WS.listedSeeds.positions));
%                 features.matrixed.atPositions{i}(WS.listedSeeds.positions) = features.matrixed.atPositions{i}(WS.listedSeeds.positions) - minAtPositions + 0.01;
% 
%                 nh = jh_getNeighborhoodFromConnectivity(WS.WS_conn, WS.dimensions);
%                 features.matrixed.atPositions{i} = ...
%                     jh_normalizeMatrix( ...
%                         jh_regionGrowing3D( ... 
%                             features.matrixed.atPositions{i}, WS.results{1}, nh, 0, 'l', ...
%                             'prefType', data.prefType, 'iterations', 0 ...
%                             ) ...
%                         );
%             end
%             showImage = jh_overlayLabels( ...
%                 showImage, features.matrixed.atPositions{i}(:,:,slice), ...
%                 'type', 'colorize', type, 'range', [0 .67], 'inv');
%         end
%     end
%     
%     if isfield(features, 'classification')
%         count = count + 1;
%         if overlayIndex == count
%             showImage = jh_overlayLabels( ...
%                 showImage, classification.result{2}(:,:,slice), ...
%                 'oneColor', [.3 .3 0], 'type', 'colorizeInv', type);
%         end
%         count = count + 1;
%         if overlayIndex == count
%             showImage = jh_overlayLabels( ...
%                 showImage, classification.overlayScore(:,:,slice), ...
%                 'type', 'colorize', type, 'range', [0 .67], 'inv');
%         end
%     end
%     
%     if isfield(postProcessing, 'result')
%         count = count + 1;
%         if overlayIndex == count
%             showImage = jh_overlayLabels( ...
%                 showImage, postProcessing.result{1}(:,:,slice), ...
%                 'type', 'colorize', type, 'range', [0 .67], 'inv'); % 'range', [0 .33]);
%         end
% 
%         count = count + 1;
%         if overlayIndex == count
%             showImage = jh_overlayLabels( ...
%                 showImage, postProcessing.result{2}(:,:,slice), ...
%                 'type', 'colorize', type, 'range', [0 .67], 'inv'); % 'range', [0 .33]);
% %                 'oneColor', [.3 .3 0], 'type', 'colorizeInv', type);
%         end
%         
%         count = count + 1;
%         if overlayIndex == count
%             showImage = jh_overlayLabels( ...
%                 showImage, postProcessing.result{3}(:,:,slice), ...
%                 'type', 'colorize', type, 'range', [0 .67], 'inv'); 
%         end
%         
%         count = count + 1;
%         if overlayIndex == count
%             showImage = jh_overlayLabels( ...
%                 showImage, postProcessing.result{4}(:,:,slice), ...
%                 'type', 'colorize', type, 'range', [0 .67], 'inv'); 
%         end
% 
%     end
% 
%     
%     
% end
% 
% if data.currentStep == 7
%     
%     overlayIndex = get(handles.popmS2SelectOverlay, 'Value');
% 
%     count = 1;
% 
%     if isfield(fixedModel, 'classScores')
%         count = count + 1;
%         if overlayIndex == count
%             showImage = jh_overlayLabels( ...
%                 showImage, fixedModel.classScores(:,:,slice), ...
%                 'type', 'colorize', type, 'range', [0 .67], 'inv'); 
%         end
%     end
% 
%     if isfield(fixedModel, 'classification')
%         count = count + 1;
%         if overlayIndex == count
%             showImage = jh_overlayLabels( ...
%                 showImage, fixedModel.classification(:,:,slice), ...
%                 'oneColor', [.3 .3 0], 'type', 'colorizeInv', type);
%         end
%     end
%     
%     if isfield(fixedModel, 'vesicles')
%         count = count + 1;
%         if overlayIndex == count
%             showImage = jh_overlayLabels( ...
%                 showImage, fixedModel.vesicles(:,:,slice), ...
%                 'type', 'colorize', type, 'range', [0 .67], 'inv');
%         end
%     end
%     
%     if isfield(fixedModel, 'postProcessing')
%         count = count + 1;
%         if overlayIndex == count
%             showImage = jh_overlayLabels( ...
%                 showImage, fixedModel.postProcessing(:,:,slice), ...
%                 'type', 'colorize', type);
%         end
%     end
%     
%     if isfield(fixedModel, 'vesicleCloudsScore')
%         count = count + 1;
%         if overlayIndex == count
%             showImage = jh_overlayLabels( ...
%                 showImage, fixedModel.vesicleCloudsScore(:,:,slice), ...
%                 'type', 'colorize', type, 'range', [0 .67], 'inv'); 
%         end
%     end
%     
%     if isfield(fixedModel, 'vesicleCloudsNHScore')
%         count = count + 1;
%         if overlayIndex == count
%             showImage = jh_overlayLabels( ...
%                 showImage, fixedModel.vesicleCloudsNHScore(:,:,slice), ...
%                 'type', 'colorize', type, 'range', [0 .67], 'inv'); 
%         end
%     end
% 
%     if isfield(fixedModel, 'result')
%         count = count + 1;
%         if overlayIndex == count
%             showImage = fixedModel.result(:,:,slice,:);
%             showImage = permute(showImage, [1 2 4 3]);
%         end
%     end        
% 
% 
% end
% 
% if data.currentStep >= 3
%     
%     if data.currentStep == 7
%         imshow(showImage, 'Parent', handles.axesCurrentSlice);
%         clear showImage;
%     else
%         imageHandle = imshow(showImage, 'Parent', handles.axesCurrentSlice);
%         clear showImage;
%         set(imageHandle, 'ButtonDownFcn', {@ImageClickCallback, handles});
%     end
% 
%     
%     
%     
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setCurrent(handles, im)
global visualization

if ~exist('im', 'var')
    im = getCurrentImage(handles);
end

% Invert image
if visualization.pImage.bInvert
    im = jh_invertImage(im);
end

visualization.output.image = jh_normalizeMatrix(im);
displayCurrentSlice(visualization.currentSlice, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WS(handles)

global data WS classification;

[h, disabledObj] = computationStart(handles.figMain);

try
    
    WS.result = GUI_watershed(data.image, WS, data, h);

    if isfield(classification, 'groundTruth')
        classification = rmfield(classification, 'groundTruth');
    end
    
catch
    
    computationEnd(h, disabledObj);
    return;

end

computationEnd(h, disabledObj);

displayCurrentSlice(get(handles.sldrSlice, 'Value'), handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is responsible for all visibilities etc for each step and
% can be called at any time 
function activateObjects(handles)
global data;



setLstbS2SelectOverlay(handles);

switch data.currentStep
    case 0 
        set(findall(handles.panelStep2, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep3, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep4, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep5, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep6, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep7, '-property', 'Enable'), 'Enable', 'off');
    case 1
        set(findall(handles.panelStep2, '-property', 'Enable'), 'Enable', 'on');
        set(findall(handles.panelStep3, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep4, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep5, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep6, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep7, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelS2SelectDisplayedImage, '-property', 'Enable'), 'Enable', 'on');
        set(handles.editAnisotropyX, 'Enable', 'on');
        set(handles.editAnisotropyY, 'Enable', 'on');
        set(handles.editAnisotropyZ, 'Enable', 'on');
    case 2
        set(handles.sldrX, 'Enable', 'off');
        set(handles.sldrY, 'Enable', 'off');
        set(handles.sldrZ, 'Enable', 'off');
        set(handles.bttnStep2, 'Enable', 'off');
        set(findall(handles.panelStep3, '-property', 'Enable'), 'Enable', 'on');
        set(findall(handles.panelStep4, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep5, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelS2SelectDisplayedImage, '-property', 'Enable'), 'Enable', 'on');
        set(handles.editAnisotropyX, 'Enable', 'off');
        set(handles.editAnisotropyY, 'Enable', 'off');
        set(handles.editAnisotropyZ, 'Enable', 'off');
    case 3
        set(handles.bttnStep3, 'String', 'Recalculate')
        set(findall(handles.panelStep3, '-property', 'Enable'), 'Enable', 'on');
        set(findall(handles.panelStep4, '-property', 'Enable'), 'Enable', 'on');
        set(findall(handles.panelStep5, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelS2SelectDisplayedImage, '-property', 'Enable'), 'Enable', 'on');
    case 4
        set(handles.bttnStep4, 'String', 'Recalculate')
        set(findall(handles.panelStep3, '-property', 'Enable'), 'Enable', 'on');
        set(findall(handles.panelStep4, '-property', 'Enable'), 'Enable', 'on');
        set(findall(handles.panelStep5, '-property', 'Enable'), 'Enable', 'on');
    case 5
        set(findall(handles.panelStep3, '-property', 'Enable'), 'Enable', 'on');
        set(findall(handles.panelStep4, '-property', 'Enable'), 'Enable', 'on');
        set(findall(handles.panelStep5, '-property', 'Enable'), 'Enable', 'on');
        set(findall(handles.panelStep6, '-property', 'Enable'), 'Enable', 'on');
    case 6
        set(findall(handles.panelStep3, '-property', 'Enable'), 'Enable', 'on');
        set(findall(handles.panelStep4, '-property', 'Enable'), 'Enable', 'on');
        set(findall(handles.panelStep5, '-property', 'Enable'), 'Enable', 'on');
        set(findall(handles.panelStep6, '-property', 'Enable'), 'Enable', 'on');
        set(findall(handles.panelStep7, '-property', 'Enable'), 'Enable', 'on');
        set(handles.sldrX, 'Enable', 'off');
        set(handles.sldrY, 'Enable', 'off');
        set(handles.sldrZ, 'Enable', 'off');
    case 7
        set(findall(handles.panelStep3, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep4, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep5, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep6, '-property', 'Enable'), 'Enable', 'off');
        set(findall(handles.panelStep7, '-property', 'Enable'), 'Enable', 'on');
        set(handles.sldrX, 'Enable', 'on');
        set(handles.sldrY, 'Enable', 'on');
        set(handles.sldrZ, 'Enable', 'on');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setLstbS2SelectOverlay(handles)
global data features postProcessing fixedModel classification;

if data.currentStep <= 7
    
    fl = {'< no additional overlay >'};

    if isfield(features, 'result')
        fl = [fl, features.result.namesCalculated];
        for i = 1:length(features.result.names)
            fl = [fl, features.result.names(i)];
        end
    end
    if isfield(classification, 'result')
        fl = [fl, classification.result.names];
    end
    if isfield(postProcessing, 'result')
        fl = [fl, postProcessing.result.names];
    end
    
    set(handles.popmS2SelectOverlay, 'String', fl);
    if get(handles.popmS2SelectOverlay, 'Value') > length(fl)
        set(handles.popmS2SelectOverlay, 'Value', length(fl));
    end

elseif data.currentStep > 7
    
    fl = {'< no additional overlay >'};
    
    if isfield(fixedModel, 'classScores')
        fl = [fl, {'Classification scores'}];
    end
    if isfield(fixedModel, 'classification')
        fl = [fl, {'Classification result'}];
    end
    if isfield(fixedModel, 'postProcessing')
        fl = [fl, {'Vesicle clouds'}];
    end
    if isfield(fixedModel, 'vesicles')
        fl = [fl, {'Vesicle clouds: Vesicles'}];
    end
    if isfield(fixedModel, 'vesicleCloudsScore')
        fl = [fl, {'Vesicle clouds score'}];
    end
    if isfield(fixedModel, 'vesicleCloudsNHScore')
        fl = [fl, {'Vesicle clouds NH score'}];
    end
    
    set(handles.popmS2SelectOverlay, 'String', fl);
    if get(handles.popmS2SelectOverlay, 'Value') > length(fl)
        set(handles.popmS2SelectOverlay, 'Value', length(fl));
    end
    
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateGroundtruth()
global WS classification

if length(find(classification.groundTruth.matrixed.class1 > 0 & WS.result.matrixed{2} > 0)) > 1
%     data.bGT = true;

    listedClass1 = classification.groundTruth.matrixed.class1(WS.result.listed.seeds.positions);
    listedClass2 = classification.groundTruth.matrixed.class2(WS.result.listed.seeds.positions);
    classification.groundTruth.listed = zeros(size(listedClass1));
    classification.groundTruth.listed(listedClass1 > 0) = 2;
    classification.groundTruth.listed(listedClass2 > 0) = 1;

else
%     data.bGT = false;
end

function updateUsedFeatures(handles)
global features

features.pFeatures.methods = cellfun(@(x) features.available(x), features.inUse);
features.pFeatures.parameterNames = cellfun(@(x) features.parameterNames(x), features.inUse);
features.pFeatures.subFeatures = cellfun(@(x) features.subFeatures(x), features.inUse);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Own events %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ImageScrollWheelCallback(hObject, eventdata, handles)
global data visualization

if data.currentStep >= 1
    C = get(gca, 'CurrentPoint');
    if C(1, 1) >= 1 && C(1, 1) < size(data.image, 2) && ...
            C(1, 2) >= 1 && C(1, 2) < size(data.image, 1)
        newValue = get(handles.sldrSlice, 'Value') + eventdata.VerticalScrollCount;
        if newValue > size(data.image, 3)
            newValue = size(data.image, 3);
        elseif newValue < 1
            newValue = 1;
        end
        set(handles.sldrSlice, 'Value', newValue);
        visualization.currentSlice = newValue;
        displayCurrentSlice(visualization.currentSlice, handles);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ImageClickCallback(hObject, eventdata, handles)

global data WS visualization classification;

axesHandle  = get(hObject,'Parent');
coordinates = get(axesHandle,'CurrentPoint'); 
coordinates = round(coordinates(1,1:2));

if data.currentStep > 3
    
    if ~isfield(classification, 'groundTruth')
        classification.groundTruth.matrixed.class1 = zeros(size(data.image), data.prefType);
        classification.groundTruth.matrixed.class2 = zeros(size(data.image), data.prefType);
    end
    
    % Get the label of the selected WS basin
    label = WS.result.matrixed{1}(coordinates(2), coordinates(1), visualization.currentSlice);
    
    if label ~= 0
        if strcmp(get(gcf,'SelectionType'), 'normal')
            if classification.groundTruth.matrixed.class2(WS.result.matrixed{1} == label) == 1
                classification.groundTruth.matrixed.class2(WS.result.matrixed{1} == label) = 0;
            else
                classification.groundTruth.matrixed.class1(WS.result.matrixed{1} == label) = 1;
            end
        else
            if classification.groundTruth.matrixed.class1(WS.result.matrixed{1} == label) == 1
                classification.groundTruth.matrixed.class1(WS.result.matrixed{1} == label) = 0;
            else
                classification.groundTruth.matrixed.class2(WS.result.matrixed{1} == label) = 1;
            end
        end
        updateGroundtruth();

%         if data.currentStep >= 4
%             % Calculate probabilities
%             if data.bGT
% 
%                 setLstbS2SelectOverlay(handles);
%                 
%             end
%             if data.currentStep == 5
%             end
%             if get(handles.popmS2SelectOverlay, 'Value') > length(get(handles.popmS2SelectOverlay, 'String'))
%                 set(handles.popmS2SelectOverlay, 'Value', length(get(handles.popmS2SelectOverlay, 'String')));
%             end
%         end
            
    end
    
end

activateObjects(handles);
setOverlaysForDisplay(handles);
displayCurrentSlice(visualization.currentSlice, handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Outputs from this function are returned to the command line.
function varargout = ModelClassify3D_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
try
    varargout{1} = handles.output;
catch
    varargout{1} = [];
end


% --- Executes on slider movement.
function sldrSlice_Callback(hObject, eventdata, handles)
% hObject    handle to sldrSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global data;
value = round(get(hObject,'Value'));
set(handles.sldrSlice, 'Value', value);

displayCurrentSlice(value, handles);


% --- Executes during object creation, after setting all properties.
function sldrSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldrSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in bttnStep1.
function bttnStep1_Callback(hObject, eventdata, handles)
% hObject    handle to bttnStep1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load data
global data visualization;
data.image = jh_openCubeRange(data.folder, data.name, ...
    [data.range.X.start data.range.X.end], ...
    [data.range.Y.start data.range.Y.end], ...
    [data.range.Z.start data.range.Z.end], ...
    [128 128 128], 'single', 'cubed');

data.currentStep = 1;

% Show the currently selected slice in axes
setCurrent(handles);
displayCurrentSlice(1, handles);

% Set the sliders
%   Slices
set(handles.sldrSlice, 'Value', 1);
set(handles.sldrSlice, 'Min', 1);
set(handles.sldrSlice, 'Max', size(visualization.output.image, 3));
set(handles.sldrSlice, 'sliderStep', [1/size(visualization.output.image, 3), 1/size(visualization.output.image, 3)]);
%   X
set(handles.sldrX, 'Value', data.range.X.start);
set(handles.sldrX, 'Min', data.range.X.start);
set(handles.sldrX, 'Max', data.range.X.end);
set(handles.sldrX, 'sliderStep', ...
    [1/(data.range.X.end-data.range.X.start), 1/(data.range.X.end-data.range.X.start)]);
%   Y
set(handles.sldrY, 'Value', data.range.Y.start);
set(handles.sldrY, 'Min', data.range.Y.start);
set(handles.sldrY, 'Max', data.range.Y.end);
set(handles.sldrY, 'sliderStep', ...
    [1/(data.range.Y.end-data.range.Y.start), 1/(data.range.Y.end-data.range.Y.start)]);
%   Z
set(handles.sldrZ, 'Value', data.range.Z.start);
set(handles.sldrZ, 'Min', data.range.Z.start);
set(handles.sldrZ, 'Max', data.range.Z.end);
set(handles.sldrZ, 'sliderStep', ...
    [1/(data.range.Z.end-data.range.Z.start), 1/(data.range.Z.end-data.range.Z.start)]);

% Set edits
set(handles.editX, 'String', num2str(data.range.X.start));
set(handles.editY, 'String', num2str(data.range.Y.start));
set(handles.editZ, 'String', num2str(data.range.Z.start));

activateObjects(handles);


% --- Executes on slider movement.
function sldrX_Callback(hObject, eventdata, handles)
% hObject    handle to sldrX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global data;
value = round(get(hObject, 'Value'));
set(handles.sldrX, 'Value', value);

data.disp.X = value; 
switchCube(handles);

% set(handles.sldrSlice, 'Value', 1);
set(handles.editX, 'String', num2str(value));


% --- Executes during object creation, after setting all properties.
function sldrX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldrX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sldrY_Callback(hObject, eventdata, handles)
% hObject    handle to sldrY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global data;
value = round(get(hObject, 'Value'));
set(handles.sldrY, 'Value', value);

data.disp.Y = value; 

switchCube(handles);
% set(handles.sldrSlice, 'Value', 1);
set(handles.editY, 'String', num2str(value));


% --- Executes during object creation, after setting all properties.
function sldrY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldrY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sldrZ_Callback(hObject, eventdata, handles)
% hObject    handle to sldrZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global data
value = round(get(hObject, 'Value'));
set(handles.sldrZ, 'Value', value);

oldZ = data.disp.Z;
data.disp.Z = value; 

if oldZ < value
    visualization.currentSlice = 1;
else
    visualization.currentSlice = size(data.image, 3);
end
set(handles.sldrSlice, 'Value', visualization.currentSlice);

switchCube(handles);

set(handles.editZ, 'String', num2str(value));


% --- Executes during object creation, after setting all properties.
function sldrZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldrZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editX_Callback(hObject, eventdata, handles)
% hObject    handle to editX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editX as text
%        str2double(get(hObject,'String')) returns contents of editX as a double


% --- Executes during object creation, after setting all properties.
function editX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editY_Callback(hObject, eventdata, handles)
% hObject    handle to editY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editY as text
%        str2double(get(hObject,'String')) returns contents of editY as a double


% --- Executes during object creation, after setting all properties.
function editY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editZ_Callback(hObject, eventdata, handles)
% hObject    handle to editZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editZ as text
%        str2double(get(hObject,'String')) returns contents of editZ as a double


% --- Executes during object creation, after setting all properties.
function editZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editCurrentSlice_Callback(hObject, eventdata, handles)
% hObject    handle to editCurrentSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCurrentSlice as text
%        str2double(get(hObject,'String')) returns contents of editCurrentSlice as a double


% --- Executes during object creation, after setting all properties.
function editCurrentSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCurrentSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bttnStep3.
function bttnStep3_Callback(hObject, eventdata, handles)
% hObject    handle to bttnStep3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data visualization

data.currentStep = 2;
WS(handles)
data.currentStep = 3;

setOverlaysForDisplay(handles);
displayCurrentSlice(visualization.currentSlice, handles);
activateObjects(handles);


function editWSConn_Callback(hObject, eventdata, handles)
% hObject    handle to editWSConn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWSConn as text
%        str2double(get(hObject,'String')) returns contents of editWSConn as a double
global WS;
WS.pWS.parameters.conn = str2double(get(hObject, 'String'));


% --- Executes during object creation, after setting all properties.
function editWSConn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWSConn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editWSMaxDepth_Callback(hObject, eventdata, handles)
% hObject    handle to editWSMaxDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWSMaxDepth as text
%        str2double(get(hObject,'String')) returns contents of editWSMaxDepth as a double
global WS;
WS.pWS.parameters.maxDepth = str2double(get(hObject, 'String'));


% --- Executes during object creation, after setting all properties.
function editWSMaxDepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWSMaxDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editWSMaxSize_Callback(hObject, eventdata, handles)
% hObject    handle to editWSMaxSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWSMaxSize as text
%        str2double(get(hObject,'String')) returns contents of editWSMaxSize as a double
global WS;
WS.pWS.parameters.maxSize = str2double(get(hObject, 'String'));


% --- Executes during object creation, after setting all properties.
function editWSMaxSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWSMaxSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bttnStep2.
function bttnStep2_Callback(hObject, eventdata, handles)
% hObject    handle to bttnStep2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data;

data.currentStep = 2;
activateObjects(handles);


% --- Executes on button press in bttnStep4.
function bttnStep4_Callback(hObject, eventdata, handles)
% hObject    handle to bttnStep4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[h, disabledObj] = computationStart(handles.figMain);

global data features WS visualization;

try

    if isfield(features, 'intensities')
        features = rmfield(features, 'intensities');
    end
    if isfield(features, 'probabilities')
        features = rmfield(features, 'probabilities');
    end
    if isfield(features, 'results')
        features = rmfield(features, 'results');
    end

    data.currentStep = 3;
    
    thispath = mfilename('fullpath');
    posLastSlash = find(thispath == filesep, 1, 'last');
    scriptPath = [thispath(1:posLastSlash), 'scripts' filesep 'features' filesep];

    [data, features] = GUI_createFeatureIntensities(data, features, WS, h);
    setLstbS2SelectOverlay(handles);
    
catch EX
    
    unexpectedException(EX);
    computationEnd(h, disabledObj);
    return;
    
end

computationEnd(h, disabledObj);

data.currentStep = 4;

displayCurrentSlice(visualization.currentSlice, handles);
activateObjects(handles);



function editEvaluation_Callback(hObject, eventdata, handles)
% hObject    handle to editEvaluation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEvaluation as text
%        str2double(get(hObject,'String')) returns contents of editEvaluation as a double


% --- Executes during object creation, after setting all properties.
function editEvaluation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEvaluation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chbxWSOverlay.
function chbxWSOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to chbxWSOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chbxWSOverlay
global data visualization

if get(hObject, 'Value') == 1
    data.bWSOverlay = true;
else
    data.bWSOverlay = false;
end
setOverlaysForDisplay(handles);
displayCurrentSlice(visualization.currentSlice, handles);


% --- Executes when user attempts to close figMain.
function figMain_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global data 

delete(hObject);

rmpath(genpath(data.folders.main));

clear -global data visualization features WS postProcessing fixedModel;


% --- Executes on button press in bttnS5ClearClass1.
function bttnS5ClearClass1_Callback(hObject, eventdata, handles)
% hObject    handle to bttnS5ClearClass1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data visualization classification

classification.groundTruth.matrixed.class1(:,:,visualization.currentSlice) ...
    = zeros(size(data.image, 1), size(data.image, 2), data.prefType);

updateGroundtruth();

setOverlaysForDisplay(handles);
displayCurrentSlice(visualization.currentSlice, handles);

% --- Executes on button press in chbxManualOverlay.
function chbxManualOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to chbxManualOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chbxManualOverlay
global visualization;

% if get(hObject, 'Value') == 1
%     data.bManualOverlay = true;
% else
%     data.bManualOverlay = false;
% end
setOverlaysForDisplay(handles);
displayCurrentSlice(visualization.currentSlice, handles);


% --- Executes when selected object is changed in uipnSelectOverlay.
function uipnSelectOverlay_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipnSelectOverlay 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global visualization;

displayCurrentSlice(visualization.currentSlice, handles);



function editS4DivThresh_Callback(hObject, eventdata, handles)
% hObject    handle to editS4DivThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editS4DivThresh as text
%        str2double(get(hObject,'String')) returns contents of editS4DivThresh as a double


% --- Executes during object creation, after setting all properties.
function editS4DivThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editS4DivThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editS4GaussianThresh_Callback(hObject, eventdata, handles)
% hObject    handle to editS4GaussianThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editS4GaussianThresh as text
%        str2double(get(hObject,'String')) returns contents of editS4GaussianThresh as a double


% --- Executes during object creation, after setting all properties.
function editS4GaussianThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editS4GaussianThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editS4HessianThresh_Callback(hObject, eventdata, handles)
% hObject    handle to editS4HessianThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editS4HessianThresh as text
%        str2double(get(hObject,'String')) returns contents of editS4HessianThresh as a double


% --- Executes during object creation, after setting all properties.
function editS4HessianThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editS4HessianThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bttnRunOnWholeDataSet.
function bttnRunOnWholeDataSet_Callback(hObject, eventdata, handles)
% hObject    handle to bttnRunOnWholeDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WS features classification postProcessing data

% removeUnnecessary
saveStuff.pWS = WS.pWS;
saveStuff.pFeatures = features.pFeatures;
saveStuff.pClassification = classification.pClassification;
saveStuff.pPP = postProcessing.pPP;
saveStuff.data.anisotropic = data.anisotropic;
saveStuff.data.prefType = data.prefType;
saveStuff.data.folders = data.folders;

[fileName, pathName, ~] = uiputfile('*.mat');
save([pathName fileName], 'saveStuff');


% folder = uigetdir(pwd);
% 
% pWS.preStep.type = WS.available{WS.inUse};
% pWS.preStep.parameters = WS.parameters;
% pWS.parameters.conn = WS.WS_conn;
% pWS.parameters.maxDepth = WS.WS_maxDepth;
% pWS.parameters.maxSize = WS.WS_maxSize;
% thispath = mfilename('fullpath');
% posLastSlash = find(thispath == '\', 1, 'last');
% pWS.scriptPath = [thispath(1:posLastSlash), 'scripts\watershed\'];
% pWS.bInvert = WS.bInvert;
% pWS.bInvertRaw = WS.bInvertRaw;
% 
% pFeatures.names = cellfun(@(x) features.available(x), features.inUse);
% pFeatures.parameters = features.pFeatures.parameters;
% 
% pClassification.type = fixedModel.classificationType;
% pClassification.model = fixedModel.model;
% 
% pVesicleClouds = [];
% 
% rangeX = [4 5];
% rangeY = [3 4];
% rangeZ = [2 3];
% im = jh_openCubeRange(data.folder, data.name, ...
%     'range', rangeX, rangeY, rangeZ, ...
%     'cubeSize', [128 128 128], ...
%     'dataType', 'single');
% 
% result = jh_synapseSeg3D( ...
%     im, pWS, pFeatures, pClassification, pVesicleClouds, ...
%     'prefType', 'single', ...
%     'anisotropic', [1 1 3], ...
%     'save', {'postProcessing'}, folder, 'test');
% 
% fixedModel.result = jh_overlayLabels( ...
%     jh_normalizeMatrix(im), jh_normalizeMatrix(result), ...
%     'type', 'colorize', 'gray', 'range', [0 .33], 'randomizeColors');
% 
% setLstbS2SelectOverlay(handles);


% --- Executes on button press in bttnStep5.
function bttnStep5_Callback(hObject, eventdata, handles)
% hObject    handle to bttnStep5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data features WS classification visualization
% [data, features, featureList] = GUI_optimizeResults1(data, features, WS);
% updateParameterTable(handles);

[h, disabledObj] = computationStart(handles.figMain);

try
    
    classification.result.matrixed = cell(1, 4);
    switch get(handles.popmS5Classification, 'Value')
        case 1 % KNN
            classification.pClassification.method = 'KNN';
            [classification.result.matrixed{1}, classification.result.matrixed{2}, classification.pClassification.model] = GUI_KNNanalysis(data, features, WS, 2, h);
        case 2 % SVM
            classification.pClassification.method = 'SVM';
            try
                [classification.result.matrixed{1}, classification.result.matrixed{2}, classification.pClassification.model, classification.result.matrixed{3}] ...
                    = GUI_SVManalysis(data, features, WS, classification, h);
                classification.result.names = { ...
                    'Classification: Minima', ...
                    'Classification: WS', ...
                    'Classification: Score', ...
                    'Classification: Score (cut off)'};
            catch
                classification = rmfield(classification, 'result');
                fprintf('    ERROR: SVM classification failed.\n');
                fprintf('        Consider adding additional features or reducing ground truth annotation\n\n');
                computationEnd(h, disabledObj);
                return
            end
            classification.result.matrixed{4} = classification.result.matrixed{3};
            cutOffValue = 2;
            classification.result.matrixed{4}(classification.result.matrixed{4} < -cutOffValue) = -cutOffValue;
            classification.result.matrixed{4}(WS.result.matrixed{1} == 0) = -cutOffValue-0.01;
            classification.result.matrixed{4}(classification.result.matrixed{4} >= cutOffValue) = cutOffValue;
%             classification.result.matrixed{4}(classification.result.matrixed{4} < cutOffValue & classification.result.matrixed{4} > -cutOffValue) = 0;
            classification.result.matrixed{4} = jh_normalizeMatrix(classification.result.matrixed{4});
    end
    
    set(handles.editEvaluation, 'String', GUI_evaluate(WS, classification));
    
catch EX
    
    unexpectedException(EX);
    computationEnd(h, disabledObj);
    fprintf('    ERROR: Unknown error.\n\n');
    return
    
end


computationEnd(h, disabledObj);

setLstbS2SelectOverlay(handles);
data.currentStep = 5;

setOverlaysForDisplay(handles);
displayCurrentSlice(visualization.currentSlice, handles);
activateObjects(handles);


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lstbS4SelectedFeatures.
function lstbS4SelectedFeatures_Callback(hObject, eventdata, handles)
% hObject    handle to lstbS4SelectedFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lstbS4SelectedFeatures contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstbS4SelectedFeatures


% --- Executes during object creation, after setting all properties.
function lstbS4SelectedFeatures_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstbS4SelectedFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editS4Value_Callback(hObject, eventdata, handles)
% hObject    handle to editS4Value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editS4Value as text
%        str2double(get(hObject,'String')) returns contents of editS4Value as a double


% --- Executes during object creation, after setting all properties.
function editS4Value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editS4Value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figMain_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% persistent chk
% 


% --- Executes on selection change in lstbS4InUse.
function lstbS4InUse_Callback(hObject, eventdata, handles)
% hObject    handle to lstbS4InUse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lstbS4InUse contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstbS4InUse
global features

if strcmp(get(gcf, 'SelectionType'), 'normal')
    % Single click
    
    
else
    % Double click
    value = get(hObject, 'Value');
%     features.inUse = features.inUse{~value};
%     features.pFeatures.parameters = features.pFeatures.parameters{~value};
    features.inUse(value) = [];
    features.pFeatures.parameters(value) = [];
    
    listUsedFeatures = [];
    for i = 1:length(features.inUse)
        listUsedFeatures = [listUsedFeatures, features.available(features.inUse{i})];
    end
    
    set(handles.lstbS4InUse, 'String', listUsedFeatures);

    if length(get(handles.lstbS4InUse, 'String')) < value
        set(handles.lstbS4InUse, 'Value', length(get(handles.lstbS4InUse, 'String')));
    end
end

% Any callback
updateUsedFeatures(handles);
updateParameterTable(handles);


function updateParameterTable(handles)
global features
selectedFeature = get(handles.lstbS4InUse, 'Value');
selFeatureName = get(handles.lstbS4InUse, 'String');
if ~isa(selFeatureName, 'cell')
    selFeatureName = {selFeatureName};
end
selFeatureName = selFeatureName{selectedFeature};
selFeatureIndex = find(strcmp(features.available, selFeatureName));

set(handles.tbleS4Parameters, 'Data', [permute(features.parameterNames{selFeatureIndex}, [2 1]), permute(features.pFeatures.parameters{selectedFeature}, [2 1])]);



% --- Executes during object creation, after setting all properties.
function lstbS4InUse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstbS4InUse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in tbleS4Parameters.
function tbleS4Parameters_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tbleS4Parameters (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
global features

if isempty(eventdata.Error)
    
    if isnan(eventdata.NewData)
        data = get(hObject, 'Data');
        data{eventdata.Indices(1), eventdata.Indices(2)} = eventdata.PreviousData;
        set(hObject, 'Data', data);
    else
        value = get(handles.lstbS4InUse, 'Value');
        features.pFeatures.parameters{value}{eventdata.Indices(1)} = eventdata.NewData;
    end
    
end


% --- Executes on button press in bttnOptimizeSelected.
function bttnOptimizeSelected_Callback(hObject, eventdata, handles)
% hObject    handle to bttnOptimizeSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data features

listFeatures = get(handles.lstbS4InUse, 'String');
GUI_optimizeFeature(data, features, get(handles.lstbS4InUse, 'Value'), ...
    listFeatures{get(handles.lstbS4InUse, 'Value')}, {2}, {{.5,3}}, {0.5});


% --- Executes on button press in bttnS5ClearClass2.
function bttnS5ClearClass2_Callback(hObject, eventdata, handles)
% hObject    handle to bttnS5ClearClass2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global data classification visualization

classification.groundTruth.matrixed.class2(:,:,visualization.currentSlice) ...
    = zeros(size(data.image, 1), size(data.image, 2), data.prefType);

updateGroundtruth();

setOverlaysForDisplay(handles);
displayCurrentSlice(visualization.currentSlice, handles);



function edit43_Callback(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit43 as text
%        str2double(get(hObject,'String')) returns contents of edit43 as a double


% --- Executes during object creation, after setting all properties.
function edit43_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit42_Callback(hObject, eventdata, handles)
% hObject    handle to edit42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit42 as text
%        str2double(get(hObject,'String')) returns contents of edit42 as a double


% --- Executes during object creation, after setting all properties.
function edit42_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit41_Callback(hObject, eventdata, handles)
% hObject    handle to edit41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit41 as text
%        str2double(get(hObject,'String')) returns contents of edit41 as a double


% --- Executes during object creation, after setting all properties.
function edit41_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox10.
function listbox10_Callback(hObject, eventdata, handles)
% hObject    handle to listbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox10


% --- Executes during object creation, after setting all properties.
function listbox10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popmS3Source.
function popmS3Source_Callback(hObject, eventdata, handles)
% hObject    handle to popmS3Source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popmS3Source contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popmS3Source
global WS

WS.inUse = get(hObject, 'Value');
WS.pWS.preStep.parameters = WS.defaults{WS.inUse};
set(handles.tbleS3Parameters, 'Data', ...
    [permute(WS.parameterNames{WS.inUse}, [2 1]), ...
     permute(WS.pWS.preStep.parameters, [2 1])]);
 WS.pWS.preStep.method = WS.available{WS.inUse};


% --- Executes during object creation, after setting all properties.
function popmS3Source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popmS3Source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in tbleS3Parameters.
function tbleS3Parameters_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tbleS3Parameters (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
global WS

if isempty(eventdata.Error)
    
    if isnan(eventdata.NewData)
        data = get(hObject, 'Data');
        data{eventdata.Indices(1), eventdata.Indices(2)} = eventdata.PreviousData;
        set(hObject, 'Data', data);
    else
        WS.pWS.preStep.parameters{eventdata.Indices(1)} = eventdata.NewData;
    end
    
end


% --------------------------------------------------------------------
function m_project_loadProject_Callback(hObject, eventdata, handles)
% hObject    handle to m_project_loadProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global data WS features visualization postProcessing fixedModel classification

[file, path] = uigetfile('*.mat', 'Select project file');

if file == 0
    return
end

load([path, file]);

visualization = saveStuff.visualization;
data = saveStuff.data;
features = saveStuff.features;
classification = saveStuff.classification;
WS = saveStuff.WS;
postProcessing = saveStuff.postProcessing;
fixedModel = saveStuff.fixedModel;

setRange(handles);
currentStep = data.currentStep;
for i = 1:currentStep
    data.currentStep = i;
    activateObjects(handles);
end

setObjectValues(handles);


% --------------------------------------------------------------------
function m_project_saveProject_Callback(hObject, eventdata, handles)
% hObject    handle to m_project_saveProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global data WS features visualization postProcessing fixedModel classification

[file, path] = uiputfile('*.mat', 'Select target folder', 'Project.mat');

if file == 0
    return
end

saveStuff.data = data;
saveStuff.WS = WS;
saveStuff.features = features;
saveStuff.classification = classification;
saveStuff.visualization = visualization;
saveStuff.postProcessing = postProcessing;
saveStuff.fixedModel = fixedModel;


save([path, file], 'saveStuff');

% --------------------------------------------------------------------
function m_project_new_Callback(hObject, eventdata, handles)
% hObject    handle to m_project_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function m_project_new_loadCubedDataSet_Callback(hObject, eventdata, handles)
% hObject    handle to m_project_new_loadCubedDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Load data
global data;

data.folder = uigetdir(data.defaultFolder, 'Select dataset folder');

if data.folder == 0
    return
end

pos = strfind(data.folder, filesep);
data.name = data.folder(pos(end)+1 : end);
set(handles.textDataSet, 'String', data.name);

data.currentStep = 1;


% Load the first image of the data set
data.image = openCube(data, handles);
if isempty(data.image);
    data.currentStep = 0;
    return;
end

% Show the first image
setCurrent(handles);

setRange(handles);
activateObjects(handles);


% --- Executes on selection change in popmS2SelectOverlay.
function popmS2SelectOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to popmS2SelectOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popmS2SelectOverlay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popmS2SelectOverlay
global visualization

setOverlaysForDisplay(handles);
displayCurrentSlice(visualization.currentSlice, handles);


% --- Executes during object creation, after setting all properties.
function popmS2SelectOverlay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popmS2SelectOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popmS4AvailableFeatures.
function popmS4AvailableFeatures_Callback(hObject, eventdata, handles)
% hObject    handle to popmS4AvailableFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popmS4AvailableFeatures contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popmS4AvailableFeatures
global features

value = get(hObject,'Value');
features.inUse = [features.inUse, value];
features.pFeatures.parameters = [features.pFeatures.parameters, features.defaults(value)];
listUsedFeatures = [];
for i = 1:length(features.inUse)
    listUsedFeatures = [listUsedFeatures, features.available(features.inUse{i})];
end
set(handles.lstbS4InUse, 'String', listUsedFeatures);
if isempty(get(handles.lstbS4InUse, 'Value')) || get(handles.lstbS4InUse, 'Value') == 0
    set(handles.lstbS4InUse, 'Value', 1);
end

updateUsedFeatures(handles);


% --- Executes during object creation, after setting all properties.
function popmS4AvailableFeatures_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popmS4AvailableFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popmS2SelectDisplayedImage.
function popmS2SelectDisplayedImage_Callback(hObject, eventdata, handles)
% hObject    handle to popmS2SelectDisplayedImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popmS2SelectDisplayedImage contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popmS2SelectDisplayedImage
global visualization

% Set parameter table and sub-feature list
value = get(hObject, 'Value');
if ~isempty(visualization.defaults{value})
    d = [permute(visualization.parameterNames{value}, [2 1]), ...
         permute(visualization.pImage.parameters{value}, [2 1])];
    set(handles.tbleS2DisplayedImageParameters, 'Data', d);
else
    set(handles.tbleS2DisplayedImageParameters, 'Data', []);
end
% set(handles.popmS2SelectDisplayedImageSub, 'String', visualization.subAvailable{value});
setObjectValues(handles);
setCurrent(handles);


% --- Executes during object creation, after setting all properties.
function popmS2SelectDisplayedImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popmS2SelectDisplayedImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popmS2SelectDisplayedImageSub.
function popmS2SelectDisplayedImageSub_Callback(hObject, eventdata, handles)
% hObject    handle to popmS2SelectDisplayedImageSub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popmS2SelectDisplayedImageSub contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popmS2SelectDisplayedImageSub
global visualization
subFeatureList = get(handles.popmS2SelectDisplayedImageSub, 'String');
if ~strcmp(subFeatureList{1}, '');
    ID = get(handles.popmS2SelectDisplayedImage, 'Value');
    featureName = visualization.available{ID};
    subFeatureName = visualization.subAvailable{ID}{get(handles.popmS2SelectDisplayedImageSub, 'Value')};
    setCurrent(handles, visualization.(featureName).(subFeatureName));
end


% --- Executes during object creation, after setting all properties.
function popmS2SelectDisplayedImageSub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popmS2SelectDisplayedImageSub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in tbleS2DisplayedImageParameters.
function tbleS2DisplayedImageParameters_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tbleS2DisplayedImageParameters (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
global visualization

selectedFeature = get(handles.popmS2SelectDisplayedImage, 'Value');
featureName = get(handles.popmS2SelectDisplayedImage, 'String');
featureName = featureName{selectedFeature};
d = get(hObject, 'Data');
for i = 1:size(d, 1)
    visualization.pImage.parameters{selectedFeature}{i} = d{i, 2};
end

if isfield(visualization, featureName)
    visualization = rmfield(visualization, featureName);
end
setCurrent(handles);


% --- Executes on selection change in popmS5Classification.
function popmS5Classification_Callback(hObject, eventdata, handles)
% hObject    handle to popmS5Classification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popmS5Classification contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popmS5Classification


% --- Executes during object creation, after setting all properties.
function popmS5Classification_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popmS5Classification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bttnS5SwitchAnnotatedSlice.
function bttnS5SwitchAnnotatedSlice_Callback(hObject, eventdata, handles)
% hObject    handle to bttnS5SwitchAnnotatedSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data visualization classification

i = visualization.currentSlice +1;
securityExit = 1;
while (max(max(classification.groundTruth.matrixed.class1(:,:,i))) == 0 ...
        && max(max(classification.groundTruth.matrixed.class2(:,:,i))) == 0) ...
        && securityExit <= size(data.image, 3)
    i = i + 1;
    if i > size(data.image, 3)
        i = 1;
    end
    securityExit = securityExit + 1;
end

visualization.currentSlice = i;
displayCurrentSlice(i, handles);


% --- Executes on button press in bttnS5FillClass1.
function bttnS5FillClass1_Callback(hObject, eventdata, handles)
% hObject    handle to bttnS5FillClass1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WS classification visualization

thisSlice = classification.groundTruth.matrixed.class2(:,:,visualization.currentSlice);
thisWS = WS.result.matrixed{1}(:,:,visualization.currentSlice);
classification.groundTruth.matrixed.class1(:,:,visualization.currentSlice) = (thisSlice == 0 & thisWS > 0);

updateGroundtruth();

setOverlaysForDisplay(handles);
displayCurrentSlice(visualization.currentSlice, handles);

% --- Executes on button press in bttnS5FillClass2.
function bttnS5FillClass2_Callback(hObject, eventdata, handles)
% hObject    handle to bttnS5FillClass2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WS visualization classification

thisSlice = classification.groundTruth.matrixed.class1(:,:,visualization.currentSlice);
thisWS = WS.result.matrixed{1}(:,:,visualization.currentSlice);
classification.groundTruth.matrixed.class2(:,:,visualization.currentSlice) ...
    = (thisSlice == 0 & thisWS > 0);

updateGroundtruth();

setOverlaysForDisplay(handles);
displayCurrentSlice(visualization.currentSlice, handles);


% --- Executes on button press in bttnStep6.
function bttnStep6_Callback(hObject, eventdata, handles)
% hObject    handle to bttnStep6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global features postProcessing data WS classification
 
[h, disabledObj] = computationStart(handles.figMain);

try
    
%     pPP.method = postProcessing.available{postProcessing.inUse};
%     pPP.parameters = postProcessing.parameters;
%     pPP.WS = WS;
%     pPP.data = data;
%     pPP.features = features;
%     pPP.classification = classification;
%     pPP.scriptPath = [data.folders.main postProcessing.folder];
    
    [postProcessing.result.matrixed, postProcessing.result.names] = GUI_postProcessingFromScript( ...
        data.image, postProcessing.pPP, ...
        WS, data, features, classification, ...
        'waitbar', h, 0, 1, ...
        'anisotropic', data.anisotropic);
    
catch EX

    unexpectedException(EX);
    computationEnd(h, disabledObj);
    return;
    
end

computationEnd(h, disabledObj);

data.currentStep = 6;
setOverlaysForDisplay(handles);
setLstbS2SelectOverlay(handles)
activateObjects(handles);

 
 


% --- Executes on button press in bttnStep7.
function bttnStep7_Callback(hObject, eventdata, handles)
% hObject    handle to bttnStep7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data features fixedModel postProcessing WS classification visualization

fixedModel.WS.result = WS.result;
fixedModel.features.result = features.result;
fixedModel.classification.result = classification.result;
fixedModel.postProcessing.result = postProcessing.result;
fixedModel.visualization.currentSlice = visualization.currentSlice;
fixedModel.visualization.output = visualization.output;
fixedModel.visualization.pImage = visualization.pImage;
fixedModel.visualization.pOverlay = visualization.pOverlay;
fixedModel.data.disp = data.disp;
fixedModel.data.image = data.image;


WS = rmfield(WS, 'result');
features = rmfield(features, 'result');
classification = rmfield(classification, 'result');
postProcessing = rmfield(postProcessing, 'result');

data.currentStep = 7;

setOverlaysForDisplay(handles);
setLstbS2SelectOverlay(handles)
activateObjects(handles);


% --- Executes on button press in bttnS7Unlock.
function bttnS7Unlock_Callback(hObject, eventdata, handles)
% hObject    handle to bttnS7Unlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data fixedModel WS features classification postProcessing visualization

WS.result = fixedModel.WS.result;
features.result = fixedModel.features.result;
classification.result = fixedModel.classification.result;
postProcessing.result = fixedModel.postProcessing.result;
visualization.currentSlice = fixedModel.visualization.currentSlice;
visualization.output = fixedModel.visualization.output;
visualization.pImage = fixedModel.visualization.pImage;
visualization.pOverlay = fixedModel.visualization.pOverlay;
data.disp = fixedModel.data.disp;
data.image = fixedModel.data.image;


set(handles.sldrX, 'Value', data.disp.X);
set(handles.editX, 'String', num2str(data.disp.X));
set(handles.sldrY, 'Value', data.disp.Y);
set(handles.editY, 'String', num2str(data.disp.Y));
set(handles.sldrZ, 'Value', data.disp.Z);
set(handles.editZ, 'String', num2str(data.disp.Z));

setCurrent(handles);

clear -global fixedModel

data.currentStep = 6;
setOverlaysForDisplay(handles);
setLstbS2SelectOverlay(handles)
activateObjects(handles);


% --- Executes on button press in bttnS7CalculateForCurrentCube.
function bttnS7CalculateForCurrentCube_Callback(hObject, eventdata, handles)
% hObject    handle to bttnS7CalculateForCurrentCube (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data WS features postProcessing classification

[h, disabledObj] = computationStart(handles.figMain);

try

%     pWS.preStep.type = WS.available{WS.inUse};
%     pWS.preStep.parameters = WS.parameters;
%     pWS.parameters.conn = WS.WS_conn;
%     pWS.parameters.maxDepth = WS.WS_maxDepth;
%     pWS.parameters.maxSize = WS.WS_maxSize;
%     thispath = mfilename('fullpath');
%     posLastSlash = find(thispath == filesep, 1, 'last');
%     pWS.scriptPath = [thispath(1:posLastSlash), 'Scripts' filesep 'watershed' filesep];
%     pWS.preStep.bInvert = WS.bInvert;
%     pWS.preStep.bInvertRaw = WS.bInvertRaw;
% 
%     pFeatures.names = cellfun(@(x) features.available(x), features.inUse);
%     pFeatures.parameters = features.pFeatures.parameters;
%     pFeatures.scriptPath = [thispath(1:posLastSlash), 'Scripts' filesep 'features' filesep];
%     pFeatures.parameterNames = cellfun(@(x) features.parameterNames(x), features.inUse);
% 
%     pClassification.type = fixedModel.classificationType;
%     pClassification.model = fixedModel.model;
% 
%     pVesicleClouds.excludeSolitary.enable = postProcessing.parameters{1};
%     pVesicleClouds.dimensions = WS.dimensions;
%     pVesicleClouds.excludeSolitary.conn = postProcessing.parameters{2};
%     pVesicleClouds.excludeSolitary.nhRadius = postProcessing.parameters{3}; % 12
%     pVesicleClouds.excludeSolitary.thresh = postProcessing.parameters{4}; % 7
%     pVesicleClouds.postProcessing.conn = postProcessing.parameters{5};
%     pVesicleClouds.postProcessing.dimensions = postProcessing.parameters{6};
%     pVesicleClouds.postProcessing.sizeExclusion = postProcessing.parameters{7};
%     pVesicleClouds.postProcessing.smoothing = postProcessing.parameters{8};


    [result, cWS, cFeatures, cClassification, cPostProcessing] = jh_synapseSeg3D( ...
        data, WS.pWS, features.pFeatures, classification.pClassification, postProcessing.pPP, ...
        'output', {'WS', 'features', 'classification', 'postProcessing'}, ...
        'prefType', 'single', ...
        'anisotropic', data.anisotropic);

    WS.result = cWS;
    features.result = cFeatures;
    classification.result = cClassification;
    postProcessing.result = cPostProcessing;
    
%     fixedModel.classification = cClassification{1};
%     fixedModel.classScores = cClassification{2};
%     fixedModel.vesicles = cVesicleClouds{1};
%     fixedModel.postProcessing = cVesicleClouds{2};
%     fixedModel.vesicleCloudsScore = cVesicleClouds{3};
%     fixedModel.vesicleCloudsNHScore = cVesicleClouds{4};

%     fixedModel.overlayVesicleClouds = ...
%         jh_overlayLabels( ...
%             jh_normalizeMatrix(data.image), jh_normalizeMatrix(fixedModel.postProcessing), ...
%             'type', 'colorize', 'gray', 'range', [0 .33], 'randomColors');

catch EX
    
    unexpectedException(EX)
    computationEnd(h, disabledObj);
    return;

end

computationEnd(h, disabledObj);

setLstbS2SelectOverlay(handles);


function unexpectedException(EX)

fprintf(2, '\n    ERROR: unexpected exception.\n\n');
ID = EX.identifier;
ID = strrep(ID, '\', '\\');
fprintf(2, ['        ' ID '\n']);
message = EX.message;
message = strrep(message, '\', '\\');
fprintf(2, ['        ' message '\n\n']);
for i = 1:length(EX.stack)
    file = EX.stack(i).file;
    file = strrep(file, '\', '\\');
    fprintf(2, ['        ' file '\n']);
    fprintf(2, ['        ' EX.stack(i).name]);
    fprintf(2, [' (line: ' num2str(EX.stack(i).line) ')\n\n']);
end

fprintf('    The program is still working, the previous step should possibly be recalculated.\n\n');



% --- Executes when figMain is resized.
function figMain_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

thisPosition = get(hObject, 'Position');
mainPanelPosition = get(handles.panelMain, 'Position');

if thisPosition(3) < mainPanelPosition(3)
   
else
    
end


% --- Executes on button press in chbxS2Invert.
function chbxS2Invert_Callback(hObject, eventdata, handles)
% hObject    handle to chbxS2Invert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chbxS2Invert
global visualization

visualization.pImage.bInvert = get(hObject, 'Value');

ID = get(handles.popmS2SelectDisplayedImage, 'Value');
feature = visualization.available{ID};
subID = get(handles.popmS2SelectDisplayedImageSub, 'Value');
subFeature = visualization.subAvailable{ID}{subID};
if strcmp(subFeature, '')
    setCurrent(handles, visualization.(feature));
else
    setCurrent(handles, visualization.(feature).(subFeature));
end



% --- Executes on button press in chbxS2InvertRaw.
function chbxS2InvertRaw_Callback(hObject, eventdata, handles)
% hObject    handle to chbxS2InvertRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chbxS2InvertRaw
global visualization

visualization.pImage.bInvertRaw = get(hObject, 'Value');

setCurrent(handles)


% --- Executes on scroll wheel click while the figure is in focus.
function figMain_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figMain (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in chbxS3Invert.
function chbxS3Invert_Callback(hObject, eventdata, handles)
% hObject    handle to chbxS3Invert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chbxS3Invert
global WS
WS.pWS.preStep.bInvert = get(hObject, 'Value');


% --- Executes on button press in chbxS3InvertRaw.
function chbxS3InvertRaw_Callback(hObject, eventdata, handles)
% hObject    handle to chbxS3InvertRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chbxS3InvertRaw
global WS
WS.pWS.preStep.bInvertRaw = get(hObject, 'Value');


% --- Executes during object creation, after setting all properties.
function figMain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function sldrHorizontal_Callback(hObject, eventdata, handles)
% hObject    handle to sldrHorizontal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sldrHorizontal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldrHorizontal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sldrVertical_Callback(hObject, eventdata, handles)
% hObject    handle to sldrVertical (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sldrVertical_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldrVertical (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function m_Project_Callback(hObject, eventdata, handles)
% hObject    handle to m_Project (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function m_about_Callback(hObject, eventdata, handles)
% hObject    handle to m_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function m_about_aboutModelClassify3D_Callback(hObject, eventdata, handles)
% hObject    handle to m_about_aboutModelClassify3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

About({handles.version});


% --- Executes on mouse press over axes background.
function axesCurrentSlice_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesCurrentSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in chbxS2AdditionalOverlay.
function chbxS2AdditionalOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to chbxS2AdditionalOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chbxS2AdditionalOverlay
global visualization data
visualization.pOverlay.bAdditional = get(hObject, 'Value');
if visualization.pOverlay.bAdditional
    set(handles.popmS2SelectOverlay, 'Enable', 'on');
else
    set(handles.popmS2SelectOverlay, 'Enable', 'off');
end

setOverlaysForDisplay(handles);
displayCurrentSlice(visualization.currentSlice, handles);



function editAnisotropyX_Callback(hObject, eventdata, handles)
% hObject    handle to editAnisotropyX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAnisotropyX as text
%        str2double(get(hObject,'String')) returns contents of editAnisotropyX as a double
global data;
data.anisotropic(2) = str2double(get(hObject, 'String'));


% --- Executes during object creation, after setting all properties.
function editAnisotropyX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAnisotropyX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAnisotropyY_Callback(hObject, eventdata, handles)
% hObject    handle to editAnisotropyY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAnisotropyY as text
%        str2double(get(hObject,'String')) returns contents of editAnisotropyY as a double
global data;
data.anisotropic(1) = str2double(get(hObject, 'String'));


% --- Executes during object creation, after setting all properties.
function editAnisotropyY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAnisotropyY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAnisotropyZ_Callback(hObject, eventdata, handles)
% hObject    handle to editAnisotropyZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAnisotropyZ as text
%        str2double(get(hObject,'String')) returns contents of editAnisotropyZ as a double
global data;
data.anisotropic(3) = str2double(get(hObject, 'String'));


% --- Executes during object creation, after setting all properties.
function editAnisotropyZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAnisotropyZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rbtn2D.
function rbtn2D_Callback(hObject, eventdata, handles)
% hObject    handle to rbtn2D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbtn2D


% --- Executes on button press in rbtn3D.
function rbtn3D_Callback(hObject, eventdata, handles)
% hObject    handle to rbtn3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbtn3D


% --- Executes when selected object is changed in panelS3Dimensions.
function panelS3Dimensions_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panelS3Dimensions 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global WS

if get(handles.rbtn2D, 'Value')
    
    WS.pWS.parameters.dimensions = 2;
    
elseif get(handles.rbtn3D, 'Value')
    
    WS.pWS.parameters.dimensions = 3;
end


% --- Executes on selection change in popmS6Method.
function popmS6Method_Callback(hObject, eventdata, handles)
% hObject    handle to popmS6Method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popmS6Method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popmS6Method
global postProcessing

postProcessing.inUse = get(hObject, 'Value');
postProcessing.pPP.parameters = postProcessing.defaults{postProcessing.inUse};
postProcessing.pPP.parameterNames = postProcessing.parameterNames{postProcessing.inUse};
postProcessing.pPP.method = postProcessing.available{postProcessing.inUse};
set(handles.tbleS6Parameters, 'Data', ...
    [permute(postProcessing.pPP.parameterNames, [2 1]), ...
     permute(postProcessing.pPP.parameters, [2 1])]);


% --- Executes during object creation, after setting all properties.
function popmS6Method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popmS6Method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in tbleS6Parameters.
function tbleS6Parameters_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tbleS6Parameters (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
global postProcessing

if isempty(eventdata.Error)
    
    if isnan(eventdata.NewData)
        data = get(hObject, 'Data');
        data{eventdata.Indices(1), eventdata.Indices(2)} = eventdata.PreviousData;
        set(hObject, 'Data', data);
    else
        postProcessing.pPP.parameters{eventdata.Indices(1)} = eventdata.NewData;
    end
    
end
