classdef VolumeDetector < Viewer
    
    % The menu extension
    properties
        
        % Tools...
        % > Tools        
            m_tools_createNewOverlay
            m_tools_setCalculationRange
            m_tools_calculateWatershed
        % <
        
    end
    
    properties (Access = public)
        
        watershedSeeds
        calculationRange
        
    end
    
    methods
        
        %% Constructor
        function MainWindow = VolumeDetector(varargin)

            %% Call superclass constructor
            % Initialize with already one overlay
            MainWindow = MainWindow@Viewer('name', 'MatKnossos :: VolumeDetector', ...
                varargin{:});
            
            %% The menu
            
            % Based on inherited items
            % Tools...
            % > Tools
                MainWindow.m_tools_createNewOverlay = uimenu(MainWindow.m_tools, ...
                    'Label', 'Create new overlay', ...
                    'Callback', @MainWindow.m_tools_createNewOverlay_cb);
                MainWindow.m_tools_setCalculationRange = uimenu(MainWindow.m_tools, ...
                    'Label', 'Set calculation range', ...
                    'Callback', @MainWindow.m_tools_setCalculationRange_cb, ...
                    'Separator', 'on');
                MainWindow.m_tools_calculateWatershed = uimenu(MainWindow.m_tools, ...
                    'Label', 'Calculate watershed', ...
                    'Callback', @MainWindow.m_tools_calculateWatershed_cb);
            % <
            
            % New items
            
            %% Listeners
            
            addlistener(MainWindow, 'DisplayMouseDownLeft', @MainWindow.displayMouseDownLeft_cb);
            addlistener(MainWindow, 'DisplayMouseDownRight', @MainWindow.displayMouseDownRight_cb);
            addlistener(MainWindow, 'DisplayMouseUpLeft', @MainWindow.displayMouseUpLeft_cb);
            addlistener(MainWindow, 'DisplayMouseUpRight', @MainWindow.displayMouseUpRight_cb);
            addlistener(MainWindow, 'AfterCreation', @MainWindow.afterCreation_cb);
            addlistener(MainWindow, 'ImageDataNumberChanged', @MainWindow.imageDataNumberChanged_cb);
            addlistener(MainWindow, 'ImageDataChanged', @MainWindow.imageDataChanged_cb);
            
            %% Call construction-associated event function
            if ~isempty(MainWindow.image)
                MainWindow.imageDataNumberChanged_cb(0, ImageDataNoChangeEventData(0, length(MainWindow.image)));
                MainWindow.imageDataChanged_cb(0, event.EventData());
            end
            
        end
        
    end
    
    %% Menu callbacks
    methods (Access = protected)
        
        function m_tools_createNewOverlay_cb(this, ~, ~)
            
            this.overlay{length(this.overlay)+1} = ...
                OverlayData( ...
                    'image', [], ...
                    'name', ['NewOverlay', num2str(length(this.overlay)+1)], ...
                    'dataType', 'single', ...
                    'anisotropic', this.image{1}.anisotropic, ...
                    'position', [], ...
                    'overlaySpec', OverlaySpecifier( ...
                        false, 'oneColor', [], false), ...
                    'totalImageSize', this.image{1}.totalImageSize, ...
                    'dataStructure', 'listed' );
            
        end
        function m_tools_setCalculationRange_cb(this, ~, ~)
            
            this.calculationRange = [100, 100, 100; 228, 200, 200];
            
            this.overlay{2}.position = [this.calculationRange(1, :), ...
                this.calculationRange(2, :)];
            
            this.overlay{2}.image{1} = zeros( ...
                this.calculationRange(2,2) - this.calculationRange(1,2), ...
                this.calculationRange(2,1) - this.calculationRange(1,1), ...
                this.calculationRange(2,3) - this.calculationRange(1,3));
            
            this.overlay{2}.image{1}(1:end, 1:end, 1) = 1;
            this.overlay{2}.image{1}(1:end, 1:end, end) = 1;
            this.overlay{2}.image{1}(1:end, 1, 1:end) = 1;
            this.overlay{2}.image{1}(1:end, end, 1:end) = 1;
            this.overlay{2}.image{1}(1, 1:end, 1:end) = 1;
            this.overlay{2}.image{1}(end, 1:end, 1:end) = 1;
                
        end
        function m_tools_calculateWatershed_cb(this, ~, ~)
            
            % Create seed matrix
            
            %   Initialize matrix
            seedMatrix = zeros( ...
                this.calculationRange(2,2) - this.calculationRange(1,2), ...
                this.calculationRange(2,1) - this.calculationRange(1,1), ...
                this.calculationRange(2,3) - this.calculationRange(1,3));

            %   Get seedpoints within calc range
            allSeeds = cellfun(@(x) x - this.calculationRange(1,:), this.watershedSeeds, 'uniformoutput', false);
            for i = 1:length(allSeeds)
                if min(allSeeds{i}) >= 0
                    add = true;
                    if allSeeds{i}(1) > size(seedMatrix, 2), add = false; end
                    if allSeeds{i}(2) > size(seedMatrix, 1), add = false; end
                    if allSeeds{i}(3) > size(seedMatrix, 3), add = false; end
                    if add
%                         seeds{c} = allSeeds{i};
                        seedMatrix(sub2ind(size(seedMatrix), allSeeds{i}(2)+1, allSeeds{i}(1)+1, allSeeds{i}(3)+1)) = 1;
                    end
                end
            end
            
            % Get the image section
            if strcmp(this.image{1}.bufferType, 'whole')
                
                % cubes muessen hier geladen und zusammengesetzt werden!
                % Oder so aehnlich
                
                im = this.image{1}( ...
                    this.calculationRange(1, 2) : this.calculationRange(2, 2), ...
                    this.calculationRange(1, 1) : this.calculationRange(2, 1), ...
                    this.calculationRange(1, 3) : this.calculationRange(2, 3))
                    
            else
                disp('Load whole image into buffer!');
            end
            
            % Perform watershed
%             jh_dip_waterseed(seedMatrix, 
            
        end
        
    end
    
    %% Main window callbacks
    methods (Access = protected)
        
        function displayMouseDownLeft_cb(this, ~, evnt)
            
            % DEBUG
            if this.debug
                evnt
            end
            
        end
        function displayMouseDownRight_cb(this, ~, evnt)
            
            % DEBUG
            if this.debug
                evnt
            end
            
        end
        function displayMouseUpLeft_cb(this, ~, evnt)
            
            % Return if this was not a click event
            if this.userInput.mouseEvent.downAt ~= evnt.position;
                return;
            end
            
            % Get the clicked position within the image data
            imagePosition = this.disp2imPosition(evnt.position, evnt.display);
            
            % Save it to the watershed seeds
            this.watershedSeeds{end+1} = imagePosition;

            % Write a new object into the overlay
            linInd = this.zeroBasedSub2Ind([9, 9, 3], [4, 4, 1]);
            
%             [nh, relSphere, ~] = jh_getNeighborhood3D(0, 5, ...
%                 'imgSize', this.overlay{1}.totalImageSize, ...
%                 'anisotropic', this.visualization.anisotropyFactor);
            [nh, relSphere, ~] = jh_getNeighborhood3D(0, 4, ...
                'anisotropic', this.visualization.anisotropyFactor);
            linSphere = linInd+relSphere;
            
%             this.overlay{1}.image = [ this.overlay{1}.image, ...
%                 {linSphere} ];
            
            setPosition = [imagePosition - ((size(nh)-1)/2), imagePosition + ((size(nh)-1)/2)];
            this.overlay{1}.addObject(setPosition, linSphere, [1 0 0]);
            
            this.displayCurrentPosition('');
            % DEBUG
            if this.debug
                this.overlay{1}.image
                evnt.position
            end
            
        end
        function displayMouseUpRight_cb(this, ~, evnt)
            
            % DEBUG
            if this.debug
                evnt
            end
            
        end
        
        function afterCreation_cb(this, ~)
            
        end
        
        function imageDataNumberChanged_cb(this, ~, evnt)
            
        end
        function imageDataChanged_cb(this, ~, evnt)
            
            if isempty(this.overlay)
                
                this.overlay{1} = ...
                    OverlayData( ...
                        'image', [], ...
                        'name', 'Watershed seeds', ...
                        'dataType', 'single', ...
                        'anisotropic', this.image{1}.anisotropic, ...
                        'position', [], ...
                        'overlaySpec', OverlaySpecifier( ...
                            false, 'oneColor', [], false), ...
                        'totalImageSize', this.image{1}.totalImageSize, ...
                        'dataStructure', 'listed' );
                    
                this.overlay{2} = ...
                    OverlayData( ...
                        'image', {1}, ...
                        'name', 'Calculation range', ...
                        'dataType', 'single', ...
                        'anisotropic', this.image{1}.anisotropic, ...
                        'position', [0,0,0,0,0,0], ...
                        'overlaySpec', OverlaySpecifier( ...
                            false, 'oneColor', {[1 1 0]}, false), ...
                        'totalImageSize', this.image{1}.totalImageSize, ...
                        'dataStructure', 'listed' );
                    
            end
            
        end
        
    end
    
    %%
    methods (Access = private)
       
        function iPos = disp2imPosition(this, dPos, dPlane)
            
            cPos = this.visualization.currentPosition;
            dSize = this.visualization.displaySize;
            iPos = cPos;
            
            switch dPlane
                case 'xy'
                    iPos(1:2) = iPos(1:2) + dPos - round(dSize/2);
                case 'xz'
                    iPos(1) = iPos(1) + dPos(1) - round(dSize/2);
                    iPos(3) = iPos(3) + round((dPos(2) - round(dSize/2)) / this.visualization.anisotropyFactor(3));
                case 'zy'
                    iPos(2) = iPos(2) + dPos(2) - round(dSize/2);
                    iPos(3) = iPos(3) + round((dPos(1) - round(dSize/2)) / this.visualization.anisotropyFactor(3));
            end
            
        end
        
        
    end
    
    %%
    methods (Static, Access = private)
        
        function ind = zeroBasedSub2Ind(imSize, position)
            
            position = position+1;
            imSize = [imSize(2), imSize(1), imSize(3)];
            ind = sub2ind(imSize, position(2), position(1), position(3));

        end

        
    end
    
       
end
