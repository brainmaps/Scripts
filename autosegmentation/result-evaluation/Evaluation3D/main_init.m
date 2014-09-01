global data

%{

data structure
    .image
    .cubeRange
    .defaultFolder
    .folder
    .prefType
    .fileIO
        .saveProjectFile
    .userInteraction
        .ctrlDown
        .mouseDownPosition
        .mouseDownImagePosition
        .selectedObject
            .group
            .ID
    .resultToEvaluate
        .result
        .name
        .path
    .window
        .backColor
    .visualization
        .atLastDisplayEvent
            .position
            .displaySize
            .spacerSize
        .anisotropic
        .currentPosition
        .displaySize
        .spacerSize
        .magnificationSize
        .clickedImage
        .mouseDownImage
        .mouseDownTicHandle
        .lastMousePosition
        .mousePositionOnMouseDown
        .bSectionalPlanes
        .annotatedVisible []
    .evaluation
        .labelList
        .count
        .currentLabel
        .currentLabelID
        .currentObject
            .matrix
            .position
            .voxelList
        .currentAssociated ()
            .matrix
            .position
            .voxelList
        .result []
            .statistics
                .size
                .meanIntensity
                .stdDeviation
            .overSegmentation
                .withObjects []
                .count
            .underSegmentation
                .count
            .classification
                .name
                .ID
            .properties
                .names {}
                .IDs []
            .label
            .matrix
            .position
            .centerPosition
            .voxelList
            .comment
        .overallResult
            .objects
                .total
                .evaluated
            .oversegmentation
            .undersegmentation
            .classification
                .names
                .count
            .properties
                .names
                .count
        .availableClasses {}
        .availableProperties {}
        .activeGroup ('resultToEvaluate' or 'manualAnnotation')
        .annotationCount
        .annotation []
            .matrix
            .position
            .centerPosition
            .classification
                .name
                .ID
            .properties
                .names {}
                .IDs []
            .statistics
                .size
                .meanIntensity
                .stdDeviation
            .voxelList
            .comment
        .overallAnnotation
            .objects
                .total
                .evaluated
            .classification
                .names
                .count
            .properties
                .names
                .count

%}

if strcmp(filesep, '\')
    data.defaultFolder = 'D:\Julian\';
else
    data.defaultFolder = '/~/';
end

data.prefType = 'single';
data.cubeRange = {[3 6], [3 6], [0 3]};
data.image = [];

data.fileIO.saveProjectFile = [];
data.userInteraction.ctrlDown = false;

data.visualization.currentPosition = [1, 1, 1];
data.visualization.atLastDisplayEvent = [];

data.visualization.displaySize = 256;
data.visualization.magnificationSize = 256;
data.visualization.clickedImage = [];
data.visualization.mouseDownImage = [];
data.visualization.bSectionalPlanes = true;
data.visualization.bOverlayObjects = true;
data.visualization.anisotropic = [1 1 3];
data.visualization.annotatedVisible = [];
data.resultToEvaluate = [];

data.window.backColor = get(0,'DefaultUicontrolBackgroundColor');

data.evaluation.currentLabel = [];
data.evaluation.currentLabelID = [];
data.evaluation.result = [];

data.visualization.spacerSize = 5;

data.evaluation.availableClasses = { ...
    'Vesicle cloud', ...
    'Cytoplasm', ...
    'Mitochondrion', ...
    'Membrane', ...
    'Other'};

data.evaluation.availableProperties = { ...
    {'Accurate', 'Inaccurate: less', 'Inaccurate: more', 'Inaccurate: shifted'}};

data.evaluation.activeGroup = 'resultToEvaluate';
