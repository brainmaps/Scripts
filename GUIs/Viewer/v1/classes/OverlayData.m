% This class inherits image data properties and functions.
% The basic idea is that the stored image can be a continuous image as in
% ImageData, or itself a cell array of linear index positions 
% (this.dataStructure = 'listed'):
%   
% this.image = { {a1, a2, ... , an}, {b1, b2, ... , bn}, ... , {m1, m2, ... , mn} }
%
% where each group a ... m represents a component of the same label. 
% If the flag 'overlaySpec.randomizeColors' is set to false
% 'overlaySpec.colors' can be a cell of the form
%
% this.overlaySpec.colors = { {a_r, a_g, a_b}, ... , {m_r, m_g, mb} }
%
% where x_r, x_g, x_b are the red, green, and blue color component of the
% corresponding group x. 
%
% Do we need something like this?
% this.index = [ a_minX, a_maxX, a_minY, a_maxY, a_minZ, a_maxZ ; ...
%                ... ; ...
%                m_minX, ... , m_maxZ]
classdef OverlayData < ImageData
    
    properties
        
        dataStructure   % 'listed' or 'classic'
        overlaySpec
        
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
                (this, planes, vis, type, imType)
            
            %% Put functionalities for all datatypes here:
            % >>>
            
            % <<<
            
            %% For inherited data types the original function is called
            if ~strcmp(this.dataStructure, 'listed')
                createDisplayPlanes@ImageData(planes, vis, type, imType);
                return;
            end
                
            %% Put functionalities for only the listed data type here:
            % >>>
            
            % Step1: find out if the image is present in the currently
            % displayed section
            
            %   Create list of displayed linear indices with respect to the
            %   overlay data
            cp = vis.currentPosition;
            ds = vis.displaySize;
            af = vis.anisotropyFactor;
            op = this.position;
            os = this.totalImageSize;
            minPosition = round((cp - round(ds/2) - op)./af);
            maxPosition = round((cp + round(ds/2) - op)./af);
            minPosition(minPosition<0) = 0;
            %       For xy
%             minpXY = [minPosition(1), minPosition(2), minPosition(3)];
%             minpXYlin = jh_zeroBasedSub2Ind(os, minpXY); 
%             maxpXY = [maxPosition(1), maxPosition(2), minPosition(3)];
%             maxpXYlin = jh_zeroBasedSub2Ind(os, maxpXY);
%             grid = (minpXYlin:maxPosition(2)-minPosition(2)+1);
%             grid = grid(ones(maxPosition(1)-minPosition(1)+1, 1), :);
%             grid = ndgrid(minpXYlin:maxPosition(2)-minPosition(2)+1, minpXYlin:maxPosition(1)-minPosition(1)+1)
            [g1, g2, g3] = meshgrid(minPosition(1):os(2):maxPosition(1)*os(2), minPosition(2):maxPosition(2), (cp(3)-op(3))*os(1)*os(2));
            gridXY = g1+g2+g3+1;
            
            g1(1:3, 1:3)
            g2(1:3, 1:3)
            g3(1:3, 1:3)
            gridXY(1:3, 1:3)
            
            clear g1 g2 g3;
            %       For xz
%             minpXZ = [minPosition(1), minPosition(3)];
            %       For zy
%             minpZY = [minPosition(3), minPosition(1)];
            
            
            
            % <<<

        end
        
    end
    
    methods (Access = protected)

        function image_postSet_fcn(this)
            
            % The original function did not work for the new data structure
            if strcmp(this.dataStructure, 'listed')
                
            else
                if ~isempty(this.image)

                    this.totalImageSize = ...
                        [size(this.image, 1), size(this.image, 2), size(this.image, 3)] ...
                        .* this.cubeSize;

                end
            end
            
            this.OnImageChanged();
            
        end
        
    end
    
end