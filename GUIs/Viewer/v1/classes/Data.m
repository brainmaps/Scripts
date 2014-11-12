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
    end
    
    methods
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
        
        function cubeData(this, path)
            
        end
        
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
                    
            end
        end
        
        function loadMFileImage(this)
            
            this.image = load(this.sourceFolder, 'data');
            
        end
        
        function loadCubedImage(this)
            
            im = jh_openCubeRange( ...
                this.sourceFolder, '', ...
                'cubeSize', this.image.cubeSize, ...
                'range', this.cubeRange{1}, this.cubeRange{2}, this.cubeRange{3}, ...
                'dataType', this.dataType, ...
                'outputType', 'cubed', ...
                'fileType', 'auto');

            this.image = cellfun(@(x) x/255, im, 'UniformOutput', false);

        end
        
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
    
end