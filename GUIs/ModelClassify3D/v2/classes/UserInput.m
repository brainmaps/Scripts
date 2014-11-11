classdef UserInput
    
    properties
        keyEvent = KeyEvent;
        mouseEvent = MouseEvent;
    end
    
    methods 
        function uin = UserInput()
            uin.keyEvent.ctrlDown = false;
            uin.keyEvent.shiftDown = false;
            uin.keyEvent.altDown = false;
        end
    end
    
end