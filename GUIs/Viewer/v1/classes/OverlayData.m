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
        visible
        
    end
    
    methods
        
        % Constructor
        function overl = OverlayData(varargin)
            
%             overl = overl@ImageData(varargin{:});
            overl.setProperties(varargin{:});
            
        end
        
    end
    
    methods (Access = public)
        
        function addObject(this, position, matrix, color, overlayType)
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
            %   overlayType: 'add', 'colorize'
            
            
            this.image = [this.image, {matrix}];
            this.position = [this.position; position];
            this.overlaySpec.colors = [this.overlaySpec.colors, {color}];
            this.overlaySpec.overlayType = overlayType;
            
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
            
%             disp(num2str(length(this.image)));

            % The new version:
            % Create overlay planes
            planesOl = DisplayPlanes( ...
                zeros(size(planes.XY)), ...
                zeros(size(planes.XZ)), ...
                zeros(size(planes.ZY)));
            planesOl.toRGB();
            
            % Iterate over all objects
            for i = 1:length(this.image)
                if ~isempty(this.image{i})
                    
                    % The old version:
                    % One overlay calculation for each matrix... time consuming!
                    %{
                    pos = this.position(i,:);
                    if size(this.image{i}, 2) == 1
%                         im = zeros(pos(4:6) - pos(1:3) + 1);
                        im = zeros(pos(5)-pos(2)+1, pos(4)-pos(1)+1, pos(6)-pos(3)+1);
                        im(this.image{i}) = 1;
                    else
                        im = this.image{i};
                    end
                    
                    if this.checkIfVisible(vis, i);
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
                    %}
                    
                    % The new version:
                    % Create a color map which is the input for a
                    %   subsequent overlay function
                    planesOl = this.createOverlay_addObject(planesOl, i, vis);
                    
                end
            end
            
            % The new version:
            % The overlay function
            planes = this.createOverlay_overlayMatrix(planes, planesOl);
            
            % <<<

        end
        
        function planes = createOverlay_addObject(this, planes, objToAdd, vis)
            
            pos = this.position(objToAdd,:);
            if size(this.image{objToAdd}, 2) == 1
%                         im = zeros(pos(4:6) - pos(1:3) + 1);
                objectMatrix = zeros(pos(5)-pos(2)+1, pos(4)-pos(1)+1, pos(6)-pos(3)+1);
                objectMatrix(this.image{objToAdd}) = 1;
            else
                objectMatrix = this.image{objToAdd};
            end
            
            n = round(vis.displaySize ./ vis.anisotropyFactor / 2) *2;
            objectPosition = this.position(objToAdd,1:3);
            objectPosition = objectPosition - [1 1 1];
            position = vis.roundedPosition - objectPosition;
            

            kernelP = cell(1, 3);
            pad = zeros(1, 3);
            for i = 1:3
                if i == 1, j=2; end
                if i == 2, j=1; end
                if i == 3, j=3; end
                kernelP{i} = (-(n(i)/2) + 1 : (n(i)/2)) + position(i);
                pad(i) = n(i) - max(kernelP{i});
                kernelP{i} = kernelP{i}(kernelP{i} >= 1 & kernelP{i} <= size(objectMatrix, j));
            end


            % XY
            if position(3) > 0 && position(3) <= size(objectMatrix, 3) ...
                    && ~isempty(kernelP{1}) && ~isempty(kernelP{2})
                overlayXY = zeros(n(2), n(1));
                overlayXY(kernelP{2} + pad(2), kernelP{1} + pad(1)) = ...
                    objectMatrix(kernelP{2}, kernelP{1}, position(3));
               
                planes.XY = this.createOverlay_addOverlay(planes.XY, this.overlaySpec.colors{objToAdd}, overlayXY);

            end

            % XZ
            if position(2) > 0 && position(2) <= size(objectMatrix, 1) ...
                    && ~isempty(kernelP{1}) && ~isempty(kernelP{3})
                overlayXZ = zeros(n(3), n(1));
                overlayXZ(kernelP{3} + pad(3), kernelP{1} + pad(1)) = ...
                    permute(objectMatrix(position(2), kernelP{1}, kernelP{3}), [3, 2, 1]);

                planes.XZ = this.createOverlay_addOverlay(planes.XZ, this.overlaySpec.colors{objToAdd}, overlayXZ);

            end

            % ZY
            if position(1) > 0 && position(1) <= size(objectMatrix, 2) ...
                    && ~isempty(kernelP{2}) && ~isempty(kernelP{3})
                overlayYZ = zeros(n(2), n(3));
                overlayYZ(kernelP{2} + pad(2), kernelP{3} + pad(3)) = ...
                    permute(objectMatrix(kernelP{2}, position(1), kernelP{3}), [1, 3, 2]);

                planes.ZY = this.createOverlay_addOverlay(planes.ZY, this.overlaySpec.colors{objToAdd}, overlayYZ);
                
            end
    
        end
        function plane = createOverlay_addOverlay(~, plane, color, overlay)

                
                r = plane(:,:,1);
                g = plane(:,:,2);
                b = plane(:,:,3);
                r(overlay == 1) = color(1);
                g(overlay == 1) = color(2);
                b(overlay == 1) = color(3);
                plane(:,:,1) = r;
                plane(:,:,2) = g;
                plane(:,:,3) = b;

                
        end
        function planesBack = createOverlay_overlayMatrix(this, planesBack, planesOv)
            
            if strcmp(this.overlaySpec.overlayType, 'colorize')
                sumBefore = sum(planesBack.XY, 3);
                sumBefore(:,:,2) = sumBefore(:,:,1);
                sumBefore(:,:,3) = sumBefore(:,:,1);
                planesBack.XY = planesBack.XY + planesOv.XY;
                sumAfter = sum(planesBack.XY, 3);
                sumAfter(:,:,2) = sumAfter(:,:,1);
                sumAfter(:,:,3) = sumAfter(:,:,1);
                planesBack.XY = planesBack.XY ./ sumAfter .* sumBefore;

                sumBefore = sum(planesBack.XZ, 3);
                sumBefore(:,:,2) = sumBefore(:,:,1);
                sumBefore(:,:,3) = sumBefore(:,:,1);
                planesBack.XZ = planesBack.XZ + planesOv.XZ;
                sumAfter = sum(planesBack.XZ, 3);
                sumAfter(:,:,2) = sumAfter(:,:,1);
                sumAfter(:,:,3) = sumAfter(:,:,1);
                planesBack.XZ = planesBack.XZ ./ sumAfter .* sumBefore;

                sumBefore = sum(planesBack.ZY, 3);
                sumBefore(:,:,2) = sumBefore(:,:,1);
                sumBefore(:,:,3) = sumBefore(:,:,1);
                planesBack.ZY = planesBack.ZY + planesOv.ZY;
                sumAfter = sum(planesBack.ZY, 3);
                sumAfter(:,:,2) = sumAfter(:,:,1);
                sumAfter(:,:,3) = sumAfter(:,:,1);
                planesBack.ZY = planesBack.ZY ./ sumAfter .* sumBefore;

            else % 'add'
                planesBack.XY = planesBack.XY + planesOv.XY;
                planesBack.XY(planesBack.XY > 1) = 1;
                planesBack.XZ = planesBack.XZ + planesOv.XZ;
                planesBack.XZ(planesBack.XZ > 1) = 1;
                planesBack.ZY = planesBack.ZY + planesOv.ZY;
                planesBack.ZY(planesBack.ZY > 1) = 1;
            end
        end
        
        function visible = checkIfVisible(this, vis, ID)
            
            visible = true;
            
%             cp = vis.roundedPosition;
%             op = this.position;
%             
%             if cp(1) < op(ID,1) || cp(1) > op(ID, 4)
%                     && cp(2) < op(ID,2) || cp(2) > op(ID, 5)
%                 visible = false;
%             end
%             if cp(3) < op(ID,3) || cp(3) > op(ID, 6)
%                 visible = false;
%             end
            
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
    
    % Overwritten stuff
    methods (Access = protected)
        
        %% FileIO
        
        % Overwrite exportImage_whole function to make it suitable also for
        % the listed data type
        function status = exportImage_whole(this, path)
            
            %% Put functionalities for all datatypes here:
            % >>>
            
            % <<<
            
            %% For inherited data types the original function is called
            if ~strcmp(this.dataStructure, 'listed')
                status = exportImage_whole@ImageData(vis);
                return;
            end
            
            %% Put functionalities for only the listed data type here:
            % >>>
            
            try
                
                % Build the image
                im = this.listed2image();

                % Save image
                jh_saveImageAsTiff3D(jh_normalizeMatrix(im), path, 'gray');
                
                % Success!
                status = 1;

            catch
                % WTF!
                status = 0;
            end
            
            % <<<
            
        end        
        
    end
    
    methods (Access = private)
        
        function im = listed2image(this)
            
            im = zeros(this.totalImageSize);
            
            for i = 1:length(this.image)
                
                tim = im( ...
                        this.position(i,2)+1:this.position(i,5)+1, ...
                        this.position(i,1)+1:this.position(i,4)+1, ...
                        this.position(i,3)+1:this.position(i,6)+1 ...
                    );
                
                tim(this.image{i} > 0) = this.image{i}(this.image{i} > 0) * i;
                
                im( ...
                        this.position(i,2)+1:this.position(i,5)+1, ...
                        this.position(i,1)+1:this.position(i,4)+1, ...
                        this.position(i,3)+1:this.position(i,6)+1 ...
                    ) = ...
                    tim;
                    
            end
            
        end
        
    end
    
end