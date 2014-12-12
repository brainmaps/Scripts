global main

%{

main structure
    .settings
        .prefType
        .window
            .backColor
    .visualization
        .currentPosition
        .displaySize
        .bSectionalPlanes
        .bOverlayObjects
        .spacerSize
        .anisotropicInterpolationType
    .data
        .cubeRange
        .image
        .anisotropic
        .bufferType: 'whole' | 'cubed'
    .overlays()
        .cubeRange
        .image
        .anisotropic
    .fileIO
        .defaultFolder
        .saveProjectFile
        .load
            .folder
    .userInput
        .keyDown
            .ctrl
            .shift
            .alt
        .mouseDown
            .on
            .at
        .mousePosition

%}

% _________________________________________________________________________
% main.settings
main.settings.prefType = 'single';
main.settings.window.backColor = get(0,'DefaultUicontrolBackgroundColor');

% _________________________________________________________________________
% main.visualization
main.visualization.currentPosition = [1, 1, 1];
main.visualization.displaySize = 256;
main.visualization.bSectionalPlanes = true;
main.visualization.bOverlayObjects = true;
main.visualization.spacerSize = 5;
main.visualization.anisotropicInterpolationType = 'bicubic';
main.visualization.bufferType = 'cubed';
main.visualization.bufferDelete = 100;

% _________________________________________________________________________
% main.data
main.data.cubeRange = {[3 6], [3 6], [0 3]};
main.data.image = [];
main.data.anisotropic = [1 1 3];
main.data.cubeSize = 128;

% _________________________________________________________________________
% main.overlays
main.overlays = [];

% _________________________________________________________________________
% main.fileIO
if strcmp(filesep, '\')
    main.fileIO.defaultFolder = 'D:\Julian\';
else
    main.fileIO.defaultFolder = '~/';
end
main.fileIO.saveProjectFile = [];
main.fileIO.load.folder = [];

% _________________________________________________________________________
% main.userInput
main.userInput.keyDown.ctrl = false;
main.userInput.keyDown.shift = false;
main.userInput.keyDown.alt = false;
main.userInput.mouseDown.on = [];
main.userInput.mouseDown.at = [];
main.userInput.mousePosition = [];

% 
% 
% main.visualization.atLastDisplayEvent = [];
% 
% main.visualization.clickedImage = [];
% main.visualization.mouseDownImage = [];
% 
% 



