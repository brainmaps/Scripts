classdef MainSettings
   
    properties
        prefType
        windowBackColor        
    end
    
    methods
        function mset = MainSettings(varargin)
            mset.prefType = varargin{1};
            mset.windowBackColor = varargin{2};
        end
    end
    
end