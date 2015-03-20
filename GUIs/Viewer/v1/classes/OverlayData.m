% DESCRIPTION
%
% This class inherits image data properties and functions.
% The basic idea is that the stored image can be a continuous image as in
% ImageData, or itself a cell array of linear index positions 
% (this.dataStructure = 'listed'):
%   
% this.image = { [a1,a2,...,an] , [b1,b2,...,bn] , ... , [m1,m2,...,mn] }
%
% where each group [x1,...,xn] represents a component of the same label. 
% If the flag 'overlaySpec.randomizeColors' is set to false
% 'overlaySpec.colors' can be a cell of the form
%
% this.overlaySpec.colors = { [a_r, a_g, a_b] , ... , [m_r, m_g, mb] }
%
% where x_r, x_g, x_b are the red, green, and blue color component of the
% corresponding group x. 
%
%
% DEVELOPMENTAL NOTES
%
% Do we need something like this?
% this.index = [ a_minX, a_maxX, a_minY, a_maxY, a_minZ, a_maxZ ; ...
%                ... ; ...
%                m_minX, ... , m_maxZ]
%   Yes! simply use the position property and make it multidimensional!
%
%
classdef OverlayData < ImageData
    
    properties
        
        dataStructure   % 'listed' or 'classic'
        
    end
    
    methods
        
        % Constructor
        function overl = OverlayData(varargin)
            
%             overl = overl@ImageData(varargin{:});
            overl.setProperties(varargin{:});
            
        end
        
    end
    
    methods (Access = public)
        
        function addObject(this, position, matrix, color)
            % Function is for listed data type only!
            %
            %   position: [ minX, minY, minZ, maxX, maxY, maxZ ]
            %   matrix: 
            %       array form, e.g., matrix = [ 0,1,0; 1,1,1; 0,1,0 ]
            %       linear form, e.g., matrix = [ 2, 4, 5, 6, 8 ]
            %       For the matrixed form the matrix has to be of the
            %           same dimensionality as spanned by position, in the
            %           linear form the indices are based on a matrix of
            %           size position
            
            this.image = [this.image, {matrix}];
            this.position = [this.position; position];
            this.overlaySpec.colors = [this.overlaySpec.colors, {color}];
            
        end
        
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
            
            % Defaults
            this.dataStructure = 'classic';
            
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
                    elseif strcmp(varargin{i}, 'dataStructure')
                        this.dataStructure = varargin{i+1};
                        i = i+1;
                    end
                    
                end
                
            end
            
%             addlistener(this, 'image', 'PostSet', @this.image_postSet_cb);

            if strcmp(this.dataStructure, 'listed')
                
                this.cubeRange = [];
                this.cubeSize = [];
                this.bufferType = 'whole';
                
            else
                
            end
            
        end
        
        function loadVisibleSubImage(this, vis)
            
            %% Put functionalities for all datatypes here:
            % >>>
            
            % <<<
            
            %% For inherited data types the original function is called
            if ~strcmp(this.dataStructure, 'listed')
                loadVisibleSubImage@ImageData(vis);
                return;
            end
            
            %% Put functionalities for only the listed data type here:
            % >>>
            
            % <<<
            
        end
        
        function [planes] = createDisplayPlanes ...
                (this, planes, vis, imType)
            
            %% Put functionalities for all datatypes here:
            % >>>
            
            % <<<
            
            %% For inherited data types the original function is called
            if ~strcmp(this.dataStructure, 'listed')
                [planes] = createDisplayPlanes@ImageData(planes, vis, this.overlaySpec.overlayType, imType);
                return;
            end
                
            %% Put functionalities for only the listed data type here:
            % >>>
            
            % Return if the image is empty
            if isempty(this.image), return, end
            
            planes.toRGB();
            
            % Iterate over all objects
            for i = 1:length(this.image)
                if ~isempty(this.image{i})
                    pos = this.position(i,:);
                    if max(max(max(this.image{i}))) ~= 1
                        im = zeros(pos(4:6) - pos(1:3) + 1);
                        im(this.image{i}) = 1;
                    else
                        im = this.image{i};
                    end
                    [planes.XY, planes.XZ, planes.ZY, ~] = jh_overlayObject( ...
                        planes.XY, planes.XZ, planes.ZY, ...    images
                        vis.roundedPosition, ...                position
                        pos(1:3), ...                           object position
                        im, ...                                 object matrix
                        vis.displaySize, ...                    display size
                        vis.anisotropyFactor, ...               anisotropy factor
                        this.overlaySpec.overlayType, ...       overlay specifier
                        this.overlaySpec.colors{i}, 'rgb');
                end
            end
            
%             % Step1: find out if the image is present in the currently
%             % displayed section
%             % And for this we now have the position property
%             
%             
%             
%             
%             %   Create list of displayed linear indices with respect to the
%             %   overlay data
%             
%             [gXY, gXZ, gZY] = planes.createIndexGrids(this.totalImageSize, vis.currentPosition-this.position);
% %             gXY, gXZ, gZY
%             
%             %   Compare visible position indices with potentially visible
%             %   objects within the overlay data
%             
%             cp = vis.currentPosition;
%             ds = vis.displaySize;
%             af = vis.anisotropyFactor;
%             op = this.position;
%             os = this.totalImageSize;
%             
%             planes = this.createDisplayPlanesOfListed(planes, {gXY, gXZ, gZY});
            
            % <<<

        end
        
        
        function planes = createDisplayPlanesOfListed(this, planes, indexGrids)
            
            gridXY = indexGrids{1};
            gridXZ = indexGrids{2};
            gridZY = indexGrids{3};
            clear indexGrids
            
            indices = this.image;
            
%             tic
            for i = 1:length(indices)
                for j = 1:length(indices{i})
                    
                    if ~isempty(find(gridXY == indices{i}(j), 1))

                        planes.XY(gridXY == indices{i}(j)) = 1;
                        
                    end
                    
                    if ~isempty(find(gridXZ == indices{i}(j), 1))

                        planes.XZ(gridXZ == indices{i}(j)) = 1;
                        
                    end

                    if ~isempty(find(gridZY == indices{i}(j), 1))

                        planes.ZY(gridZY == indices{i}(j)) = 1;
                        
                    end

                end
            end
%             toc
            
%             tic
%             t = cellfun(@(x) arrayfun(@(v) ~isempty(find(gridXY == v, 1)), x), indices, 'uniformoutput', false);
%             toc
%             tic
%             for i = 1:length(t)
%                 
%                 if max(t{i}) == 1
%                     
%                     for j = 1:length(indices{i})
%                         planes.XY(gridXY == indices{i}(j)) = 1;
%                     end
%                     
%                 end
%                 
%             end
%             toc
        end
       
        
    end
    
    methods (Access = protected)

        function image_postSet_fcn(this)
            
            % The original function did not work for the new data structure
            if strcmp(this.dataStructure, 'listed')
                
            else
                if ~isempty(this.image) && ~isempty(this.cubeSize)

                    this.totalImageSize = ...
                        [size(this.image, 1), size(this.image, 2), size(this.image, 3)] ...
                        .* this.cubeSize;

                end
            end
            
            this.OnImageChanged();
            
        end
        
    end
    
end