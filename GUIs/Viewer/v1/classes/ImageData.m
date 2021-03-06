classdef ImageData < handle
    
    properties (SetObservable)
        name
        cubeRange       % [x1, x2], [y1, y2], [z1, z2]
        image           % cell of cubes
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
    
    properties (SetAccess = public, GetAccess = public)

        minLoadedCube
        maxLoadedCube
        
        % cubeMap is a matrix of the size of the image cell array. It
        % stores values for each image cubes describing for how long
        % these were not seen on the display, i.e., if visible the
        % value is set to an initial number and each time this function
        % is called all values are decreased by one. 
        cubeMap
        overlaySpec
        
    end
        
    events
        
        ImageChanged
        
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
            %   handle = ImageData(___, 'name', 'name')
            %   handle = ImageData(___, 'cubeRange', cubeRange)
            %   handle = ImageData(___, 'cubeSize', cubeSize)
            %   handle = ImageData(___, 'bufferType', bufferType)
            %   handle = ImageData(___, 'dataType', dataType)
            %   handle = ImageData(___, 'sourceType', sourceType)
            %   handle = ImageData(___, 'sourceFolder', sourceFolder)
            %   handle = ImageData(___, 'anisotropic', anisotropic)
            %   handle = ImageData(___, 'position', position)
            %   handle = ImageData(___, 'overlaySpec', overlaySpec)
            %
            % INPUT
            %   ---
            %   Note: All input parameters are optional upon initialization
            %       and are set to [] by default
            %   ---
            %   image: A cell array containing the image data
            %   name: A name to identify the data set
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
            %   overlaySpec: Object of class OverlaySpecifier to describe
            %       overlay behaviour (not needed for background images)
            
            % Set defaults
            dat.image = [];
            dat.name = '';
            dat.cubeRange = [];
            dat.cubeSize = [];
            dat.bufferType = [];
            dat.dataType = [];
            dat.sourceType = [];
            dat.sourceFolder = [];
            dat.anisotropic = [];
            dat.position = [];
            dat.cubeMap = [];
            
            % Check input
            if ~isempty(varargin)
                i = 0;
                
                while i < length(varargin)
                    i = i+1;
                    
                    if strcmp(varargin{i}, 'image')
                        dat.image = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'name')
                        dat.name = varargin{i+1};
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
            
            addlistener(dat, 'image', 'PostSet', @dat.image_postSet_cb);

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
        
        function status = exportImageDlg(this)
            % OUTPUT
            %   status == 1: success
            %   status == 0: failed
            %   status == -1: in development
            
            % Dialog input
            [file, path] = uiputfile({'*.tiff', 'TIFF image'});
            
            % Export to determined destination
            status = this.exportImage([path file]);
            
        end
        function status = exportImage(this, path)
            % OUTPUT
            %   status == 1: success
            %   status == 0: failed
            %   status == -1: in development
            
            switch this.bufferType
                case 'cubed'
                    status = this.exportImage_cubed(path);
                case 'whole'
                    status = this.exportImage_whole(path);
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
    
    % Event functions
    methods (Access = protected)
        
        function OnImageChanged(this)
            
            notify(this, 'ImageChanged');
            
        end
        
    end
    
    methods (Access = protected)
        
        function image_postSet_cb(this, src, evnt)
            
            this.image_postSet_fcn();
            
        end
        function image_postSet_fcn(this)
            
            if ~isempty(this.image)
                
                this.totalImageSize = ...
                    [size(this.image, 1), size(this.image, 2), size(this.image, 3)] ...
                    .* this.cubeSize;
                
            end
                
            this.OnImageChanged();
            
        end
        
    end
    
    methods (Access = public)
        %%
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
        
        function clearBuffer(this)
            
            % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            % Clear the buffer also for whole images: Needs reloading of 
            % the image to be implemented
            
            
            if strcmp(this.bufferType, 'cubed')
                this.image = cellfun(@(x) [], this.image, 'uniformoutput', false);
                this.cubeMap(:) = 0;
            end
            
        end
        
        function fillBuffer(this, vis)
            
            if strcmp(this.bufferType, 'whole')
                
                this.loadCubedImage();
                
            elseif strcmp(this.bufferType, 'cubed')
                
                this.loadVisibleSubImage(vis);
                
            end
            
        end

        function [planes, visibility] = overlayObject(this, ...
                planes, ...
                vis, ...
                imType, ...
                screenSize)
            
            visibility = false;
            
            if ~this.visible, return; end
            
            
            % Get the current displayed planes if the image is cubed
            if strcmp(this.bufferType, 'cubed')
                
                this.loadVisibleSubImage(vis);
                
            else
                
            end
            
%             % Create new display planes for the overlay ...
%             planes = DisplayPlanes( ...
%                 zeros(screenSize(2), screenSize(1)), ...  % xy
%                 zeros(screenSize(3), screenSize(1)), ...  % xz
%                 zeros(screenSize(2), screenSize(3)) ...   % zy
%                 );
            % ... and fill them with the overlay      
            
            if size(planes.XY, 3) == 3, imType = 'rgb'; end
            planes = this.createDisplayPlanes(planes, vis, imType);
            
%             % Perform the actual overlay computation for each plane
%             planes.XY = jh_overlayLabels( ...
%                 planes.XY, planesOl.XY, ...
%                 'oneColor', [0.5 0 0], ...
%                 'type', 'colorize', ...
%                 imType);
%             planes.XZ = jh_overlayLabels( ...
%                 planes.XZ, planesOl.XZ, ...
%                 'oneColor', [0.5 0 0], ...
%                 'type', 'colorize', ...
%                 imType);
%             planes.ZY = jh_overlayLabels( ...
%                 planes.ZY, planesOl.ZY, ...
%                 'oneColor', [0.5 0 0], ...
%                 'type', 'colorize', ...
%                 imType);
          
        end
        
        %% Create display planes
        
        function [planes] = createDisplayPlanes ...
                (this, planes, vis, imType, type)
            
            if isempty(type), type = 'replace'; end
            
            % Iterate over the loaded cube range
            for x = this.minLoadedCube(1) : this.maxLoadedCube(1)
                for y = this.minLoadedCube(2) : this.maxLoadedCube(2)
                    for z = this.minLoadedCube(3) : this.maxLoadedCube(3)

                        if ~isempty(this.image{y+1, x+1, z+1})
                            [planes.XY, planes.XZ, planes.ZY, ~] = jh_overlayObject( ...
                                planes.XY, planes.XZ, planes.ZY, ...    images
                                vis.roundedPosition, ...                position
                                [x, y, z] .* this.cubeSize + this.position, ...         object position
                                this.image{y+1, x+1, z+1}, ...          object matrix
                                vis.displaySize, ...                    display size
                                vis.anisotropyFactor, ...               anisotropy factor
                                type, ...                               overlay specifier
                                [1, 0, 0], imType);
                        end

                    end
                end
            end
            
        end
        
        % This function returns a subimage specified by position and size
        function subIm = getSubImage(this, position, sze)
            % INPUT
            %   position: vector [x, y, z]
            %   sze: vector [width, height, depth]
            
            subIm = [];
            
            if strcmp(this.sourceType, 'cubed')
                
                % Get cube range
                minCube = floor(position ./ this.cubeSize) ...
                    + [this.cubeRange{1}(1), this.cubeRange{2}(1), this.cubeRange{3}(1)];
                maxCube = floor((position + sze) ./ this.cubeSize) ...
                    + [this.cubeRange{1}(1), this.cubeRange{2}(1), this.cubeRange{3}(1)];

                % Load the cube range as complete image
                im = jh_openCubeRange( ...
                    this.sourceFolder, '', ...
                    'cubeSize', this.cubeSize, ...
                    'range', ...
                        [minCube(1), maxCube(1)], ...
                        [minCube(2), maxCube(2)], ...
                        [minCube(3), maxCube(3)], ...
                    'dataType', this.dataType, ...
                    'outputType', 'one', ...
                    'fileType', 'auto') / 255;

                % Extract the necessary subimage
                minCubeRel = floor(position ./ this.cubeSize);
                from = position - minCubeRel.*this.cubeSize + 1;
                to = position+sze - minCubeRel.*this.cubeSize + 1;
                subIm = im(from(2):to(2), from(1):to(1), from(3):to(3));
                
            end
            
        end
        
        % This function is exclusively necessary for cubed image data where
        % only parts of the whole data set are loaded into memory. 
        % Use this function to load the desired cubes into memory.
        function loadVisibleSubImage(this, vis)
            
            % If the bufferType is cubed then a cell array to fill with
            % data has to be present. If this fails to be created the
            % function returns without making changes.
            if isempty(this.image) && strcmp(this.sourceType, 'cubed')
                try
                    this.image = cell(this.cubeRange{2}(2)-this.cubeRange{2}(1)+1, ...
                        this.cubeRange{1}(2)-this.cubeRange{1}(1)+1, ...
                        this.cubeRange{3}(2)-this.cubeRange{3}(1)+1);
                catch e
                    EX.identifier = 'ImageData.loadVisibleSubImage: Buffer not filled!';
                    EX.message = 'Could not find necessary cube range information.';
                    EX.stack = [];
                    EX.solution = 'Set cubeRange before excecuting this function.';
                    this.throwException(EX, 'ERROR: Cube range not found');
                    return;
                end
            end
            
            % cubeMap is a matrix of the size of the image cell array. It
            % stores values for each image cubes describing for how long
            % these were not seen on the display, i.e., if visible the
            % value is set to an initial number and each time this function
            % is called all values are decreased by one. 
            if isempty(this.cubeMap) || isequal(size(this.cubeMap), size(this.image))
                this.cubeMap = zeros(size(this.image));
            end
            this.cubeMap = this.cubeMap - 1;
            this.cubeMap(this.cubeMap < 0) = 0;

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
                                'cubeSize', this.cubeSize, ...
                                'range', 'oneCube', [xR, yR, zR], ...
                                'dataType', this.dataType, ...
                                'outputType', 'one', ...
                                'fileType', 'auto') / 255;

                        end

                        this.cubeMap(y+1, x+1, z+1) ...
                            = vis.bufferDelete;

                    end
                end
            end
            
            % Remove a data cube if the corresponding cubeMap matrix
            % position reaches zero.
            for x = 0 : size(this.image, 2)-1
                for y = 0 : size(this.image, 1)-1
                    for z = 0 : size(this.image, 3)-1
                        if this.cubeMap(y+1, x+1, z+1) <= 0
                            this.image{y+1, x+1, z+1} = [];
                        end
                    end
                end
            end
            
            this.minLoadedCube = minVisibleCube;
            this.maxLoadedCube = maxVisibleCube;

        end
        
        
    end
    
    methods (Access = protected)
        
        %% FileIO
        
        function status = exportImage_cubed(this, path)
            status = -1;
        end
        function status = exportImage_whole(this, path)
            
            try
                %Build image
                im = this.concatenateCubes();
                
                %Save image 
                jh_saveImageAsTiff3D(im, path, 'gray');
                
                %Success!
                status = 1;
            catch
                % WTF!
                status = 0;
            end

        end
        
        %% Data processing
        function concCubes = concatenateCubes(this)
            
            concCubes = zeros(this.totalImageSize);
            
            for x = 0:size(this.image, 1)-1
                for y = 0:size(this.image, 2)-1
                    for z = 0:size(this.image, 3)-1
                        
                        concCubes( ...
                            y*this.cubeSize(2)+1 : (y+1)*this.cubeSize(2), ...
                            x*this.cubeSize(1)+1 : (x+1)*this.cubeSize(1), ...
                            z*this.cubeSize(3)+1 : (z+1)*this.cubeSize(3)) ...
                            = this.image{y+1, x+1, z+1};
                        
                    end
                end
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
                
                parameterNames = {'Name'};
                parameters = {this.name};
                
            end
                
            if getInfo(2) 
                
                parameterNames = [parameterNames, ...
                    {'From (x, y, z)', 'To (x, y, z)'}];
                parameters = [parameters, ...
                    { ...
                    [ num2str(this.cubeRange{1}(1)) ', ' ...
                      num2str(this.cubeRange{2}(1)) ', ' ...
                      num2str(this.cubeRange{3}(1)) ], ...
                    [ num2str(this.cubeRange{1}(2)) ', ' ...
                      num2str(this.cubeRange{2}(2)) ', ' ...
                      num2str(this.cubeRange{3}(2)) ] ...
                    }];
                
            end
            
            if getInfo(3)
                
                parameterNames = [parameterNames, ...
                    {'Anisotropy factors (x, y, z)'}];
                parameters = [parameters, ...
                    {[num2str(this.anisotropic(1)), ', ' num2str(this.anisotropic(2)), ', ', num2str(this.anisotropic(3))]}];
                
            end
            
            if getInfo(4)
                
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
                this.name = settings{p};
                p = p+1;
            end
            if getInfo(2)
                rangeFrom = strsplit(settings{p}, {', ', ','});
                rangeTo = strsplit(settings{p+1}, {', ', ','});
                rangeX = [str2double(rangeFrom{1}) str2double(rangeTo{1})];
                rangeY = [str2double(rangeFrom{2}) str2double(rangeTo{2})];
                rangeZ = [str2double(rangeFrom{3}) str2double(rangeTo{3})];
                this.cubeRange = {rangeX, rangeY, rangeZ};
                p = p+2;
            end
            if getInfo(3)
                anisotrpc = strsplit(settings{p}, {', ', ','});
                this.anisotropic = cellfun(@(x) str2double(x), anisotrpc);
                p = p+1;
            end
            if getInfo(4)
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
            %           'name', 'cubeRange', 'anisotropy', 'position'
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
                            t = [0, 0, 0, 0];
                            for j = 1:length(varargin{i+1})
                                if strcmp(varargin{i+1}, 'name')
                                    t(1) = 1;
                                elseif strcmp(varargin{i+1}, 'cubeRange')
                                    t(2) = 1;
                                elseif strcmp(varargin{i+1}, 'anisotropy')
                                    t(3) = 1;
                                elseif strcmp(varargin{i+1}, 'position')
                                    t(4) = 1;
                                end                                    
                            end
                            getInfo = t;
                        else
                            getInfo = [1, 1, 1, 1];
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
        function status = loadFromCubedDataDlg(this, varargin)
            % loadFromCubedDataDlg loads image data form cubed data files
            % -------------------------------------------------------------
            % SYNOPSIS
            %   status = loadFromCubedDataDlg()
            %   status = loadFromCubedDataDlg(___, 'getInfo', getInfo)
            %
            % INPUT
            %   getInfo: Cell array of strings describing which information 
            %       is to be retrieved by an input dialog window
            %       Possible strings:
            %           'name', 'cubeRange', 'anisotropy', 'position'
            %       If getInfo == 'all', all of the above are assumed
            %           (default)
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
                            t = [0, 0, 0, 0];
                            for j = 1:length(varargin{i+1})
                                if strcmp(varargin{i+1}, 'name')
                                    t(1) = 1;
                                elseif strcmp(varargin{i+1}, 'cubeRange')
                                    t(2) = 1;
                                elseif strcmp(varargin{i+1}, 'anisotropy')
                                    t(3) = 1;
                                elseif strcmp(varargin{i+1}, 'position')
                                    t(4) = 1;
                                end                                    
                            end
                            getInfo = t;
                        elseif strcmp(varargin{i+1}, 'all');
                            getInfo = [1, 1, 1, 1];
                        end
                        i = i+1;
                    end
                    
                end
                
            end
            
            if ~iscell(getInfo)
                if strcmp(getInfo, 'all')
                    getInfo = [1, 1, 1, 1];
                end
            end
            
            %%

            % Get the directory
            folder = uigetdir(this.sourceFolder, 'Select dataset folder');
            if folder == 0
                status = 0;
                return;
            else
                this.sourceFolder = folder;
            end

            if max(getInfo) == 1
                this.getParametersFromDialog(getInfo);
            end
            
            if strcmp(this.bufferType, 'whole')
                % The whole specified image will be loaded instantly
                this.loadCubedImage();
            elseif strcmp(this.bufferType, 'cubed')
                % An empty cell matrix is set up and is filled on demand
                this.image = cell(this.cubeRange{2}(2)-this.cubeRange{2}(1)+1, ...
                    this.cubeRange{1}(2)-this.cubeRange{1}(1)+1, ...
                    this.cubeRange{3}(2)-this.cubeRange{3}(1)+1);
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