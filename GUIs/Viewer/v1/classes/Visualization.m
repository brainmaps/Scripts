classdef Visualization
    
    properties
        currentPosition % [x y z]
        displaySize     % [x y z]
        bSectionalPlanes
        bOverlayObjects
        spacerSize
        anisotropicInterpolationType
        bufferDelete
    end
    
    methods
        function vis = Visualization(varargin)
            vis.currentPosition = varargin{1};
            vis.displaySize = varargin{2};
            vis.bSectionalPlanes = varargin{3};
            vis.bOverlayObjects = varargin{4};
            vis.spacerSize = varargin{5};
            vis.anisotropicInterpolationType = varargin{6};
            vis.bufferDelete = varargin{7};
        end
    end
    
end