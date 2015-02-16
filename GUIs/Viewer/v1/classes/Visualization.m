classdef Visualization
    
    properties
        data
        currentPosition     % [x y z]
        displaySize         % [x y z]
        currentImage        % integer
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
        
        function vis = Visualization(curPos, dispSize, bSecPl, bOverlObj, spSize, anInterpT, anFactor, buffDel, curIm)
            vis.currentPosition = curPos;
            vis.displaySize = dispSize;
            vis.bSectionalPlanes = bSecPl;
            vis.bOverlayObjects = bOverlObj;
            vis.spacerSize = spSize;
            vis.anisotropicInterpolationType = anInterpT;
            vis.anisotropyFactor = anFactor;
            vis.bufferDelete = buffDel;
            vis.currentImage = curIm;
        end
        
        %% Get-sets
        
        function value = get.roundedPosition(this)
            value = round(this.currentPosition);
        end
        
        %% Operations
        

    end
    
end