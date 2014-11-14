classdef Visualization
    
    properties
        data
        currentPosition     % [x y z]
        displaySize         % [x y z]
        bSectionalPlanes
        bOverlayObjects
        spacerSize
        anisotropicInterpolationType
        anisotropyFactor    % [x y z]
        bufferDelete
    end
    
    properties (Dependent)
        
        roundedPosition

    end
    
    methods
        
        %% Initialization
        
        function vis = Visualization(varargin)
            vis.currentPosition = varargin{1};
            vis.displaySize = varargin{2};
            vis.bSectionalPlanes = varargin{3};
            vis.bOverlayObjects = varargin{4};
            vis.spacerSize = varargin{5};
            vis.anisotropicInterpolationType = varargin{6};
            vis.anisotropyFactor = varargin{7};
            vis.bufferDelete = varargin{8};
        end
        
        %% Get-sets
        
        function value = get.roundedPosition(this)
            value = round(this.currentPosition);
        end
        
        %% Operations
        
        
    end
    
end