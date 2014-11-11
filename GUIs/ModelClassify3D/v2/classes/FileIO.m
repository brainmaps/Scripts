classdef FileIO
    
    properties
        defaultFolder
        loadImageFolder
        loadProjectFolder
        loadOverlayFolder
        saveImageFolder
        saveProjectFolder
        saveOverlayFolder
        thisFolder
    end
    
    methods
        function io = FileIO(varargin)
            io.defaultFolder = varargin{1};
            if length(varargin) > 1
                io.loadImageFolder = varargin{2};
                io.loadProjectFolder = varargin{3};
                io.loadOverlayFolder = varargin{4};
                io.saveImageFolder = varargin{5};
                io.saveProjectFolder = varargin{6};
                io.saveOverlayFolder = varargin{7};
            end            
        end
    end
    
end