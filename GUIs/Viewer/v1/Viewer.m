classdef Viewer < handle
    
    %%
    
    properties
        Figure
        AxesDisplay
        PanelMain
        PanelDisplays
        TextDisplay
        Display
        
        prefType
        windowBackColor
    end
    
    % The menu
    properties 
        m_file
        m_file_loadImage
        m_file_loadImage_fromCubedData
        m_file_saveProject
        m_file_saveProjectAs
        m_file_loadProject
        m_settings
        m_settings_displaySize
        m_settings_displaySize_512
        m_settings_displaySize_256
        m_settings_displaySize_128
        m_settings_displaySize_64
        m_settings_displaySize_other
        m_settings_anisotropicInterpolationType
        m_settings_anisotropicInterpolationType_nearest
        m_settings_anisotropicInterpolationType_bilinear
        m_settings_anisotropicInterpolationType_bicubic
        m_settings_anisotropicInterpolationType_box
        m_settings_anisotropicInterpolationType_lanczos2
        m_settings_anisotropicInterpolationType_lanczos3
        m_settings_bufferType
        m_settings_bufferType_wholeImage
        m_settings_bufferType_cubed
        m_settings_sectionalPlanes
        m_settings_overlayObjects
        m_settings_advanced
        m_tools
        m_overlays
        m_overlays_loadOverlay
        m_overlays_loadOverlay_cubedData
        m_overlays_loadOverlay_imageStack
        m_overalys_loadOverlay_mFile
        m_overlays_addBlank
    end
    
    properties (SetAccess = private)
        screenSize
%         windowSize
        initialWindowPosition
        userInput = UserInput;
    end
    
    % Default values
    properties (SetAccess = protected)
        visualization = Visualization([0, 0, 0], 256, true, true, 5, 'bicubic', 100);
        mainSettings = MainSettings('single', 'DefaultUicontrolBackgroundColor');
        image = Data({[3 6], [3 6], [0 3]}, [], [1 1 3], [128 128 128], 'cubed');
        overlay
        fileIO
    end
    
    properties (Constant)
        defaultWindowSize = [800 600];
    end
    
    %%
    methods
        %% Constructor
        function MainWindow = Viewer()
                        
            % Main window
            MainWindow.Figure = figure( ...
                'MenuBar', 'none', ...
                'Name', 'Viewer', ...
                'NumberTitle', 'off', ...
                'ToolBar', 'none', ...
                'Position', MainWindow.initialWindowPosition, ...
                'Units', 'pixels', ...
                'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
                'ResizeFcn', @MainWindow.this_resizeFcn, ...
                'CreateFcn', @MainWindow.this_createFcn, ...
                'KeyPressFcn', @MainWindow.this_keyPressFcn, ...
                'KeyReleaseFcn', @MainWindow.this_keyReleaseFcn, ...
                'WindowButtonMotionFcn', @MainWindow.this_windowButtonMotionFcn, ...
                'WindowButtonUpFcn', @MainWindow.this_windowButtonUpFcn, ...
                'WindowScrollWheelFcn', @MainWindow.this_windowScrollWheelFcn, ...
                'CloseRequestFcn', @MainWindow.this_closeRequestFcn);
            % Main panel which contains everything
            MainWindow.PanelMain = uipanel(MainWindow.Figure, ...
                'Tag', 'panelMain', ...
                'Title', '', ...
                'BorderType', 'none', ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1]);
            % Panels which contains all axes (has to be quadratic)
            MainWindow.PanelDisplays = uipanel(MainWindow.PanelMain, ...
                'Tag', 'panelDisplays', ...
                'Title', 'Visualization', ...
                'BorderType', 'etchedin', ...
                'Units', 'pixels');
            % Main display
            MainWindow.AxesDisplay = axes('Parent', MainWindow.PanelDisplays, ...
                'Tag', 'axesDisplay', ...
                'Units', 'normalized', ...
                'Position', [.01, .01, .98, .98]);
            % Text display
            MainWindow.TextDisplay = uicontrol(MainWindow.PanelDisplays, ...
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
            
            % -------------------------------------------------------------
            % The Menu

            % File...
            MainWindow.m_file = uimenu(MainWindow.Figure, ...
                'Label', 'File');
            MainWindow.m_file_loadImage = uimenu(MainWindow.m_file, ...
                'Label', 'Load image');
            MainWindow.m_file_loadImage_fromCubedData = uimenu(MainWindow.m_file_loadImage, ...
                'Label', 'From cubed data', ...
                'Callback', @MainWindow.m_file_loadImage_fromCubedData_callback, ...
                'Accelerator', 'i');
            MainWindow.m_file_saveProject = uimenu(MainWindow.m_file, ...
                'Label', 'Save project', ...
                'Callback', @m_file_saveProject_callback, ...
                'Separator', 'on', ...
                'Accelerator', 's');
            MainWindow.m_file_saveProjectAs = uimenu(MainWindow.m_file, ...
                'Label', 'Save project as', ...
                'Callback', @m_file_saveProjectAs_callback);
            MainWindow.m_file_loadProject = uimenu(MainWindow.m_file, ...
                'Label', 'Load project', ...
                'Callback', @m_file_loadProject_callback, ...
                'Accelerator', 'l');

            % Settings...
            MainWindow.m_settings = uimenu(MainWindow.Figure, ...
                'Label', 'Settings');
            % > Settings
                MainWindow.m_settings_displaySize = uimenu(MainWindow.m_settings, ...
                    'Label', 'Display size');
                % > Display size
                    MainWindow.m_settings_displaySize_512 = uimenu(MainWindow.m_settings_displaySize, ...
                        'Label', '512 pixels', ...
                        'Callback', @m_settings_displaySize_512_callback);
                    MainWindow.m_settings_displaySize_256 = uimenu(MainWindow.m_settings_displaySize, ...
                        'Label', '256 pixels', ...
                        'Callback', @m_settings_displaySize_256_callback);
                    MainWindow.m_settings_displaySize_128 = uimenu(MainWindow.m_settings_displaySize, ...
                        'Label', '128 pixels', ...
                        'Callback', @m_settings_displaySize_128_callback);
                    MainWindow.m_settings_displaySize_64 = uimenu(MainWindow.m_settings_displaySize, ...
                        'Label', '64 pixels', ...
                        'Callback', @m_settings_displaySize_64_callback);
                    % -
                    MainWindow.m_settings_displaySize_other = uimenu(MainWindow.m_settings_displaySize, ...
                        'Label', 'Other', ...
                        'Callback', @m_settings_displaySize_other, ...
                        'Separator', 'on');
                % <
                MainWindow.m_settings_anisotropicInterpolationType = uimenu(MainWindow.m_settings, ...
                    'Label', 'Anisotropic interpolation type');
                % > Anisotropic interpolation type
                    MainWindow.m_settings_anisotropicInterpolationType_nearest = uimenu(MainWindow.m_settings_anisotropicInterpolationType, ...
                        'Label', 'Nearest', ...
                        'Callback', @m_settings_anisotropicInterpolationType_nearest_callback);
                    MainWindow.m_settings_anisotropicInterpolationType_bilinear = uimenu(MainWindow.m_settings_anisotropicInterpolationType, ...
                        'Label', 'Bilinear', ...
                        'Callback', @m_settings_anisotropicInterpolationType_bilinear_callback);
                    MainWindow.m_settings_anisotropicInterpolationType_bicubic = uimenu(MainWindow.m_settings_anisotropicInterpolationType, ...
                        'Label', 'Bicubic', ...
                        'Callback', @m_settings_anisotropicInterpolationType_bicubic_callback);
                    MainWindow.m_settings_anisotropicInterpolationType_box = uimenu(MainWindow.m_settings_anisotropicInterpolationType, ...
                        'Label', 'Box', ...
                        'Callback', @m_settings_anisotropicInterpolationType_box_callback);
                    MainWindow.m_settings_anisotropicInterpolationType_lanczos2 = uimenu(MainWindow.m_settings_anisotropicInterpolationType, ...
                        'Label', 'Lanczos-2', ...
                        'Callback', @m_settings_anisotropicInterpolationType_lanczos2_callback);
                    MainWindow.m_settings_anisotropicInterpolationType_lanczos3 = uimenu(MainWindow.m_settings_anisotropicInterpolationType, ...
                        'Label', 'Lanczos-3', ...
                        'Callback', @m_settings_anisotropicInterpolationType_lanczos3_callback);
                % <
                MainWindow.m_settings_bufferType = uimenu(MainWindow.m_settings, ...
                    'Label', 'Buffer type');
                % > Buffer Type
                    MainWindow.m_settings_bufferType_wholeImage = uimenu(MainWindow.m_settings_bufferType, ...
                        'Label', 'Whole image', ...
                        'Callback', @m_settings_bufferType_wholeImage_callback);
                    MainWindow.m_settings_bufferType_cubed = uimenu(MainWindow.m_settings_bufferType, ...
                        'Label', 'Cubed', ...
                        'Callback', @m_settings_bufferType_cubed_callback);
                % -
                MainWindow.m_settings_sectionalPlanes = uimenu(MainWindow.m_settings, ...
                    'Label', 'Sectional planes', ...
                    'Callback', @m_settings_sectionalPlanes_callback, ...
                    'Separator', 'on', ...
                    'Accelerator', 'q');
                MainWindow.m_settings_overlayObjects = uimenu(MainWindow.m_settings, ...
                    'Label', 'Overlay objects', ...
                    'Callback', @m_settings_overlayObjects_callback, ...
                    'Accelerator', 'w');
                % -
                MainWindow.m_settings_advanced = uimenu(MainWindow.m_settings, ...
                    'Label', 'Advanced', ...
                    'Separator', 'on', ...
                    'Enable', 'off');

            % Tools...
            MainWindow.m_tools = uimenu(MainWindow.Figure, ...
                'Label', 'Tools');

            % Overlays...
            MainWindow.m_overlays = uimenu(MainWindow.Figure, ...
                'Label', 'Overlays');
            % > Overlays
                MainWindow.m_overlays_loadOverlay = uimenu(MainWindow.m_overlays, ...
                    'Label', 'Load overlay', ...
                    'Callback', @m_overlays_loadOverlay_callback);
                % > Load overlay
                    MainWindow.m_overlays_loadOverlay_cubedData = uimenu(MainWindow.m_overlays_loadOverlay, ...
                        'Label', 'Cubed data', ...
                        'Callback', @m_overlays_loadOverlay_cubedData_callback, ...
                        'Enable', 'off');
                    MainWindow.m_overlays_loadOverlay_imageStack = uimenu(MainWindow.m_overlays_loadOverlay, ...
                        'Label', 'Image stack', ...
                        'Callback', @m_overlays_loadOverlay_imageStack_callback, ...
                        'Enable', 'off');
                    MainWindow.m_overalys_loadOverlay_mFile = uimenu(MainWindow.m_overlays_loadOverlay, ...
                        'Label', 'M-file', ...
                        'Callback', @m_overlays_loadOverlay_mFile_callback);
                % <
                MainWindow.m_overlays_addBlank = uimenu(MainWindow.m_overlays, ...
                    'Label', 'Add blank', ...
                    'Callback', @m_overlays_addBlank_callback, ...
                    'Enable', 'off');

        end
        
        %% MainWindow callbacks
        function this_closeRequestFcn(MainWindow, ~, ~)
            delete(MainWindow.Figure);
        end
        function this_resizeFcn(MainWindow, hObject, ~)
        
            % Resize displays
            windowPosition = get(hObject, 'Position');
            newPositions = (get(MainWindow.PanelMain, 'Position') + [0 .01 -.02 -.02]) ...
                .* [windowPosition(3) windowPosition(4) windowPosition(3) windowPosition(4)] ...
                + [5 0 0 0];
            newPositions(3) = newPositions(4);
            set(MainWindow.PanelDisplays, 'Position', newPositions);

        end
        function this_createFcn(this, ~, ~)
            
            % Add all folders within the main path
            thisPath = mfilename('fullpath');
            posSlash = find(thisPath == filesep, 1, 'last');
            posSlash = posSlash(1);
            thisPath = thisPath(1:posSlash);
            this.fileIO = FileIO(thisPath);
            this.fileIO.thisFolder = thisPath;
            addpath(genpath(thisPath));

        end
        function this_keyPressFcn(this, ~, eventdata)

            if strcmp(eventdata.Key, 'control')
                this.userInput.keyEvent.ctrlDown = true;
            end
            if strcmp(eventdata.Key, 'shift')
                this.userInput.keyEvent.shiftDown = true;
            end
            if strcmp(eventdata.Key, 'alt')
                this.userInput.keyEvent.altDown = true;
            end        

        end
        function this_keyReleaseFcn(this, ~, eventdata)

            if strcmp(eventdata.Key, 'control')
                this.userInput.keyEvent.ctrlDown = false;
            end
            if strcmp(eventdata.Key, 'shift')
                this.userInput.keyEvent.shiftDown = false;
            end
            if strcmp(eventdata.Key, 'alt')
                this.userInput.keyEvent.altDown = false;
            end        

        end
        function this_windowButtonMotionFcn(this, ~, ~)
            persistent persMousePosition;

            if ~isempty(this.userInput.mouseEvent.downOn)
                
                if isempty(persMousePosition)
                    persMousePosition = this.userInput.mouseEvent.downAt;
                end
                
                mousePosition = round(get(this.AxesDisplay, 'CurrentPoint'));
                mousePosition = mousePosition(2, 1:2);
                diffMousePosition = mousePosition - persMousePosition;
                persMousePosition = mousePosition;

                if this.userInput.keyEvent.ctrlDown


                else

                    % This moves the image
                    switch this.userInput.mouseEvent.downOn
                        case 'xy'
                            this.visualization.currentPosition(1) = round(this.visualization.currentPosition(1) - diffMousePosition(1) / this.image.anisotropic(1));
                            this.visualization.currentPosition(2) = round(this.visualization.currentPosition(2) - diffMousePosition(2) / this.image.anisotropic(2));
                        case 'xz'
                            this.visualization.currentPosition(1) = round(this.visualization.currentPosition(1) - diffMousePosition(1) / this.image.anisotropic(1));
                            this.visualization.currentPosition(3) = round(this.visualization.currentPosition(3) - diffMousePosition(2) / this.image.anisotropic(3));
                        case 'yz'
                            this.visualization.currentPosition(2) = round(this.visualization.currentPosition(2) - diffMousePosition(2) / this.image.anisotropic(2));
                            this.visualization.currentPosition(3) = round(this.visualization.currentPosition(3) - diffMousePosition(1) / this.image.anisotropic(3));
                    end
                    this.checkForOutOfBounds();

                end

                this.displayCurrentPosition('checkForChange');
            else 
                persMousePosition = [];
            end

        end
        function this_windowButtonUpFcn(this, ~, ~)

            this.userInput.mouseEvent.downOn = [];
            this.userInput.mouseEvent.downAt = [];
        end
        function this_windowScrollWheelFcn(this, ~, eventdata)

            imageInFocus = this.getImageInFocus();
            if ~isempty(imageInFocus)

                if this.userInput.keyEvent.ctrlDown

                    this.visualization.displaySize = this.visualization.displaySize + eventdata.VerticalScrollCount * 10;
                    if this.visualization.displaySize < 10
                        this.visualization.displaySize = 10;
                    end
                    this.createImageDisplay();
%                     main_checkCurrentDisplaySizeInMenu();
                    this.displayCurrentPosition('checkForChange');

                else

                    switch imageInFocus
                        case 'xy'
                            this.visualization.currentPosition(3) = this.visualization.currentPosition(3) - eventdata.VerticalScrollCount;
                        case 'xz'
                            this.visualization.currentPosition(2) = this.visualization.currentPosition(2) - eventdata.VerticalScrollCount;
                        case 'yz'
                            this.visualization.currentPosition(1) = this.visualization.currentPosition(1) - eventdata.VerticalScrollCount;
                    end
                    this.checkForOutOfBounds();
                    this.displayCurrentPosition('checkForChange');

                end


            end

        end

        
        %% Display callbacks
        function display_buttonDownFcn(this, ~, ~)

            % Get the plain
            this.userInput.mouseEvent.downOn = this.getImageInFocus();

            % Get the position
            pos = round(get(this.AxesDisplay, 'CurrentPoint'));
            this.userInput.mouseEvent.downAt = pos(2, 1:2); clear pos;

        end
        
        %% Menu callbacks
        function m_file_loadImage_fromCubedData_callback(this, ~, ~)
%             handles = guidata(hObject);

            % Get the directory
            folder = uigetdir(this.fileIO.defaultFolder, 'Select dataset folder');
            if folder == 0
                return;
            else
                this.fileIO.loadImageFolder = folder;
            end

            % Dialog box to specify the range which will be loaded
            range = inputdlg( ...
                {   'From (x, y, z)', 'To (x, y, z)', ...
                    'Anisotropy factors (x, y, z)' ...
                }, ...
                'Specify range...', ...
                1, ...
                {   [num2str(this.image.cubeRange{1}(1)) ', ' num2str(this.image.cubeRange{2}(1)) ', ' num2str(this.image.cubeRange{3}(1))], ...
                    [num2str(this.image.cubeRange{1}(2)) ', ' num2str(this.image.cubeRange{2}(2)) ', ' num2str(this.image.cubeRange{3}(2))], ...
                    [num2str(this.image.anisotropic(1)), ', ' num2str(this.image.anisotropic(2)), ', ', num2str(this.image.anisotropic(3))] ...
                });
            rangeFrom = strsplit(range{1}, {', ', ','});
            rangeTo = strsplit(range{2}, {', ', ','});
            rangeX = [str2double(rangeFrom{1}) str2double(rangeTo{1})];
            rangeY = [str2double(rangeFrom{2}) str2double(rangeTo{2})];
            rangeZ = [str2double(rangeFrom{3}) str2double(rangeTo{3})];
            anisotropic = strsplit(range{3}, {', ', ','});

            this.image.anisotropic = cellfun(@(x) str2double(x), anisotropic);
            this.image.cubeRange = {rangeX, rangeY, rangeZ};

            if strcmp(this.image.bufferType, 'whole')
                this.image.image = main_loadImage(rangeX, rangeY, rangeZ);
            elseif strcmp(this.image.bufferType, 'cubed')
                this.image.image = cell(rangeX(2)+1, rangeY(2)+1, rangeZ(2)+1);
            else
                EX.identifier = 'Viewer: Unknown buffer type';
                EX.message = ['Buffer type ' this.image.bufferType 'is invalid.'];
                EX.stack = [];
                EX.solution = 'No known solution found.';
                this.throwException(EX, 'ERROR: Unknown buffer type');
            end

            this.createImageDisplay();
            this.displayCurrentPosition('');
            this.activateObjects();

        end
%         function m_file_saveProject_callback(hObject, ~)
%             handles = guidata(hObject);
% 
%         end
%         function m_file_saveProjectAs_callback(hObject, ~)
%             handles = guidata(hObject);
% 
%         end
%         function m_file_loadProject_callback(hObject, ~)
%             handles = guidata(hObject);
% 
%         end
% 
%         function m_settings_displaySize_512_callback(hObject, ~)
%             handles = guidata(hObject);
%             main.visualization.displaySize = 512;
%             main_createImage(hObject);
%             main_checkCurrentDisplaySizeInMenu();
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
%         end
%         function m_settings_displaySize_256_callback(hObject, ~)
%             handles = guidata(hObject);
%             main.visualization.displaySize = 256;
%             main_createImage(hObject);
%             main_checkCurrentDisplaySizeInMenu();
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
%         end
%         function m_settings_displaySize_128_callback(hObject, ~)
%             handles = guidata(hObject);
%             main.visualization.displaySize = 128;
%             main_createImage(hObject);
%             main_checkCurrentDisplaySizeInMenu();
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
%         end
%         function m_settings_displaySize_64_callback(hObject, ~)
%             handles = guidata(hObject);
%             main.visualization.displaySize = 64;
%             main_createImage(hObject);
%             main_checkCurrentDisplaySizeInMenu();
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
%         end
%         function m_settings_displaySize_other(hObject, ~)
%             handles = guidata(hObject);
%             dispSize = inputdlg({'Display size (even values only)'}, ...
%                 'Set display size', ...
%                 1, {num2str(main.visualization.displaySize)});
%             main.visualization.displaySize = str2double(dispSize{1});
%             main_createImage(hObject);
%             main_checkCurrentDisplaySizeInMenu();
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
% 
%         end
%         function m_settings_anisotropicInterpolationType_nearest_callback(hObject, ~)
%             handles = guidata(hObject);
%             main.visualization.anisotropicInterpolationType = 'nearest';
% 
%             main_checkAnisotropicInterpolationType();
% 
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
%         end
%         function m_settings_anisotropicInterpolationType_bilinear_callback(hObject, ~)
%             handles = guidata(hObject);
%             main.visualization.anisotropicInterpolationType = 'bilinear';
% 
%             main_checkAnisotropicInterpolationType();
% 
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
%         end
%         function m_settings_anisotropicInterpolationType_bicubic_callback(hObject, ~)
%             handles = guidata(hObject);
%             main.visualization.anisotropicInterpolationType = 'bicubic';
% 
%             main_checkAnisotropicInterpolationType();
% 
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
%         end
%         function m_settings_anisotropicInterpolationType_box_callback(hObject, ~)
%             handles = guidata(hObject);
%             main.visualization.anisotropicInterpolationType = 'box';
% 
%             main_checkAnisotropicInterpolationType();
% 
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
%         end
%         function m_settings_anisotropicInterpolationType_lanczos2_callback(hObject, ~)
%             handles = guidata(hObject);
%             main.visualization.anisotropicInterpolationType = 'lanczos2';
% 
%             main_checkAnisotropicInterpolationType();
% 
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
%         end
%         function m_settings_anisotropicInterpolationType_lanczos3_callback(hObject, ~)
%             handles = guidata(hObject);
%             main.visualization.anisotropicInterpolationType = 'lanczos3';
% 
%             main_checkAnisotropicInterpolationType();
% 
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
%         end
%         function m_settings_bufferType_wholeImage_callback(hObject, ~)
%             handles = guidata(hObject);
% 
%             main.visualization.bufferType = 'whole';
%             main_checkBufferType();
%             main.data.image = main_loadImage(main.data.cubeRange{1}, main.data.cubeRange{2}, main.data.cubeRange{3});
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
%             main_activateObjects();
% 
%         end
%         function m_settings_bufferType_cubed_callback(hObject, ~)
%             handles = guidata(hObject);
% 
%             main.visualization.bufferType = 'cubed';
%             main_checkBufferType();
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
%             main_activateObjects();
% 
%         end
%         function m_settings_sectionalPlanes_callback(hObject, ~)
%             handles = guidata(hObject);
% 
%             if main.visualization.bSectionalPlanes
%                 main.visualization.bSectionalPlanes = false;
%                 set(handles.m_settings_sectionalPlanes, 'Checked', 'off');
%             else
%                 main.visualization.bSectionalPlanes = true;
%                 set(handles.m_settings_sectionalPlanes, 'Checked', 'on');
%             end
%             main_displayCurrentPosition(main.visualization.currentPosition, '', handles);
% 
%         end
% 
%         function m_overlays_loadOverlay_mFile_callback(hObject, ~)
%             handles = guidata(hObject);
% 
%             % Get the directory
%             folder = uigetdir(main.fileIO.defaultFolder, 'Select m-file');
%             if folder == 0
%                 return;
%             else
%                 main.fileIO.load.folder = folder;
%             end
% 
%         end

        
        %% Property get functions
        function value = get.screenSize(~)
            value = get(0,'ScreenSize');
        end
        function value = get.initialWindowPosition(MainWindow)
            ws = MainWindow.defaultWindowSize;
            if ws(1) > MainWindow.screenSize(3), ws(1) = MainWindow.screenSize(3); end
            if ws(2) > MainWindow.screenSize(4), ws(2) = MainWindow.screenSize(4); end
            value = [MainWindow.screenSize(3)/2 - ws(1)/2, MainWindow.screenSize(4)/2 - ws(2)/2, ws(1), ws(2)];
        end
        
        %% Other functions
        function throwException(~, EX, title)

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
        
        function createImageDisplay(this)

            dispSize = this.visualization.displaySize * 2 + this.visualization.spacerSize;
            this.Display = imshow(zeros(dispSize), 'Parent', this.AxesDisplay);
            set(this.Display, 'ButtonDownFcn', @this.display_buttonDownFcn);
%             set(this.Display, 'uicontextmenu', this.cm_images);

        end

        function displayCurrentPosition(this, type)
            
            position = round(this.visualization.currentPosition);

            if strcmp(type, 'checkForChange');
                if ~this.checkForChange('getset')
                    return
                end
            else
                this.checkForChange('set');
            end

            anisotropic = jh_xyz2rcd(this.image.anisotropic);
%             position = position;
            cubeSize = this.image.cubeSize;

            % Load the desired part of the image (if not already open)
            if strcmp(this.image.bufferType, 'cubed')
                [minVisibleCube, maxVisibleCube] = this.createVisibleSubImage();
            else 
                for i = 1:3
                    minVisibleCube(i) = this.image.cubeRange{i}(1);
                    maxVisibleCube(i) = this.image.cubeRange{i}(2);
                end
            end

            % ---

            n = round(this.visualization.displaySize ./ anisotropic / 2) *2;
            ds = this.visualization.displaySize;

            % Pre-define images 
            imageXY = zeros(n(2), n(1));
            imageXZ = zeros(n(3), n(1));
            imageYZ = zeros(n(2), n(3));
    %         tic
            % Iterate over the loaded cube range
            for x = minVisibleCube(1) : maxVisibleCube(1)
                for y = minVisibleCube(2) : maxVisibleCube(2)
                    for z = minVisibleCube(3) : maxVisibleCube(3)

                        if ~isempty(this.image.image{y+1, x+1, z+1})
                            [imageXY, imageXZ, imageYZ, ~] = jh_overlayObject( ...
                                imageXY, imageXZ, imageYZ, ...
                                position, [x, y, z] .* cubeSize, ...
                                this.image.image{y+1, x+1, z+1}, ...
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
            
            anisotrType = this.visualization.anisotropicInterpolationType;
            if this.image.anisotropic(1) ~= 1 || this.image.anisotropic(2) ~= 1
                imageXY = imresize(imageXY, [ds, ds], anisotrType);
                imageXY(imageXY < 0) = 0;
            end
            if this.image.anisotropic(1) ~= 1 || this.image.anisotropic(3) ~= 1
                imageXZ = imresize(imageXZ, [ds, ds], anisotrType);
                imageXZ(imageXZ < 0) = 0;
            end
            if this.image.anisotropic(2) ~= 1 || this.image.anisotropic(3) ~= 1
                imageYZ = imresize(imageYZ, [ds, ds], anisotrType);
                imageYZ(imageYZ < 0) = 0;
            end
    %         toc


            % White dot in the middle
            imageXY(ds/2, ds/2, :) = 1;
            imageXZ(ds/2, ds/2, :) = 1;
            imageYZ(ds/2, ds/2, :) = 1;

            if this.visualization.bSectionalPlanes
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

            spacer = this.visualization.spacerSize;
%             backColor = this.mainSettings.windowBackColor;
            showImage = ones(ds*2 + spacer, ds*2 + spacer, 3);
%             showImage(:,:,1) = backColor(1);
%             showImage(:,:,2) = backColor(2);
%             showImage(:,:,3) = backColor(3);
            showImage(1:ds, 1:ds, :) = imageXY;
            showImage(1:ds, ds+spacer+1:2*ds+spacer, :) = imageYZ;
            showImage(ds+spacer+1:2*ds+spacer, 1:ds, :) = imageXZ;

            % Show the image
            set(this.Display, 'cdata', showImage);

        end
        function change = checkForChange(this, type)
            persistent position displaySize spacerSize
            change = false;

            if strcmp(type, 'getset') || strcmp(type, 'get')
                if ~isequal(position, this.visualization.currentPosition) ...
                        || displaySize == this.visualization.displaySize ...
                        || spacerSize == this.visualization.spacerSize
                    change = true;
                end            
            end
            if strcmp(type, 'getset') || strcmp(type, 'set')
                position = this.visualization.currentPosition;
                displaySize = this.visualization.displaySize;
                spacerSize = this.visualization.spacerSize;
            end
        end
        
        function [minVisibleCube, maxVisibleCube] = createVisibleSubImage(this)
            persistent cubeMap

            if isempty(cubeMap)
                cubeMap = zeros(size(this.image.image));
            end
            cubeMap = cubeMap - 1;
            cubeMap(cubeMap < 0) = 0;
            
            % These are [x y z]-zero-based
            position = this.visualization.currentPosition;
            cubeSize = this.image.cubeSize;
            cubeRange = this.image.cubeRange;

            minVisible = position - this.visualization.displaySize / 2;
            minVisibleCube = floor(minVisible ./ cubeSize);
            maxVisible = position + this.visualization.displaySize / 2;
            maxVisibleCube = floor(maxVisible ./ cubeSize);
            
            for i = 1:3
                if minVisibleCube(i) < this.image.cubeRange{i}(1)
                    minVisibleCube(i) = cubeRange{i}(1);
                end
                if maxVisibleCube(i) > this.image.cubeRange{i}(2)
                    maxVisibleCube(i) = cubeRange{i}(2);
                end
            end

            for x = minVisibleCube(1) : maxVisibleCube(1)
                for y = minVisibleCube(2) : maxVisibleCube(2)
                    for z = minVisibleCube(3) : maxVisibleCube(3)

                        if isempty(this.image.image{y+1, x+1, z+1})

                            this.image.image{y+1, x+1, z+1} = jh_openCubeRange( ...
                                this.fileIO.loadImageFolder, '', ...
                                'cubeSize', [128 128 128], ...
                                'range', 'oneCube', [x, y, z], ...
                                'dataType', this.mainSettings.prefType, ...
                                'outputType', 'one', ...
                                'fileType', 'auto') / 255;

                        end

                        cubeMap(y+1, x+1, z+1) = this.visualization.bufferDelete;

                    end
                end
            end

            for x = this.image.cubeRange{1}(1) : this.image.cubeRange{1}(2)
                for y = this.image.cubeRange{2}(1) : this.image.cubeRange{2}(2)
                    for z = this.image.cubeRange{3}(1) : this.image.cubeRange{3}(2)
                        if cubeMap(y+1, x+1, z+1) == 0
                            this.image.image{y+1, x+1, z+1} = [];
                        end
                    end
                end
            end

        end

        function activateObjects(this)
        
            if isempty(this.image.image)
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
        
        function imageName = getImageInFocus(this)
        
            imageName = [];
            n = this.visualization.displaySize;

    %         axesHandle  = get(hObject,'Parent');
            coordinates = get(this.AxesDisplay,'CurrentPoint'); 
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

        function checkForOutOfBounds(this)
            
            bounds = this.visualization.currentPosition;
            
            for i = 1:3
                if bounds(i) > (this.image.cubeRange{i}(2) + 1) * this.image.cubeSize(i) - 1;
                    bounds(i) = (this.image.cubeRange{i}(2) + 1) * this.image.cubeSize(i) - 1;
                elseif bounds(i) < (this.image.cubeRange{i}(1)) * this.image.cubeSize(i)
                    bounds(i) = (this.image.cubeRange{i}(1)) * this.image.cubeSize(i);
                end
            end
            
            this.visualization.currentPosition = bounds;

        end

    end
    
   
end
