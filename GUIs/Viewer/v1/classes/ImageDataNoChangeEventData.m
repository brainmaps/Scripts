classdef (ConstructOnLoad) ImageDataNoChangeEventData < event.EventData
    
    properties
        
        previous
        current
        
    end
    
    methods
        
        function data = ImageDataNoChangeEventData(prev, curr)
            
            data.previous = prev;
            data.current = curr;
            
        end
    
    end
    
end