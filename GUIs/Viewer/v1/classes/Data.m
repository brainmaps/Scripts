classdef Data < handle
    
    properties
        cubeRange       % [x, y, z]
        image
        anisotropic     % [x, y, z]
        cubeSize        % [x, y, z]
        bufferType      % 'cubed', 'whole'
        dataType        % 'single', 'double', 'integer', ...
        sourceFolder
        sourceType      % 'cubed', 'stack', 'm-file'
        position        % [x, y, z]
    end
    
    properties (SetAccess = protected)
        
        minLoadedCube
        maxLoadedCube
        
    end
        
    methods
        
        %% initialization
        
        function dat = Data(varargin)
            dat.cubeRange = varargin{1};
            dat.image = varargin{2};
            dat.anisotropic = varargin{3};
            dat.cubeSize = varargin{4};
            dat.bufferType = varargin{5};
            dat.dataType = varargin{6};
            dat.sourceFolder = varargin{7};
            dat.sourceType = varargin{8};
            dat.position = varargin{9};
        end
        
        %% Data processing
        
        function cubeData(this, path)
            
        end
        
        %% FileIO
        
        function loadDataDlg(this)
            
            switch this.sourceType
                case 'cubed'
                    
                    % Get the directory
                    folder = uigetdir(this.sourceFolder, 'Select dataset folder');
                    if folder == 0
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
                        this.loadCubedImage();
                    elseif strcmp(this.bufferType, 'cubed')
                        this.image = cell(rangeX(2)+1, rangeY(2)+1, rangeZ(2)+1);
                    else
                        EX.identifier = 'Data: Unknown buffer type';
                        EX.message = ['Buffer type ' this.image.bufferType 'is invalid.'];
                        EX.stack = [];
                        EX.solution = 'No known solution found.';
                        this.throwException(EX, 'ERROR: Unknown buffer type');
                    end
                
                case 'stack'
                    
                case 'm-file'

                    % Get the file
                    [file, path] = uigetfile('*.mat', 'Select dataset file');
                    if file == 0
                        return;
                    else
                        this.sourceFolder = [path, file];
                    end
                    
                    % Dialog box to specify the anisotropy
                    settings = inputdlg( ...
                        {   'Anisotropy factors (x, y, z)', ...
                            'Position (x, y, z)' ...
                        }, ...
                        'Data settings...', 1, ...
                        {   [num2str(this.anisotropic(1)), ', ' num2str(this.anisotropic(2)), ', ', num2str(this.anisotropic(3))], ...
                            [num2str(this.position(1)) ', ' num2str(this.position(2)) ', ' num2str(this.position(3))] ...
                        });
                    
                    anisotrpc = strsplit(settings{1}, {', ', ','});
                    this.anisotropic = cellfun(@(x) str2double(x), anisotrpc);
                    
                    pos = strsplit(settings{2}, {', ', ','});
                    this.position = cellfun(@(x) str2double(x), pos);

                    this.loadMFileImage();
                    
                    this.cubeRange = [];
                    this.cubeSize = [];
                    this.bufferType = 'whole';
                    
            end
        end
        
        function loadMFileImage(this)
            
            this.image = load(this.sourceFolder, 'data');
            
        end
        
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
                this.minLoadedCube(i) = this.cubeRange{i}(1);
                this.maxLoadedCube(i) = this.cubeRange{i}(2);
            end
                    
        end
        
        %% Create display planes
        
        function loadVisibleSubImage(this, vis)
            persistent cubeMap

            if isempty(cubeMap)
                cubeMap = zeros(size(this.image));
            end
            cubeMap = cubeMap - 1;
            cubeMap(cubeMap < 0) = 0;

            minVisible = vis.currentPosition - vis.displaySize / 2;
            minVisibleCube = floor(minVisible ./ this.cubeSize);
            maxVisible = vis.currentPosition + vis.displaySize / 2;
            maxVisibleCube = floor(maxVisible ./ this.cubeSize);
            
            for i = 1:3
                if minVisibleCube(i) < this.cubeRange{i}(1)
                    minVisibleCube(i) = this.cubeRange{i}(1);
                end
                if maxVisibleCube(i) > this.cubeRange{i}(2)
                    maxVisibleCube(i) = this.cubeRange{i}(2);
                end
            end

            for x = minVisibleCube(1) : maxVisibleCube(1)
                for y = minVisibleCube(2) : maxVisibleCube(2)
                    for z = minVisibleCube(3) : maxVisibleCube(3)

                        if isempty(this.image{y+1, x+1, z+1})

                            this.image{y+1, x+1, z+1} = jh_openCubeRange( ...
                                this.sourceFolder, '', ...
                                'cubeSize', [128 128 128], ...
                                'range', 'oneCube', [x, y, z], ...
                                'dataType', this.dataType, ...
                                'outputType', 'one', ...
                                'fileType', 'auto') / 255;

                        end

                        cubeMap(y+1, x+1, z+1) = vis.bufferDelete;

                    end
                end
            end

            for x = this.cubeRange{1}(1) : this.cubeRange{1}(2)
                for y = this.cubeRange{2}(1) : this.cubeRange{2}(2)
                    for z = this.cubeRange{3}(1) : this.cubeRange{3}(2)
                        if cubeMap(y+1, x+1, z+1) == 0
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
                                planes.XY, planes.XZ, planes.ZY, ...
                                vis.roundedPosition, [x, y, z] .* this.cubeSize, ...
                                this.image{y+1, x+1, z+1}, ...
                                vis.displaySize, vis.anisotropyFactor, ...
                                type, 0);
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