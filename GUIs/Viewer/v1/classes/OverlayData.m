% This class inherits image data properties and functions.
% The basic idea is that the stored image can be a continuous image as in
% ImageData, or itself a cell array of ImageData objects:
%   OverlayData.dataStructure = 'multiple'
% For this to be handled correctly, this class provides space to add 
% additional functions or properties.
%
% Note: Especially when using the multiple data structure it is recommended
% to use the setProperties function or the constructor to set Properties 
% (including image data). Direct usage of properties might cause unexpected 
% behaviour.
%
classdef OverlayData < ImageData
    
    properties
        
        dataStructure   % 'multiple' or 'classic'
        
    end
    
    methods
        
        % Constructor
        function overl = OverlayData(varargin)
            
%             overl = overl@ImageData(varargin{:});
            overl.setProperties(varargin{:});
            
        end
        
    end
    
    methods (Access = public)
        
        function addOverlay(this, image, position, overlaySpec)
            
            if ~strcmp(this.dataStructure, 'multiple')
                return;
            end
            
            newOverlay = ImageData( ...
                'image', image, ...
                'position', position, ...
                'overlaySpec', overlaySpec);
            
            this.image = [this.image, {newOverlay}];
            
        end
        
        function setProperties(this, varargin)
            % SYNOPSIS
            %   handle = OverlayData()
            %   handle = OverlayData(___, 'image', image)
            %   handle = OverlayData(___, 'name', 'name')
            %   handle = OverlayData(___, 'cubeRange', cubeRange)
            %   handle = OverlayData(___, 'cubeSize', cubeSize)
            %   handle = OverlayData(___, 'bufferType', bufferType)
            %   handle = OverlayData(___, 'dataType', dataType)
            %   handle = OverlayData(___, 'sourceType', sourceType)
            %   handle = OverlayData(___, 'sourceFolder', sourceFolder)
            %   handle = OverlayData(___, 'anisotropic', anisotropic)
            %   handle = OverlayData(___, 'position', position)
            %   handle = OverlayData(___, 'overlaySpec', overlaySpec)
            %   handle = OverlayData(___, 'totalImageSize', totalImageSize)
            
            % Check input
            if ~isempty(varargin)
                i = 0;
                
                while i < length(varargin)
                    i = i+1;
                    
                    if strcmp(varargin{i}, 'image')
                        this.image = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'name')
                        this.name = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'cubeRange')
                        this.cubeRange = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'cubeSize')
                        this.cubeSize = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'bufferType')
                        this.bufferType = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'dataType')
                        this.dataType = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'sourceType')
                        this.sourceType = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'sourceFolder')
                        this.sourceFolder = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'anisotropic')
                        this.anisotropic = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'position')
                        this.position = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'overlaySpec')
                        this.overlaySpec = varargin{i+1};
                        i = i+1;
                    elseif strcmp(varargin{i}, 'totalImageSize')
                        this.totalImageSize = varargin{i+1};
                        i = i+1;
                    end
                    
                end
                
            end
            
            if isa(this.image, 'ImageData')
                this.dataStructure = 'multiple';
                this.cubeRange = [];
                this.cubeSize = [];
                this.bufferType = 'whole';
                this.sourceType = [];
                this.copyPropertiesToSubObjects();
            else
                this.dataStructure = 'classic';
            end

        end
        
    end
    
    methods (Access = private)
        
        function copyPropertiesToSubObjects(this)
            
            if ~strcmp(this.dataStructure, 'multiple')
                return;
            end
            
            for i = 1:length(this.image)
                this.image{i}.anisotropic = this.anisotropic;
            end
            
        end
        
    end
    
end