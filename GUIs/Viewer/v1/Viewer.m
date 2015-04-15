% Viewer is a basic GUI-class including xy, xz, and zy displays for easy
% navigation of volumetric image data.
%
% DEPENDENCIES
%   Load the following paths:
%       .../Functions/v1/
%       .../Viewer/v1
%       .../Viewer/v1/classes
%   
%
% NOTES FOR DEVELOPMENT
%
%   For correct image display with respect to anisotropy the property
%   anisotropyFactor found in the visualization class is used. This enables
%   the display to be adjusted if the image is already loaded. The correct
%   anisotropy factors remain stored within the image object (class ImageData).

classdef Viewer < handle
    
    properties
        Figure
%         AxesDisplay
        AxesDisplayXY
        AxesDisplayXZ
        AxesDisplayZY
        PanelMain
        PanelDisplays
        TextDisplay
%         Display
        DisplayXY
        DisplayXZ
        DisplayZY
        
        prefType
        windowBackColor
        windowName
    end
    
    % The menu
    properties (Access = protected)
        
        % File ...
        m_file
        % > File
            m_file_loadImage
            % > Load image
                m_file_loadImage_fromCubedData
            % <
            m_file_loadOverlay
            % > Load overlay
                m_file_loadOverlay_cubedData
                m_file_loadOverlay_imageStack
                m_file_loadOverlay_matFile
            % <
            % -
            m_file_saveProject
            m_file_saveProjectAs
            m_file_loadProject
        % <
        
        % Settings ...
        m_settings
        % > Setting
            m_settings_displaySize
            % > Display size
                m_settings_displaySize_512
                m_settings_displaySize_256
                m_settings_displaySize_128
                m_settings_displaySize_64
                % -
                m_settings_displaySize_other
            % <
            m_settings_anisotropicInterpolationType
            % > Anisotropic interpolation type
                m_settings_anisotropicInterpolationType_nearest
                m_settings_anisotropicInterpolationType_bilinear
                m_settings_anisotropicInterpolationType_bicubic
                m_settings_anisotropicInterpolationType_box
                m_settings_anisotropicInterpolationType_lanczos2
                m_settings_anisotropicInterpolationType_lanczos3
            % <
            m_settings_bufferType
            % > Buffer type
                m_settings_bufferType_wholeImage
                m_settings_bufferType_cubed
            % <
            % -
            m_settings_sectionalPlanes
            m_settings_overlayObjects
            % -
            m_settings_switchImage
            m_settings_images
            % > Images
                m_settings_images_image
            % <
            m_settings_overlays
            % > Overlays
                m_settings_overlays_overlay
                % > Overlay_n
                    m_settings_overlays_overlay_bufferType
                    % > Buffer type
                        m_settings_overlays_overlay_bufferType_whole
                        m_settings_overlays_overlay_bufferType_cubed
                    % <
                    m_settings_overlays_overlay_visible
                    % - 
                    m_settings_overlays_overlay_export
                    % -
                    m_settings_overlays_overlay_close
                % <
            % <
            % -
            m_settings_advanced
        % <
        
        m_tools
        
%         m_overlays
%         m_overlays_loadedOverlays
%         m_overlays_loadOverlay
%         m_overlays_loadOverlay_cubedData
%         m_overlays_loadOverlay_imageStack
%         m_overalys_loadOverlay_mFile
%         m_overlays_addBlank
        
    end
    
    properties (Access = public)
        screenSize
%         windowSize
        initialWindowPosition
        userInput = UserInput;
        debug = false;
    end
    
    % Default values
    properties (SetAccess = public, GetAccess = public)
        visualization
        mainSettings = MainSettings('single', 'DefaultUicontrolBackgroundColor');
        fileIO
    end
    
    properties (Access = public, SetObservable)
        
        image   % Is a cell of ImageData objects
        overlay
       
    end
    
    properties (Constant)
        defaultWindowSize = [800 600];
    end
    
    
    events 
        
        ImageDataChanged
        ImageDataNumberChanged
        
        OverlayDataChanged
        OverlayDataNumberChanged
        
        DisplayMouseDownLeft
        DisplayMouseDownRight
        DisplayMouseUpLeft
        DisplayMouseUpRight
        
        AfterCreation
        
    end
    
   
    methods
        %% Constructor
        
        function MainWindow = Viewer(varargin)
            %
            % SYNOPSIS
            %   h = Viewer();
            %   h = Viewer(___, 'name', name)
            %   h = Viewer(___, 'image', { imageProps } )
            %   h = Viewer(___, 'overlay', { overlayProps } )
            %
            % INPUT
            %   name: Name of the window
            %   imageProps: Properties of an image as used in the
            %       constructor for the ImageData class
            %       E.g.:
            %       {imageProps} = { 'name', 'Image1', 'bufferType','whole', 'sourceType', 'cubed', ... }
            
            %% Check input
            
            % Set defaults
            MainWindow.windowName = 'Viewer';
            addImage = [];
            addOverlay = [];
                
            % Check input
            i = 0;
            while i < length(varargin)
                i = i+1;
        
                if strcmp(varargin{i}, 'name')
                    MainWindow.windowName = varargin{i+1};
                    i = i+1;
                end
                if strcmp(varargin{i}, 'image')
                    try
                        addImage = varargin{i+1};
                    catch
                        return;
                    end
                    i = i+1;
                end
                if strcmp(varargin{i}, 'overlay')
                    try
                        addOverlay = varargin{i+1};
                    catch
                        return;
                    end
                    i = i+1;
                end
                
            end
            
            %% The window
            
            % Main window
            MainWindow.Figure = figure( ...
                'MenuBar', 'none', ...
                'Name', MainWindow.windowName, ...
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
            MainWindow.AxesDisplayXY = axes('Parent', MainWindow.PanelDisplays, ...
                'Tag', 'axesDisplayXY', ...
                'Units', 'normalized', ...
                'Position', [.01, .51, .48, .48]);
            MainWindow.AxesDisplayXZ = axes('Parent', MainWindow.PanelDisplays, ...
                'Tag', 'axesDisplayXZ', ...
                'Units', 'normalized', ...
                'Position', [.01, .01, .48, .48]);
            MainWindow.AxesDisplayZY = axes('Parent', MainWindow.PanelDisplays, ...
                'Tag', 'axesDisplayZY', ...
                'Units', 'normalized', ...
                'Position', [.51, .51, .48, .48]);
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
            
            %% The Menu:
            %% File...
            MainWindow.m_file = uimenu(MainWindow.Figure, ...
                'Label', 'File');
            % > File
                MainWindow.m_file_loadImage = uimenu(MainWindow.m_file, ...
                    'Label', 'Load image');
                % > Load image
                    MainWindow.m_file_loadImage_fromCubedData = uimenu(MainWindow.m_file_loadImage, ...
                        'Label', 'From cubed data', ...
                        'Callback', @MainWindow.m_file_loadImage_fromCubedData_callback, ...
                        'Accelerator', 'i');
                % <
                MainWindow.m_file_loadOverlay = uimenu(MainWindow.m_file, ...
                    'Label', 'Load overlay');
                % > Load overlay
                    MainWindow.m_file_loadOverlay_cubedData = uimenu(MainWindow.m_file_loadOverlay, ...
                        'Label', 'Cubed data', ...
                        'Callback', @MainWindow.m_file_loadOverlay_cubedData_callback);
                    MainWindow.m_file_loadOverlay_imageStack = uimenu(MainWindow.m_file_loadOverlay, ...
                        'Label', 'Image stack', ...
                        'Callback', @MainWindow.m_file_loadOverlay_imageStack_callback, ...
                        'Enable', 'off');
                    MainWindow.m_file_loadOverlay_matFile = uimenu(MainWindow.m_file_loadOverlay, ...
                        'Label', 'Mat-file', ...
                        'Callback', @MainWindow.m_file_loadOverlay_matFile_callback);
                % <
                % -
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
            % <

            %% Settings...
            MainWindow.m_settings = uimenu(MainWindow.Figure, ...
                'Label', 'Settings');
            % > Settings
                MainWindow.m_settings_displaySize = uimenu(MainWindow.m_settings, ...
                    'Label', 'Display size');
                % > Display size
                    MainWindow.m_settings_displaySize_512 = uimenu(MainWindow.m_settings_displaySize, ...
                        'Label', '512 pixels', ...
                        'Callback', @MainWindow.m_settings_displaySize_512_callback);
                    MainWindow.m_settings_displaySize_256 = uimenu(MainWindow.m_settings_displaySize, ...
                        'Label', '256 pixels', ...
                        'Callback', @MainWindow.m_settings_displaySize_256_callback);
                    MainWindow.m_settings_displaySize_128 = uimenu(MainWindow.m_settings_displaySize, ...
                        'Label', '128 pixels', ...
                        'Callback', @MainWindow.m_settings_displaySize_128_callback);
                    MainWindow.m_settings_displaySize_64 = uimenu(MainWindow.m_settings_displaySize, ...
                        'Label', '64 pixels', ...
                        'Callback', @MainWindow.m_settings_displaySize_64_callback);
                    % -
                    MainWindow.m_settings_displaySize_other = uimenu(MainWindow.m_settings_displaySize, ...
                        'Label', 'Other', ...
                        'Callback', @MainWindow.m_settings_displaySize_other_callback, ...
                        'Separator', 'on');
                % <
                MainWindow.m_settings_anisotropicInterpolationType = uimenu(MainWindow.m_settings, ...
                    'Label', 'Anisotropic interpolation type');
                % > Anisotropic interpolation type
                    MainWindow.m_settings_anisotropicInterpolationType_nearest = uimenu(MainWindow.m_settings_anisotropicInterpolationType, ...
                        'Label', 'Nearest', ...
                        'Callback', @MainWindow.m_settings_anisotropicInterpolationType_nearest_callback);
                    MainWindow.m_settings_anisotropicInterpolationType_bilinear = uimenu(MainWindow.m_settings_anisotropicInterpolationType, ...
                        'Label', 'Bilinear', ...
                        'Callback', @MainWindow.m_settings_anisotropicInterpolationType_bilinear_callback);
                    MainWindow.m_settings_anisotropicInterpolationType_bicubic = uimenu(MainWindow.m_settings_anisotropicInterpolationType, ...
                        'Label', 'Bicubic', ...
                        'Callback', @MainWindow.m_settings_anisotropicInterpolationType_bicubic_callback);
                    MainWindow.m_settings_anisotropicInterpolationType_box = uimenu(MainWindow.m_settings_anisotropicInterpolationType, ...
                        'Label', 'Box', ...
                        'Callback', @MainWindow.m_settings_anisotropicInterpolationType_box_callback);
                    MainWindow.m_settings_anisotropicInterpolationType_lanczos2 = uimenu(MainWindow.m_settings_anisotropicInterpolationType, ...
                        'Label', 'Lanczos-2', ...
                        'Callback', @MainWindow.m_settings_anisotropicInterpolationType_lanczos2_callback);
                    MainWindow.m_settings_anisotropicInterpolationType_lanczos3 = uimenu(MainWindow.m_settings_anisotropicInterpolationType, ...
                        'Label', 'Lanczos-3', ...
                        'Callback', @MainWindow.m_settings_anisotropicInterpolationType_lanczos3_callback);
                % <
                MainWindow.m_settings_bufferType = uimenu(MainWindow.m_settings, ...
                    'Label', 'Buffer type');
                % > Buffer Type
                    MainWindow.m_settings_bufferType_wholeImage = uimenu(MainWindow.m_settings_bufferType, ...
                        'Label', 'Whole image', ...
                        'Callback', @MainWindow.m_settings_bufferType_wholeImage_callback);
                    MainWindow.m_settings_bufferType_cubed = uimenu(MainWindow.m_settings_bufferType, ...
                        'Label', 'Cubed', ...
                        'Callback', @MainWindow.m_settings_bufferType_cubed_callback);
                % <
                % -
                MainWindow.m_settings_sectionalPlanes = uimenu(MainWindow.m_settings, ...
                    'Label', 'Sectional planes', ...
                    'Callback', @MainWindow.m_settings_sectionalPlanes_callback, ...
                    'Separator', 'on', ...
                    'Accelerator', 'q');
                MainWindow.m_settings_overlayObjects = uimenu(MainWindow.m_settings, ...
                    'Label', 'Overlay objects', ...
                    'Callback', @MainWindow.m_settings_overlayObjects_callback, ...
                    'Accelerator', 'w');
                % -
                MainWindow.m_settings_switchImage = uimenu(MainWindow.m_settings, ...
                    'Label', 'Switch image', ...
                    'Separator', 'on', ...
                    'Callback', @MainWindow.m_settings_switchImage_callback, ...
                    'Accelerator', 'a');
                MainWindow.m_settings_images = uimenu(MainWindow.m_settings, ...
                    'Label', 'Images', ...
                    'Enable', 'off');
                % >
                    % All loaded images
                    % Menu items are created in function loadNewImage(type)
                % <
                MainWindow.m_settings_overlays = uimenu(MainWindow.m_settings, ...
                    'Label', 'Overlays', ...
                    'Enable', 'off');
                % >
                    % All loaded overlays
                % <
                % -
                MainWindow.m_settings_advanced = uimenu(MainWindow.m_settings, ...
                    'Label', 'Advanced', ...
                    'Separator', 'on', ...
                    'Enable', 'off');
                
            %% Tools...
            MainWindow.m_tools = uimenu(MainWindow.Figure, ...
                'Label', 'Tools');

%             % Overlays...
%             MainWindow.m_overlays = uimenu(MainWindow.Figure, ...
%                 'Label', 'Overlays');
%             % > Overlays
%                 MainWindow.m_overlays_loadedOverlays = uimenu(MainWindow.m_overlays, ...
%                     'Label', 'Loaded overlays');
%                 % -
%                 MainWindow.m_overlays_loadOverlay = uimenu(MainWindow.m_overlays, ...
%                     'Label', 'Load overlay', ...
%                     'Separator', 'on');
%                 % > Load overlay
%                     MainWindow.m_overlays_loadOverlay_cubedData = uimenu(MainWindow.m_overlays_loadOverlay, ...
%                         'Label', 'Cubed data', ...
%                         'Callback', @MainWindow.m_overlays_loadOverlay_cubedData_callback, ...
%                         'Enable', 'off');
%                     MainWindow.m_overlays_loadOverlay_imageStack = uimenu(MainWindow.m_overlays_loadOverlay, ...
%                         'Label', 'Image stack', ...
%                         'Callback', @MainWindow.m_overlays_loadOverlay_imageStack_callback, ...
%                         'Enable', 'off');
%                     MainWindow.m_overalys_loadOverlay_mFile = uimenu(MainWindow.m_overlays_loadOverlay, ...
%                         'Label', 'M-file', ...
%                         'Callback', @MainWindow.m_overlays_loadOverlay_mFile_callback);
%                 % <
%                 MainWindow.m_overlays_addBlank = uimenu(MainWindow.m_overlays, ...
%                     'Label', 'Add blank', ...
%                     'Callback', @MainWindow.m_overlays_addBlank_callback, ...
%                     'Enable', 'off');

            %% Add events
            
            addlistener(MainWindow, 'image', 'PostSet', @MainWindow.image_postSet_cb);
            addlistener(MainWindow, 'overlay', 'PostSet', @MainWindow.overlay_postSet_cb);
            
            %%
            if ~isempty(addImage)
                MainWindow.image{1} = ImageData(addImage{:});
            end
            if ~isempty(addOverlay)
                MainWindow.overlay{1} = OverlayData(addOverlay{:});
            end
            MainWindow.this_afterCreationFcn();
            
        end
        
        
        
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
        
        
    end
    
    methods (Access = protected)    
        %% Display callbacks
        
        function displayXY_buttonDownFcn(this, ~, ~)
            
            this.userInput.mouseEvent.downOn = 'xy';
            % Get the position
            pos = round(get(this.AxesDisplayXY, 'CurrentPoint'));
            this.userInput.mouseEvent.downAt = pos(2, 1:2); clear pos;
            
            this.OnDisplayMouseDown('xy', this.userInput.mouseEvent.downAt);

        end

        function displayXZ_buttonDownFcn(this, ~, ~)
            
            this.userInput.mouseEvent.downOn = 'xz';
            % Get the position
            pos = round(get(this.AxesDisplayXZ, 'CurrentPoint'));
            this.userInput.mouseEvent.downAt = pos(2, 1:2); clear pos;

            this.OnDisplayMouseDown('xz', this.userInput.mouseEvent.downAt);
            
        end

        function displayZY_buttonDownFcn(this, ~, ~)
            
            this.userInput.mouseEvent.downOn = 'zy';
            % Get the position
            pos = round(get(this.AxesDisplayZY, 'CurrentPoint'));
            this.userInput.mouseEvent.downAt = pos(2, 1:2); clear pos;
            
            this.OnDisplayMouseDown('zy', this.userInput.mouseEvent.downAt);
            
        end

        %% MainWindow callbacks
        function this_closeRequestFcn(this, ~, ~)
            
            % Clear all functions with persistent variables
%             clear this.OnImageDataNumberChanged
%             clear this.image_postSet_cb
%             clear this.OnOverlayDataNumberChanged
%             clear this.overlay_postSet_cb
%             
%             clear this.image
            
            clear functions
            
            delete(this.Figure);
%             delete(this.image(:));
%             delete(this.visualization);
            delete(this);
            clear this
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
            
            % Determine the path of this script
            t = mfilename('fullpath');
            posSlash = find(t == filesep, 1, 'last');
            posSlash = posSlash(1);
            thisPath = t(1:posSlash);

            % Add all folders within the main path
            this.fileIO = FileIO(thisPath);
            this.fileIO.thisFolder = thisPath;
            
            % Initialize some stuff
%             this.image = ImageData({[3 6], [3 6], [0 3]}, [], [1 1 3], ...
%                 [128 128 128], 'cubed', 'single', [], [], [0 0 0]);
%             this.image = {ImageData( ...
%                 'cubeRange', {[3 6], [3 6], [0 3]}, ...
%                 'dataType', 'single', ...
%                 'bufferType', 'cubed', ...
%                 'cubeSize', [128 128 128], ...
%                 'anisotropic', [1 1 3], ...
%                 'position', [0 0 0])};
                
            this.visualization = Visualization( ...
                [0, 0, 0], ...  currentPosition
                256, ...        displaySize
                true, ...       bSectionalPlanes
                true, ...       bOverlayObj
                5, ...          spacerSize
                'bicubic', ...  anisotropicInterpolationType
                [1 1 3], ...    anisotropyFactor
                100, ...        bufferDelete
                1 ...           currentImage
                );
            
        end
        function this_afterCreationFcn(this)
            % Check all menu items according to their corresponding values
            this.checkAllMenuItems();
            
            if ~isempty(this.image)
%                 this.image{1}.loadVisibleSubImage(this.visualization); 
                this.image{1}.fillBuffer();
                this.createImageDisplay();
                this.displayCurrentPosition('set');
            end
            
            % Notify the event
            this.OnAfterCreation();
            
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
                
                switch this.userInput.mouseEvent.downOn
                    case 'xy'
                        mousePosition = round(get(this.AxesDisplayXY, 'CurrentPoint'));
                    case 'xz'
                        mousePosition = round(get(this.AxesDisplayXZ, 'CurrentPoint'));
                    case 'zy'
                        mousePosition = round(get(this.AxesDisplayZY, 'CurrentPoint'));
                end

%                 mousePosition = round(get(this.AxesDisplay, 'CurrentPoint'));
                mousePosition = mousePosition(2, 1:2);
                diffMousePosition = mousePosition - persMousePosition;
                persMousePosition = mousePosition;

                if this.userInput.keyEvent.ctrlDown


                else

                    % This moves the image
                    switch this.userInput.mouseEvent.downOn
                        case 'xy'
                            this.visualization.currentPosition(1) ...
                                = round(this.visualization.currentPosition(1) ...
                                - diffMousePosition(1) / this.visualization.anisotropyFactor(1));
                            this.visualization.currentPosition(2) ...
                                = round(this.visualization.currentPosition(2) ...
                                - diffMousePosition(2) / this.visualization.anisotropyFactor(2));
                        case 'xz'
                            this.visualization.currentPosition(1) ...
                                = round(this.visualization.currentPosition(1) ...
                                - diffMousePosition(1) / this.visualization.anisotropyFactor(1));
                            this.visualization.currentPosition(3) ...
                                = round(this.visualization.currentPosition(3) ...
                                - diffMousePosition(2) / this.visualization.anisotropyFactor(3));
                        case 'zy'
                            this.visualization.currentPosition(2) ...
                                = round(this.visualization.currentPosition(2) ...
                                - diffMousePosition(2) / this.visualization.anisotropyFactor(2));
                            this.visualization.currentPosition(3) ...
                                = round(this.visualization.currentPosition(3) ...
                                - diffMousePosition(1) / this.visualization.anisotropyFactor(3));
                    end
                    this.checkForOutOfBounds();

                end

                this.displayCurrentPosition('checkForChange');
            else 
                persMousePosition = [];
            end

        end
        function this_windowButtonUpFcn(this, ~, ~)
            
            if ~isempty(this.userInput.mouseEvent.downOn)
                    
                switch this.userInput.mouseEvent.downOn
                    case 'xy'
                        pos = round(get(this.AxesDisplayXY, 'CurrentPoint'));
                    case 'xz'
                        pos = round(get(this.AxesDisplayXZ, 'CurrentPoint'));
                    case 'zy'
                        pos = round(get(this.AxesDisplayZY, 'CurrentPoint'));
                end

                switch this.userInput.mouseEvent.keySpecifier
                    case 'normal'
                        this.OnDisplayMouseUpLeft(this.userInput.mouseEvent.downOn, pos(2, 1:2));
                    case 'alt'
                        this.OnDisplayMouseUpRight(this.userInput.mouseEvent.downOn, pos(2, 1:2));                    
                end
                
            end
            
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
                        case 'zy'
                            this.visualization.currentPosition(1) = this.visualization.currentPosition(1) - eventdata.VerticalScrollCount;
                    end
                    this.checkForOutOfBounds();
                    this.displayCurrentPosition('checkForChange');

                end


            end

        end

        %% Menu callbacks
        function m_file_loadImage_fromCubedData_callback(this, ~, ~)
            
            this.loadNewImage('cubed');
            
        end
        function m_file_loadOverlay_cubedData_callback(this, ~, ~)
            this.loadNewOverlay('cubed');
        end
        function m_file_loadOverlay_matFile_callback(this, ~, ~)
            
            this.loadNewOverlay('matFile');

        end
        function m_settings_displaySize_512_callback(this, ~, ~)
            this.visualization.displaySize = 512;
            this.createImageDisplay();
            this.checkCurrentDisplaySizeInMenu();
            this.displayCurrentPosition('');
        end
        function m_settings_displaySize_256_callback(this, ~, ~)
            this.visualization.displaySize = 256;
            this.createImageDisplay();
            this.checkCurrentDisplaySizeInMenu();
            this.displayCurrentPosition('');
        end
        function m_settings_displaySize_128_callback(this, ~, ~)
            this.visualization.displaySize = 128;
            this.createImageDisplay();
            this.checkCurrentDisplaySizeInMenu();
            this.displayCurrentPosition('');
        end
        function m_settings_displaySize_64_callback(this, ~, ~)
            this.visualization.displaySize = 64;
            this.createImageDisplay();
            this.checkCurrentDisplaySizeInMenu();
            this.displayCurrentPosition('');
        end
        function m_settings_displaySize_other_callback(this, ~, ~)
            dispSize = inputdlg({'Display size (even values only)'}, ...
                'Set display size', ...
                1, {num2str(this.visualization.displaySize)});
            this.visualization.displaySize = str2double(dispSize{1});
            this.createImageDisplay();
            this.checkCurrentDisplaySizeInMenu();
            this.displayCurrentPosition('');

        end
        function m_settings_anisotropicInterpolationType_nearest_callback(this, ~, ~)
            
            this.visualization.anisotropicInterpolationType = 'nearest';
            this.checkAnisotropicInterpolationType();
            this.displayCurrentPosition('');
            
        end
        function m_settings_anisotropicInterpolationType_bilinear_callback(this, ~, ~)
            
            this.visualization.anisotropicInterpolationType = 'bilinear';
            this.checkAnisotropicInterpolationType();
            this.displayCurrentPosition('');
            
        end
        function m_settings_anisotropicInterpolationType_bicubic_callback(this, ~, ~)
            
            this.visualization.anisotropicInterpolationType = 'bicubic';
            this.checkAnisotropicInterpolationType();
            this.displayCurrentPosition('');
            
        end
        function m_settings_anisotropicInterpolationType_box_callback(this, ~, ~)
            
            this.visualization.anisotropicInterpolationType = 'box';
            this.checkAnisotropicInterpolationType();
            this.displayCurrentPosition('');
            
        end
        function m_settings_anisotropicInterpolationType_lanczos2_callback(this, ~, ~)
            
            this.visualization.anisotropicInterpolationType = 'lanczos2';
            this.checkAnisotropicInterpolationType();
            this.displayCurrentPosition('');
            
        end
        function m_settings_anisotropicInterpolationType_lanczos3_callback(this, ~, ~)
            
            this.visualization.anisotropicInterpolationType = 'lanczos3';
            this.checkAnisotropicInterpolationType();
            this.displayCurrentPosition('');
            
        end
        function m_settings_bufferType_wholeImage_callback(this, ~, ~)
            
            cID = this.visualization.currentImage;
            
            this.image{cID}.bufferType = 'whole';
            this.checkBufferType();
            if ~isempty(this.image{cID}.image);
                this.image{cID}.loadCubedImage();
                this.displayCurrentPosition('');
%                 this.activateObjects();
            end

        end
        function m_settings_bufferType_cubed_callback(this, ~, ~)
            
            cID = this.visualization.currentImage;
            
            this.image{cID}.bufferType = 'cubed';
            this.checkBufferType();
            this.displayCurrentPosition('');
%             this.activateObjects();

        end
        function m_settings_sectionalPlanes_callback(this, ~, ~)

            if this.visualization.bSectionalPlanes
                this.visualization.bSectionalPlanes = false;
                set(this.m_settings_sectionalPlanes, 'Checked', 'off');
            else
                this.visualization.bSectionalPlanes = true;
                set(this.m_settings_sectionalPlanes, 'Checked', 'on');
            end
            this.displayCurrentPosition('');

        end
        function m_settings_switchImage_callback(this, ~, ~)
            
            oldID = this.visualization.currentImage;
            newID = oldID+1;
            if newID > length(this.image)
                newID = 1;
            end
            
            this.switchImage(newID);
            
        end
        function m_settings_images_image_callback(this, src, ~)
            
            % Get image id
            ID = find(this.m_settings_images_image == src);
            
            % Set new image
            this.switchImage(ID);
            
        end
        function m_settings_overlays_overlay_bufferType_cubed_callback(this, src, ~)
            
            % Get overlay id
            ID = find(this.m_settings_overlays_overlay_bufferType_cubed == src);
            
            this.overlay{ID}.bufferType = 'cubed';
            set(this.m_settings_overlays_overlay_bufferType_cubed(ID), 'Checked', 'on');
            set(this.m_settings_overlays_overlay_bufferType_whole(ID), 'Checked', 'off');
            
        end
        function m_settings_overlays_overlay_bufferType_whole_callback(this, src, ~)
            
            % Get overlay id
            ID = find(this.m_settings_overlays_overlay_bufferType_whole == src);
            
            this.overlay{ID}.bufferType = 'whole';
            
            if ~isempty(this.overlay{ID}.image);
                this.overlay{ID}.loadCubedImage();
                this.displayCurrentPosition('');
%                 this.activateObjects();
            end

            set(this.m_settings_overlays_overlay_bufferType_cubed(ID), 'Checked', 'off');
            set(this.m_settings_overlays_overlay_bufferType_whole(ID), 'Checked', 'on');
            this.displayCurrentPosition('');
            
        end
        function m_settings_overlays_overlay_visible_cb(this, src, ~)
            
            % Get overlay id
            ID = find(this.m_settings_overlays_overlay_visible == src);
            
            if this.overlay{ID}.visible
                this.overlay{ID}.visible = false;
                set(this.m_settings_overlays_overlay_visible, 'checked', 'off');
            else
                this.overlay{ID}.visible = true;
                set(this.m_settings_overlays_overlay_visible, 'checked', 'on');
            end

        end
        function m_settings_overlays_overlay_export_cb(this, src, ~)
            
            % Get overlay id
            ID = this.m_settings_overlays_overlay_export == src;
            
            this.overlay{ID}.exportImageDlg();
            
        end
        
        %% Property callbacks
        
        function image_postSet_cb(this, ~, ~)
            
            % Detect change in the number of imageData objects
            persistent noImData
            if isempty(noImData), noImData = 0; end
            
            if noImData ~= length(this.image)
                this.OnImageDataNumberChanged();
                noImData = length(this.image);
            end
  
        end
        function image_imageChanged_cb(this, ~, ~)
            
            this.OnImageDataChanged();
            
        end
        
        function overlay_postSet_cb(this, ~, ~)
            
            % Detect change in the number of imageData objects
            persistent noOvData
            if isempty(noOvData), noOvData = 0; end
            
            if noOvData ~= length(this.overlay)
                this.OnOverlayDataNumberChanged();
                noOvData = length(this.overlay);
            end
            
        end
        function overlay_imageChanged_cb(this, ~, ~)
            
            this.OnOverlayDataChanged();
            
        end
        
    end
    
    % Event functions
    methods (Access = private)
       
        function OnImageDataNumberChanged(this)
            persistent noImData
            if isempty(noImData), noImData = 0; end
            
            % Only invoke this if an image was added
            if noImData < length(this.image)
                addlistener(this.image{end}, 'ImageChanged', @this.image_imageChanged_cb);
            end
            
            
            % Add image to menu
            this.m_settings_images_image(length(this.image)) = uimenu(this.m_settings_images, ...
                'Label', this.image{length(this.image)}.name, ...
                'Callback', @this.m_settings_images_image_callback);
            set(this.m_settings_images, 'Enable', 'on');
            
            % Check menu item of the bufferType
            this.checkBufferType();
            % Check current image
            this.checkVisibleImage();
%             
%             this.createImageDisplay();
            try
                this.displayCurrentPosition('');
            catch
            end
            this.activateObjects();
            
            % Call the event
            notify(this, 'ImageDataNumberChanged', ImageDataNoChangeEventData(noImData, length(this.image)));
            
            noImData = length(this.image);
            
        end
        
        function OnImageDataChanged(this)
            
            % Check menu item of the bufferType
            this.checkBufferType;
            % Check current image
            this.checkVisibleImage();
            
            try
                this.displayCurrentPosition('');
            catch
            end
            
           % Call the event
            notify(this, 'ImageDataChanged');
            
        end
        
        function OnOverlayDataNumberChanged(this)
            
            persistent noOvData
            if isempty(noOvData), noOvData = 0; end
            
            if noOvData < length(this.overlay)
                addlistener(this.overlay{end}, 'ImageChanged', @this.overlay_imageChanged_cb);
            end
            
            noOvData = length(this.overlay);
            
             % Add overlay to menu
            this.m_settings_overlays_overlay(length(this.overlay)) = uimenu(this.m_settings_overlays, ...
                'Label', this.overlay{length(this.overlay)}.name);
            this.m_settings_overlays_overlay_bufferType(length(this.overlay)) = uimenu(this.m_settings_overlays_overlay(length(this.overlay)), ...
                'Label', 'BufferType');
            this.m_settings_overlays_overlay_bufferType_cubed(length(this.overlay)) = uimenu(this.m_settings_overlays_overlay_bufferType(length(this.overlay)), ...
                'Label', 'Cubed', ...
                'Callback', @this.m_settings_overlays_overlay_bufferType_cubed_callback);
            this.m_settings_overlays_overlay_bufferType_whole(length(this.overlay)) = uimenu(this.m_settings_overlays_overlay_bufferType(length(this.overlay)), ...
                'Label', 'Whole', ...
                'Callback', @this.m_settings_overlays_overlay_bufferType_whole_callback);
            this.m_settings_overlays_overlay_visible(length(this.overlay)) = uimenu(this.m_settings_overlays_overlay(length(this.overlay)), ...
                'Label', 'Visible', ...
                'Callback', @this.m_settings_overlays_overlay_visible_cb, ...
                'Checked', 'on');
            this.m_settings_overlays_overlay_export(length(this.overlay)) = uimenu(this.m_settings_overlays_overlay(length(this.overlay)), ...
                'Label', 'Export', ...
                'Callback', @this.m_settings_overlays_overlay_export_cb, ...
                'Separator', 'on');
            this.m_settings_overlays_overlay_close(length(this.overlay)) = uimenu(this.m_settings_overlays_overlay(length(this.overlay)), ...
                'Label', 'Close', ...
                'Separator', 'on', ...
                'Callback', @this.m_settings_overlays_overlay_close_callback, ...
                'Enable', 'off');
            
            set(this.m_settings_overlays, 'Enable', 'on');
            
            try
                this.displayCurrentPosition('');
            catch
            end
            this.activateObjects();
            
            % Call this event
            notify(this, 'OverlayDataNumberChanged');
            
       end
        
        function OnOverlayDataChanged(this)
            
            try
                this.displayCurrentPosition('');
            catch
            end
           
            % Call this event
            notify(this, 'OverlayDataChanged');
            
        end
        
        function OnDisplayMouseDown(this, display, position)
            
            % Get the mouse button
            bttn = get(this.Figure, 'SelectionType');
            this.userInput.mouseEvent.keySpecifier = bttn;
            
            % Call the according event
            switch bttn
                case 'normal'
                    this.OnDisplayMouseDownLeft(display, position);
                case 'alt'
                    this.OnDisplayMouseDownRight(display, position);
            end

        end
        function OnDisplayMouseDownLeft(this, display, position)
            
            notify(this, 'DisplayMouseDownLeft', DisplayEventData(display, position));
            
        end
        function OnDisplayMouseDownRight(this, display, position)
            
            notify(this, 'DisplayMouseDownRight', DisplayEventData(display, position));
            
        end
        
        function OnDisplayMouseUp(this, position)
            
        end
        function OnDisplayMouseUpLeft(this, display, position)
            
            notify(this, 'DisplayMouseUpLeft', DisplayEventData(display, position));
            
        end
        function OnDisplayMouseUpRight(this, display, position)
            
            notify(this, 'DisplayMouseUpRight', DisplayEventData(display, position));
            
        end
        
        function OnAfterCreation(this)
            
            notify(this, 'AfterCreation');
            
        end
        
    end
    
    methods (Access = protected)
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

            this.DisplayXY = imshow(zeros(this.visualization.displaySize), 'Parent', this.AxesDisplayXY);
            set(this.DisplayXY, 'ButtonDownFcn', @this.displayXY_buttonDownFcn);

            this.DisplayXZ = imshow(zeros(this.visualization.displaySize), 'Parent', this.AxesDisplayXZ);
            set(this.DisplayXZ, 'ButtonDownFcn', @this.displayXZ_buttonDownFcn);
            
            this.DisplayZY = imshow(zeros(this.visualization.displaySize), 'Parent', this.AxesDisplayZY);
            set(this.DisplayZY, 'ButtonDownFcn', @this.displayZY_buttonDownFcn);

        end

        function displayCurrentPosition(this, type)
            %%
            
            % Abort if nothing has changed
            if strcmp(type, 'checkForChange');
                if ~this.checkForChange('getset')
                    return
                end
            else
                this.checkForChange('set');
            end

            %% Start with the background image:
            
            % This is the currently visible image (note that only one
            % background image can be visible, here no overlay is possible
            % - or at least not yet...)
            im = this.visualization.currentImage;
            
            % Load the desired part of the image (if not already open)
            if strcmp(this.image{im}.bufferType, 'cubed')
                this.image{im}.loadVisibleSubImage(this.visualization);
            else
                
            end
            
            n = round(this.visualization.displaySize ./ this.visualization.anisotropyFactor / 2) *2;
            
            % Pre-define image planes (filled with zeros)
            planes = DisplayPlanes( ...
                zeros(n(2), n(1)), ...  % xy
                zeros(n(3), n(1)), ...  % xz
                zeros(n(2), n(3)) ...   % zy
                );

            % Draw the background image
            [planes] = this.image{im}.createDisplayPlanes ...
                (planes, this.visualization, 'gray', 'replace');

            %% Let's get to the overlays
            
            if ~isempty(this.overlay)
                % Add overlays
                imType = 'gray';
                for i = length(this.overlay):-1:1
                    
                    [planes, ~] = this.overlay{i}.overlayObject( ...
                        planes, ...
                        this.visualization, ...
                        imType, ...
                        n);

                    imType = 'rgb';
                end
            end
            
            % Convert to RGB
            planes.toRGB();
            

            ds = this.visualization.displaySize;

            %% Post-processing of the planes 
            
            % Resize the images
            planes.resize( ...
                this.visualization.anisotropyFactor, ...
                ds, ...
                this.visualization.anisotropicInterpolationType ...
                );
            planes.XY(planes.XY > 1) = 1;
            planes.XZ(planes.XZ > 1) = 1;
            planes.ZY(planes.ZY > 1) = 1;
            
            % White dot in the middle
            planes.addWhiteDot([ds, ds, ds]);

            if this.visualization.bSectionalPlanes
%                 % Red, greed and blue lines and border around each image
                planes.addSectionalPlanes([ds, ds, ds]);

            end
            
            %% Show the image
%             set(this.Display, 'cdata', showImage);
%             tic
            set(this.DisplayXY, 'cdata', planes.XY);
            set(this.DisplayXZ, 'cdata', planes.XZ);
            set(this.DisplayZY, 'cdata', planes.ZY);
%             toc

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
        
        function activateObjects(this)
        
%             if isempty(this.image.image)
%                 % No loaded image
% 
% 
%             end
% 
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
        
        function [imageName, position] = getImageInFocus(this)
        
            imageName = [];
            position = [];
            n = this.visualization.displaySize;
            
            % Check if image XY is in focus
            coord = get(this.AxesDisplayXY, 'CurrentPoint');
            coord = round(coord - [1e-10, 0, 0; 0, 0, 0]);
            if coord(1) > 0 && coord(1) <= n && ...
                    coord(3) > 0 && coord(3) <= n
                imageName = 'xy';
                %position = [100 100 100];
                return;
            end
            
            % Check if image xz is in focus
            coord = get(this.AxesDisplayXZ, 'CurrentPoint');
            coord = round(coord - [1e-10, 0, 0; 0, 0, 0]);
            if coord(1) > 0 && coord(1) <= n && ...
                    coord(3) > 0 && coord(3) <= n
                imageName = 'xz';
                return;
            end
            
            % Check if image zy is in focus
            coord = get(this.AxesDisplayZY, 'CurrentPoint');
            coord = round(coord - [1e-10, 0, 0; 0, 0, 0]);
            if coord(1) > 0 && coord(1) <= n && ...
                    coord(3) > 0 && coord(3) <= n 
                imageName = 'zy';
                return;
            end
            
            return;
            
        end

        function checkForOutOfBounds(this)
            
            bounds = this.visualization.currentPosition;
            cID = this.visualization.currentImage;
            
            for i = 1:3
                if bounds(i) > this.image{cID}.totalImageSize(i)-1
                    bounds(i) = this.image{cID}.totalImageSize(i)-1;
                elseif bounds(i) < 0
                    bounds(i) = 0;
                end
            end
            
            this.visualization.currentPosition = bounds;

        end
        
        function checkAllMenuItems(this)
            this.checkCurrentDisplaySizeInMenu();
            this.checkAnisotropicInterpolationType();
            
            % This is now performed on demand for each loaded image
            % individually:
%             this.checkBufferType(); 

            if this.visualization.bSectionalPlanes
                set(this.m_settings_sectionalPlanes, 'Checked', 'on');
            else
                set(this.m_settings_sectionalPlanes, 'Checked', 'off');
            end
            if this.visualization.bOverlayObjects
                set(this.m_settings_overlayObjects, 'Checked', 'on');
            else
                set(this.m_settings_overlayObjects, 'Checked', 'off');
            end

        end
        function checkCurrentDisplaySizeInMenu(this)

            set(this.m_settings_displaySize_512, 'Checked', 'off');
            set(this.m_settings_displaySize_256, 'Checked', 'off');
            set(this.m_settings_displaySize_128, 'Checked', 'off');
            set(this.m_settings_displaySize_64, 'Checked', 'off');
            set(this.m_settings_displaySize_other, 'Checked', 'off');
            switch this.visualization.displaySize
                case 512
                    set(this.m_settings_displaySize_512, 'Checked', 'on');
                case 256
                    set(this.m_settings_displaySize_256, 'Checked', 'on');
                case 128
                    set(this.m_settings_displaySize_128, 'Checked', 'on');
                case 64
                    set(this.m_settings_displaySize_64, 'Checked', 'on');
                otherwise
                    set(this.m_settings_displaySize_other, 'Checked', 'on');                
            end

        end
        function checkAnisotropicInterpolationType(this)

            set(this.m_settings_anisotropicInterpolationType_nearest, 'Checked', 'off');
            set(this.m_settings_anisotropicInterpolationType_bilinear, 'Checked', 'off');
            set(this.m_settings_anisotropicInterpolationType_bicubic, 'Checked', 'off');
            set(this.m_settings_anisotropicInterpolationType_box, 'Checked', 'off');
            set(this.m_settings_anisotropicInterpolationType_lanczos2, 'Checked', 'off');
            set(this.m_settings_anisotropicInterpolationType_lanczos3, 'Checked', 'off');

            switch this.visualization.anisotropicInterpolationType
                case 'nearest'
                    set(this.m_settings_anisotropicInterpolationType_nearest, 'Checked', 'on');
                case 'bilinear'
                    set(this.m_settings_anisotropicInterpolationType_bilinear, 'Checked', 'on');
                case 'bicubic'
                    set(this.m_settings_anisotropicInterpolationType_bicubic, 'Checked', 'on');
                case 'box'
                    set(this.m_settings_anisotropicInterpolationType_box, 'Checked', 'on');
                case 'lanczos2'
                    set(this.m_settings_anisotropicInterpolationType_lanczos2, 'Checked', 'on');
                case 'lanczos3'
                    set(this.m_settings_anisotropicInterpolationType_lanczos3, 'Checked', 'on');
            end                

        end
        function checkBufferType(this)
            set(this.m_settings_bufferType_wholeImage, 'Checked', 'off');
            set(this.m_settings_bufferType_cubed, 'Checked', 'off');
            
            cID = this.visualization.currentImage;
            
            switch this.image{cID}.bufferType
                case 'whole'
                    set(this.m_settings_bufferType_wholeImage, 'Checked', 'on');
                case 'cubed'
                    set(this.m_settings_bufferType_cubed, 'Checked', 'on');
            end
        end
        function checkVisibleImage(this)
            
            % Check the menu entry
            ID = this.visualization.currentImage;
            for i = 1:length(this.m_settings_images_image)
                set(this.m_settings_images_image(i), 'Checked', 'off');
            end
            set(this.m_settings_images_image(ID), 'Checked', 'on');
            
            % Write name to window
            set(this.Figure, 'Name', [this.windowName ' @ (#' num2str(ID) ') ' this.image{ID}.name]);
            
        end
        
       	function loadNewImage(this, type)
            
            if strcmp(type, 'cubed')
                % Load the image
                success = this.loadImageFromCubedData();
                if success ~= 1 
                    return;
                end
            end

        end
        function success = loadImageFromCubedData(this)
            
            % Initialize an image
            this.image = [this.image, ...
                {ImageData( ...
                'cubeRange', {[3 6], [3 6], [0 3]}, ...
                'dataType', 'single', ...
                'bufferType', 'cubed', ...
                'cubeSize', [128 128 128], ...
                'anisotropic', [1 1 3], ...
                'position', [0 0 0], ...
                'name', ['ImageData' num2str(length(this.image)+1)], ...
                'sourceFolder', this.fileIO.defaultFolder, ...
                'sourceType', 'cubed')}];

            
            % Set the new image for display
            this.visualization.currentImage = length(this.image);
            
            % Anisotropy also has to be set for display
            this.visualization.anisotropyFactor = this.image{end}.anisotropic;
            
            % Selects data using a dialog window; returns 1 for success
            success = this.image{end}.loadDataDlg();
            if success ~= 1
                % Delete last entry if no image was loaded
                this.image = this.image(1:end-1);
                return;
            end

        end
        
        function loadNewOverlay(this, type)
            
            if strcmp(type, 'matFile')
                success = this.loadOverlayFromMatFile();
            elseif strcmp(type, 'cubed')
                success = this.loadOverlayFromCubedData();
            end
            if success ~= 1
                return;
            end

        end
        function success = loadOverlayFromCubedData(this)
            
            % Add entry to the overlays
            this.overlay = [this.overlay, ...
                { OverlayData( ...
                    'anisotropic', this.image{1}.anisotropic, ...
                    'dataType', 'single', ...
                    'bufferType', 'cubed', ...
                    'sourceFolder', this.fileIO.defaultFolder, ...
                    'sourceType', 'cubed', ...
                    'position', [0, 0, 0], ...
                    'cubeSize', [128,128,128], ...
                    'name', ['Overlay' num2str(length(this.overlay)+1)], ...
                    'cubeRange', {[0 3], [0 3], [0 3]} ) }];
                
            % Load the image
            success = this.overlay{end}.loadDataDlg();
            if success ~= 1
                % Delete last entry if no image was loaded
                this.overlay = this.overlay(1:end-1);
                return;
            end
            
           
        end
        function success = loadOverlayFromMatFile(this)
            
            % Add entry to the overlays
            this.overlay{length(this.overlay) + 1} ...
                = OverlayData( ...
                    'anisotropic', this.image{1}.anisotropic, ...
                    'bufferType', this.image{1}.bufferType, ...
                    'sourceFolder', this.fileIO.defaultFolder, ...
                    'sourceType', 'matFile', ...
                    'position', [0, 0, 0], ...
                    'cubeSize', [128,128,128], ...
                    'name', ['Overlay' num2str(length(this.overlay)+1)], ...
                    'cubeRange', {[0 3], [0 3], [0 3]} );
            
            % Load the image
            success = this.overlay{end}.loadDataDlg();
            if success ~= 1
                % Delete last entry if no image was loaded
                this.overlay = this.overlay(1:end-1);
                return;
            end

        end
        
        function switchImage(this, newID)
            
            % Get currentID
            cID = this.visualization.currentImage;
            
            % Clear image buffer of the old image
            this.image{cID}.clearBuffer();
            
            % Switch to the new image
            this.visualization.currentImage = newID;
            this.visualization.anisotropyFactor = this.image{newID}.anisotropic;
            
            this.displayCurrentPosition('set');
            this.checkBufferType();
            this.checkVisibleImage();

        end


    end
    
    methods (Static)
        
        
    end
   
end
