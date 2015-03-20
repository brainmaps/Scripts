function [imageXY, imageXZ, imageYZ, visibility] = jh_overlayObject( ...
        imageXY, imageXZ, imageYZ, ...
        position, objectPosition, objectMatrix, ...
        displaySize, anisotropic, ...
        overlaySpec, osValue, imType, color)

    visibility = false;
    n = round(displaySize ./ anisotropic / 2) *2;
    objectPosition = objectPosition - [1 1 1];
    position = position - objectPosition;

%         kernel = cell(1, 3);
    kernelP = cell(1, 3);
    pad = zeros(1, 3);
    for i = 1:3
        if i == 1, j=2; end
        if i == 2, j=1; end
        if i == 3, j=3; end
        kernelP{i} = (-(n(i)/2) + 1 : (n(i)/2)) + position(i);
%             kernelP{i} = kernel{i} + position(i);
        pad(i) = n(i) - max(kernelP{i});
        kernelP{i} = kernelP{i}(kernelP{i} >= 1 & kernelP{i} <= size(objectMatrix, j));
    end

    if strcmp(overlaySpec, 'replace')
        
        % XY
        if position(3) > 0 && position(3) <= size(objectMatrix, 3) ...
                && ~isempty(kernelP{1}) && ~isempty(kernelP{2})
            imageXY(kernelP{2} + pad(2), kernelP{1} + pad(1)) = ...
                objectMatrix(kernelP{2}, kernelP{1}, position(3));
            visibility = true;
        end

        % XZ
        if position(2) > 0 && position(2) <= size(objectMatrix, 1) ...
                && ~isempty(kernelP{1}) && ~isempty(kernelP{3})
            imageXZ(kernelP{3} + pad(3), kernelP{1} + pad(1)) = ...
                permute(objectMatrix(position(2), kernelP{1}, kernelP{3}), [3, 2, 1]);
            visibility = true;
        end

        % YZ
        if position(1) > 0 && position(1) <= size(objectMatrix, 2) ...
                && ~isempty(kernelP{2}) && ~isempty(kernelP{3})
            imageYZ(kernelP{2} + pad(2), kernelP{3} + pad(3)) = ...
                permute(objectMatrix(kernelP{2}, position(1), kernelP{3}), [1, 3, 2]);
            visibility = true;
        end
        
    else
        
        % XY
        if position(3) > 0 && position(3) <= size(objectMatrix, 3) ...
                && ~isempty(kernelP{1}) && ~isempty(kernelP{2})
            overlayXY = zeros(n(2), n(1));
            overlayXY(kernelP{2} + pad(2), kernelP{1} + pad(1)) = ...
                objectMatrix(kernelP{2}, kernelP{1}, position(3));
            imageXY = jh_overlayLabels( ...
                imageXY, overlayXY, ...
                'type', 'colorize', ...
                overlaySpec, osValue, ...
                imType);
            visibility = true;
        end

        % XZ
        if position(2) > 0 && position(2) <= size(objectMatrix, 1) ...
                && ~isempty(kernelP{1}) && ~isempty(kernelP{3})
            overlayXZ = zeros(n(3), n(1));
            overlayXZ(kernelP{3} + pad(3), kernelP{1} + pad(1)) = ...
                permute(objectMatrix(position(2), kernelP{1}, kernelP{3}), [3, 2, 1]);
            imageXZ = jh_overlayLabels( ...
                imageXZ, overlayXZ, ...
                'type', 'colorize', ...
                overlaySpec, osValue, ...
                imType);
            visibility = true;
        end

        % ZY
        if position(1) > 0 && position(1) <= size(objectMatrix, 2) ...
                && ~isempty(kernelP{2}) && ~isempty(kernelP{3})
            overlayYZ = zeros(n(2), n(3));
            overlayYZ(kernelP{2} + pad(2), kernelP{3} + pad(3)) = ...
                permute(objectMatrix(kernelP{2}, position(1), kernelP{3}), [1, 3, 2]);
            imageYZ = jh_overlayLabels( ...
                imageYZ, overlayYZ, ...
                'type', 'colorize', ...
                overlaySpec, osValue, ...
                imType);
            visibility = true;
        end
        
    end
    
end

