classdef Data
    
    properties
        cubeRange       % [x, y, z]
        image
        anisotropic     % [x, y, z]
        cubeSize        % [x, y, z]
        bufferType
    end
    
    methods
        function dat = Data(varargin)
            dat.cubeRange = varargin{1};
            dat.image = varargin{2};
            dat.anisotropic = varargin{3};
            dat.cubeSize = varargin{4};
            dat.bufferType = varargin{5};
        end
    end
    
end