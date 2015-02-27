classdef VolumeDetector < Viewer
    
    % The menu extension
    properties
        
        % Tools...
        % > Tools        
            m_tools_createNewOverlay
            m_tools_setCalculationRange
        % <
        
    end
    
    methods
        
        %% Constructor
        function MainWindow = VolumeDetector(varargin)
            %% Call superclass constructor
            MainWindow = MainWindow@Viewer('name', 'MatKnossos :: VolumeDetector', varargin{:});
            
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
            % <
            
            % New items
            
            %% Listeners
            
            addlistener(MainWindow, 'DisplayMouseDownLeft', @MainWindow.displayMouseDownLeft_cb);
            addlistener(MainWindow, 'DisplayMouseDownRight', @MainWindow.displayMouseDownRight_cb);
            addlistener(MainWindow, 'DisplayMouseUpLeft', @MainWindow.displayMouseUpLeft_cb);
            addlistener(MainWindow, 'DisplayMouseUpRight', @MainWindow.displayMouseUpRight_cb);
            
        end
        
    end
    
    methods (Access = protected)
        
        function m_tools_createNewOverlay_cb(this, ~, ~)
            
            this.overlay{length(this.overlay)+1} = ...
                OverlayData( ...
                    'image', [], ...
                    'name', ['NewOverlay', num2str(length(this.overlay)+1)], ...
                    'dataType', 'single', ...
                    'anisotropic', this.image{1}.anisotropic, ...
                    'position', [0 0 0], ...
                    'overlaySpec', OverlaySpecifier( ...
                        false, 'colorize', [0.5, 0, 0], false), ...
                    'totalImageSize', this.image{1}.totalImageSize, ...
                    'dataStructure', 'listed' );
            
        end
        function m_tools_setCalculationRange_cb(this, ~, ~)
            
        end
        
    end
    
    methods (Access = protected)
        
        function displayMouseDownLeft_cb(this, ~, evnt)
            
            evnt
            
        end
        function displayMouseDownRight_cb(this, ~, evnt)
            
            evnt
            
        end
        function displayMouseUpLeft_cb(this, ~, evnt)
            
            % Return if this was not a click event
            if this.userInput.mouseEvent.downAt ~= evnt.position;
                return;
            end
            
            % Get the clicked position within the image data
            imagePosition = this.disp2imPosition(evnt.position, evnt.display);
            
            % Write a new object into the overlay
            linInd = this.zeroBasedSub2Ind(this.overlay{1}.totalImageSize, imagePosition);
            this.overlay{1}.image = [ this.overlay{1}.image, ...
                {linInd} ];
            
        end
        function displayMouseUpRight_cb(this, ~, evnt)
            
            evnt
            
        end
        
    end
    
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
                    iPos(3) = iPos(3) + dPos(2) - round(dSize/2);
                case 'zy'
                    iPos(2) = iPos(2) + dPos(2) - round(dSize/2);
                    iPos(3) = iPos(3) + dPos(1) - round(dSize/2);
            end
            
        end
        
        
    end
    
    methods (Static, Access = private)
        
        function ind = zeroBasedSub2Ind(imSize, position)
            
            position = position+1;
            imSize = [imSize(2), imSize(1), imSize(3)];
            ind = sub2ind(imSize, position(2), position(1), position(3));

        end
        
    end
    
       
end
