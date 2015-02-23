classdef (ConstructOnLoad) DisplayEventData < event.EventData
    
    properties 
        
        display
        position
        
    end
    
    methods
        
        function data = DisplayEventData(dispPlane, position)
            
            data.display = dispPlane;
            data.position = position;
            
        end
        
    end
    
end