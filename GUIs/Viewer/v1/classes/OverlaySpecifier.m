classdef OverlaySpecifier
    
    properties
        
        invert
        overlayType
        colors
        randomizeColors
        
    end
    
    methods
        
        function os = OverlaySpecifier(invert, overlayType, colors, randomizeColors)
            % invert = boolean
            % overlayType = 'mult', 'colorize', 'colorizeInv'
            % colors = [r, g, b], [fromHue toHue]
            % randomizeColors = boolean
        
            os.invert = invert;
            os.overlayType = overlayType;
            os.colors = colors;
            os.randomizeColors = randomizeColors;
            
        end
        
    end
    
end