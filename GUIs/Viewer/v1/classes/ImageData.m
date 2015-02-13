classdef ImageData < handle
    
    properties
        cubeRange       % [x, y, z]
        image
        anisotropic     % [x, y, z]
        cubeSize        % [x, y, z]
        totalImageSize  % [x, y, z]
        bufferType      % 'cubed', 'whole'
        dataType        % 'single', 'double', 'integer', ...
        sourceFolder
        sourceType      % 'cubed', 'stack', 'matFile'
        position        % [x, y, z]
        varName         % Name of the variable within a .mat file
    end
    
    properties (SetAccess = protected)
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % Check if this is really needed!
        minLoadedCube
        maxLoadedCube
        
    end
        
    methods
        
        %% Constructor
        function dat = ImageData(varargin)
            % ImageData is designed as a subclass used in Viewer to store
            % image data and associated properties of the data set. 
            %
            % SYNOPSIS
            %   handle = ImageData()
            %   handle = ImageData(___, 'image', image)
            %   handle = ImageData(___, 'cubeRange', cubeRange)
            %   handle = ImageData(___, 'cubeSize', cubeSize)
            %   handle = ImageData(___, 'bufferType', bufferType)
            %   handle = ImageData(___, 'dataType', dataType)
            %   handle = ImageData(___, 'sourceType', sourceType)
            %   handle = ImageData(___, 'sourceFolder', sourceFolder)
            %   handle = ImageData(___, 'anisotropic', anisotropic)
            %   handle = ImageData(___, 'position', position)
            %
            % INPUT
            %   ---
            %   Note: All input parameters are optional upon initialization
            %       and are set to [] by default
            %   ---
            %   image: A cell array containing the image data
            %   cubeRange: Defines the cubes which are loaded when using
            %       the loadDataDlg function
            %       {[x1, x2], [y1, y2], [z1, z2]}
            %   cubeSize: Specifies the size of each cube
            %       [sizeX, sizeY, sizeZ]
            %   bufferType: Specifies if the complete image is stored in
            %       memory ('whole') or only the needed subimage ('cubed')
            %   dataType: 'single', 'double', ...
            %   sourceType: 'cubed', 'stack', or 'matFile'
            %   sourceFolder: Complete path (string)
            %   anisotropic: Anisotropy factors for each dimensions
            %       [fx fy fz]
            %   position: The position relative to the display grid of the
            %       Viewer (needed, e.g., for correct placements of
            %       overlays)
            
            % Set defaults
            dat.image = [];
            dat.cubeRange = [];
            dat.cubeSize = [];
            dat.bufferType = [];
            dat.dataType = [];
            dat.sourceType = [];
            dat.sourceFolder = [];
            dat.anisotropic = [];
            dat.position = [];
            
            % Check input
            if ~isempty(varargin)
                i = 0;
                
                while i < length(varargin)
                    i = i+1;
                    
                    if strcmp(varargin{i}, 'image')
                        dat.image = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'cubeRange')
                        dat.cubeRange = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'cubeSize')
                        dat.cubeSize = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'bufferType')
                        dat.bufferType = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'dataType')
                        dat.dataType = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'sourceType')
                        dat.sourceType = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'sourceFolder')
                        dat.sourceFolder = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'anisotropic')
                        dat.anisotropic = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'position')
                        dat.position = varargin{i+1};
                        i = i+1;
                    end
                    
                end
                
            end

        end
        
        
        %% Data processing
        
        function cubeData(this, path)
            
        end
        
        
        %% FileIO
        
        function status = loadDataDlg(this)
            % Select and load an image
            % -------------------------------------------------------------
            % DESCRIPTION
            %   loadDataDlg loads an image according to a previously
            %   specified data type ('cubed', 'stack', 'matFile') and 
            %   buffer Type ('cubed', 'whole') using a dialog window to 
            %   select the source. 
            %
            % OUTPUT
            %
            %   status: 
            %       -1 = error (see error message)
            %        0 = no file was selected
            %        1 = data successfully loaded
            % -------------------------------------------------------------
            
            if ~strcmp(this.sourceType, 'cubed') && ...
                    ~strcmp(this.sourceType, 'stack') && ...
                    ~strcmp(this.sourceType, 'matFile')
                EX.identifier = 'Data: No source type';
                EX.message = 'The source type for this object was not set correctly.';
                EX.stack = [];
                EX.solution = 'Set source type before loading data.';
                this.throwException(EX, 'ERROR: No source type found');
                status = -1;
                return;
            end
            
            if ~strcmp(this.bufferType, 'cubed') && ...
                    ~strcmp(this.bufferType, 'whole')
                EX.identifier = 'Data: Unknown buffer type';
                EX.message = ['Buffer type ' this.image.bufferType 'is invalid.'];
                EX.stack = [];
                EX.solution = 'Set buffer type correctly before attempting to load an image.';
                this.throwException(EX, 'ERROR: Unknown buffer type');
                status = -1;
                return;
            end
            
            switch this.sourceType
                case 'cubed'
                    status = this.loadFromCubedDataDlg();
                case 'stack'
                    
                case 'matFile'
                    status = this.loadFromMatFileDlg('getInfo', 'all');
            end
            
        end
        
        
        %% Create display planes
        
        function loadVisibleSubImage(this, vis)
            persistent cubeMap
            
            % cubeMap is a matrix of the size of the image cell array. It
            % stores values for each image cubes describing for how long
            % these were not seen on the display, i.e., if visible the
            % value is set to an initial number and each time this function
            % is called all values are decreased by one. 
            if isempty(cubeMap) || isequal(size(cubeMap), size(this.image))
                cubeMap = zeros(size(this.image));
            end
            cubeMap = cubeMap - 1;
            cubeMap(cubeMap < 0) = 0;

            % Determine the range of the image which is visible
            minVisible = vis.currentPosition - vis.displaySize / 2;
            minVisibleCube = floor(minVisible ./ this.cubeSize);
            maxVisible = vis.currentPosition + vis.displaySize / 2;
            maxVisibleCube = floor(maxVisible ./ this.cubeSize);
            
            % Check for out of bounds
            for i = 1:3
                if minVisibleCube(i) < 0
                    minVisibleCube(i) = 0;
                end
                if maxVisibleCube(i) > this.cubeRange{i}(2)-this.cubeRange{i}(1)
                    maxVisibleCube(i) = this.cubeRange{i}(2)-this.cubeRange{i}(1);
                end
            end

            % Iterate over every visible image cube and load it into memory
            for x = minVisibleCube(1) : maxVisibleCube(1)
                for y = minVisibleCube(2) : maxVisibleCube(2)
                    for z = minVisibleCube(3) : maxVisibleCube(3)

                        if isempty(this.image{y+1, x+1, z+1})
                            
                            xR = x + this.cubeRange{1}(1);
                            yR = y + this.cubeRange{2}(1);
                            zR = z + this.cubeRange{3}(1);
                            
                            this.image{y+1, x+1, z+1} = jh_openCubeRange( ...
                                this.sourceFolder, '', ...
                                'cubeSize', [128 128 128], ...
                                'range', 'oneCube', [xR, yR, zR], ...
                                'dataType', this.dataType, ...
                                'outputType', 'one', ...
                                'fileType', 'auto') / 255;

                        end

                        cubeMap(y+1, x+1, z+1) ...
                            = vis.bufferDelete;

                    end
                end
            end
            
            % Remove a data cube if the corresponding cubeMap matrix
            % position reaches zero.
            for x = 0 : size(this.image, 2)-1
                for y = 0 : size(this.image, 1)-1
                    for z = 0 : size(this.image, 3)-1
                        if cubeMap(y+1, x+1, z+1) <= 0
                            this.image{y+1, x+1, z+1} = [];
                        end
                    end
                end
            end
            
            this.minLoadedCube = minVisibleCube;
            this.maxLoadedCube = maxVisibleCube;

        end
        
        function [planes] = createDisplayPlanes ...
                (this, planes, vis, type)
            
            % Iterate over the loaded cube range
            for x = this.minLoadedCube(1) : this.maxLoadedCube(1)
                for y = this.minLoadedCube(2) : this.maxLoadedCube(2)
                    for z = this.minLoadedCube(3) : this.maxLoadedCube(3)

                        if ~isempty(this.image{y+1, x+1, z+1})
                            [planes.XY, planes.XZ, planes.ZY, ~] = jh_overlayObject( ...
                                planes.XY, planes.XZ, planes.ZY, ...    images
                                vis.roundedPosition, ...                position
                                [x, y, z] .* this.cubeSize, ...         object position
                                this.image{y+1, x+1, z+1}, ...          object matrix
                                vis.displaySize, ...                    display size
                                vis.anisotropyFactor, ...               anisotropy factor
                                type, ...                               overlay specifier
                                0);
                        end

                    end
                end
            end
            
        end
        
        
        %% Other

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
        
        
    end
    
    methods (Access = public)
        
        function loadCubedImage(this)
            
            im = jh_openCubeRange( ...
                this.sourceFolder, '', ...
                'cubeSize', this.cubeSize, ...
                'range', this.cubeRange{1}, this.cubeRange{2}, this.cubeRange{3}, ...
                'dataType', this.dataType, ...
                'outputType', 'cubed', ...
                'fileType', 'auto');

            this.image = cellfun(@(x) x/255, im, 'UniformOutput', false);

            for i = 1:3
                this.minLoadedCube(i) = 0;
                this.maxLoadedCube(i) = this.cubeRange{i}(2)-this.cubeRange{i}(1);
            end
                    
        end
        
        function loadMatFileImage(this)
            
            imData = load(this.sourceFolder, this.varName);
            if strcmp(this.bufferType, 'whole')
                this.image = {imData.(this.varName)};
            elseif strcmp(this.bufferType, 'cubed')
                this.image = imData.(this.varName);
            end
            
        end

    end
    
    methods (Access = private)
        %% FileIO
        
        function getParametersFromDialog(this, getInfo)
            
            if isempty(this.cubeRange)
                this.cubeRange = {[0 0], [0 0], [0 0]};
            end
            
            % Build the parameter dialog
            parameterNames = [];
            parameters = [];
            if getInfo(1) 
                
                parameterNames = {'From (x, y, z)', 'To (x, y, z)'};
                parameters = { ...
                    [ num2str(this.cubeRange{1}(1)) ', ' ...
                      num2str(this.cubeRange{2}(1)) ', ' ...
                      num2str(this.cubeRange{3}(1)) ], ...
                    [ num2str(this.cubeRange{1}(2)) ', ' ...
                      num2str(this.cubeRange{2}(2)) ', ' ...
                      num2str(this.cubeRange{3}(2)) ] ...
                    };
                
            end
            
            if getInfo(2)
                
                parameterNames = [parameterNames, ...
                    {'Anisotropy factors (x, y, z)'}];
                parameters = [parameters, ...
                    {[num2str(this.anisotropic(1)), ', ' num2str(this.anisotropic(2)), ', ', num2str(this.anisotropic(3))]}];
                
            end
            
            if getInfo(3)
                
                parameterNames = [parameterNames, ...
                    {'Position (x, y, z)'}];
                parameters = [parameters, ...
                    {[num2str(this.position(1)) ', ' num2str(this.position(2)) ', ' num2str(this.position(3))]}];
                
            end
            
            % Call dialog box
            settings = inputdlg(parameterNames, 'Data settings...', 1, parameters);
            
            % Interpret the returned data
            p = 1;
            if getInfo(1)
                rangeFrom = strsplit(settings{p}, {', ', ','});
                rangeTo = strsplit(settings{p+1}, {', ', ','});
                rangeX = [str2double(rangeFrom{1}) str2double(rangeTo{1})];
                rangeY = [str2double(rangeFrom{2}) str2double(rangeTo{2})];
                rangeZ = [str2double(rangeFrom{3}) str2double(rangeTo{3})];
                this.cubeRange = {rangeX, rangeY, rangeZ};
                p = p+2;
            end
            if getInfo(2)
                anisotrpc = strsplit(settings{p}, {', ', ','});
                this.anisotropic = cellfun(@(x) str2double(x), anisotrpc);
                p = p+1;
            end
            if getInfo(3)
                pos = strsplit(settings{p}, {', ', ','});
                this.position = cellfun(@(x) str2double(x), pos);
            end

        end
        
        function status = loadFromMatFileDlg(this, varargin)
            % loadFromMatFileDlg loads image data form a .mat file
            % -------------------------------------------------------------
            % SYNOPSIS
            %   status = loadFromMatFileDlg()
            %   status = loadFromMatFileDlg(___, 'getInfo', getInfo)
            %   status = loadFromMatFileDlg(___, 'type', type)
            %   status = loadFromMatFileDlg(___, 'varName', varName)
            %
            % INPUT
            %   getInfo: Cell array of strings describing which information 
            %       is to be retrieved by an input dialog window
            %       Possible strings:
            %           'cubeRange', 'anisotropy', 'position'
            %       If getInfo == 'all', all of the above are assumed
            %           (default)
            %   type: Defines how the data is stored within the mat
            %       file
            %       'cell': As cell array containing cubed data.
            %       'one': As one matrix contating the whole data set
            %       'auto' (default): Looks for index variable which
            %           contains one of the above strings
            %   varName: Name of the variable within the matFile
            %       'auto' (default): Looks for index variable which
            %           specifies the name
            %
            % OUTPUT
            %
            %   status: 
            %       -1 = error (see error message)
            %        0 = no file was selected
            %        1 = data successfully loaded
            % -------------------------------------------------------------
            
            %% Check input
            
            % Defaults
            getInfo = 'all';
            type = 'auto';
            this.varName = 'auto';
            
            % Check input
            if ~isempty(varargin)
                i = 0;
                
                while i < length(varargin)
                    i = i+1;
                    
                    if strcmp(varargin{i}, 'getInfo')
                        
                        if iscell(varargin{i+1})
                            t = [0, 0, 0];
                            for j = 1:length(varargin{i+1})
                                if strcmp(varargin{i+1}, 'cubeRange')
                                    t(1) = 1;
                                elseif strcmp(varargin{i+1}, 'anisotropy')
                                    t(2) = 1;
                                elseif strcmp(varargin{i+1}, 'position')
                                    t(3) = 1;
                                end                                    
                            end
                            getInfo = t;
                        else
                            getInfo = [1, 1, 1];
                        end
                        i = i+1;
                        
                    elseif strcmp(varargin{i}, 'type')
                        type = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'varName')
                        this.varName = varargin{i+1};
                        i = i+1;
                    end
                    
                end
                
            end
            
            %%
            
            % Get the file
            [file, path] = uigetfile('*.mat', 'Select dataset file');
            if file == 0
                return;
            else
                this.sourceFolder = [path, file];
            end
            
            % First, load the file and get its index variable which
            % contains information about the data type
            %   'cell': organized as cubes within a cell array
            %       (cubed cell array)
            %   'one': whole data is stored as a matrix
            if strcmp(type, 'auto') || strcmp(this.varName, 'auto')
                load([path file], 'index');
                type = index{1};
                this.varName = index{2};
            end
            
            if strcmp(type, 'one')
                
                % No range information will be retrieved
                getInfo(1) = 0;
                
                % Get user input if needed
                if max(getInfo) == 1
                    this.getParametersFromDialog(getInfo);
                end
                
                this.cubeRange = [];
                this.bufferType = 'whole';
                
                this.loadMatFileImage();
                
                this.cubeSize = size(this.image{1});
                this.totalImageSize = this.cubeSize;
                
            elseif strcmp(type, 'cell')
                
                this.bufferType = 'cubed';
                
                this.loadMatFileImage();
                
                this.cubeSize = size(this.image{1});
                this.totalImageSize = this.cubeSize .* size(this.image);
                
            end
            
            this.dataType = class(this.image{1});

            status = 1;
                    
        end
        function status = loadFromCubedDataDlg(this)
            % -------------------------------------------------------------
            % OUTPUT
            %
            %   status: 
            %       -1 = error (see error message)
            %        0 = no file was selected
            %        1 = data successfully loaded
            % -------------------------------------------------------------
            
            % Get the directory
            folder = uigetdir(this.sourceFolder, 'Select dataset folder');
            if folder == 0
                status = 0;
                return;
            else
                this.sourceFolder = folder;
            end

            % Dialog box to specify the range which will be loaded
            range = inputdlg( ...
                {   'From (x, y, z)', 'To (x, y, z)', ...
                    'Anisotropy factors (x, y, z)' ...
                    'Position (x, y, z)'
                }, ...
                'Data settings...', ...
                1, ...
                {   [num2str(this.cubeRange{1}(1)) ', ' num2str(this.cubeRange{2}(1)) ', ' num2str(this.cubeRange{3}(1))], ...
                    [num2str(this.cubeRange{1}(2)) ', ' num2str(this.cubeRange{2}(2)) ', ' num2str(this.cubeRange{3}(2))], ...
                    [num2str(this.anisotropic(1)), ', ' num2str(this.anisotropic(2)), ', ', num2str(this.anisotropic(3))], ...
                    [num2str(this.position(1)) ', ' num2str(this.position(2)) ', ' num2str(this.position(3))] ...
                });
            
            % Interpret the returned data
            rangeFrom = strsplit(range{1}, {', ', ','});
            rangeTo = strsplit(range{2}, {', ', ','});
            rangeX = [str2double(rangeFrom{1}) str2double(rangeTo{1})];
            rangeY = [str2double(rangeFrom{2}) str2double(rangeTo{2})];
            rangeZ = [str2double(rangeFrom{3}) str2double(rangeTo{3})];
            anisotrpc = strsplit(range{3}, {', ', ','});
            pos = strsplit(range{4}, {', ', ','});

            this.anisotropic = cellfun(@(x) str2double(x), anisotrpc);
            this.cubeRange = {rangeX, rangeY, rangeZ};
            this.position = cellfun(@(x) str2double(x), pos);
            
            
            if strcmp(this.bufferType, 'whole')
                % The whole specified image will be loaded instantly
                this.loadCubedImage();
            elseif strcmp(this.bufferType, 'cubed')
                % An empty cell matrix is set up and is filled on demand
                this.image = cell(rangeY(2)-rangeY(1)+1, rangeX(2)-rangeX(1)+1, rangeZ(2)-rangeZ(1)+1);
            else
                % Does not happen!
            end
            
            this.totalImageSize = size(this.image) .* this.cubeSize;
            
            status = 1;
            
        end
                
        
    end
    
    methods (Static)
        
        %% Create display planes
        
        function change = checkForChange(vis, type)
            % vis as Visualization
            
            persistent position displaySize spacerSize
            change = false;

            if strcmp(type, 'getset') || strcmp(type, 'get')
                if ~isequal(position, vis.currentPosition) ...
                        || displaySize == vis.displaySize ...
                        || spacerSize == vis.spacerSize
                    change = true;
                end            
            end
            if strcmp(type, 'getset') || strcmp(type, 'set')
                position = vis.currentPosition;
                displaySize = vis.displaySize;
                spacerSize = vis.spacerSize;
            end
            
        end
        
        %%
       
    end
    
end