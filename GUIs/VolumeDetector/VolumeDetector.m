classdef VolumeDetector < Viewer
    
    % The menu extension
    properties
        
        % Tools...
        % > Tools        
            m_tools_loadDipImageLibrary
            % -
            m_tools_setCalculationRange
            m_tools_calculateWatershed
            % -
            m_tools_activateInactivateBasin
            m_tools_nextBasin
            m_tools_previousBasin
            m_tools_markAsComplete
            % -
            m_tools_undoLastSeed
            % <
        
    end
    
    properties (Access = public)
        
        watershedSeeds
        calculationRange
        calculationRangeImage
        activeBasin             % ID of the active WS basin, 0 = no basin active
        colorListRandom         % Used to distinguish all WS basin; used for activeBasin == 0
        colorListActiveWS       % Overlay to display only active WS basin
        basinsComplete
        undoLastSeed_seedMatrix             % Structure to store previous settings
        undoLastSeed_seedImages
        undoLastSeed_basinOverlay
        undoLastSeed_seedPositions    
    
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
                MainWindow.m_tools_loadDipImageLibrary = uimenu(MainWindow.m_tools, ...
                    'Label', 'Load DIPImage library', ...
                    'Callback', @MainWindow.m_tools_loadDipImageLibrary_cb);
                % -
                MainWindow.m_tools_setCalculationRange = uimenu(MainWindow.m_tools, ...
                    'Label', 'Set calculation range', ...
                    'Callback', @MainWindow.m_tools_setCalculationRange_cb, ...
                    'Separator', 'on');
                MainWindow.m_tools_calculateWatershed = uimenu(MainWindow.m_tools, ...
                    'Label', 'Calculate watershed (W)', ...
                    'Callback', @MainWindow.m_tools_calculateWatershed_cb);
                % -
                MainWindow.m_tools_activateInactivateBasin = uimenu(MainWindow.m_tools, ...
                    'Label', 'Activate / inactivate basin (G)', ...
                    'Callback', @MainWindow.m_tools_activateInactivateBasin_cb, ...
                    'Separator', 'on');
                MainWindow.m_tools_nextBasin = uimenu(MainWindow.m_tools, ...
                    'Label', 'Next basin (F)', ...
                    'Callback', @MainWindow.m_tools_nextBasin_cb);
                MainWindow.m_tools_previousBasin = uimenu(MainWindow.m_tools, ...
                    'Label', 'Previous basin (D)', ...
                    'Callback', @MainWindow.m_tools_nextBasin_cb);
                MainWindow.m_tools_markAsComplete = uimenu(MainWindow.m_tools, ...
                    'Label', 'Mark as complete (C)', ...
                    'Callback', @MainWindow.m_tools_markAsComplete_cb);
                % -
                MainWindow.m_tools_undoLastSeed = uimenu(MainWindow.m_tools, ...
                    'Label', 'Undo last seed', ...
                    'Callback', @MainWindow.m_tools_undoLastSeed_cb, ...
                    'Accelerator', 'z', ...
                    'Separator', 'on', ...
                    'Enable', 'off');
            % <
            
            % New items
            
            %% Listeners
            
            addlistener(MainWindow, 'DisplayMouseDownLeft', @MainWindow.displayMouseDownLeft_cb);
            addlistener(MainWindow, 'DisplayMouseDownRight', @MainWindow.displayMouseDownRight_cb);
            addlistener(MainWindow, 'DisplayMouseUpLeft', @MainWindow.displayMouseUpLeft_cb);
            addlistener(MainWindow, 'DisplayMouseUpRight', @MainWindow.displayMouseUpRight_cb);
            addlistener(MainWindow, 'ImageDataNumberChanged', @MainWindow.imageDataNumberChanged_cb);
            addlistener(MainWindow, 'ImageDataChanged', @MainWindow.imageDataChanged_cb);
            
            %% Call construction-associated event function
            if ~isempty(MainWindow.image)
                MainWindow.imageDataNumberChanged_cb(0, ImageDataNoChangeEventData(0, length(MainWindow.image)));
                MainWindow.imageDataChanged_cb(0, event.EventData());
            end
            
            %% Call afterCreationFcn
            MainWindow.this_afterCreationFcn();
            
        end
        
    end
    
    %% Menu callbacks
    methods (Access = protected)
        
        function m_tools_loadDipImageLibrary_cb(this, ~, ~)
            
            % Try to initialize the Dip library
            % If this fails the GUI will not be opened
            try

                warning off
                try
                    addpath('C:\Program Files\DIPimage 2.5.1\common\dipimage');
                catch
                end
                warning on
                evalc('dip_initialise;');

                fprintf('Dip library found and loaded successfully.\n\n');

            catch

                close(handles.figMain);

                fprintf('\nERROR: Dip library not found. \n');
                fprintf('    Consider loading Dip library manually before starting ModelClassify3D.\n\n');
                return

            end
            
        end
        function m_tools_setCalculationRange_cb(this, ~, ~)
            
            % User input to specify calculation range
            calcRange = inputdlg( ...
                {'From (x, y, z)', 'To (x, y, z)'}, ...
                'Set calculation range...', ...
                1, ...
                {'0, 0, 0', '100, 100, 100'});
            
            % Interpret input
            rangeFrom = strsplit(calcRange{1}, {', ', ','});
            rangeTo = strsplit(calcRange{2}, {', ', ','});
            this.calculationRange = [str2double(rangeFrom{1}), str2double(rangeFrom{2}), str2double(rangeFrom{3}); ...
                                     str2double(rangeTo{1}), str2double(rangeTo{2}), str2double(rangeTo{3})];
                
%             this.calculationRange = [100, 100, 100; 228, 200, 200];
            
            % Everything to make the range visible...
            this.overlay{2}.position = [this.calculationRange(1, :), ...
                this.calculationRange(2, :)];
            
            this.overlay{2}.image{1} = zeros( ...
                this.calculationRange(2,2) - this.calculationRange(1,2)+1, ...
                this.calculationRange(2,1) - this.calculationRange(1,1)+1, ...
                this.calculationRange(2,3) - this.calculationRange(1,3)+1);
            
            this.overlay{2}.image{1}(1:end, 1:end, 1) = 1;
            this.overlay{2}.image{1}(1:end, 1:end, end) = 1;
            this.overlay{2}.image{1}(1:end, 1, 1:end) = 1;
            this.overlay{2}.image{1}(1:end, end, 1:end) = 1;
            this.overlay{2}.image{1}(1, 1:end, 1:end) = 1;
            this.overlay{2}.image{1}(end, 1:end, 1:end) = 1;
            
            % Load the image and calculate the pre-step
            
            % Get the image section
            if strcmp(this.image{1}.bufferType, 'whole')
                
                position = this.calculationRange(1, :);
                sze = this.calculationRange(2,:) - this.calculationRange(1,:);
                subIm = this.image{1}.getSubImage(position, sze);
  
            else
                disp('Load whole image into buffer!');
            end
            
            % Add Gaussian
%             subIm = 0.90*subIm + 0.1*jh_dip_gaussianFilter3D(subIm, 5, 3, [1 1 3]);
            % Add distance transform
            subIm = 0.90*subIm + 0.10*(1-jh_normalizeMatrix(bwdist(subIm)));
            
            this.calculationRangeImage = subIm;
            
        end
        function m_tools_calculateWatershed_cb(this, ~, ~)
            
            this.calculateWS();
            
        end
        function m_tools_activateInactivateBasin_cb(this, ~, ~)
            
            persistent lastActive
            if isempty(lastActive), lastActive = 1; end
            
            if this.activeBasin == 0
                % Watershed view is currently active, set to active view
                
                this.activeBasin = lastActive;
                
            else
                % Active view is currently active, set to watershed view
                
                lastActive = this.activeBasin;
                this.activeBasin = 0;
                
            end
            
            this.switchActiveBasin(this.activeBasin);
            
        end
        function m_tools_nextBasin_cb(this, ~, ~)
            
            this.activeBasin = this.activeBasin + 1;
            if this.activeBasin > length(this.overlay{1}.image)
                this.activeBasin = 1;
            end
            
            this.switchActiveBasin(this.activeBasin);
            
        end
        function m_tools_previousBasin_cb(this, ~, ~)
            
            this.activeBasin = this.activeBasin - 1;
            if this.activeBasin < 1
                this.activeBasin = length(this.overlay{1}.image); 
            end
            
            this.switchActiveBasin(this.activeBasin);
            
        end
        function m_tools_markAsComplete_cb(this, ~, ~)
            
            if this.basinsComplete(this.activeBasin) == 0
                this.basinsComplete(this.activeBasin) = 1;
            else
                this.basinsComplete(this.activeBasin) = 0;
            end
            
            this.colorListActiveWS = this.createActiveBasinColorList(this.activeBasin);
            if this.activeBasin > 0
                this.overlay{3}.overlaySpec.colors = this.colorListActiveWS;
            end
            
            this.displayCurrentPosition('set');
            
        end
        function m_tools_undoLastSeed_cb(this, ~, ~)
            
            set(this.m_tools_undoLastSeed, 'Enable', 'off');
            
            this.watershedSeeds = this.undoLastSeed_seedMatrix;
            this.overlay{1}.image = this.undoLastSeed_seedImages;
            this.overlay{1}.position = this.undoLastSeed_seedPositions;
            this.overlay{3} = this.undoLastSeed_basinOverlay;
            
            this.displayCurrentPosition('');
            
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
            
            % Place the seed
            this.placeSeed(imagePosition, true);
            
        end
        function displayMouseUpRight_cb(this, ~, evnt)
            
            % DEBUG
            if this.debug
                evnt
            end
            
        end
        
        function this_afterCreationFcn(this)
            
            % Call superclass function
            this_afterCreationFcn@Viewer(this);
            
            this.activeBasin = 0;
            
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
                            false, 'add', [], false), ...
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
                            false, 'add', {[1 1 0]}, false), ...
                        'totalImageSize', this.image{1}.totalImageSize, ...
                        'dataStructure', 'listed' );
                    
            end
            
        end
        
        function this_keyPressFcn(this, src, evnt)
            
            this_keyPressFcn@Viewer(this, src, evnt);
            
            % Key press event without any modifier
            if isempty(evnt.Modifier)
                
                switch evnt.Key
                    case 'w'
                        this.m_tools_calculateWatershed_cb(src, evnt);
                    case 'g'
                        this.m_tools_activateInactivateBasin_cb(src, evnt);
                    case 'f'
                        this.m_tools_nextBasin_cb(src, evnt);
                    case 'd'
                        this.m_tools_previousBasin_cb(src, evnt);
                    case 'c'
                        this.m_tools_markAsComplete_cb(src, evnt);
                end
            end
                
            
%             if strcmp(eventdata.Key, 'control')
%                 this.userInput.keyEvent.ctrlDown = true;
%             end
%             if strcmp(eventdata.Key, 'shift')
%                 this.userInput.keyEvent.shiftDown = true;
%             end
%             if strcmp(eventdata.Key, 'alt')
%                 this.userInput.keyEvent.altDown = true;
%             end
            
        end
        
    end
    
    %% Watershed associated
    methods (Access = private)
        
        function placeSeed(this, imagePosition, calculateWS)
            
            % Store temporary to make undo possible
            this.undoLastSeed_seedMatrix = this.watershedSeeds;
            this.undoLastSeed_seedImages = this.overlay{1}.image;
            this.undoLastSeed_seedPositions = this.overlay{1}.position;
            if length(this.overlay) > 2
                this.undoLastSeed_basinOverlay = this.overlay{3};
            else
                this.undoLastSeed_basinOverlay = [];
            end
            set(this.m_tools_undoLastSeed, 'Enable', 'on');
            
            % Return if outside calculation range
            if ~this.insideCalculationRange(imagePosition), return; end
            
            % Save it to the watershed seeds
            this.watershedSeeds{end+1} = imagePosition;

            % Write a new object into the overlay
%             linInd = this.zeroBasedSub2Ind([9, 9, 3], [4, 4, 1]);
            
%             [nh, relSphere, ~] = jh_getNeighborhood3D(0, 5, ...
%                 'imgSize', this.overlay{1}.totalImageSize, ...
%                 'anisotropic', this.visualization.anisotropyFactor);
            [nh, ~, ~] = jh_getNeighborhood3D(0, 4, ...
                'anisotropic', this.visualization.anisotropyFactor);
%             linSphere = linInd+relSphere;
            
%             this.overlay{1}.image = [ this.overlay{1}.image, ...
%                 {linSphere} ];
            
            setPosition = [imagePosition - ((size(nh)-1)/2), imagePosition + ((size(nh)-1)/2)];
            this.overlay{1}.addObject(setPosition, nh, [1 0 0], 'add');
            
            if isempty(calculateWS), calculateWS = false; end
            if calculateWS
                this.calculateWS()
            end
            
            
            this.displayCurrentPosition('');
            % DEBUG
            if this.debug
                this.overlay{1}.image
                evnt.position
            end
            
        end
        
        function calculateWS(this)
            
            tic
            
            if isempty(this.watershedSeeds)
                
                return;
                
            elseif length(this.watershedSeeds) == 1
                
                ims = { ones( ...
                    this.calculationRange(2,2) - this.calculationRange(1,2)+1, ...
                    this.calculationRange(2,1) - this.calculationRange(1,1)+1, ...
                    this.calculationRange(2,3) - this.calculationRange(1,3)+1, 'int32') };
                
                positions = [this.calculationRange(1, :), this.calculationRange(2, :)];
                
            else
                
                % Initialize seed matrix
                seedMatrix = zeros( ...
                    this.calculationRange(2,2) - this.calculationRange(1,2)+1, ...
                    this.calculationRange(2,1) - this.calculationRange(1,1)+1, ...
                    this.calculationRange(2,3) - this.calculationRange(1,3)+1, 'int32');
                
                % Put the seed points
                allSeeds = cellfun(@(x) x - this.calculationRange(1,:), this.watershedSeeds, 'uniformoutput', false);
                for i = 1:length(allSeeds)
                    if min(allSeeds{i}) >= 0
                        seedMatrix(sub2ind(size(seedMatrix), allSeeds{i}(2)+1, allSeeds{i}(1)+1, allSeeds{i}(3)+1)) = i;
                    end
                end
                
                % Get the image section
                subIm = this.calculationRangeImage;                
                
                % Initialize the image for watershed calculation
                calcIm = inf( ...
                    this.calculationRange(2,2) - this.calculationRange(1,2)+1, ...
                    this.calculationRange(2,1) - this.calculationRange(1,1)+1, ...
                    this.calculationRange(2,3) - this.calculationRange(1,3)+1, 'single');
                
                ox = this.overlay{3}.position(this.activeBasin, 1);
                oy = this.overlay{3}.position(this.activeBasin, 2);
                oz = this.overlay{3}.position(this.activeBasin, 3);
                
                sx = size(this.overlay{3}.image{this.activeBasin}, 2);
                sy = size(this.overlay{3}.image{this.activeBasin}, 1);
                sz = size(this.overlay{3}.image{this.activeBasin}, 3);
                
%                 px = this.calculationRange(1, 1);
%                 py = this.calculationRange(1, 2);
%                 pz = this.calculationRange(1, 3);

                % Extract the necessary part of the subimage
                subIm = subIm(oy+1:oy+sy, ox+1:ox+sx, oz+1:oz+sz);
                % And put the active basin into the calculation image
                tCalcIm = calcIm(oy+1:oy+sy, ox+1:ox+sx, oz+1:oz+sz);
                tCalcIm(this.overlay{3}.image{this.activeBasin} == 1) = subIm(this.overlay{3}.image{this.activeBasin} == 1);
                clear subIm
                calcIm(oy+1:oy+sy, ox+1:ox+sx, oz+1:oz+sz) = tCalcIm;
                clear tCalcIm
                
                % Clear all seeds at infinity
                seedMatrix(calcIm == inf) = 0;
                
                % Calculate WS
                ws = im2mat(jh_dip_waterseed(seedMatrix, calcIm, 2, 0, 0));
                
                ims = this.overlay{3}.image;
                positions = this.overlay{3}.position;
                for i = 1:max(max(max(ws)))
                    if ~isempty(find(ws == i, 1))
                        ims{i} = zeros(size(ws));
                        ims{i}(ws == i) = 1;
                        [offset, width, ims{i}] = this.reduceMatrix(ims{i});
                        positions(i, :) = [this.calculationRange(1, :)+offset, offset+width-1];
                    end
                end
                
%                 positions = [this.calculationRange(1, :), this.calculationRange(2, :)];
%                 positions = positions(ones(length(ims),1),:);
                               
            end
            
            this.extendRandomColorList();
            if this.activeBasin > 0
                this.colorListActiveWS = this.createActiveBasinColorList(this.activeBasin);
                colorList = this.colorListActiveWS;
            else
                colorList = this.colorListRandom;
            end
            
            this.overlay{3} = ...
                OverlayData( ...
                    'image', ims, ...
                    'name', 'Watershed', ...
                    'dataType', 'int32', ...
                    'anisotropic', this.image{1}.anisotropic, ...
                    'position', positions, ...
                    'overlaySpec', OverlaySpecifier( ...
                        false, 'colorize', colorList, false), ...
                    'totalImageSize', this.calculationRange(2, :)-this.calculationRange(1, :)+1, ...
                    'dataStructure', 'listed' );
                
            t = this.basinsComplete;
            this.basinsComplete = zeros(length(this.watershedSeeds), 1);
            this.basinsComplete(1:length(t)) = t;
            clear t

            toc 
            
        end
        
        function switchActiveBasin(this, ID)
            
            if ID == 0
                
                this.overlay{3}.overlaySpec.colors = this.colorListRandom;
                
            else
                
                this.colorListActiveWS = this.createActiveBasinColorList(ID);

                this.overlay{3}.overlaySpec.colors = this.colorListActiveWS;
                
                this.jumpToActiveSeedPosition();
            end
            
            this.displayCurrentPosition('set');
            
        end
        
        function colorList = createActiveBasinColorList(this, ID)
            
            colorList = cell(length(this.watershedSeeds), 1);
            colorList = cellfun(@(x) [0.5, 0, 0], colorList, 'uniformoutput', false);
            if this.basinsComplete(ID) == 1
                colorList{ID} = [0.5, 1, 0.6];
            else
                colorList{ID} = [0.95, 0.9, 1];
            end
            
        end
        function extendRandomColorList(this)
            
            if length(this.colorListRandom) < length(this.watershedSeeds)
               
                count = length(this.watershedSeeds) - length(this.colorListRandom);
                
                hues = rand(count, 1, 'double');
                
                for i = length(this.colorListRandom)+1:length(this.colorListRandom)+count
                    
                    this.colorListRandom{i} = hsv2rgb([hues(i-length(this.colorListRandom)), 1, 0.7]);
                    
                end
                
            end
            
        end
        
        function jumpToActiveSeedPosition(this)
            
            activeSeed = this.watershedSeeds{this.activeBasin};
            
            this.visualization.currentPosition = activeSeed;
            this.displayCurrentPosition('set');
            
            
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
        
        function icr = insideCalculationRange(this, position)
            
            icr = false;
            
            if isempty(this.calculationRange), return, end
            
            if position(1) >= this.calculationRange(1, 1) ...
                    && position(1) <= this.calculationRange(2, 1)
               if position(2) >= this.calculationRange(1, 2) ...
                       && position(2) <= this.calculationRange(2, 2)
                   if position(3) >= this.calculationRange(1, 3) ...
                           && position(3) <= this.calculationRange(2, 3)
                       
                       icr = true;
                       
                   end
               end                
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
        
        function [offset, width, M] = reduceMatrix(M)
            
            z = find(max(max(M)) > 0);
            y = find(max(max(permute(M, [2, 3, 1]))) > 0);
            x = find(max(max(permute(M, [3, 1, 2]))) > 0);
            
            M = M(y(1):y(end), x(1):x(end), z(1):z(end));
            offset = [x(1)-1, y(1)-1, z(1)-1];
            width = [x(end)-x(1)+1, y(end)-y(1)+1, z(end)-z(1)+1];
            
        end

        
    end
    
       
end
