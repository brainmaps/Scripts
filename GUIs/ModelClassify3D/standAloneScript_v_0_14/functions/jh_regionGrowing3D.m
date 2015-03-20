function rg = jh_regionGrowing3D(regions, mask, nh, thresh, type, varargin)
%jh_regionGrowing3D performes a dilation-based region growing
% 
% SYNOPSIS
%   rg = jh_regionGrowing(regions, mask, nh, thresh, type)
%   rg = jh_regionGrowing(___, 'prefType', prefType)
%   rg = jh_regionGrowing(___, 'iterations', iterations)
%
% INPUT
%   regions: labeled or greyscale
%   mask: greyscale image, according its values the growing of regions is
%       performed
%   nh: neighborhood for dilation
%   thresh: threshold to determine the intensity values along which the
%       growing occurs
%   type: how the threshold is interpreted
%       's': smaller
%       'l': larger
%       'se': smaller or equal
%       'le': larger or equal
%       'e': equal
%       'ne': not equal
%   prefType (optional): specifies the data type of the output matrix
%       Default = class(mask)
%   iterations (optional): number of growing steps, when put to zero the
%       function continues until no change is detected
%       Default = 1
%
% OUTPUT
%   rg: the grown regions
%
% EXAMPLE
%
%   nh = ones(3, 3, 3);
%   rg = jh_regionGrowing(regions, mask, nh, .5, 's', 'iterations', 5, 'prefType', 'single')
%
%   --> Performes 5 growing steps of regions along the voxels of mask with
%       lower intensity than 0.5. rg is returned as data type 'single'

%% Check input

% Defaults
prefType = class(regions);
iterations = 1;
% Check input
i = 0;
while i < length(varargin)
    i = i+1;
    
    if strcmp(varargin{i}, 'prefType')
        prefType = varargin{i+1};
        i = i+1;
    elseif strcmp(varargin{i}, 'iterations')
        iterations = varargin{i+1};
        i = i+1;
    end
        
end


[n1, n2, n3] = size(regions);
%%

rg = cast(regions, prefType);


if iterations > 0

    for i = 1:iterations

        rgDil = imdilate(rg, nh);
        if strcmp(type, 's')
            rgDil(mask >= thresh) = 0;
        elseif strcmp(type, 'se')
            rgDil(mask > thresh) = 0;
        elseif strcmp(type, 'e')
            rgDil(mask ~= thresh) = 0;
        elseif strcmp(type, 'le')
            rgDil(mask < thresh) = 0;
        elseif strcmp(type, 'l')
            rgDil(mask <= thresh) = 0;
        elseif strcmp(type, 'ne')
            rgDil(mask == thresh) = 0;
        end
        rgDil(rg > 0) = rg(rg > 0);
        rg = rgDil;

    end

else
    
    rgDil = rg;
    rg = zeros(size(rg), prefType);

    while ~isequal(rg, rgDil)
        
        rg = rgDil;
        
        rgDil = imdilate(rg, nh);
        if strcmp(type, 's')
            rgDil(mask >= thresh) = 0;
        elseif strcmp(type, 'se')
            rgDil(mask > thresh) = 0;
        elseif strcmp(type, 'e')
            rgDil(mask ~= thresh) = 0;
        elseif strcmp(type, 'le')
            rgDil(mask < thresh) = 0;
        elseif strcmp(type, 'l')
            rgDil(mask <= thresh) = 0;
        elseif strcmp(type, 'ne')
            rgDil(mask == thresh) = 0;
        end
        rgDil(rg > 0) = rg(rg > 0);

    end
    
    rg = rgDil;

end


end

