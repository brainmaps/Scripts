% This GUI is part of ModelClassify3D
% version 1.0, 11.2014
%
% written by Julian Hennies
% Max Planck Institute for Medical Research, Heidelberg

function MC3D_Viewer

% -------------------------------------------------------------------------
% Check for already opened GUI

if ~isempty(findobj('type', 'figure', 'name', 'ModelClassify3D - Viewer'))
    EX.identifier = 'ModelClassify3D: Figure Conflict';
    EX.message = 'This GUI is presumably already running.';
    EX.stack = [];
    EX.solution = 'The script was stopped and the requested figure was not opened.';
    main_throwException(EX, 'ERROR: Cannot open figure');
    return
end

% -------------------------------------------------------------------------
% Initializations

% Initialization files
global main
% Add all folders within the main path
thisPath = mfilename('fullpath');
posSlash = find(thisPath == filesep, 1, 'last');
posSlash = posSlash(1);
thisPath = thisPath(1:posSlash);
addpath(genpath(thisPath));

main_init

% -------------------------------------------------------------------------

% Read resolution
scrsz = get(0,'ScreenSize');

% Define window position and size
winSize = [600 600];
winPosition = [scrsz(3)/2 - winSize(1)/2, scrsz(4)/2 - winSize(2)/2, winSize(1), winSize(2)];
% handles.oldWindowPosition = winPosition;

% Create window
handles.MainWindow = figure( ...
    'MenuBar', 'none', ...
    'Name', 'ModelClassify3D - Viewer', ...
    'NumberTitle', 'off', ...
    'ToolBar', 'none', ...
    'Position', winPosition, ...
    'Units', 'pixels', ...
    'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
    'ResizeFcn', @MainWindow_resizeFcn, ...
    'KeyPressFcn', @MainWindow_keyPressFcn, ...
    'KeyReleaseFcn', @MainWindow_keyReleaseFcn, ...
    'WindowButtonMotionFcn', @MainWindow_windowButtonMotionFcn, ...
    'WindowButtonUpFcn', @MainWindow_windowButtonUpFcn, ...
    'WindowScrollWheelFcn', @MainWindow_windowScrollWheelFcn, ...
    'CloseRequestFcn', @MainWindow_closeRequestFcn);

%%  Add Controls

% -------------------------------------------------------------------------
% Panels

% Main panel which contains everything
handles.panelMain = uipanel(handles.MainWindow, ...
    'Tag', 'panelMain', ...
    'Title', '', ...
    'BorderType', 'none', ...
    'Units', 'normalized', ...
    'Position', [0, 0, 1, 1]);

% Panels which contains all axes (has to be quadratic)
handles.panelDisplays = uipanel(handles.panelMain, ...
    'Tag', 'panelDisplays', ...
    'Title', 'Visualization', ...
    'BorderType', 'etchedin', ...
	'Units', 'pixels');

% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% For display

handles.axesDisplay = axes('Parent', handles.panelDisplays, ...
    'Tag', 'axesDisplay', ...
    'Units', 'normalized', ...
    'Position', [.01, .01, .98, .98]);

handles.textEvaluation = uicontrol(handles.panelDisplays, ...
    'Tag', 'textAvailableClasses', ...
    'Units', 'normalized', ...
    'FontUnits', 'points', ...
    'FontSize', 8, ...
    'FontName', 'Courier New', ...
    'HorizontalAlignment', 'left', ...
    'Position', [0.51 0.01 .48 .48], ...
    'Style', 'edit', ...
    'String', '', ...
    'SliderStep', [.01 .1], ...
    'Max', 2);
% jScrollPaneTextEvaluation = findjobj(handles.textEvaluation);
% set(jScrollPaneTextEvaluation.VERTICAL_SCROLLBAR_AS_NEEDED);

% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% The Menu

% File...
handles.m_file = uimenu(handles.MainWindow, ...
    'Label', 'File');
handles.m_file_loadImage = uimenu(handles.m_file, ...
    'Label', 'Load image');
handles.m_file_loadImage_fromCubedData = uimenu(handles.m_file_loadImage, ...
    'Label', 'From cubed data', ...
    'Callback', @m_file_loadImage_fromCubedData_callback, ...
    'Accelerator', 'i');
handles.m_file_saveProject = uimenu(handles.m_file, ...
    'Label', 'Save project', ...
    'Callback', @m_file_saveProject_callback, ...
    'Separator', 'on', ...
    'Accelerator', 's');
handles.m_file_saveProjectAs = uimenu(handles.m_file, ...
    'Label', 'Save project as', ...
    'Callback', @m_file_saveProjectAs_callback);
handles.m_file_loadProject = uimenu(handles.m_file, ...
    'Label', 'Load project', ...
    'Callback', @m_file_loadProject_callback, ...
    'Accelerator', 'l');


% Settings...
handles.m_settings = uimenu(handles.MainWindow, ...
    'Label', 'Settings');
% > Settings
    handles.m_settings_displaySize = uimenu(handles.m_settings, ...
        'Label', 'Display size');
    % > Display size
        handles.m_settings_displaySize_512 = uimenu(handles.m_settings_displaySize, ...
            'Label', '512 pixels', ...
            'Callback', @m_settings_displaySize_512_callback);
        handles.m_settings_displaySize_256 = uimenu(handles.m_settings_displaySize, ...
            'Label', '256 pixels', ...
            'Callback', @m_settings_displaySize_256_callback);
        handles.m_settings_displaySize_128 = uimenu(handles.m_settings_displaySize, ...
            'Label', '128 pixels', ...
            'Callback', @m_settings_displaySize_128_callback);
        handles.m_settings_displaySize_64 = uimenu(handles.m_settings_displaySize, ...
            'Label', '64 pixels', ...
            'Callback', @m_settings_displaySize_64_callback);
        % -
        handles.m_settings_displaySize_other = uimenu(handles.m_settings_displaySize, ...
            'Label', 'Other', ...
            'Callback', @m_settings_displaySize_other, ...
            'Separator', 'on');
    % <
    handles.m_settings_anisotropicInterpolationType = uimenu(handles.m_settings, ...
        'Label', 'Anisotropic interpolation type');
    % > Anisotropic interpolation type
        handles.m_settings_anisotropicInterpolationType_nearest = uimenu(handles.m_settings_anisotropicInterpolationType, ...
            'Label', 'Nearest', ...
            'Callback', @m_settings_anisotropicInterpolationType_nearest_callback);
        handles.m_settings_anisotropicInterpolationType_bilinear = uimenu(handles.m_settings_anisotropicInterpolationType, ...
            'Label', 'Bilinear', ...
            'Callback', @m_settings_anisotropicInterpolationType_bilinear_callback);
        handles.m_settings_anisotropicInterpolationType_bicubic = uimenu(handles.m_settings_anisotropicInterpolationType, ...
            'Label', 'Bicubic', ...
            'Callback', @m_settings_anisotropicInterpolationType_bicubic_callback);
        handles.m_settings_anisotropicInterpolationType_box = uimenu(handles.m_settings_anisotropicInterpolationType, ...
            'Label', 'Box', ...
            'Callback', @m_settings_anisotropicInterpolationType_box_callback);
        handles.m_settings_anisotropicInterpolationType_lanczos2 = uimenu(handles.m_settings_anisotropicInterpolationType, ...
            'Label', 'Lanczos-2', ...
            'Callback', @m_settings_anisotropicInterpolationType_lanczos2_callback);
        handles.m_settings_anisotropicInterpolationType_lanczos3 = uimenu(handles.m_settings_anisotropicInterpolationType, ...
            'Label', 'Lanczos-3', ...
            'Callback', @m_settings_anisotropicInterpolationType_lanczos3_callback);
    % <
    handles.m_settings_bufferType = uimenu(handles.m_settings, ...
        'Label', 'Buffer type');
    % > Buffer Type
        handles.m_settings_bufferType_wholeImage = uimenu(handles.m_settings_bufferType, ...
            'Label', 'Whole image', ...
            'Callback', @m_settings_bufferType_wholeImage_callback);
        handles.m_settings_bufferType_cubed = uimenu(handles.m_settings_bufferType, ...
            'Label', 'Cubed', ...
            'Callback', @m_settings_bufferType_cubed_callback);
    % -
    handles.m_settings_sectionalPlanes = uimenu(handles.m_settings, ...
        'Label', 'Sectional planes', ...
        'Callback', @m_settings_sectionalPlanes_callback, ...
        'Separator', 'on', ...
        'Accelerator', 'q');
    handles.m_settings_overlayObjects = uimenu(handles.m_settings, ...
        'Label', 'Overlay objects', ...
        'Callback', @m_settings_overlayObjects_callback, ...
        'Accelerator', 'w');
    % -
    handles.m_settings_advanced = uimenu(handles.m_settings, ...
        'Label', 'Advanced', ...
        'Separator', 'on', ...
        'Enable', 'off');
    
% Tools...
handles.m_tools = uimenu(handles.MainWindow, ...
    'Label', 'Tools');

% Overlays...
handles.m_overlays = uimenu(handles.MainWindow, ...
    'Label', 'Overlays');
% > Overlays
    handles.m_overlays_loadOverlay = uimenu(handles.m_overlays, ...
        'Label', 'Load overlay', ...
        'Callback', @m_overlays_loadOverlay_callback);
    % > Load overlay
        handles.m_overlays_loadOverlay_cubedData = uimenu(handles.m_overlays_loadOverlay, ...
            'Label', 'Cubed data', ...
            'Callback', @m_overlays_loadOverlay_cubedData_callback, ...
            'Enable', 'off');
        handles.m_overlays_loadOverlay_imageStack = uimenu(handles.m_overlays_loadOverlay, ...
            'Label', 'Image stack', ...
            'Callback', @m_overlays_loadOverlay_imageStack_callback, ...
            'Enable', 'off');
        handles.m_overalys_loadOverlay_mFile = uimenu(handles.m_overlays_loadOverlay, ...
            'Label', 'M-file', ...
            'Callback', @m_overlays_loadOverlay_mFile_callback);
    % <
    handles.m_overlays_addBlank = uimenu(handles.m_overlays, ...
        'Label', 'Add blank', ...
        'Callback', @m_overlays_addBlank_callback, ...
        'Enable', 'off');

% -------------------------------------------------------------------------
% Context menu(s)

handles.cm_images = uicontextmenu( ...
    'Callback', @cm_images_callback);

% -------------------------------------------------------------------------
% Set defaults

main_checkAll();

main_activateObjects();

% -------------------------------------------------------------------------

% Save the structure
guidata(handles.MainWindow, handles);

%% Callbacks

% -------------------------------------------------------------------------
% The menu

    function m_file_loadImage_fromCubedData_callback(hObject, ~)
        handles = guidata(hObject);
        
        % Get the directory
        folder = uigetdir(main.fileIO.defaultFolder, 'Select dataset folder');
        if folder == 0
            return;
        else
            main.fileIO.load.folder = folder;
        end
        
        % Dialog box to specify the range which will be loaded
        range = inputdlg( ...
            {   'From (x, y, z)', 'To (x, y, z)', ...
                'Anisotropy factors (x, y, z)' ...
            }, ...
            'Specify range...', ...
            1, ...
            {   [num2str(main.data.cubeRange{1}(1)) ', ' num2str(main.data.cubeRange{2}(1)) ', ' num2str(main.data.cubeRange{3}(1))], ...
                [num2str(main.data.cubeRange{1}(2)) ', ' num2str(main.data.cubeRange{2}(2)) ', ' num2str(main.data.cubeRange{3}(2))], ...
                [num2str(main.data.anisotropic(1)), ', ' num2str(main.data.anisotropic(2)), ', ', num2str(main.data.anisotropic(3))] ...
            });
        rangeFrom = strsplit(range{1}, {', ', ','});
        rangeTo = strsplit(range{2}, {', ', ','});
        rangeX = [str2double(rangeFrom{1}) str2double(rangeTo{1})];
        rangeY = [str2double(rangeFrom{2}) str2double(rangeTo{2})];
        rangeZ = [str2double(rangeFrom{3}) str2double(rangeTo{3})];
        anisotropic = strsplit(range{3}, {', ', ','});
        
        main.data.anisotropic = cellfun(@(x) str2double(x), anisotropic);
        main.data.cubeRange = {rangeX, rangeY, rangeZ};
        
        if strcmp(main.visualization.bufferType, 'whole')
            main.data.image = main_loadImage(rangeX, rangeY, rangeZ);
        else
            main.data.image = cell(rangeX(2)+1, rangeY(2)+1, rangeZ(2)+1);
        end
        
        main_createImage(hObject);
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
        main_activateObjects();

    end
    function m_file_saveProject_callback(hObject, ~)
        handles = guidata(hObject);
           
    end
    function m_file_saveProjectAs_callback(hObject, ~)
        handles = guidata(hObject);
                   
    end
    function m_file_loadProject_callback(hObject, ~)
        handles = guidata(hObject);
        
    end

    function m_settings_displaySize_512_callback(hObject, ~)
        handles = guidata(hObject);
        main.visualization.displaySize = 512;
        main_createImage(hObject);
        main_checkCurrentDisplaySizeInMenu();
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
    end
    function m_settings_displaySize_256_callback(hObject, ~)
        handles = guidata(hObject);
        main.visualization.displaySize = 256;
        main_createImage(hObject);
        main_checkCurrentDisplaySizeInMenu();
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
    end
    function m_settings_displaySize_128_callback(hObject, ~)
        handles = guidata(hObject);
        main.visualization.displaySize = 128;
        main_createImage(hObject);
        main_checkCurrentDisplaySizeInMenu();
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
    end
    function m_settings_displaySize_64_callback(hObject, ~)
        handles = guidata(hObject);
        main.visualization.displaySize = 64;
        main_createImage(hObject);
        main_checkCurrentDisplaySizeInMenu();
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
    end
    function m_settings_displaySize_other(hObject, ~)
        handles = guidata(hObject);
        dispSize = inputdlg({'Display size (even values only)'}, ...
            'Set display size', ...
            1, {num2str(main.visualization.displaySize)});
        main.visualization.displaySize = str2double(dispSize{1});
        main_createImage(hObject);
        main_checkCurrentDisplaySizeInMenu();
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);

    end
    function m_settings_anisotropicInterpolationType_nearest_callback(hObject, ~)
        handles = guidata(hObject);
        main.visualization.anisotropicInterpolationType = 'nearest';
        
        main_checkAnisotropicInterpolationType();
        
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
    end
    function m_settings_anisotropicInterpolationType_bilinear_callback(hObject, ~)
        handles = guidata(hObject);
        main.visualization.anisotropicInterpolationType = 'bilinear';
        
        main_checkAnisotropicInterpolationType();
        
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
    end
    function m_settings_anisotropicInterpolationType_bicubic_callback(hObject, ~)
        handles = guidata(hObject);
        main.visualization.anisotropicInterpolationType = 'bicubic';
        
        main_checkAnisotropicInterpolationType();
        
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
    end
    function m_settings_anisotropicInterpolationType_box_callback(hObject, ~)
        handles = guidata(hObject);
        main.visualization.anisotropicInterpolationType = 'box';
        
        main_checkAnisotropicInterpolationType();
        
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
    end
    function m_settings_anisotropicInterpolationType_lanczos2_callback(hObject, ~)
        handles = guidata(hObject);
        main.visualization.anisotropicInterpolationType = 'lanczos2';
        
        main_checkAnisotropicInterpolationType();
        
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
    end
    function m_settings_anisotropicInterpolationType_lanczos3_callback(hObject, ~)
        handles = guidata(hObject);
        main.visualization.anisotropicInterpolationType = 'lanczos3';
        
        main_checkAnisotropicInterpolationType();
        
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
    end
    function m_settings_bufferType_wholeImage_callback(hObject, ~)
        handles = guidata(hObject);
        
        main.visualization.bufferType = 'whole';
        main_checkBufferType();
        main.data.image = main_loadImage(main.data.cubeRange{1}, main.data.cubeRange{2}, main.data.cubeRange{3});
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
        main_activateObjects();

    end
    function m_settings_bufferType_cubed_callback(hObject, ~)
        handles = guidata(hObject);
        
        main.visualization.bufferType = 'cubed';
        main_checkBufferType();
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
        main_activateObjects();

    end
    function m_settings_sectionalPlanes_callback(hObject, ~)
        handles = guidata(hObject);
        
        if main.visualization.bSectionalPlanes
            main.visualization.bSectionalPlanes = false;
            set(handles.m_settings_sectionalPlanes, 'Checked', 'off');
        else
            main.visualization.bSectionalPlanes = true;
            set(handles.m_settings_sectionalPlanes, 'Checked', 'on');
        end
        main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
        
    end

    function m_overlays_loadOverlay_mFile_callback(hObject, ~)
        handles = guidata(hObject);
        
        % Get the directory
        folder = uigetdir(main.fileIO.defaultFolder, 'Select m-file');
        if folder == 0
            return;
        else
            main.fileIO.load.folder = folder;
        end

    end

% -------------------------------------------------------------------------
% Context menu(s)

% -------------------------------------------------------------------------
% Image properties
    function images_buttonDownFcn(hObject, ~)
        handles = guidata(hObject);
        
        % Get the plain
        axesHandle = get(hObject, 'Parent');
        main.userInput.mouseDown.on = main_getImageInFocus(axesHandle);
        
        % Get the position
        pos = round(get(handles.axesDisplay, 'CurrentPoint'));
        main.userInput.mouseDown.at = pos(2, 1:2); clear pos;

    end

% -------------------------------------------------------------------------
% Window properties

    function MainWindow_resizeFcn(hObject, ~)
        handles = guidata(hObject);
        
        % Resize displays
        windowPosition = get(handles.MainWindow, 'Position');
        newPositions = (get(handles.panelMain, 'Position') + [0 .01 -.02 -.02]) ...
            .* [windowPosition(3) windowPosition(4) windowPosition(3) windowPosition(4)] ...
            + [5 0 0 0];
        newPositions(3) = newPositions(4);
        set(handles.panelDisplays, 'Position', newPositions);

    end
    function MainWindow_closeRequestFcn(hObject, ~)
        handles = guidata(hObject);
        delete(hObject);
        if isfield(handles, 'showAvailableClasses')
            if ishandle(handles.showAvailableClasses)
                delete(handles.showAvailableClasses);
            end
        end
        clear -global main
    end

    function MainWindow_keyPressFcn(hObject, eventdata)
        handles = guidata(hObject);
        
        if strcmp(eventdata.Key, 'control')
            main.userInput.keyDown.ctrl = true;
        end
        if strcmp(eventdata.Key, 'shift')
            main.userInput.keyDown.shift = true;
        end
        if strcmp(eventdata.Key, 'alt')
            main.userInput.keyDown.alt = true;
        end        
        
    end
    function MainWindow_keyReleaseFcn(hObject, eventdata)
        handles = guidata(hObject);
        
        if strcmp(eventdata.Key, 'control')
            main.userInput.keyDown.ctrl = false;
        end
        if strcmp(eventdata.Key, 'shift')
            main.userInput.keyDown.shift = false;
        end
        if strcmp(eventdata.Key, 'alt')
            main.userInput.keyDown.alt = false;
        end        

    end

    function MainWindow_windowButtonMotionFcn(hObject, ~)
        handles = guidata(hObject);
        persistent persMousePosition;
        
        if ~isempty(main.userInput.mouseDown.on)
            if isempty(persMousePosition)
                persMousePosition = main.userInput.mouseDown.at;
            end
            mousePosition = round(get(handles.axesDisplay, 'CurrentPoint'));
            mousePosition = mousePosition(2, 1:2);
            diffMousePosition = mousePosition - persMousePosition;
            persMousePosition = mousePosition;
            
            if main.userInput.keyDown.ctrl
                
                
            else
                
                % This moves the image
                switch main.userInput.mouseDown.on
                    case 'xy'
                        main.visualization.currentPosition(1) = round(main.visualization.currentPosition(1) - diffMousePosition(1) / main.data.anisotropic(1));
                        main.visualization.currentPosition(2) = round(main.visualization.currentPosition(2) - diffMousePosition(2) / main.data.anisotropic(2));
                    case 'xz'
                        main.visualization.currentPosition(1) = round(main.visualization.currentPosition(1) - diffMousePosition(1) / main.data.anisotropic(1));
                        main.visualization.currentPosition(3) = round(main.visualization.currentPosition(3) - diffMousePosition(2) / main.data.anisotropic(3));
                    case 'yz'
                        main.visualization.currentPosition(2) = round(main.visualization.currentPosition(2) - diffMousePosition(2) / main.data.anisotropic(2));
                        main.visualization.currentPosition(3) = round(main.visualization.currentPosition(3) - diffMousePosition(1) / main.data.anisotropic(3));
                end
                main.visualization.currentPosition = main_checkForOutOfBounds(main.visualization.currentPosition);

            end
            
            main_displayCurrentPosition(main.visualization.currentPosition, 'checkForChange', handles);
        else 
            persMousePosition = [];
        end
        
    end
    function MainWindow_windowButtonUpFcn(hObject, ~)
        handles = guidata(hObject);
        
        main.userInput.mouseDown.on = [];
        main.userInput.mouseDown.at = [];
    end
    function MainWindow_windowScrollWheelFcn(hObject, eventdata)
        handles = guidata(hObject);
        
        imageInFocus = main_getImageInFocus(handles.axesDisplay);
        if ~isempty(imageInFocus)
            
            if main.userInput.keyDown.ctrl
                
                main.visualization.displaySize = main.visualization.displaySize + eventdata.VerticalScrollCount * 10;
                if main.visualization.displaySize < 10
                    main.visualization.displaySize = 10;
                end
                main_createImage(hObject);
                main_checkCurrentDisplaySizeInMenu();
                main_displayCurrentPosition(main.visualization.currentPosition, 'checkForChange', handles);
                
            else

                switch imageInFocus
                    case 'xy'
                        main.visualization.currentPosition(3) = main.visualization.currentPosition(3) - eventdata.VerticalScrollCount;
                    case 'xz'
                        main.visualization.currentPosition(2) = main.visualization.currentPosition(2) - eventdata.VerticalScrollCount;
                    case 'yz'
                        main.visualization.currentPosition(1) = main.visualization.currentPosition(1) - eventdata.VerticalScrollCount;
                end
                main.visualization.currentPosition = main_checkForOutOfBounds(main.visualization.currentPosition);
                main_displayCurrentPosition(main.visualization.currentPosition, 'checkForChange', handles);
                
            end
            
           
        end
        
    end

%% Other functions

    function main_createImage(hObject)
        handles = guidata(hObject);
        
        dispSize = main.visualization.displaySize * 2 + main.visualization.spacerSize;
        handles.display = imshow(zeros(dispSize), 'Parent', handles.axesDisplay);
        set(handles.display, 'ButtonDownFcn', @images_buttonDownFcn);
        set(handles.display, 'uicontextmenu', handles.cm_images);
        
        guidata(handles.display, handles);
    end

    function main_checkAll()
        main_checkCurrentDisplaySizeInMenu();
        main_checkAnisotropicInterpolationType();
        main_checkBufferType();
        
        if main.visualization.bSectionalPlanes
            set(handles.m_settings_sectionalPlanes, 'Checked', 'on');
        else
            set(handles.m_settings_sectionalPlanes, 'Checked', 'off');
        end
        if main.visualization.bOverlayObjects
            set(handles.m_settings_overlayObjects, 'Checked', 'on');
        else
            set(handles.m_settings_overlayObjects, 'Checked', 'off');
        end

    end
    function main_checkCurrentDisplaySizeInMenu()
        
        set(handles.m_settings_displaySize_512, 'Checked', 'off');
        set(handles.m_settings_displaySize_256, 'Checked', 'off');
        set(handles.m_settings_displaySize_128, 'Checked', 'off');
        set(handles.m_settings_displaySize_64, 'Checked', 'off');
        set(handles.m_settings_displaySize_other, 'Checked', 'off');
        switch main.visualization.displaySize
            case 512
                set(handles.m_settings_displaySize_512, 'Checked', 'on');
            case 256
                set(handles.m_settings_displaySize_256, 'Checked', 'on');
            case 128
                set(handles.m_settings_displaySize_128, 'Checked', 'on');
            case 64
                set(handles.m_settings_displaySize_64, 'Checked', 'on');
            otherwise
                set(handles.m_settings_displaySize_other, 'Checked', 'on');                
        end

    end
    function main_checkAnisotropicInterpolationType()
        
        set(handles.m_settings_anisotropicInterpolationType_nearest, 'Checked', 'off');
        set(handles.m_settings_anisotropicInterpolationType_bilinear, 'Checked', 'off');
        set(handles.m_settings_anisotropicInterpolationType_bicubic, 'Checked', 'off');
        set(handles.m_settings_anisotropicInterpolationType_box, 'Checked', 'off');
        set(handles.m_settings_anisotropicInterpolationType_lanczos2, 'Checked', 'off');
        set(handles.m_settings_anisotropicInterpolationType_lanczos3, 'Checked', 'off');
        
        switch main.visualization.anisotropicInterpolationType
            case 'nearest'
                set(handles.m_settings_anisotropicInterpolationType_nearest, 'Checked', 'on');
            case 'bilinear'
                set(handles.m_settings_anisotropicInterpolationType_bilinear, 'Checked', 'on');
            case 'bicubic'
                set(handles.m_settings_anisotropicInterpolationType_bicubic, 'Checked', 'on');
            case 'box'
                set(handles.m_settings_anisotropicInterpolationType_box, 'Checked', 'on');
            case 'lanczos2'
                set(handles.m_settings_anisotropicInterpolationType_lanczos2, 'Checked', 'on');
            case 'lanczos3'
                set(handles.m_settings_anisotropicInterpolationType_lanczos3, 'Checked', 'on');
        end                
        
    end
    function main_checkBufferType()
        set(handles.m_settings_bufferType_wholeImage, 'Checked', 'off');
        set(handles.m_settings_bufferType_cubed, 'Checked', 'off');
        
        switch main.visualization.bufferType
            case 'whole'
                set(handles.m_settings_bufferType_wholeImage, 'Checked', 'on');
            case 'cubed'
                set(handles.m_settings_bufferType_cubed, 'Checked', 'on');
        end
    end

    function main_activateObjects()
        
        if isempty(main.data.image)
            % No loaded image
            
            
        end
        
%         if isempty(data.evaluation.currentLabelID)
%             % Evaluation inactive
%             % -------------------
%             
%             set(handles.m_file_loadImage, 'Enable', 'on');
%             
%             if isempty(data.image)
%                 set(handles.m_navigation, 'Enable', 'off');
%                 set(handles.m_file_loadResult, 'Enable', 'off');
%             else
%                 set(handles.m_navigation, 'Enable', 'on');
%                 set(handles.m_file_loadResult, 'Enable', 'on');
%             end
%             
%             set(findall(handles.m_evaluation, '-property', 'Enable'), 'Enable', 'off');
%             if isempty(data.image) || isempty(data.resultToEvaluate);
%                 set(handles.m_evaluation, 'Enable', 'off');
%                 set(handles.m_evaluation_startEvaluation, 'Enable', 'off');
%             else
%                 set(handles.m_evaluation, 'Enable', 'on');
%                 set(handles.m_evaluation_startEvaluation, 'Enable', 'on');
%             end
%             
%             set(handles.m_annotation, 'Enable', 'off');
%             
%         else
%             % Evaluation active
%             % -----------------
%             
%             set(handles.m_file_loadImage, 'Enable', 'off');
%             set(handles.m_file_loadResult, 'Enable', 'off');
%             
%             set(findall(handles.m_evaluation, '-property', 'Enable'), 'Enable', 'on');
%             set(handles.m_annotation, 'Enable', 'on');
%             set(handles.m_navigation, 'Enable', 'on');
%             
%             if strcmp(data.evaluation.activeGroup, 'resultToEvaluate');
%                 
%                 set(handles.m_evaluation_undersegmentation, 'Enable', 'on');
%                 set(handles.m_evaluation_oversegmentation, 'Enable', 'on');
%                 
%             elseif strcmp(data.evaluation.activeGroup, 'manualAnnotation');
%                 
%                 set(handles.m_evaluation_undersegmentation, 'Enable', 'off');
%                 set(handles.m_evaluation_oversegmentation, 'Enable', 'off');
% 
%             end
%             
%         end 
% 
    end
    function [minVisibleCube, maxVisibleCube] = main_createVisibleSubImage(position)
        % Note: position is [r c d]-based!
        persistent cubeMap

        if isempty(cubeMap)
%             main.data.image = cell(1,1);
            cubeMap = zeros(size(main.data.image));
        end
        cubeMap = cubeMap - 1;
        cubeMap(cubeMap < 0) = 0;
        
        minVisible = position - main.visualization.displaySize / 2;
        minVisibleCube = floor(minVisible / main.data.cubeSize);
        maxVisible = position + main.visualization.displaySize / 2;
        maxVisibleCube = floor(maxVisible / main.data.cubeSize);

        if minVisibleCube(1) < main.data.cubeRange{2}(1) + 1, minVisibleCube(1) = main.data.cubeRange{2}(1) + 1; end
        if minVisibleCube(2) < main.data.cubeRange{1}(1) + 1, minVisibleCube(2) = main.data.cubeRange{1}(1) + 1; end
        if minVisibleCube(3) < main.data.cubeRange{3}(1) + 1, minVisibleCube(3) = main.data.cubeRange{3}(1) + 1; end

        if maxVisibleCube(1) > main.data.cubeRange{2}(2) + 1, maxVisibleCube(1) = main.data.cubeRange{2}(2) + 1; end
        if maxVisibleCube(2) > main.data.cubeRange{1}(2) + 1, maxVisibleCube(2) = main.data.cubeRange{1}(2) + 1; end
        if maxVisibleCube(3) > main.data.cubeRange{3}(2) + 1, maxVisibleCube(3) = main.data.cubeRange{3}(2) + 1; end

        for r = minVisibleCube(1) : maxVisibleCube(1)
            for c = minVisibleCube(2) : maxVisibleCube(2)
                for d = minVisibleCube(3) : maxVisibleCube(3)
                    
                    if isempty(main.data.image{r, c, d})
                        
                        main.data.image{r, c, d} = jh_openCubeRange( ...
                            main.fileIO.load.folder, '', ...
                            'cubeSize', [128 128 128], ...
                            'range', 'oneCube', [c-1, r-1, d-1], ...
                            'dataType', main.settings.prefType, ...
                            'outputType', 'one', ...
                            'fileType', 'auto') / 255;
                        
                    end

                    cubeMap(r, c, d) = main.visualization.bufferDelete;

                end
            end
        end

        for r = main.data.cubeRange{2}(1) : main.data.cubeRange{2}(2)
            for c = main.data.cubeRange{1}(1) : main.data.cubeRange{1}(2)
                for d = main.data.cubeRange{3}(1) : main.data.cubeRange{3}(2)
                    if cubeMap(r+1, c+1, d+1) == 0
                        main.data.image{r+1, c+1, d+1} = [];
                    end
                end
            end
        end

%         cubePosition = ceil(position / main.data.cubeSize);
        
    end
    function main_displayCurrentPosition(position, type, handles)
        
        position = round(position);
        
        if strcmp(type, 'checkForChange');
            if ~main_checkForChange('getset')
                return
            end
        else
            main_checkForChange('set');
        end
        
        anisotropic = xyz2rcd(main.data.anisotropic);
        sPosition = xyz2rcd(position);
        
        % Load the desired part of the image (if not already open)
        % and adjust the sPosition
        
        % Development note:
        %   Hier ist noch speed-Potential
        
        if strcmp(main.visualization.bufferType, 'cubed')
            [minVisibleCube, maxVisibleCube] = main_createVisibleSubImage(sPosition);
        else 
            minVisibleCube(1) = main.data.cubeRange{2}(1) + 1;
            minVisibleCube(2) = main.data.cubeRange{1}(1) + 1;
            minVisibleCube(3) = main.data.cubeRange{3}(1) + 1;
            maxVisibleCube(1) = main.data.cubeRange{2}(2) + 1;
            maxVisibleCube(2) = main.data.cubeRange{1}(2) + 1;
            maxVisibleCube(3) = main.data.cubeRange{3}(2) + 1;
        end
        
        % ---
        
        n = round(main.visualization.displaySize ./ anisotropic / 2) *2;
        ds = main.visualization.displaySize;
    
        % Pre-define images 
        imageXY = zeros(n(1), n(2));
        imageXZ = zeros(n(3), n(2));
        imageYZ = zeros(n(1), n(3));
%         tic
        % Iterate over the loaded cube range
        for r = minVisibleCube(1) : maxVisibleCube(1)
            for c = minVisibleCube(2) : maxVisibleCube(2)
                for d = minVisibleCube(3) : maxVisibleCube(3)
                    
                    if ~isempty(main.data.image{r,c,d})
                        [imageXY, imageXZ, imageYZ, ~] = overlayObject( ...
                            imageXY, imageXZ, imageYZ, ...
                            sPosition, [r, c, d]*main.data.cubeSize, ...
                            main.data.image{r,c,d}, ...
                            ds, anisotropic, ...
                            'replace', 0);
                    end
                    
                end
            end
        end

%         toc
        % Convert to RGB
%         tic
        imageXY = jh_convertGray2RGB(imageXY);
        imageXZ = jh_convertGray2RGB(imageXZ);
        imageYZ = jh_convertGray2RGB(imageYZ);
%         toc

        % Resize the images
%         tic
        anisotrType = main.visualization.anisotropicInterpolationType;
        if main.data.anisotropic(1) ~= 1 || main.data.anisotropic(2) ~= 1
            imageXY = imresize(imageXY, [ds, ds], anisotrType);
            imageXY(imageXY < 0) = 0;
        end
        if main.data.anisotropic(1) ~= 1 || main.data.anisotropic(3) ~= 1
            imageXZ = imresize(imageXZ, [ds, ds], anisotrType);
            imageXZ(imageXZ < 0) = 0;
        end
        if main.data.anisotropic(2) ~= 1 || main.data.anisotropic(3) ~= 1
            imageYZ = imresize(imageYZ, [ds, ds], anisotrType);
            imageYZ(imageYZ < 0) = 0;
        end
%         toc


        % White dot in the middle
        imageXY(ds/2, ds/2, :) = 1;
        imageXZ(ds/2, ds/2, :) = 1;
        imageYZ(ds/2, ds/2, :) = 1;
        
        if main.visualization.bSectionalPlanes
            % Red, greed and blue lines
            imageXY(:, ds/2, 3) = 1;
            imageXY(ds/2, :, 2) = 1;
            imageXZ(:, ds/2, 3) = 1;
            imageXZ(ds/2, :, 1) = 1;
            imageYZ(ds/2, :, 2) = 1;
            imageYZ(:,ds/2, 1) = 1;
        
            % Border around each image
            imageXY(:, 1:2, 1) = 1;
            imageXY(:, end-1:end, 1) = 1;
            imageXY(1:2, :, 1) = 1;
            imageXY(end-1:end, :, 1) = 1;
            imageXZ(:, 1:2, 2) = 1;
            imageXZ(:, end-1:end, 2) = 1;
            imageXZ(1:2, :, 2) = 1;
            imageXZ(end-1:end, :, 2) = 1;
            imageYZ(:, 1:2, 3) = 1;
            imageYZ(:, end-1:end, 3) = 1;
            imageYZ(1:2, :, 3) = 1;
            imageYZ(end-1:end, :, 3) = 1;
            
        end
        
        spacer = main.visualization.spacerSize;
        backColor = main.settings.window.backColor;
        showImage = ones(ds*2 + spacer, ds*2 + spacer, 3);
        showImage(:,:,1) = backColor(1);
        showImage(:,:,2) = backColor(2);
        showImage(:,:,3) = backColor(3);
        showImage(1:ds, 1:ds, :) = imageXY;
        showImage(1:ds, ds+spacer+1:2*ds+spacer, :) = imageYZ;
        showImage(ds+spacer+1:2*ds+spacer, 1:ds, :) = imageXZ;
        
        % Show the image
        set(handles.display, 'cdata', showImage);
        
    end
    function [imageXY, imageXZ, imageYZ, visibility] = overlayObject( ...
            imageXY, imageXZ, imageYZ, ...
            position, objectPosition, objectMatrix, ...
            displaySize, anisotropic, ...
            overlaySpec, osValue)
        
        visibility = false;
        n = round(displaySize ./ anisotropic / 2) *2;
        objectPosition = objectPosition - [1 1 1];
        position = position - objectPosition;

%         kernel = cell(1, 3);
        kernelP = cell(1, 3);
        pad = zeros(1, 3);
        for i = 1:3
            kernelP{i} = (-(n(i)/2) + 1 : (n(i)/2)) + position(i);
%             kernelP{i} = kernel{i} + position(i);
            pad(i) = n(i) - max(kernelP{i});
            kernelP{i} = kernelP{i}(kernelP{i} >= 1 & kernelP{i} <= size(objectMatrix, i));
        end

        if strcmp(overlaySpec, 'replace')
            % XY
            if position(3) > 0 && position(3) <= size(objectMatrix, 3) ...
                    && ~isempty(kernelP{1}) && ~isempty(kernelP{2})
                imageXY(kernelP{1} + pad(1), kernelP{2} + pad(2)) = ...
                    objectMatrix(kernelP{1}, kernelP{2}, position(3));
                visibility = true;
            end
            
            % XZ
            if position(1) > 0 && position(1) <= size(objectMatrix, 1) ...
                    && ~isempty(kernelP{2}) && ~isempty(kernelP{3})
                imageXZ(kernelP{3} + pad(3), kernelP{2} + pad(2)) = ...
                    permute(objectMatrix(position(1), kernelP{2}, kernelP{3}), [3, 2, 1]);
                visibility = true;
            end

            % YZ
            if position(2) > 0 && position(2) <= size(objectMatrix, 2) ...
                    && ~isempty(kernelP{1}) && ~isempty(kernelP{3})
                imageYZ(kernelP{1} + pad(1), kernelP{3} + pad(3)) = ...
                    permute(objectMatrix(kernelP{1}, position(2), kernelP{3}), [1, 3, 2]);
                visibility = true;
            end
        else
            % XY
            if position(3) > 0 && position(3) <= size(objectMatrix, 3) ...
                    && ~isempty(kernelP{1}) && ~isempty(kernelP{2})
                overlayXY = zeros(n(1), n(2));
                overlayXY(kernelP{1} + pad(1), kernelP{2} + pad(2)) = ...
                    objectMatrix(kernelP{1}, kernelP{2}, position(3));
                imageXY = jh_overlayLabels( ...
                    imageXY, overlayXY, ...
                    'type', 'colorize', ...
                    overlaySpec, osValue, ...
                    'auto');
                visibility = true;
            end

            % XZ
            if position(1) > 0 && position(1) <= size(objectMatrix, 1) ...
                    && ~isempty(kernelP{2}) && ~isempty(kernelP{3})
                overlayXZ = zeros(n(3), n(2));
                overlayXZ(kernelP{3} + pad(3), kernelP{2} + pad(2)) = ...
                    permute(objectMatrix(position(1), kernelP{2}, kernelP{3}), [3, 2, 1]);
                imageXZ = jh_overlayLabels( ...
                    imageXZ, overlayXZ, ...
                    'type', 'colorize', ...
                    overlaySpec, osValue, ...
                    'auto');
                visibility = true;
            end

            % YZ
            if position(2) > 0 && position(2) <= size(objectMatrix, 2) ...
                    && ~isempty(kernelP{1}) && ~isempty(kernelP{3})
                overlayYZ = zeros(n(1), n(3));
                overlayYZ(kernelP{1} + pad(1), kernelP{3} + pad(3)) = ...
                    permute(objectMatrix(kernelP{1}, position(2), kernelP{3}), [1, 3, 2]);
                imageYZ = jh_overlayLabels( ...
                    imageYZ, overlayYZ, ...
                    'type', 'colorize', ...
                    overlaySpec, osValue, ...
                    'auto');
                visibility = true;
            end
        end
    end

    function change = main_checkForChange(type)
        persistent position displaySize spacerSize
        change = false;
        
        if strcmp(type, 'getset') || strcmp(type, 'get')
            if ~isequal(position, main.visualization.currentPosition) ...
                    || displaySize == main.visualization.displaySize ...
                    || spacerSize == main.visualization.spacerSize
                change = true;
            end            
        end
        if strcmp(type, 'getset') || strcmp(type, 'set')
            position = main.visualization.currentPosition;
            displaySize = main.visualization.displaySize;
            spacerSize = main.visualization.spacerSize;
        end
    end
    function image = main_loadImage(rangeX, rangeY, rangeZ)
        
        image = jh_openCubeRange( ...
            main.fileIO.load.folder, '', ...
            'cubeSize', [128 128 128], ...
            'range', rangeX, rangeY, rangeZ, ...
            'dataType', main.settings.prefType, ...
            'outputType', 'cubed', ...
            'fileType', 'auto');
        
        image = cellfun(@(x) x/255, image, 'UniformOutput', false);
        
    end
    function bounds = main_checkForOutOfBounds(bounds)
            if bounds(1) > (main.data.cubeRange{2}(2) + 2)*main.data.cubeSize - 1;
                bounds(1) =(main.data.cubeRange{2}(2) + 2)*main.data.cubeSize - 1;
            elseif bounds(1) < (main.data.cubeRange{2}(1) + 1)*main.data.cubeSize
                bounds(1) = (main.data.cubeRange{2}(1) + 1)*main.data.cubeSize;
            end
            if bounds(2) > (main.data.cubeRange{1}(2) + 2)*main.data.cubeSize - 1;
                bounds(2) = (main.data.cubeRange{1}(2) + 2)*main.data.cubeSize - 1;
            elseif bounds(2) < (main.data.cubeRange{1}(1) + 1)*main.data.cubeSize
                bounds(2) = (main.data.cubeRange{1}(1) + 1)*main.data.cubeSize;
            end
            if bounds(3) > (main.data.cubeRange{3}(2) + 2)*main.data.cubeSize - 1;
                bounds(3) = (main.data.cubeRange{3}(2) + 2)*main.data.cubeSize - 1;
            elseif bounds(3) < (main.data.cubeRange{3}(1) + 1)*main.data.cubeSize
                bounds(3) = (main.data.cubeRange{3}(1) + 1)*main.data.cubeSize;
            end

    end

    function imageName = main_getImageInFocus(axesHandle)
        
        imageName = [];
        n = main.visualization.displaySize;
        
%         axesHandle  = get(hObject,'Parent');
        coordinates = get(axesHandle,'CurrentPoint'); 
        coordinates = round(coordinates(1,1:2));
        
        % Get the image in focus
        if coordinates(1) <= n && coordinates(1) >= 1
            if coordinates(2) <= n && coordinates(2) >= 1
                imageName = 'xy';                
            elseif coordinates(2) > n+5 && coordinates(2) <= 2*n+5
                imageName = 'xz';                
            end
        elseif coordinates(1) > n+5 && coordinates(1) <= 2*n+5
            if coordinates(2) <= n && coordinates(2) >= 1
                imageName = 'yz';                
            elseif coordinates(2) > n+5 && coordinates(2) <= 2*n+5
                imageName = 'magnification';                
            end
        end
    end

    function main_throwException(EX, title)
        
        if isempty(title)
            title = 'ERROR: Unexpected exception';
        end
        
        fprintf(2, ['\n    ' title '.\n\n']);
        ID = EX.identifier;
        ID = strrep(ID, '\', '\\');
        fprintf(2, ['        ' ID '\n']);
        message = EX.message;
        message = strrep(message, '\', '\\');
        fprintf(2, ['        ' message '\n\n']);
        
        if ~isempty(EX.stack)
            for i = 1:length(EX.stack)
                file = EX.stack(i).file;
                file = strrep(file, '\', '\\');
                fprintf(2, ['        ' file '\n']);
                fprintf(2, ['        ' EX.stack(i).name]);
                fprintf(2, [' (line: ' num2str(EX.stack(i).line) ')\n\n']);
            end
        end
        
        if isfield(EX, 'solution')
            fprintf(['    ' EX.solution '\n\n']);
        end
       
    end

end

function RGB = jh_convertGray2RGB(gray)
if size(gray, 3) == 1
    RGB(:,:,1) = gray;
    RGB(:,:,2) = gray;
    RGB(:,:,3) = gray;
elseif size(gray, 3) > 1 && size(gray, 4) == 1
    RGB(:,:,:,1) = gray;
    RGB(:,:,:,2) = gray;
    RGB(:,:,:,3) = gray;
end
end


function rcd = xyz2rcd(xyz)
    rcd(1) = xyz(2);
    rcd(2) = xyz(1);
    rcd(3) = xyz(3);
end





