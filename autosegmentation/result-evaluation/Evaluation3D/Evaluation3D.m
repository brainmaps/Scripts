% Evaluation3D
% version 1.0, 08.2014
%
% written by Julian Hennies
% Max Planck Institute for Medical Research, Heidelberg

function Evaluation3D

% -------------------------------------------------------------------------
% Initializations

% Initialization files
global data
main_init

% Add all folders within the main path
thisPath = mfilename('fullpath');
posSlash = find(thisPath == filesep, 1, 'last');
posSlash = posSlash(1);
thisPath = thisPath(1:posSlash);
addpath(genpath(thisPath));

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
    'Name', 'Evaluation3D', ...
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
    'Callback', @m_file_loadImage_fromCubedData_callback);
handles.m_file_loadResult = uimenu(handles.m_file, ...
    'Label', 'Load result', ...
    'Callback', @m_file_loadResult_callback);
handles.m_file_saveProject = uimenu(handles.m_file, ...
    'Label', 'Save project', ...
    'Callback', @m_file_saveProject_callback, ...
    'Separator', 'on');
handles.m_file_saveProjectAs = uimenu(handles.m_file, ...
    'Label', 'Save project as', ...
    'Callback', @m_file_saveProjectAs_callback);
handles.m_file_loadProject = uimenu(handles.m_file, ...
    'Label', 'Load project', ...
    'Callback', @m_file_loadProject_callback);

% View...
handles.m_view = uimenu(handles.MainWindow, ...
    'Label', 'View');
handles.m_view_displaySize = uimenu(handles.m_view, ...
    'Label', 'Display size');
handles.m_view_displaySize_512 = uimenu(handles.m_view_displaySize, ...
    'Label', '512 pixels', ...
    'Callback', @m_view_displaySize_512_callback);
handles.m_view_displaySize_256 = uimenu(handles.m_view_displaySize, ...
    'Label', '256 pixels', ...
    'Callback', @m_view_displaySize_256_callback);
handles.m_view_displaySize_128 = uimenu(handles.m_view_displaySize, ...
    'Label', '128 pixels', ...
    'Callback', @m_view_displaySize_128_callback);
handles.m_view_displaySize_64 = uimenu(handles.m_view_displaySize, ...
    'Label', '64 pixels', ...
    'Callback', @m_view_displaySize_64_callback);
handles.m_view_displaySize_other = uimenu(handles.m_view_displaySize, ...
    'Label', 'Other', ...
    'Callback', @m_view_displaySize_other, ...
    'Separator', 'on');
handles.m_view_sectionalPlanes = uimenu(handles.m_view, ...
    'Label', 'Sectional planes', ...
    'Callback', @m_view_sectionalPlanes_callback, ...
    'Separator', 'on');
handles.m_view_overlayObjects = uimenu(handles.m_view, ...
    'Label', 'Overlay objects', ...
    'Callback', @m_view_overlayObjects_callback);

% Evaluation...
handles.m_evaluation = uimenu(handles.MainWindow, ...
    'Label', 'Evaluation');
% > Evaluation
    handles.m_evaluation_startEvaluation = uimenu(handles.m_evaluation, ...
        'Label', 'Start Evaluation', ...
        'Callback', @m_evaluation_startEvaluation_callback);
    % -
    handles.m_evaluation_nextLabel = uimenu(handles.m_evaluation, ...
        'Label', '(F) Next label', ...
        'Callback', @m_evaluation_nextLabel_callback, ...
        'Separator', 'on');
    handles.m_evaluation_previousLabel = uimenu(handles.m_evaluation, ...
        'Label', '(D) Previous label', ...
        'Callback', @m_evaluation_previousLabel_callback);
    handles.m_evaluation_nextUnclassified = uimenu(handles.m_evaluation, ...
        'Label', '(G) Next unclassified', ...
        'Callback', @m_evaluation_nextUnclassified_callback);
    % -
    handles.m_evaluation_classifyAs = uimenu(handles.m_evaluation, ...
        'Label', 'Classify as', ...
        'Separator', 'on'); 
    % > Classify as
        for item = 1:length(data.evaluation.availableClasses)
            handles.m_evaluation_classifyAs_class(item) = uimenu(handles.m_evaluation_classifyAs, ...
                'Label', ['(' num2str(item) ') ' data.evaluation.availableClasses{item}], ...
                'Callback', @m_evaluation_classifyAs_class_callback);
        end
        handles.m_evaluation_classifyAs_classNA = uimenu(handles.m_evaluation_classifyAs, ...
            'Label', '(0) N/A', ...
            'Callback', @m_evaluation_classifyAs_classNA_callback, ...
            'Separator', 'on');
    % <
    handles.m_evaluation_oversegmentation = uimenu(handles.m_evaluation, ...
        'Label', 'Oversegmentation');
    % > Oversegmentation
        handles.m_evaluation_oversegmentation_add = uimenu(handles.m_evaluation_oversegmentation, ...
            'Label', '(W) Add', ...
            'Callback', @m_evaluation_oversegmentation_add_callback);
        handles.m_evaluation_oversegmentation_remove = uimenu(handles.m_evaluation_oversegmentation, ...
            'Label', '(Q) Remove', ...
            'Callback', @m_evaluation_oversegmentation_remove_callback);
    % <
    handles.m_evaluation_undersegmentation = uimenu(handles.m_evaluation, ...
        'Label', 'Undersegmentation');
    % > Undersegmentation
        handles.m_evaluation_undersegmentation_add = uimenu(handles.m_evaluation_undersegmentation, ...
            'Label', '(S) Add', ...
            'Callback', @m_evaluation_undersegmentation_add_callback);
        handles.m_evaluation_undersegmentation_remove = uimenu(handles.m_evaluation_undersegmentation, ...
            'Label', '(A) Remove', ...
            'Callback', @m_evaluation_undersegmentation_remove_callback);
    % <
    handles.m_evaluation_properties = uimenu(handles.m_evaluation, ...
        'Label', 'Properties');
    % > Properties
        count = 0;
        for ind1 = 1:length(data.evaluation.availableProperties)
            for ind2 = 1:length(data.evaluation.availableProperties{ind1})
                count = count + 1;
                handles.m_evaluation_properties_props{ind1}{ind2} = uimenu(handles.m_evaluation_properties, ...
                    'Label', ['(Shift+' num2str(count) ') ' data.evaluation.availableProperties{ind1}{ind2}], ...
                    'Callback', @m_evaluation_properties_props_callback);
                if ind2 == 1 && ind1 ~= 1
                    set(handles.m_evaluation_properties_props{ind1}{ind2}, 'Separator', 'on');
                end
            end
        end
    % <
    handles.m_evaluation_addComment = uimenu(handles.m_evaluation, ...
        'Label', '(C) Add comment', ...
        'Callback', @m_evaluation_addComment_callback);
    % -
    handles.m_evaluation_availableClasses = uimenu(handles.m_evaluation, ...
        'Label', 'Available classes', ...
        'Callback', @m_evaluation_availableClasses_callback, ...
        'Separator', 'on');
    % -
    handles.m_evaluation_showOverallResult = uimenu(handles.m_evaluation, ... 
        'Label', 'Show overall result', ...
        'Callback', @m_evaluation_showOverallResult_callback, ...
        'Separator', 'on');
    handles.m_evaluation_exportEvaluation = uimenu(handles.m_evaluation, ...
        'Label', 'Export evaluation', ...
        'Callback', @m_evaluation_exportEvaluation_callback);
    handles.m_evaluation_importEvaluation = uimenu(handles.m_evaluation, ...
        'Label', 'Import evaluation', ...
        'Callback', @m_evaluation_importEvaluation_callback);
    
% Annotation
handles.m_annotation = uimenu(handles.MainWindow, ...
    'Label', 'Annotation');
handles.m_annotation_addObjects = uimenu(handles.m_annotation, ...
    'Label', 'Add objects', ...
    'Callback', @m_annotation_addObjects_callback);

% Navigation
handles.m_navigation = uimenu(handles.MainWindow, ...
    'Label', 'Navigation');
handles.m_navigation_navigateTo = uimenu(handles.m_navigation, ...
    'Label', 'Navigate to');
handles.m_navigation_navigateTo_position = uimenu(handles.m_navigation_navigateTo, ...
    'Label', 'Position', ...
    'Callback', @m_navigation_navigateTo_position_callback);
handles.m_navigation_navigateTo_object = uimenu(handles.m_navigation_navigateTo, ...
    'Label', 'Object', ...
    'Callback', @m_navigation_navigateTo_object_callback);

% -------------------------------------------------------------------------
% Context menu(s)

handles.cm_images = uicontextmenu( ...
    'Callback', @cm_images_callback);
handles.cm_images_remove = uimenu(handles.cm_images, ...
    'Label', 'Remove', ...
    'Callback', @cm_images_remove_callback);


% -------------------------------------------------------------------------
% Set defaults

checkCurrentDisplaySizeInMenu();
if data.visualization.bSectionalPlanes
    set(handles.m_view_sectionalPlanes, 'Checked', 'on');
else
    set(handles.m_view_sectionalPlanes, 'Checked', 'off');
end
if data.visualization.bOverlayObjects
    set(handles.m_view_overlayObjects, 'Checked', 'on');
else
    set(handles.m_view_overlayObjects, 'Checked', 'off');
end

activateObjects();

% -------------------------------------------------------------------------

% Save the structure
guidata(handles.MainWindow, handles);

%% Callbacks

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
        clear -global data
    end

% -------------------------------------------------------------------------
% Image navigation

    function images_buttonDownFcn(hObject, ~)
        handles = guidata(hObject);

        axesHandle  = get(hObject,'Parent');
        data.visualization.mouseDownImage = getImageInFocus(axesHandle);
        data.visualization.lastMousePosition = round(get(handles.axesDisplay, 'CurrentPoint'));
        data.visualization.lastMousePosition = data.visualization.lastMousePosition(2, 1:2);
        data.visualization.mousePositionOnMouseDown = data.visualization.lastMousePosition;
        data.visualization.mouseDownTicHandle = tic;
        data.userInteraction.mouseDownPosition = data.visualization.lastMousePosition;
        switch data.visualization.mouseDownImage
            case 'xy'
                data.userInteraction.mouseDownImagePosition = ceil( ... 
                    data.visualization.currentPosition ...
                    + ( ...
                    - [data.visualization.displaySize, data.visualization.displaySize, 0] / 2 ...
                    + [data.userInteraction.mouseDownPosition 0] ...
                    ) ./ data.visualization.anisotropic);
            case 'xz'
                data.userInteraction.mouseDownImagePosition = ceil( ...
                    data.visualization.currentPosition ...
                    + ( ...
                    - [data.visualization.displaySize, 0, data.visualization.displaySize] / 2 ...
                    - [0, 0, data.visualization.displaySize] ...
                    - [0, 0, data.visualization.spacerSize] ...
                    + [data.userInteraction.mouseDownPosition(1), 0, data.userInteraction.mouseDownPosition(2)] ...
                    ) ./ data.visualization.anisotropic);
            case 'yz'
                data.userInteraction.mouseDownImagePosition = ceil( ... 
                    data.visualization.currentPosition ...
                    + ( ...
                    - [0, data.visualization.displaySize, data.visualization.displaySize] / 2 ...
                    - [0, 0, data.visualization.displaySize] ...
                    - [0, 0, data.visualization.spacerSize] ...
                    + [0, data.userInteraction.mouseDownPosition(2), data.userInteraction.mouseDownPosition(1)] ...
                    ) ./ data.visualization.anisotropic);
        end
        
    end
    function images_imageClickFcn(hObject, ~)
        handles = guidata(hObject);
        
        oversegmentationFromPosition(data.userInteraction.mouseDownImagePosition, handles);
        
    end
    function images_imageDragFcn(hObject, eventdata)
        handles = guidata(hObject);
        
        mouseDownPosition = eventdata.mouseDownPosition;
        mouseUpPosition = eventdata.mouseUpPosition;
        mouseDownImage = eventdata.image;
        
        if data.userInteraction.ctrlDown

            % Add a new object
            if strcmp(mouseDownImage, 'xy')
                centerPosition = round(([mouseUpPosition, 0] + [mouseDownPosition, 0]) / 2) ...
                    + data.visualization.currentPosition ...
                    - [data.visualization.displaySize/2, data.visualization.displaySize/2, 0];
                diameter = mouseUpPosition - mouseDownPosition;
                diameter = sqrt(diameter(1)^2 + diameter(2)^2);
                addObject(centerPosition, round(diameter));
            end
            displayCurrentPosition(data.visualization.currentPosition, '', handles);

        end
    
    end

    function MainWindow_keyPressFcn(hObject, eventdata)
        handles = guidata(hObject);

        switch eventdata.Key
            case 'control'
                data.userInteraction.ctrlDown = true;
            case 'rightarrow'
                data.visualization.currentPosition(1) = data.visualization.currentPosition(1) + 1;
            case 'leftarrow'
                data.visualization.currentPosition(1) = data.visualization.currentPosition(1) - 1;
            case 'downarrow'
                data.visualization.currentPosition(2) = data.visualization.currentPosition(2) + 1;
            case 'uparrow'
                data.visualization.currentPosition(2) = data.visualization.currentPosition(2) - 1;
            case 'c'
                m_evaluation_addComment_callback(handles.m_evaluation_addComment, eventdata);
            case 'd'
                m_evaluation_previousLabel_callback(handles.m_evaluation_previousLabel, eventdata);
            case 'f'
                m_evaluation_nextLabel_callback(handles.m_evaluation_nextLabel, eventdata);
            case 'g'
                m_evaluation_nextUnclassified_callback(handles.m_evaluation_nextUnclassified, eventdata);
            case 'w'
                m_evaluation_oversegmentation_add_callback(handles.m_evaluation_oversegmentation_add, eventdata);
            case 'q'
                m_evaluation_oversegmentation_remove_callback(handles.m_evaluation_oversegmentation_remove, eventdata);
            case 's'
                m_evaluation_undersegmentation_add_callback(handles.m_evaluation_undersegmentation_add, eventdata);
            case 'a'
                m_evaluation_undersegmentation_remove_callback(handles.m_evaluation_undersegmentation_remove, eventdata);
            case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                value = str2double(eventdata.Key);
                if isempty(eventdata.Modifier)
                    if value <= length(data.evaluation.availableClasses) && value ~= 0
                        m_evaluation_classifyAs_class_callback(handles.m_evaluation_classifyAs_class(value), eventdata);
                    elseif value == 0;
                        m_evaluation_classifyAs_classNA_callback(handles.m_evaluation_classifyAs_classNA, eventdata);
                    end
                elseif ~isempty(find(ismember(eventdata.Modifier, 'shift'), 1))
                    total = sum(cellfun(@(x) length(x), data.evaluation.availableProperties));
                    if value ~= 0 && value <= total
                        c = 0;
                        for i = 1:length(data.evaluation.availableProperties)
                            for j = 1:length(data.evaluation.availableProperties{i})
                                c = c+1;
                                if c == value
                                    i1 = i;
                                    i2 = j;
                                end
                            end
                        end
                        m_evaluation_properties_props_callback( ...
                            handles.m_evaluation_properties_props{i1}{i2}, eventdata);
                    end
                end
                
        end
        
        try
            displayCurrentPosition(data.visualization.currentPosition, 'checkForChange', handles);
        catch
        end
    end
    function MainWindow_keyReleaseFcn(hObject, eventdata)
        handles = guidata(hObject);
        
        switch eventdata.Key
            case 'control'
                data.userInteraction.ctrlDown = false;
        end

    end
    function MainWindow_windowButtonMotionFcn(hObject, ~)
        handles = guidata(hObject);
        
        if ~isempty(data.visualization.mouseDownImage)
            lastMousePosition = data.visualization.lastMousePosition;
            thisMousePosition = round(get(handles.axesDisplay, 'CurrentPoint'));
            thisMousePosition = thisMousePosition(2, 1:2);
            diffMousePosition = thisMousePosition-lastMousePosition;
            
            if data.userInteraction.ctrlDown
                
                
            else
                
                % This moves the image
                switch data.visualization.mouseDownImage
                    case 'xy'
                        data.visualization.currentPosition(1) = round(data.visualization.currentPosition(1) - diffMousePosition(1) / data.visualization.anisotropic(1));
                        data.visualization.currentPosition(2) = round(data.visualization.currentPosition(2) - diffMousePosition(2) / data.visualization.anisotropic(2));
                        data.visualization.lastMousePosition = thisMousePosition;
                    case 'xz'
                        data.visualization.currentPosition(1) = round(data.visualization.currentPosition(1) - diffMousePosition(1) / data.visualization.anisotropic(1));
                        data.visualization.currentPosition(3) = round(data.visualization.currentPosition(3) - diffMousePosition(2) / data.visualization.anisotropic(3));
                        data.visualization.lastMousePosition = thisMousePosition;
                    case 'yz'
                        data.visualization.currentPosition(2) = round(data.visualization.currentPosition(2) - diffMousePosition(2) / data.visualization.anisotropic(2));
                        data.visualization.currentPosition(3) = round(data.visualization.currentPosition(3) - diffMousePosition(1) / data.visualization.anisotropic(3));
                        data.visualization.lastMousePosition = thisMousePosition;
                end
                data.visualization.currentPosition = checkForOutOfBounds(data.visualization.currentPosition);
                
            end
            
            displayCurrentPosition(data.visualization.currentPosition, 'checkForChange', handles);
        end
        
    end
    function MainWindow_windowButtonUpFcn(hObject, ~)
        handles = guidata(hObject);
        
        elapsedTimeSinceMouseDown = toc(data.visualization.mouseDownTicHandle);
        thisMousePosition = round(get(handles.axesDisplay, 'CurrentPoint'));
        thisMousePosition = thisMousePosition(2, 1:2);
        mouseDownPosition = data.userInteraction.mouseDownPosition;
        
        mousePosition = round(get(handles.axesDisplay, 'CurrentPoint'));
        mouseMoveDifference = mousePosition(2, 1:2) - data.visualization.mousePositionOnMouseDown;
        mouseMoveDistance = sqrt(mouseMoveDifference(1)^2 + mouseMoveDifference(2)^2);
        if elapsedTimeSinceMouseDown < 0.5 ...
                && ~isempty(data.visualization.mouseDownImage) ...
                && mouseMoveDistance == 0
            
            % This calls the image click event
            ed.image = data.visualization.mouseDownImage;
            images_imageClickFcn(hObject, ed);
            
        elseif ~isempty(data.visualization.mouseDownImage) ...
                && mouseMoveDistance > 0
            
            % This calls a drag event)
            ed.image = data.visualization.mouseDownImage;
            ed.mouseDownPosition = mouseDownPosition;
            ed.mouseUpPosition = thisMousePosition;
            images_imageDragFcn(hObject, ed);
            
        end
        
        data.visualization.mouseDownImage = [];
        
    end
    function MainWindow_windowScrollWheelFcn(hObject, eventdata)
        handles = guidata(hObject);
        
        imageInFocus = getImageInFocus(handles.axesDisplay);
        if ~isempty(imageInFocus)
            
            if data.userInteraction.ctrlDown
                
                data.visualization.displaySize = data.visualization.displaySize + eventdata.VerticalScrollCount * 10;
                if data.visualization.displaySize < 10
                    data.visualization.displaySize = 10;
                end
                checkCurrentDisplaySizeInMenu();
                displayCurrentPosition(data.visualization.currentPosition, 'checkForChange', handles);
                
            else

                switch imageInFocus
                    case 'xy'
                        data.visualization.currentPosition(3) = data.visualization.currentPosition(3) - eventdata.VerticalScrollCount;
                    case 'xz'
                        data.visualization.currentPosition(2) = data.visualization.currentPosition(2) - eventdata.VerticalScrollCount;
                    case 'yz'
                        data.visualization.currentPosition(1) = data.visualization.currentPosition(1) - eventdata.VerticalScrollCount;
                end
                data.visualization.currentPosition = checkForOutOfBounds(data.visualization.currentPosition);
                displayCurrentPosition(data.visualization.currentPosition, 'checkForChange', handles);
                
            end
            
           
        end
        
    end


% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% The menu

    function m_file_loadImage_fromCubedData_callback(hObject, ~)
        handles = guidata(hObject);
        
        % Get the directory
        data.folder = uigetdir(data.defaultFolder, 'Select dataset folder');
        
        % Dialog box to specify the range which will be loaded
        range = inputdlg( ...
            {   'From (x, y, z)', 'To (x, y, z)', ...
                'Anisotropy factors (x, y, z)' ...
            }, ...
            'Specify range...', ...
            1, ...
            {   [num2str(data.cubeRange{1}(1)) ', ' num2str(data.cubeRange{2}(1)) ', ' num2str(data.cubeRange{3}(1))], ...
                [num2str(data.cubeRange{1}(2)) ', ' num2str(data.cubeRange{2}(2)) ', ' num2str(data.cubeRange{3}(2))], ...
                [num2str(data.visualization.anisotropic(1)), ', ' num2str(data.visualization.anisotropic(2)), ', ', num2str(data.visualization.anisotropic(3))] ...
            });
        rangeFrom = strsplit(range{1}, {', ', ','});
        rangeTo = strsplit(range{2}, {', ', ','});
        rangeX = [str2double(rangeFrom{1}) str2double(rangeTo{1})];
        rangeY = [str2double(rangeFrom{2}) str2double(rangeTo{2})];
        rangeZ = [str2double(rangeFrom{3}) str2double(rangeTo{3})];
        anisotropic = strsplit(range{3}, {', ', ','});
        
        data.visualization.anisotropic = cellfun(@(x) str2double(x), anisotropic);
        
        data.image = loadImage(rangeX, rangeY, rangeZ);
            
        data.cubeRange = {rangeX, rangeY, rangeZ};
        
        displayCurrentPosition(data.visualization.currentPosition, '', handles);
        activateObjects();
        
    end
    function m_file_loadResult_callback(hObject, ~)
        handles = guidata(hObject);
        
        % Get the directory
        [data.resultToEvaluate.file, data.resultToEvaluate.path] = uigetfile([data.defaultFolder '*.mat'], 'Select result file');
        
        % Load result file 
        result = load([data.resultToEvaluate.path data.resultToEvaluate.file]);
        data.resultToEvaluate.result = result.result;
        
        activateObjects();
        displayCurrentPosition(data.visualization.currentPosition, '', handles);
        
    end
    function m_file_saveProject_callback(hObject, ~)
        handles = guidata(hObject);
        
        saveProject([]);
        
    end
    function m_file_saveProjectAs_callback(hObject, ~)
        handles = guidata(hObject);
               
        saveProjectAs();
        
    end
    function m_file_loadProject_callback(hObject, ~)
        handles = guidata(hObject);
        
        [file, path] = uigetfile('*.mat', 'Select project file');
        
        if file == 0
            return
        end
        
        load([path, file], 'saveData');
        
        data = saveData;
        data.image = loadImage(data.cubeRange{1}, data.cubeRange{2}, data.cubeRange{3});
        result = load([data.resultToEvaluate.path data.resultToEvaluate.file]);
        data.resultToEvaluate.result = result.result;
        data.fileIO.saveProjectFile = [path file];
        set(handles.MainWindow, 'Name', ['Evaluation3D - ' path file]);
        
        activateObjects();
        displayCurrentPosition(data.visualization.currentPosition, '', handles);
        
    end

    function m_view_displaySize_512_callback(hObject, ~)
        handles = guidata(hObject);
        data.visualization.displaySize = 512;
        checkCurrentDisplaySizeInMenu();
        displayCurrentPosition(data.visualization.currentPosition, '', handles);
    end
    function m_view_displaySize_256_callback(hObject, ~)
        handles = guidata(hObject);
        data.visualization.displaySize = 256;
        checkCurrentDisplaySizeInMenu();
        displayCurrentPosition(data.visualization.currentPosition, '', handles);
    end
    function m_view_displaySize_128_callback(hObject, ~)
        handles = guidata(hObject);
        data.visualization.displaySize = 128;
        checkCurrentDisplaySizeInMenu();
        displayCurrentPosition(data.visualization.currentPosition, '', handles);
    end
    function m_view_displaySize_64_callback(hObject, ~)
        handles = guidata(hObject);
        data.visualization.displaySize = 64;
        checkCurrentDisplaySizeInMenu();
        displayCurrentPosition(data.visualization.currentPosition, '', handles);
    end
    function m_view_displaySize_other(hObject, ~)
        handles = guidata(hObject);
        dispSize = inputdlg({'Display size (even values only)'}, ...
            'Set display size', ...
            1, {num2str(data.visualization.displaySize)});
        data.visualization.displaySize = str2double(dispSize{1});
        checkCurrentDisplaySizeInMenu();
        displayCurrentPosition(data.visualization.currentPosition, '', handles);

    end
    function m_view_sectionalPlanes_callback(hObject, ~)
        handles = guidata(hObject);
        
        if data.visualization.bSectionalPlanes
            data.visualization.bSectionalPlanes = false;
            set(handles.m_view_sectionalPlanes, 'Checked', 'off');
        else
            data.visualization.bSectionalPlanes = true;
            set(handles.m_view_sectionalPlanes, 'Checked', 'on');
        end
        displayCurrentPosition(data.visualization.currentPosition, '', handles);
        
    end
    function m_view_overlayObjects_callback(hObject, ~)
        handles = guidata(hObject);
        
        if data.visualization.bOverlayObjects
            data.visualization.bOverlayObjects = false;
            set(handles.m_view_overlayObjects, 'Checked', 'off');
        else
            data.visualization.bOverlayObjects = true;
            set(handles.m_view_overlayObjects, 'Checked', 'on');
        end
        displayCurrentPosition(data.visualization.currentPosition, '', handles);

    end

    function m_evaluation_startEvaluation_callback(hObject, ~)
        handles = guidata(hObject);

        startEvaluation();
        activateObjects();
        
    end
    function m_evaluation_nextLabel_callback(hObject, ~)
        handles = guidata(hObject);
        
        switchLabelID(1, 'add', data.evaluation.activeGroup);
        
    end
    function m_evaluation_previousLabel_callback(hObject, ~)
        handles = guidata(hObject);
        
        switchLabelID(-1, 'add', data.evaluation.activeGroup);
    end
    function m_evaluation_nextUnclassified_callback(hObject, ~)
        handles = guidata(hObject);
        
        if strcmp(data.evaluation.activeGroup, 'resultToEvaluate')

            % Find next unclassified
            c = data.evaluation.currentLabelID + 1;
            if c > data.evaluation.count
                c = 1;
            end
            i = 1;
            while ~isempty(data.evaluation.result(c).classification.ID) ...
                    && i <= data.evaluation.count

                i = i+1;
                c = c + 1;
                if c > data.evaluation.count
                    c = 1;
                end

            end
            
            count = data.evaluation.count;

        elseif strcmp(data.evaluation.activeGroup, 'manualAnnotation')
            
            c = data.evaluation.currentLabelID + 1;
            if c > data.evaluation.annotationCount
                c = 1;
            end
            i = 1;
            while ~isempty(data.evaluation.annotation(c).classification.ID) ...
                    && i <= data.evaluation.annotationCount

                i = i+1;
                c = c + 1;
                if c > data.evaluation.annotationCount
                    c = 1;
                end

            end
            
            count = data.evaluation.annotationCount;
            
        end
        
        switchLabelID(c, 'jump', data.evaluation.activeGroup);

        if i > count
            msgbox('All objects of this group are classified.', ...
                'Classification complete');
        end
        
    end
    function m_evaluation_classifyAs_class_callback(hObject, ~)
        handles = guidata(hObject);
        
        classID = find(handles.m_evaluation_classifyAs_class == hObject);
        
        cID = data.evaluation.currentLabelID;
        
        if strcmp(data.evaluation.activeGroup, 'resultToEvaluate')
            
            data.evaluation.result(cID).classification.ID = classID;
            data.evaluation.result(cID).classification.name = ...
                data.evaluation.availableClasses{classID};
            
            printEvaluation(data.evaluation.result(cID), [], handles);
        
        elseif strcmp(data.evaluation.activeGroup, 'manualAnnotation')
            
            data.evaluation.annotation(cID).classification.ID = classID;
            data.evaluation.annotation(cID).classification.name = ...
                data.evaluation.availableClasses{classID};
            
            printEvaluation(data.evaluation.annotation(cID), [], handles);

        end
        
        
    end
    function m_evaluation_classifyAs_classNA_callback(hObject, ~)
        handles = guidata(hObject);
       
        cID = data.evaluation.currentLabelID;
        
        if strcmp(data.evaluation.activeGroup, 'resultToEvlaluate')

            data.evaluation.result(cID).classification.ID = [];
            data.evaluation.result(cID).classification.name = [];

            printEvaluation(data.evaluation.result(cID), [], handles);

        elseif strcmp(data.evaluation.activeGroup, 'manualAnnotation')
            
            data.evaluation.annotation(cID).classification.ID = [];
            data.evaluation.annotation(cID).classification.name = [];

            printEvaluation(data.evaluation.annotation(cID), [], handles);

        end
        
        end
    function m_evaluation_oversegmentation_add_callback(hObject, ~)
        handles = guidata(hObject);
        
        if strcmp(data.evaluation.activeGroup, 'resultToEvaluate')
            msgbox('Select oversegmented objects within the image.', ...
                'Oversegmentation', 'help', 'modal');
        end
        
    end
    function m_evaluation_oversegmentation_remove_callback(hObject, ~)
        handles = guidata(hObject);
        
        if strcmp(data.evaluation.activeGroup, 'resultToEvaluate')
            msgbox('Select object within the image.', ...
                'Oversegmentation', 'help', 'modal');
        end
    end
    function m_evaluation_undersegmentation_add_callback(hObject, ~)
        handles = guidata(hObject);
        
        if strcmp(data.evaluation.activeGroup, 'resultToEvaluate')
            cID = data.evaluation.currentLabelID;
            data.evaluation.result(cID).underSegmentation.count = ...
                data.evaluation.result(cID).underSegmentation.count + 1;

            printEvaluation(data.evaluation.result(cID), [], handles);
        end
        
    end
    function m_evaluation_undersegmentation_remove_callback(hObject, ~)
        handles = guidata(hObject);
        
        if strcmp(data.evaluation.activeGroup, 'resultToEvaluate')
            cID = data.evaluation.currentLabelID;
            data.evaluation.result(cID).underSegmentation.count = ...
                data.evaluation.result(cID).underSegmentation.count - 1;
            if data.evaluation.result(cID).underSegmentation.count < 0
                data.evaluation.result(cID).underSegmentation.count = 0;
            end

            printEvaluation(data.evaluation.result(cID), [], handles);
        end
        
    end
    function m_evaluation_properties_props_callback(hObject, ~)
        handles = guidata(hObject);
        
        i1 = 0;
        i2 = 0;
        for i = 1:length(handles.m_evaluation_properties_props)
            hP = handles.m_evaluation_properties_props{i};
            index = false(1, numel(hP));
            for k = 1:numel(hP)
                index(k) = (hP{k} == hObject);
            end
            if ~isempty(find(index, 1))
                i1 = i;
                i2 = find(index);
            end
        end
        
        cID = data.evaluation.currentLabelID;
        
        if strcmp(data.evaluation.activeGroup, 'resultToEvaluate')

            data.evaluation.result(cID).properties.names{i1} = ...
                data.evaluation.availableProperties{i1}{i2};
            data.evaluation.result(cID).properties.IDs(i1) = i2;

            printEvaluation(data.evaluation.result(cID), [], handles);
            
        elseif strcmp(data.evaluation.activeGroup, 'manualAnnotation')
            
            data.evaluation.annotation(cID).properties.names{i1} = ...
                data.evaluation.availableProperties{i1}{i2};
            data.evaluation.annotation(cID).properties.IDs(i1) = i2;

            printEvaluation(data.evaluation.annotation(cID), [], handles);
            
        end            
        
    end
    function m_evaluation_addComment_callback(hObject, ~)
        handles = guidata(hObject);
        
        cID = data.evaluation.currentLabelID;
        
        if isempty(data.evaluation.result(cID).comment)
            data.evaluation.result(cID).comment = '';
        end
        
        comment = inputdlg({'Add comment'}, ...
            ['ID = ' num2str(cID)], ...
            5, {data.evaluation.result(cID).comment});
        
        if strcmp(data.evaluation.activeGroup, 'resultToEvaluate')

            if ~isempty(comment)
                data.evaluation.result(cID).comment = comment{1};
            end
            if strcmp(data.evaluation.result(cID).comment, '')
                data.evaluation.result(cID).comment = [];
            end

            printEvaluation(data.evaluation.result(cID), [], handles);
            
        elseif strcmp(data.evaluation.activeGroup, 'manualAnnotation')            

            if ~isempty(comment)
                data.evaluation.annotation(cID).comment = comment{1};
            end
            if strcmp(data.evaluation.annotation(cID).comment, '')
                data.evaluation.annotation(cID).comment = [];
            end

            printEvaluation(data.evaluation.annotation(cID), [], handles);
            
        end

    end
    function m_evaluation_availableClasses_callback(hObject, ~)
        handles = guidata(hObject);
        
        handles.showAvailableClasses = ShowAvailableClasses(data.evaluation.availableClasses);
        
        guidata(handles.MainWindow, handles);
    end
    function m_evaluation_showOverallResult_callback(hObject, ~)
        handles = guidata(hObject);
        
        [data.evaluation.overallResult, rStr1] = createOverallResult(data.evaluation.result, 'Evaluation of RESULT');
        [data.evaluation.overallAnnotation, rStr2] = createOverallResult(data.evaluation.annotation, 'Evaluation of MANUAL ANNOTATION');
        fprintf([rStr1 rStr2]);
        
    end
    function m_evaluation_exportEvaluation_callback(hObject, ~)
        handles = guidata(hObject);

        m_evaluation_showOverallResult_callback(hObject, []);
        
        [file, path] = uiputfile('*.mat', 'Select target folder', 'Evaluation.mat');
        
        if file == 0
            return
        end
        
        evaluation.result = data.evaluation.result;
        evaluation.overallResult = data.evaluation.overallResult;
        evaluation.annotation = data.evaluation.annotation;
        evaluation.dataSource = data.folder;
        evaluation.cubeRange = data.cubeRange;
        evaluation.segmentationResult = [data.resultToEvaluate.path data.resultToEvaluate.file];
        
        save([path, file], 'evaluation');
        fprintf('\nEvaluation exported.\n\n');
        
    end
    function m_evaluation_importEvaluation_callback(hObject, ~)
        handles = guidata(hObject);
        
        [file, path] = uigetfile('*.mat', 'Select evaluation file');
        
        if file == 0
            return
        end
        
        load([path, file], 'evaluation');
        
        data.evaluation.result = evaluation.result;
        data.evaluation.overallResult = evaluation.overallResult;
        data.evaluation.annotation = evaluation.annotation;
        data.evaluation.annotationCount = length(evaluation.annotation);
        
        data.evaluation.activeGroup = 'resultToEvaluate';
        set(handles.m_annotation_addObjects, 'Checked', 'off');
        switchLabelID(1, 'jump', data.evaluation.activeGroup);
        
    end

    function m_annotation_addObjects_callback(hObject, ~)
        handles = guidata(hObject);
        
        switchGroup([], data.evaluation.activeGroup);
        
    end 

    function m_navigation_navigateTo_position_callback(hObject, ~)
        handles = guidata(hObject);
        
        newPosition = inputdlg({'X:', 'Y:', 'Z:'}, ...
            'Jump to position', ...
            1, ...
            {   num2str(data.visualization.currentPosition(1)), ...
                num2str(data.visualization.currentPosition(2)), ...
                num2str(data.visualization.currentPosition(3))});
            
            data.visualization.currentPosition(1) = str2double(newPosition{1});
            data.visualization.currentPosition(2) = str2double(newPosition{2});
            data.visualization.currentPosition(3) = str2double(newPosition{3});
            
            displayCurrentPosition( ...
                [str2double(newPosition{1}), str2double(newPosition{2}), str2double(newPosition{3})], ...
                '', handles);
        
    end 
    function m_navigation_navigateTo_object_callback(hObject, ~)
        handles = guidata(hObject);
        
    end 

% -------------------------------------------------------------------------
% Context menu(s)

    function cm_images_callback(hObject, ~)
        handles = guidata(hObject);

        % Check on which object the right click was performed
        
        matMouseDown(1) = data.userInteraction.mouseDownImagePosition(2);
        matMouseDown(2) = data.userInteraction.mouseDownImagePosition(1);
        matMouseDown(3) = data.userInteraction.mouseDownImagePosition(3);
        linMouseDown = jh_coordinates2Linear(matMouseDown, size(data.image));
        
        i = 1;
        while i < length(data.visualization.annotatedVisible) ...
                && isempty(find(data.evaluation.annotation(data.visualization.annotatedVisible(i)).voxelList == linMouseDown, 1))
            
            i = i + 1;
            
        end
        
        if ~isempty(find(data.evaluation.annotation(data.visualization.annotatedVisible(i)).voxelList == linMouseDown, 1))
            % Store the found oject ID
            data.userInteraction.selectedObject.ID = data.visualization.annotatedVisible(i);
            data.userInteraction.selectedObject.group = 'manualAnnotation';
            % Enable the remove field in the menu
            set(handles.cm_images_remove, 'Enable', 'on');
        else
            % Disable the remove field in the menu
            set(handles.cm_images_remove, 'Enable', 'off');
        end
            
    end
    function cm_images_remove_callback(hObject, ~)
        handles = guidata(hObject);
        
        ID = data.userInteraction.selectedObject.ID;
        
        if ~isempty(ID)
            
            if ID < length(data.evaluation.annotation)
                data.evaluation.annotation(ID : end-1) = ...
                    data.evaluation.annotation(ID+1 : end);
            end
            data.evaluation.annotation = data.evaluation.annotation(1 : end-1);
            
            data.evaluation.annotationCount = length(data.evaluation.annotation);
            
            displayCurrentPosition(data.visualization.currentPosition, '', handles); 
            
            % Update the display ...
            if strcmp(data.evaluation.activeGroup, 'resultToEvaluate')
                % ... when manual annotation group is inactive
                
                printEvaluation(data.evaluation.result(data.evaluation.currentLabelID), [], handles);
                
            elseif strcmp(data.evaluation.activeGroup, 'manualAnnotation')
                % ... when manual annotation group is active, and ...
                
                if data.evaluation.annotationCount ~= 0
                    % ... there are objects left, and ...
                    
                    if data.evaluation.currentLabelID > data.evaluation.annotationCount
                        % ... the currently active object has the highest
                        %   and now removed ID
                        
                        switchLabelID(data.evaluation.annotationCount, 'jump', 'manualAnnotation', 'keepPosition');
                        
                    else
                        % ... the currently active Object has any ID but
                        %   not the highest, and ...
                        
                        if ID <= data.evaluation.currentLabelID
                            % ... the current ID is higher than the ID of
                            %   the deleted object
                            
                            switchLabelID(data.evaluation.currentLabelID - 1, 'jump', 'manualAnnotation', 'keepPosition');
                            
                        else
                            % ... the current ID is lower than the ID of
                            %   the deleted object
                            
                            printEvaluation(data.evaluation.annotation(data.evaluation.currentLabelID), [], handles);
                            
                        end
                    end
                    
                else
                    % ... there are no objects left
                    
                    switchGroup('resultToEvaluate', [], 'keepPosition');
                    
                end
            end
        end
        
    end

% -------------------------------------------------------------------------
%% Evaluation

    function startEvaluation()
        
        % Create list of all present labels
        data.evaluation.labelList = unique(data.resultToEvaluate.result.result);
        data.evaluation.labelList = data.evaluation.labelList(data.evaluation.labelList > 0);
        
        data.evaluation.count = length(data.evaluation.labelList);
        data.evaluation.annotationCount = 0;
        
        data.evaluation.annotation = [];
        
        createResultStructure();
        
        switchLabelID(1, 'jump', data.evaluation.activeGroup);
        
    end

    function switchLabelID(n, type, group, varargin)

        % Defaults
        jumpToObject = true;
        % Check input
        if ~isempty(varargin)
            i = 0;
            while i < length(varargin)
                i = i+1;

                if strcmp(varargin{i}, 'jumpToObject')
                    jumpToObject = true;
                elseif strcmp(varargin{i}, 'keepPosition')
                    jumpToObject = false;
                end
                
            end

        end

        
        if strcmp(type, 'add')

            % Find new labelID
            if ~isempty(data.evaluation.currentLabelID)
                data.evaluation.currentLabelID = data.evaluation.currentLabelID + n;
            else 
                data.evaluation.currentLabelID = n;
            end

        elseif strcmp(type, 'jump')

            data.evaluation.currentLabelID = n;

        else 

            return;

        end
            
        if strcmp(group, 'resultToEvaluate')

            % Check for correct ID
            if data.evaluation.currentLabelID < 1
                data.evaluation.currentLabelID = 1;
            end
            if data.evaluation.currentLabelID > data.evaluation.count
                data.evaluation.currentLabelID = data.evaluation.count;
            end

            % Get the label
            data.evaluation.currentLabel = data.evaluation.labelList(data.evaluation.currentLabelID);

            % Activate object
            getSelectedObject(data.evaluation.currentLabel, data.evaluation.currentLabelID);

            % Navigate to object
            if jumpToObject
                data.visualization.currentPosition(1) = ...
                    data.evaluation.currentObject.position(1) + round(size(data.evaluation.currentObject.matrix, 2)/2);
                data.visualization.currentPosition(2) = ...
                    data.evaluation.currentObject.position(2) + round(size(data.evaluation.currentObject.matrix, 1)/2);
                data.visualization.currentPosition(3) = ...
                    data.evaluation.currentObject.position(3) + round(size(data.evaluation.currentObject.matrix, 3)/2);
            end

            % Calculate associated objects
            data.evaluation.currentAssociated = [];
            for i = 1:data.evaluation.result(data.evaluation.currentLabelID).overSegmentation.count

                [data.evaluation.currentAssociated(i).matrix, ...
                 data.evaluation.currentAssociated(i).position, ...
                 data.evaluation.currentAssociated(i).voxelList] ...
                    = getObjectByID( ...
                    data.evaluation.result(data.evaluation.currentLabelID).overSegmentation.withObjects(i));

            end

            % Write and print the result structure
            setBasicInformationToResult();
            printEvaluation(data.evaluation.result(data.evaluation.currentLabelID), [], handles)

            displayCurrentPosition(data.visualization.currentPosition, '', handles);

        elseif strcmp(group, 'manualAnnotation')
            
            % Check for correct ID
            if data.evaluation.currentLabelID < 1
                data.evaluation.currentLabelID = 1;
            end
            if data.evaluation.currentLabelID > data.evaluation.annotationCount
                data.evaluation.currentLabelID = data.evaluation.annotationCount;
            end

            % Get the label
            data.evaluation.currentLabel = NaN;
    
            % Activate object
            data.evaluation.currentObject.matrix = data.evaluation.annotation(data.evaluation.currentLabelID).matrix;
            data.evaluation.currentObject.position = data.evaluation.annotation(data.evaluation.currentLabelID).position;
            data.evaluation.currentObject.voxelList = data.evaluation.annotation(data.evaluation.currentLabelID).voxelList;
            
            % Navigate to object
            if jumpToObject
                data.visualization.currentPosition = data.evaluation.annotation(data.evaluation.currentLabelID).centerPosition;
            end

            % No associated objects
            data.evaluation.currentAssociated = [];

            % Write and print the result structure
            printEvaluation(data.evaluation.annotation(data.evaluation.currentLabelID), [], handles)

            displayCurrentPosition(data.visualization.currentPosition, '', handles);

        end
        
    end

    function setBasicInformationToResult()
        
        cID = data.evaluation.currentLabelID;
        
        % Label 
        data.evaluation.result(cID).label = data.evaluation.currentLabel;
        % Matrix
        data.evaluation.result(cID).matrix = data.evaluation.currentObject.matrix;
        % Position 
        data.evaluation.result(cID).position = data.evaluation.currentObject.position;
        % Center position
        [sr, sc, sd] = size(data.evaluation.currentObject.matrix);
        data.evaluation.result(cID).centerPosition = ...
            data.evaluation.currentObject.position + round([sr, sc, sd]/2);
        % VoxelList
        data.evaluation.result(cID).voxelList = ...
            data.evaluation.currentObject.voxelList;
        % Size
        data.evaluation.result(cID).statistics.size = ...
            length(find(data.evaluation.currentObject.matrix > 0));
        % Mean intensity
        data.evaluation.result(cID).statistics.meanIntensity = ...
            mean(data.image(data.evaluation.result(cID).voxelList));
        % Standard deviation
        data.evaluation.result(cID).statistics.stdDeviation = ...
            std(data.image(data.evaluation.result(cID).voxelList));
        
        
    end

    function createResultStructure()
        
        for i = 1:data.evaluation.count

            % Label
            data.evaluation.result(i).label = [];
            % Matrix
            data.evaluation.result(i).matrix = [];
            % Position 
            data.evaluation.result(i).position = [];
            % Center position
            data.evaluation.result(i).centerPosition = [];
            % VoxelList
            data.evaluation.result(i).voxelList = [];
            % Size
            data.evaluation.result(i).statistics.size = [];
            % Mean intensity
            data.evaluation.result(i).statistics.meanIntensity = [];
            % Standard deviation
            data.evaluation.result(i).statistics.stdDeviation = [];

            % Create the complete structure framework ---
            %   Over segmentation
            data.evaluation.result(i).overSegmentation.count = 0;
            data.evaluation.result(i).overSegmentation.withObjects = [];

            %   Under segmentation
            data.evaluation.result(i).underSegmentation.count = 0;

            %   Classification
            data.evaluation.result(i).classification.name = [];
            data.evaluation.result(i).classification.ID = [];
            
            %   Properties
%             data.evaluation.result(i).properties = cellfun(@(x) x(1), data.evaluation.availableProperties);
            data.evaluation.result(i).properties.names = cellfun(@(x) x(1), data.evaluation.availableProperties);
            data.evaluation.result(i).properties.IDs = ones(1, length(data.evaluation.availableProperties));

            %   Comment
            data.evaluation.result(i).comment = [];
            
        end
        
    end

    function printEvaluation(result, title, handles)
        
        if isempty(title)
            
            if strcmp(data.evaluation.activeGroup, 'resultToEvaluate')
                title = 'Evaluation for current object: ';
            elseif strcmp(data.evaluation.activeGroup, 'manualAnnotation')
                title = 'Manually annotated object: ';
            end
            
        end

        if ~isempty(result)
            outStr = [];
            lenTitle = length(title);
            underLine = ones(1, lenTitle) * 45;
            outStr = sprintf([outStr title '\n']);
            outStr = sprintf([outStr underLine '\n\n']);
            
            if strcmp(data.evaluation.activeGroup, 'resultToEvaluate')
                labelCount = data.evaluation.count;
            elseif strcmp(data.evaluation.activeGroup, 'manualAnnotation')
                labelCount = data.evaluation.annotationCount;
            end
            outStr = sprintf([outStr '    ID: ' ...
                num2str(data.evaluation.currentLabelID) ' / ' ...
                num2str(labelCount) '\n']);
            if isfield(result, 'label')
                outStr = sprintf([outStr '    Label: ' num2str(result.label) '\n']);
            end
            outStr = sprintf([outStr '    Position (X,Y,Z): ' ...
                num2str(result.centerPosition(1)) ',' ...
                num2str(result.centerPosition(2)) ',' ...
                num2str(result.centerPosition(3)) '\n\n']);

            outStr = sprintf([outStr 'EVALUATION \n\n']);
            if ~isempty(result.classification.name)
                classificationName = result.classification.name;
            else
                classificationName = 'N/A';
            end
            outStr = sprintf([outStr '    Classification: ' classificationName '\n']);
            if isfield(result, 'overSegmentation')
                if result.overSegmentation.count ~= 0
                    outStr = sprintf([outStr '    Over segmentation \n']);
                    outStr = sprintf([outStr '        Count: ' num2str(result.overSegmentation.count) '\n']);
                    outStr = sprintf([outStr '        With object(s): ' num2str(result.overSegmentation.withObjects(1))]);
                    for i = 2:length(result.overSegmentation.withObjects)
                        outStr = sprintf([outStr ', ' num2str(result.overSegmentation.withObjects(i))]);
                    end
                    outStr = sprintf([outStr '\n']);
                end
            end
            if isfield(result, 'underSegmentation')
                if result.underSegmentation.count ~= 0;
                    outStr = sprintf([outStr '    Under segmentation \n']);
                    outStr = sprintf([outStr '        Count: ' num2str(result.underSegmentation.count) '\n']);
                end
            end
            outStr = sprintf([outStr '    Properties: ' result.properties.names{1} '\n']);
            for i = 2:length(result.properties)
                outStr = sprintf([outStr '                ' result.properties.names{i} '\n']);
            end
            if ~isempty(result.comment)
                if size(result.comment, 1) == 1
                    outStr = sprintf([outStr '    Comment: ' result.comment '\n']);
                else
                    outStr = sprintf([outStr '    Comment: ' result.comment(1, :) '\n']);
                    for i = 2:size(result.comment)
                        outStr = sprintf([outStr '             ' result.comment(i, :) '\n']);
                    end
                end
            end
            outStr = sprintf([outStr '\n']);
            
            if isfield(result, 'statistics')
                outStr = sprintf([outStr 'STATISTICS \n\n']);
                if isfield(result.statistics, 'size')
                    outStr = sprintf([outStr '    Size: ' num2str(result.statistics.size) '\n']);
                end
                if isfield(result.statistics, 'meanIntensity')
                    outStr = sprintf([outStr '    Mean intensity: ' num2str(result.statistics.meanIntensity) '\n']);
                end
                if isfield(result.statistics, 'stdDeviation')
                    outStr = sprintf([outStr '    Standard deviation: ' num2str(result.statistics.stdDeviation) '\n']);
                end
            end

        else
            outStr = 'No results available.';
        end

        set(handles.textEvaluation, 'String', outStr);
        
    end

    % This function retrieves the current Object according to its label and
    % sets data.evaluation.currentObject
    function getSelectedObject(label, labelID)
        
        if ~isempty(labelID) && ~isempty(data.evaluation.result(labelID).matrix)
            
            data.evaluation.currentObject.matrix = data.evaluation.result(labelID).matrix;
            data.evaluation.currentObject.position = data.evaluation.result(labelID).position;
            data.evaluation.currentObject.voxelList = data.evaluation.result(labelID).voxelList;
            
        else
            
            [data.evaluation.currentObject.matrix, ...
                data.evaluation.currentObject.position, ...
                data.evaluation.currentObject.voxelList] ...
                = jh_cutObject(data.resultToEvaluate.result.result, label);
            
        end
        
    end

    function oversegmentationFromPosition(position, handles)
        
        if strcmp(data.evaluation.activeGroup, 'resultToEvaluate')
            % Determine target label 
            targetLabel = data.resultToEvaluate.result.result(position(2), position(1), position(3));

            if targetLabel ~= 0 && targetLabel ~= data.evaluation.currentLabel

                ID1 = data.evaluation.currentLabelID;
                ID2 = find(data.evaluation.labelList == targetLabel);

                if isempty(find(data.evaluation.result(ID1).overSegmentation.withObjects == ID2, 1))
                    setOversegmentation(ID1, ID2, 'combineAll');
                else
                    removeOversegmentation(ID2, ID1, 'removeFromGroup');
                end

                % For visualization and output
                data.evaluation.currentAssociated = [];
                for i = 1:data.evaluation.result(data.evaluation.currentLabelID).overSegmentation.count
                    [data.evaluation.currentAssociated(i).matrix, ...
                     data.evaluation.currentAssociated(i).position, ...
                     data.evaluation.currentAssociated(i).voxelList] ...
                        = getObjectByID( ...
                        data.evaluation.result(data.evaluation.currentLabelID).overSegmentation.withObjects(i));
                end
                displayCurrentPosition(data.visualization.currentPosition, '', handles);
                printEvaluation(data.evaluation.result(ID1), [], handles);

            end
        end
        
    end
    function setOversegmentation(ID1, ID2, type)
        
        % Abort if any ID is empty
        if isempty(ID1) || isempty(ID2)
            return;
        end
        
        % Return if ID1 --> ID2
        if ~isempty(find(data.evaluation.result(ID1).overSegmentation.withObjects == ID2, 1))
            return;
        end
        
        % And ID1 should not be equal to ID2
        if ID1 == ID2
            return;
        end
        
        % Set ID1 --> ID2
        data.evaluation.result(ID1).overSegmentation.withObjects = ...
            [data.evaluation.result(ID1).overSegmentation.withObjects, ...
            ID2];
        data.evaluation.result(ID1).overSegmentation.count = ...
            length(data.evaluation.result(ID1).overSegmentation.withObjects);
        
        % Set ID2 --> ID1
        if strcmp(type, 'revers') || strcmp(type, 'combineAll')
            data.evaluation.result(ID2).overSegmentation.withObjects = ...
                [data.evaluation.result(ID2).overSegmentation.withObjects, ...
                ID1];
            data.evaluation.result(ID2).overSegmentation.count = ...
                length(data.evaluation.result(ID2).overSegmentation.withObjects);
        end
        
        % Set ID1 <--> subID2(:)
        % Set subID1(:) <--> ID2
        % Set subID1(:) <--> subID2(:)
        if strcmp(type, 'combineAll')

            subID1 = data.evaluation.result(ID1).overSegmentation.withObjects;
            subID2 = data.evaluation.result(ID2).overSegmentation.withObjects;
            
            for i = 1:length(subID2)
                setOversegmentation(ID1, subID2(i), 'revers');
            end
            for i = 1:length(subID1)
                setOversegmentation(subID1(i), ID2, 'revers');
                for j = 1:length(subID2)
                    setOversegmentation(subID1(i), subID2(j), 'revers');
                end
            end            
            
        end
        
    end
    function removeOversegmentation(ID1, ID2, type)
        
        % Abort if any ID is empty
        if isempty(ID1) || isempty(ID2)
            return;
        end
        
        % Return if !(ID1 --> ID2)
        if isempty(find(data.evaluation.result(ID1).overSegmentation.withObjects == ID2, 1))
            return;
        end
        
        % And ID1 should not be equal to ID2
        if ID1 == ID2
            return;
        end
        
        % Set ID1 -->! ID2
        data.evaluation.result(ID1).overSegmentation.withObjects = ...
            data.evaluation.result(ID1).overSegmentation.withObjects ...
            (data.evaluation.result(ID1).overSegmentation.withObjects ~= ID2);
        data.evaluation.result(ID1).overSegmentation.count = ...
            length(data.evaluation.result(ID1).overSegmentation.withObjects);
        
        % Set ID2 -->! ID1
        if strcmp(type, 'revers') || strcmp(type, 'combineAll') || strcmp(type, 'removeFromGroup')
            data.evaluation.result(ID2).overSegmentation.withObjects = ...
                data.evaluation.result(ID2).overSegmentation.withObjects ...
                (data.evaluation.result(ID2).overSegmentation.withObjects ~= ID1);
            data.evaluation.result(ID2).overSegmentation.count = ...
                length(data.evaluation.result(ID2).overSegmentation.withObjects);
        end
        
        % Set ID1 !<-->! subID2(:)
        if strcmp(type, 'removeFromGroup')
            
            subID2 = data.evaluation.result(ID2).overSegmentation.withObjects;

            for i = 1:length(subID2)
                removeOversegmentation(ID1, subID2(i), 'revers');
            end
            
        end
        
        % Set ID1 !<-->! subID2(:)
        % Set subID1(:) !<-->! ID2
        % Set subID1(:) !<-->! subID2(:)
        if strcmp(type, 'combineAll')

            subID1 = data.evaluation.result(ID1).overSegmentation.withObjects;
            subID2 = data.evaluation.result(ID2).overSegmentation.withObjects;
            
            for i = 1:length(subID2)
                removeOversegmentation(ID1, subID2(i), 'revers');
            end
            for i = 1:length(subID1)
                removeOversegmentation(subID1(i), ID2, 'revers');
                for j = 1:length(subID2)
                    removeOversegmentation(subID1(i), subID2(j), 'revers');
                end
            end            
            
        end
        
    end

    function [overall, rStr] = createOverallResult(result, title)
        
        classIDs = arrayfun(@(x) {x.classification.ID}, result);
        evaluated = find(cellfun(@(x) ~isempty(x), classIDs));
        
        overall.objects.total = length(result);
        result = result(evaluated);
        
        overall.objects.evaluated = length(evaluated);
        
        % Oversegmentation
        if isfield(result, 'overSegmentation')
            oversegCount = arrayfun(@(x) x.overSegmentation.count, result);
            overall.oversegmentation = 0;
            for i = 1:max(oversegCount)
                overall.oversegmentation = ...
                    overall.oversegmentation + ...
                    i * length(find(oversegCount == i)) / (i * (i+1));
            end
        end

        % Undersegmentation
        if isfield(result, 'underSegmentation')
            overall.undersegmentation = sum(arrayfun(@(x) x.underSegmentation.count, result));
        end
        
        % Classification
        overall.classification.names = data.evaluation.availableClasses;
        overall.classification.count = hist(arrayfun(@(x) x.classification.ID, result), 1:length(data.evaluation.availableClasses));
        
        % Properties
        overall.properties.names = data.evaluation.availableProperties;
        for i = 1:length(data.evaluation.availableProperties)
            overall.properties.count{i} = hist(arrayfun(@(x) x.properties.IDs(i), result), 1:length(data.evaluation.availableProperties{i}));
        end
        
        rStr = createOverallResultString(overall, title);
        
    end
    function rStr = createOverallResultString(overall, title)
        
        rStr = sprintf(['\n' title '\n']);
        underline = ones(1, length(title)) * 45;
        rStr = sprintf([rStr underline '\n\n']);
        rStr = sprintf([rStr 'Total objects: ' num2str(overall.objects.total) '\n']);
        rStr = sprintf([rStr 'Evaluated objects: ' num2str(overall.objects.evaluated) '\n\n']);
        
        if isfield(overall, 'oversegmentation')
            rStr = sprintf([rStr 'Oversegmentation: ' num2str(overall.oversegmentation) '\n']);
        end
        if isfield(overall, 'undersegmentation')
            rStr = sprintf([rStr 'Undersegmentation: ' num2str(overall.undersegmentation) '\n\n']);
        end
        
        rStr = sprintf([rStr 'Classified as: \n' '\t']);
        lengthName = zeros(1, length(overall.classification.names));
        rStr = sprintf([rStr overall.classification.names{1}]);
        lengthName(1) = length(overall.classification.names{1});
        for i = 2:length(overall.classification.names)
            rStr = sprintf([rStr '\t' overall.classification.names{i}]);
            lengthName(i) = length(overall.classification.names{i});
        end
        rStr = sprintf([rStr '\n' '\t']);
        lengthNum = length(num2str(overall.classification.count(1)));
        tStr = ones(1, lengthName(1)) * 32;
        tStr(end-lengthNum+1:end) = num2str(overall.classification.count(1));
        rStr = sprintf([rStr tStr]);
        for i = 2:length(overall.classification.count)
            lengthNum = length(num2str(overall.classification.count(i)));
            tStr = ones(1, lengthName(i)) * 32;
            tStr(end-lengthNum+1:end) = num2str(overall.classification.count(i));
            rStr = sprintf([rStr '\t' tStr]);
        end
        rStr = sprintf([rStr '\n' '\t']);
        rel = overall.classification.count(1)/overall.objects.evaluated;
        rel = rel*100;
        rel = round(rel);
        rel = rel/100;
        lengthNum = length(num2str(rel));
        tStr = ones(1, lengthName(1)) * 32;
        tStr(end-lengthNum+1:end) = num2str(rel);
        rStr = sprintf([rStr tStr]);
        for i = 2:length(overall.classification.count)
            rel = overall.classification.count(i)/overall.objects.evaluated;
            rel = rel*100;
            rel = round(rel);
            rel = rel/100;
            lengthNum = length(num2str(rel));
            tStr = ones(1, lengthName(i)) * 32;
            tStr(end-lengthNum+1:end) = num2str(rel);
            rStr = sprintf([rStr '\t' tStr]);
        end
        rStr = sprintf([rStr '\n\n']);
        
        rStr = sprintf([rStr 'Properties: \n' '\t']);
        for p = 1:length(overall.properties.names)
            lengthName = zeros(1, length(overall.properties.names{p}));
            rStr = sprintf([rStr overall.properties.names{p}{1}]);
            lengthName(1) = length(overall.properties.names{p}{1});
            for i = 2:length(overall.properties.names{p})
                rStr = sprintf([rStr '\t' overall.properties.names{p}{i}]);
                lengthName(i) = length(overall.properties.names{p}{i});
            end
            rStr = sprintf([rStr '\n' '\t']);
            lengthNum = length(num2str(overall.properties.count{p}(1)));
            tStr = ones(1, lengthName(1)) * 32;
            tStr(end-lengthNum+1:end) = num2str(overall.properties.count{p}(1));
            rStr = sprintf([rStr tStr]);
            for i = 2:length(overall.properties.count{p})
                lengthNum = length(num2str(overall.properties.count{p}(i)));
                tStr = ones(1, lengthName(i)) * 32;
                tStr(end-lengthNum+1:end) = num2str(overall.properties.count{p}(i));
                rStr = sprintf([rStr '\t' tStr]);
            end
            rStr = sprintf([rStr '\n' '\t']);
            rel = overall.properties.count{p}(1)/overall.objects.evaluated;
            rel = rel*100;
            rel = round(rel);
            rel = rel/100;
            lengthNum = length(num2str(rel));
            tStr = ones(1, lengthName(1)) * 32;
            tStr(end-lengthNum+1:end) = num2str(rel);
            rStr = sprintf([rStr tStr]);
            for i = 2:length(overall.properties.count{p})
                rel = overall.properties.count{p}(i)/overall.objects.evaluated;
                rel = rel*100;
                rel = round(rel);
                rel = rel/100;
                lengthNum = length(num2str(rel));
                tStr = ones(1, lengthName(i)) * 32;
                tStr(end-lengthNum+1:end) = num2str(rel);
                rStr = sprintf([rStr '\t' tStr]);
            end
            rStr = sprintf([rStr '\n\n']);
        end
        
        
    end

    function switchGroup(targetGroup, fromGroup, varargin)
        
        % Defaults
        jumpToObject = 'jumpToObject';
        % Check input
        if ~isempty(varargin)
            i = 0;
            while i < length(varargin)
                i = i+1;

                if strcmp(varargin{i}, 'jumpToObject')
                    jumpToObject = varargin{i};
                elseif strcmp(varargin{i}, 'keepPosition')
                    jumpToObject = varargin{i};
                end
                
            end

        end
        
        if ~isempty(targetGroup)
            selectGroup = targetGroup;
        elseif ~isempty(fromGroup)
            if strcmp(fromGroup, 'resultToEvaluate')
                selectGroup = 'manualAnnotation';
            elseif strcmp(fromGroup, 'manualAnnotation')
                selectGroup = 'resultToEvaluate';
            end
        else
            selectGroup = 'resultToEvaluate';
        end
        
        data.evaluation.activeGroup = selectGroup;
        
        if strcmp(selectGroup, 'resultToEvaluate')
        
            set(handles.m_annotation_addObjects, 'Checked', 'off');
            printEvaluation(data.evaluation.result(1), [], handles);

        elseif strcmp(selectGroup, 'manualAnnotation')

            if ~isempty(data.evaluation.annotation)
                set(handles.m_annotation_addObjects, 'Checked', 'on');
                printEvaluation(data.evaluation.annotation(1), [], handles);
            else
                switchGroup([], selectGroup);
            end

        end
        
        activateObjects()
        switchLabelID(1, 'jump', data.evaluation.activeGroup, jumpToObject);

    end

    function addObject(centerPosition, diameter)
        
        radius = floor(diameter/2);
        
        data.evaluation.annotationCount = data.evaluation.annotationCount + 1;
        ID = data.evaluation.annotationCount;
        
        anisotropic(1) = data.visualization.anisotropic(2);
        anisotropic(2) = data.visualization.anisotropic(1);
        anisotropic(3) = data.visualization.anisotropic(3);
        matrix = jh_getNeighborhood3D(0, radius, 'anisotropic', anisotropic);
        data.evaluation.annotation(ID).matrix = matrix;
        
        data.evaluation.annotation(ID).centerPosition = centerPosition;
        
        position = centerPosition - ([size(matrix, 2), size(matrix, 1), size(matrix, 3)]-1) / 2;
        data.evaluation.annotation(ID).position = position;
        
        % Get the voxel list
        [objVoxelCoordinates.R, objVoxelCoordinates.C, objVoxelCoordinates.D] = ...
            jh_getCoordinatesFromLinear(find(matrix == 1), size(matrix));
        voxelCoordinates.R = objVoxelCoordinates.R + position(2);
        voxelCoordinates.C = objVoxelCoordinates.C + position(1);
        voxelCoordinates.D = objVoxelCoordinates.D + position(3);
%         voxelList = jh_coordinates2Linear(voxelCoordinates
        voxelCoordinatesList = [voxelCoordinates.R, voxelCoordinates.C, voxelCoordinates.D];
        voxelList = jh_coordinates2Linear(voxelCoordinatesList, size(data.image));
        data.evaluation.annotation(ID).voxelList = voxelList;
        
        % Classification
        data.evaluation.annotation(ID).classification.name = [];
        data.evaluation.annotation(ID).classification.ID = [];

        % Properties
        data.evaluation.annotation(ID).properties.names = cellfun(@(x) x(1), data.evaluation.availableProperties);
        data.evaluation.annotation(ID).properties.IDs = ones(1, length(data.evaluation.availableProperties));

        % Comment
        data.evaluation.annotation(ID).comment = [];

        % Size
        data.evaluation.annotation(ID).statistics.size = ...
            length(voxelList);
%         % Mean intensity
%         data.evaluation.result(ID).statistics.meanIntensity = ...
%             mean(data.image(voxelList));
%         % Standard deviation
%         data.evaluation.result(ID).statistics.stdDeviation = ...
%             std(data.image(voxelList));
        
        % Activate manual annotated objects
        switchGroup('manualAnnotation', [], 'keepPosition');
        switchLabelID(ID, 'jump', data.evaluation.activeGroup, 'keepPosition');
        
    end

%% Other functions

    function imageName = getImageInFocus(axesHandle)
        
        imageName = [];
        n = data.visualization.displaySize;
        
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

    function change = checkForChange()
        change = false;
        
        if ~isequal(data.visualization.atLastDisplayEvent.position, data.visualization.currentPosition) ...
                || data.visualization.atLastDisplayEvent.displaySize ~= data.visualization.displaySize ...
                || data.visualization.atLastDisplayEvent.spacerSize ~= data.visualization.spacerSize
            change = true;
        end
        
    end
    function displayCurrentPosition(position, type, handles)
        
        position = round(position);
        
        if strcmp(type, 'checkForChange') && ~isempty(data.visualization.atLastDisplayEvent);
            if ~checkForChange 
                return
            end
        end
        
        data.visualization.atLastDisplayEvent.position = data.visualization.currentPosition;
        data.visualization.atLastDisplayEvent.displaySize = data.visualization.displaySize;
        data.visualization.atLastDisplayEvent.spacerSize = data.visualization.spacerSize;
        
        anisotropic(1) = data.visualization.anisotropic(2);
        anisotropic(2) = data.visualization.anisotropic(1);
        anisotropic(3) = data.visualization.anisotropic(3);
        
        sPosition(1) = position(2);
        sPosition(2) = position(1);
        sPosition(3) = position(3);
        
        n = round(data.visualization.displaySize ./ anisotropic / 2) *2;
        
        ds = data.visualization.displaySize;
    
        kernel = cell(1, 3);
        kernelP = cell(1, 3);
        pad = zeros(1, 3);
        for i = 1:3
            kernel{i} = -(n(i)/2) + 1 : (n(i)/2);
            kernelP{i} = kernel{i} + sPosition(i);
            pad(i) = n(i) - max(kernelP{i});
            kernelP{i} = kernelP{i}(kernelP{i} >= 1 & kernelP{i} <= size(data.image, i));
        end

        imageXY = zeros(n(1), n(2));
        imageXZ = zeros(n(3), n(2));
        imageYZ = zeros(n(1), n(3));

%         disp('create Image');
%         tic

        imageXY(kernelP{1} + pad(1), kernelP{2} + pad(2)) = ...
            data.image(kernelP{1}, kernelP{2}, sPosition(3));
        imageXZ(kernelP{3} + pad(3), kernelP{2} + pad(2)) = ...
            permute(data.image(sPosition(1), kernelP{2}, kernelP{3}), [3, 2, 1]);
        imageYZ(kernelP{1} + pad(1), kernelP{3} + pad(3)) = ...
            permute(data.image(kernelP{1}, sPosition(2), kernelP{3}), [1, 3, 2]);
        
        if ~isempty(data.resultToEvaluate) ...
                && isempty(data.evaluation.currentLabel) ...
                && data.visualization.bOverlayObjects
            
            % Result overlay (labels are color coded)
            [imageXY, imageXZ, imageYZ] = overlayObject( ...
                imageXY, imageXZ, imageYZ, ...
                sPosition, [0, 0, 0], ...
                data.resultToEvaluate.result.result, ...
                ds, anisotropic, ...
                'range', [0, .67]);
        
        elseif ~isempty(data.resultToEvaluate) ...
                && ~isempty(data.evaluation.currentLabel) ...
                && data.visualization.bOverlayObjects
            
            % Result overlay
            [imageXY, imageXZ, imageYZ] = overlayObject( ...
                imageXY, imageXZ, imageYZ, ...
                sPosition, [1, 1, 1], ...
                data.resultToEvaluate.result.result, ...
                ds, anisotropic, ...
                'oneColor', [0, .25, .1]);
            
            objPos(1) = data.evaluation.currentObject.position(2);
            objPos(2) = data.evaluation.currentObject.position(1);
            objPos(3) = data.evaluation.currentObject.position(3);
            
            % Current object overlay
            [imageXY, imageXZ, imageYZ] = overlayObject( ...
                imageXY, imageXZ, imageYZ, ...
                sPosition, objPos, ...
                data.evaluation.currentObject.matrix, ...
                ds, anisotropic, ...
                'oneColor', [.8 .1 0]);
            
            if data.evaluation.result(data.evaluation.currentLabelID).overSegmentation.count > 0
                
                for i = 1:length(data.evaluation.currentAssociated)
                    
                    objPos(1) = data.evaluation.currentAssociated(i).position(2);
                    objPos(2) = data.evaluation.currentAssociated(i).position(1);
                    objPos(3) = data.evaluation.currentAssociated(i).position(3);

                    % Associated object overlay
                    [imageXY, imageXZ, imageYZ] = overlayObject( ...
                        imageXY, imageXZ, imageYZ, ...
                        sPosition, objPos, ...
                        data.evaluation.currentAssociated(i).matrix, ...
                        ds, anisotropic, ...
                        'oneColor', [.5 0 .2]);

                end
                
            end
            
            if ~isempty(data.evaluation.annotation)
                
                data.visualization.annotatedVisible = [];
                
                for i = 1:data.evaluation.annotationCount
                    
                    objPos(1) = data.evaluation.annotation(i).position(2);
                    objPos(2) = data.evaluation.annotation(i).position(1);
                    objPos(3) = data.evaluation.annotation(i).position(3);
                    
                    % Manually annotated objects
                    [imageXY, imageXZ, imageYZ, visible] = overlayObject( ...
                        imageXY, imageXZ, imageYZ, ...
                        sPosition, objPos, ...
                        data.evaluation.annotation(i).matrix, ...
                        ds, anisotropic, ...
                        'oneColor', [0 .1 .35]);
                   
                    if visible
                        data.visualization.annotatedVisible = [data.visualization.annotatedVisible i];
                    end
                    
                end
                
            end
            
        else
            
            imageXY = jh_convertGray2RGB(imageXY);
            imageXZ = jh_convertGray2RGB(imageXZ);
            imageYZ = jh_convertGray2RGB(imageYZ);
            
        end      
        
%         toc
%         
%         disp('resize images')
%         tic
        % Resize the images
        if ~isequal(size(imageXY), [ds, ds]);
            imageXY = imresize(imageXY, [ds, ds], 'nearest');
        end
        if ~isequal(size(imageXZ), [ds, ds]);
            imageXZ = imresize(imageXZ, [ds, ds], 'nearest');
        end
        if ~isequal(size(imageYZ), [ds, ds]);
            imageYZ = imresize(imageYZ, [ds, ds], 'nearest');
        end
        
%         toc
        

%         disp('add lines')
%         tic

        % White dot in the middle
        imageXY(ds/2, ds/2, :) = 1;
        imageXZ(ds/2, ds/2, :) = 1;
        imageYZ(ds/2, ds/2, :) = 1;
        
        if data.visualization.bSectionalPlanes
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

        spacer = data.visualization.spacerSize;
        backColor = data.window.backColor;
        showImage = ones(ds*2 + spacer, ds*2 + spacer, 3);
        showImage(:,:,1) = backColor(1);
        showImage(:,:,2) = backColor(2);
        showImage(:,:,3) = backColor(3);
        showImage(1:ds, 1:ds, :) = imageXY;
        showImage(1:ds, ds+spacer+1:2*ds+spacer, :) = imageYZ;
        showImage(ds+spacer+1:2*ds+spacer, 1:ds, :) = imageXZ;
        
%         toc
%         
%         disp('show images')
%         tic
        
        % Show images
        h = imshow(showImage, 'Parent', handles.axesDisplay);
        
%         toc
        
        set(h, 'ButtonDownFcn', @images_buttonDownFcn);
        set(h, 'uicontextmenu', handles.cm_images);
%         data.visualization.currentPosition = position;

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

        kernel = cell(1, 3);
        kernelP = cell(1, 3);
        pad = zeros(1, 3);
        for i = 1:3
            kernel{i} = -(n(i)/2) + 1 : (n(i)/2);
            kernelP{i} = kernel{i} + position(i);
            pad(i) = n(i) - max(kernelP{i});
            kernelP{i} = kernelP{i}(kernelP{i} >= 1 & kernelP{i} <= size(objectMatrix, i));
        end


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

    function bounds = checkForOutOfBounds(bounds)
            if bounds(1) > size(data.image, 2)
                bounds(1) = size(data.image, 2);
            elseif bounds(1) < 1
                bounds(1) = 1;
            end
            if bounds(2) > size(data.image, 1)
                bounds(2) = size(data.image, 1);
            elseif bounds(2) < 1
                bounds(2) = 1;
            end
            if bounds(3) > size(data.image, 3)
                bounds(3) = size(data.image, 3);
            elseif bounds(3) < 1
                bounds(3) = 1;
            end

    end

    function checkCurrentDisplaySizeInMenu()
        
        set(handles.m_view_displaySize_512, 'Checked', 'off');
        set(handles.m_view_displaySize_256, 'Checked', 'off');
        set(handles.m_view_displaySize_128, 'Checked', 'off');
        set(handles.m_view_displaySize_64, 'Checked', 'off');
        set(handles.m_view_displaySize_other, 'Checked', 'off');
        switch data.visualization.displaySize
            case 512
                set(handles.m_view_displaySize_512, 'Checked', 'on');
            case 256
                set(handles.m_view_displaySize_256, 'Checked', 'on');
            case 128
                set(handles.m_view_displaySize_128, 'Checked', 'on');
            case 64
                set(handles.m_view_displaySize_64, 'Checked', 'on');
            otherwise
                set(handles.m_view_displaySize_other, 'Checked', 'on');                
        end

    end

    function [object, position, voxelList] = getObjectByID(ID)
        
        label = data.evaluation.labelList(ID);
        [object, position, voxelList] = jh_cutObject(data.resultToEvaluate.result.result, label);
        
    end

    function image = loadImage(rangeX, rangeY, rangeZ)
        
        image = jh_normalizeMatrix( ...
            jh_openCubeRange( ...
                data.folder, '', ...
                'cubeSize', [128 128 128], ...
                'range', rangeX, rangeY, rangeZ, ...
                'dataType', data.prefType, ...
                'outputType', 'one', ...
                'fileType', 'auto'));
    end

    function activateObjects()
        
        if isempty(data.evaluation.currentLabelID)
            % Evaluation inactive
            % -------------------
            
            set(handles.m_file_loadImage, 'Enable', 'on');
            
            if isempty(data.image)
                set(handles.m_navigation, 'Enable', 'off');
                set(handles.m_file_loadResult, 'Enable', 'off');
            else
                set(handles.m_navigation, 'Enable', 'on');
                set(handles.m_file_loadResult, 'Enable', 'on');
            end
            
            set(findall(handles.m_evaluation, '-property', 'Enable'), 'Enable', 'off');
            if isempty(data.image) || isempty(data.resultToEvaluate);
                set(handles.m_evaluation, 'Enable', 'off');
                set(handles.m_evaluation_startEvaluation, 'Enable', 'off');
            else
                set(handles.m_evaluation, 'Enable', 'on');
                set(handles.m_evaluation_startEvaluation, 'Enable', 'on');
            end
            
            set(handles.m_annotation, 'Enable', 'off');
            
        else
            % Evaluation active
            % -----------------
            
            set(handles.m_file_loadImage, 'Enable', 'off');
            set(handles.m_file_loadResult, 'Enable', 'off');
            
            set(findall(handles.m_evaluation, '-property', 'Enable'), 'Enable', 'on');
            set(handles.m_annotation, 'Enable', 'on');
            set(handles.m_navigation, 'Enable', 'on');
            
            if strcmp(data.evaluation.activeGroup, 'resultToEvaluate');
                
                set(handles.m_evaluation_undersegmentation, 'Enable', 'on');
                set(handles.m_evaluation_oversegmentation, 'Enable', 'on');
                
            elseif strcmp(data.evaluation.activeGroup, 'manualAnnotation');
                
                set(handles.m_evaluation_undersegmentation, 'Enable', 'off');
                set(handles.m_evaluation_oversegmentation, 'Enable', 'off');

            end
            
        end 

    end

    function saveProject(file)

        if isempty(file) && isempty(data.fileIO.saveProjectFile)

            saveProjectAs();
            return;
            
        end
        
        if isempty(file)
            usedFile = data.fileIO.saveProjectFile;
        else
            data.fileIO.saveProjectFile = file;
            usedFile = file;
        end
            
        saveData = data;
        saveData = rmfield(saveData, 'image');
        saveData.resultToEvaluate = rmfield(saveData.resultToEvaluate, 'result');
        
        try
            save(usedFile, 'saveData');
            set(handles.MainWindow, 'Name', ['Evaluation3D - ' usedFile]);
            fprintf('\nProject saved.\n\n');

        catch
            data.fileIO.saveProjectFile = [];
            msgbox('The project file could not be saved!', ...
                'File save error', ...
                'error');
        end
        
    end
    function saveProjectAs()
        
        [file, path] = uiputfile('*.mat', 'Select target folder', 'Evaluation.mat');
        
        if file == 0
            return
        end
        
        saveProject([path, file]);
        
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

function l = jh_coordinates2Linear(c, imSize)

l = c(:,1) + (c(:,2)-1)*imSize(1) + (c(:,3)-1)*imSize(1)*imSize(2);

end

function [object, position, voxelList] = jh_cutObject(matrix, label)

voxelList = find(matrix == label);
[r, c, d] = jh_getCoordinatesFromLinear(voxelList, size(matrix));

minR = min(r);
minC = min(c);
minD = min(d);

position = [minC, minR, minD];

newR = r - minR + 1;
newC = c - minC + 1;
newD = d - minD + 1;

maxNewR = max(newR);
maxNewC = max(newC);
maxNewD = max(newD);

object = zeros(maxNewR, maxNewC, maxNewD);
object(jh_coordinates2Linear([newR, newC, newD], [maxNewR, maxNewC, maxNewD])) = 1;

end











