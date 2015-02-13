function overlayImage = jh_overlayLabels(image, labels, varargin)
%jh_overlayLabels layes a label image over a greyscale image.
%
% SYNOPSIS
%   overlayImage = jh_overlayLabels(image, labels)
%   overlayImage = jh_overlayLabels(___, 'oneColor', color)
%   overlayImage = jh_overlayLabels(___, 'inv')
%   overlayImage = jh_overlayLabels(___, 'type', type)
%   overlayImage = jh_overlayLabels(___, input)
%   overlayImage = jh_overlayLabels(___, 'range', range)
%   overlayImage = jh_overlayLabels(___, 'randomizeColors')
%
% INPUT
%   color: RGB color
%   'inv': the label information will be inverted
%   type: defines the overlay type
%       'mult' (default), 'add', 'mean', 'addInv', 'colorize', 'colorizeInv'
%   input: defines the type of input data
%       'gray' (default), 'rgb'
%   range: color range specified by 1 x 2 vector [high low] specifying the
%       hue range
%       Default = [0 .67] (equals [red blue])

%% Check input

% Defaults
oneColor = 0;
inv = 0;
type = 'mult';
input = 'gray';
useRange = false;
range = [0 .67];
randomizeColors = false;
%
i = 0;
while i < length(varargin)
    i = i+1;
    
    if strcmp(varargin{i}, 'oneColor')
        oneColor = 1;
        color = varargin{i+1};
        i = i+1;
    elseif strcmp(varargin{i}, 'inv')
        inv = 1;
    elseif strcmp(varargin{i}, 'type')
        type = varargin{i+1};
        i = i+1;
    elseif strcmp(varargin{i}, 'rgb')
        input = 'rgb';
    elseif strcmp(varargin{i}, 'gray')
        input = 'gray';
    elseif strcmp(varargin{i}, 'range')
        range = varargin{i+1};
        useRange = true;
        i = i+1;
    elseif strcmp(varargin{i}, 'randomizeColors')
        randomizeColors = true;
    end
    
end


%%

if jh_globalMax(labels) == 0 && ~strcmp(type, 'colorizeInv')
    overlayImage = image;
    return;
end

if oneColor
    overlayImage = oneColorOverlay(image, labels, color, type, inv, input);
else
    overlayImage = labelOverlay(image, labels, type, inv, input, range, useRange, randomizeColors);
end

end

function overlayImage = labelOverlay(image, labels, type, inv, input, range, useRange, randomizeColors)

[n1, n2, n3, n4] = size(image);
n = n1*n2*n3;
prefType = class(labels);

if n3 > 1 && strcmp(input, 'gray')
    
    if strcmp(input, 'gray')
        overlayImage(:,:,:,1) = image;
        overlayImage(:,:,:,2) = image;
        overlayImage(:,:,:,3) = image;
    else
        overlayImage = image;
    end
    
    if randomizeColors
        
        uniqueLabels = unique(labels);
        uniqueLabels = uniqueLabels(uniqueLabels ~= 0);
        r = randperm(length(uniqueLabels));
        switchedLabels = uniqueLabels(r);
        labelPositions = arrayfun(@(x) find(labels == x), uniqueLabels, 'UniformOutput', false);
        
        for i = 1:length(uniqueLabels)
            
            labels(labelPositions{i}) = switchedLabels(i);
            
        end
        
    end
    
    hues = labels;
    
    % Saturation and Value channel
    saturation = ones(n1,n2,n3, prefType);
    saturation(labels == 0) = 0;
    values = ones(n1,n2,n3, prefType);
    % values(labels == 0) = 0;
    % HSV colors
    colors = hues(:,:,:);
    colors(:,:,:,2) = saturation;
    colors(:,:,:,3) = values;

    % Convert to RGB
    colors = reshape(colors, n, 3);
    colors = hsv2rgb(colors);
    colors = reshape(colors, n1,n2,n3, 3);

    if strcmp(type, 'mult')
        overlayImage = overlayImage .* colors;
    elseif strcmp(type, 'colorize')
        colors = colors/2;
        meanColors = sum(colors, 4) / 3;
        colors = colors - meanColors(:,:,:,ones(3,1));
        overlayImage = overlayImage + colors;
        overlayImage(overlayImage > 1) = 1;
        overlayImage(overlayImage < 0) = 0;
    end
    
elseif (n3 == 1 && strcmp(input, 'gray')) ... % 2D gray
    || (n3 == 3 && n4 == 1 && strcmp(input, 'rgb')) % 2D color

    [n1, n2, n3] = size(image);
    n = n1*n2;

    if strcmp(input, 'gray')
        overlayImage(:,:,1) = image;
        overlayImage(:,:,2) = image;
        overlayImage(:,:,3) = image;
    else
        overlayImage = image;
    end
    
    if randomizeColors
        
        uniqueLabels = unique(labels);
        uniqueLabels = uniqueLabels(uniqueLabels ~= 0);
        r = randperm(length(uniqueLabels));
        switchedLabels = uniqueLabels(r);
        labelPositions = arrayfun(@(x) find(labels == x), uniqueLabels, 'UniformOutput', false);
        
        for i = 1:length(uniqueLabels)
            
            labels(labelPositions{i}) = switchedLabels(i);
            
        end
        
    end

    if inv
        hues = 1-labels;
    else
        hues = labels;
    end
    
    if useRange
%         hues = jh_normalizeMatrix(hues, range(1), range(2), 'same');
        hues = hues * (range(2)-range(1)) + range(1);
    end
        
    
    % Saturation and Value channel
    saturation = ones(n1,n2, prefType);
    saturation(labels == 0) = 0;
    values = ones(n1,n2, prefType);
    % values(labels == 0) = 0;
    % HSV colors
    colors = hues(:,:);
    colors(:,:,2) = saturation;
    colors(:,:,3) = values;

    % Convert to RGB
    colors = reshape(colors, n, 3);
    colors = hsv2rgb(colors);
    colors = reshape(colors, n1,n2, 3);

    if strcmp(type, 'mult')
        overlayImage = overlayImage .* colors;
    elseif strcmp(type, 'colorize')
        colors = colors/2;
        meanColors = sum(colors, 3) / 3;
        colors = colors - meanColors(:,:,ones(3,1));
        overlayImage = overlayImage + colors;
        overlayImage(overlayImage > 1) = 1;
        overlayImage(overlayImage < 0) = 0;
    end
    
   

end

end

function overlayImage = oneColorOverlay(image, labels, color, type, inv, input)

[n1, n2, n3, n4, n5] = size(image);
n = n1*n2*n3;
prefType = class(labels);

% image = jh_normalizeMatrix(image, 0, 1, 'same');

if inv
    labels(labels > 0) = 1;
    labels = 1-labels; 
end

if (n3 > 1 && strcmp(input, 'gray')) || (n3 > 3)
    
    if strcmp(input, 'gray')
        overlayImage(:,:,:,1) = image;
        overlayImage(:,:,:,2) = image;
        overlayImage(:,:,:,3) = image;
    else
        overlayImage = image;
    end

    if strcmp(type, 'colorize')
        color = color - sum(color) / 3;
    end
    if strcmp(type, 'colorizeInv')
        color = color - sum(color) / 3;
        icolor = (1-color) - sum(1-color) / 3;
        icolor = permute(icolor, [1 3 4 2]);
        icolors1 = icolor(ones(n1,1), ones(n2,1), ones(n3,1), 1);
        icolors2 = icolor(ones(n1,1), ones(n2,1), ones(n3,1), 2);
        icolors3 = icolor(ones(n1,1), ones(n2,1), ones(n3,1), 3);
    end

    color = permute(color, [1 3 4 2]);
    colors1 = color(ones(n1,1), ones(n2,1), ones(n3,1), 1);
    colors2 = color(ones(n1,1), ones(n2,1), ones(n3,1), 2);
    colors3 = color(ones(n1,1), ones(n2,1), ones(n3,1), 3);
    if strcmp(type, 'mult')
        colors1(labels == 0) = 1;
        colors2(labels == 0) = 1;
        colors3(labels == 0) = 1;
    elseif strcmp(type, 'add')
        colors1(labels == 0) = 0;
        colors2(labels == 0) = 0;
        colors3(labels == 0) = 0;
    elseif strcmp(type, 'mean')
        colors1(labels == 0) = image(labels == 0);
        colors2(labels == 0) = image(labels == 0);
        colors3(labels == 0) = image(labels == 0);
    elseif strcmp(type, 'colorize')
        colors1(labels == 0) = 0;
        colors2(labels == 0) = 0;
        colors3(labels == 0) = 0;
    elseif strcmp(type, 'colorizeInv')
        colors1(labels == 0) = icolors1(labels == 0);
        colors2(labels == 0) = icolors2(labels == 0);
        colors3(labels == 0) = icolors3(labels == 0);
    end
    colors(:,:,:,1) = colors1;
    colors(:,:,:,2) = colors2;
    colors(:,:,:,3) = colors3; 

elseif (n3 == 1 && strcmp(input, 'gray')) ... % 2D gray
        || (n3 == 3 && n4 == 1 && strcmp(input, 'rgb')) % 2D color
    
    n = n1*n2;
    if strcmp(input, 'gray')
        overlayImage(:,:,1) = image;
        overlayImage(:,:,2) = image;
        overlayImage(:,:,3) = image;
    else
        overlayImage = image;
    end

    if strcmp(type, 'colorize')
        color = color - sum(color) / 3;
    end
    if strcmp(type, 'colorizeInv')
        color = color - sum(color) / 3;
        icolor = (1-color) - sum(1-color) / 3;
        icolor = permute(icolor, [1 3 2]);
        icolors1 = icolor(ones(n1,1), ones(n2,1), 1);
        icolors2 = icolor(ones(n1,1), ones(n2,1), 2);
        icolors3 = icolor(ones(n1,1), ones(n2,1), 3);
    end

    color = permute(color, [1 3 2]);
    colors1 = color(ones(n1,1), ones(n2,1), 1);
    colors2 = color(ones(n1,1), ones(n2,1), 2);
    colors3 = color(ones(n1,1), ones(n2,1), 3);
    if strcmp(type, 'mult')
        colors1(labels == 0) = 1;
        colors2(labels == 0) = 1;
        colors3(labels == 0) = 1;
    elseif strcmp(type, 'add')
        colors1(labels == 0) = 0;
        colors2(labels == 0) = 0;
        colors3(labels == 0) = 0;
    elseif strcmp(type, 'mean')
        colors1(labels == 0) = image(labels == 0);
        colors2(labels == 0) = image(labels == 0);
        colors3(labels == 0) = image(labels == 0);
    elseif strcmp(type, 'colorize')
        colors1(labels == 0) = 0;
        colors2(labels == 0) = 0;
        colors3(labels == 0) = 0;
    elseif strcmp(type, 'colorizeInv')
        colors1(labels == 0) = icolors1(labels == 0);
        colors2(labels == 0) = icolors2(labels == 0);
        colors3(labels == 0) = icolors3(labels == 0);
    end
    colors(:,:,1) = colors1;
    colors(:,:,2) = colors2;
    colors(:,:,3) = colors3; 

    
end

if strcmp(type, 'mult')
    overlayImage = overlayImage .* colors;
elseif strcmp(type, 'add')
    overlayImage = overlayImage + colors;
    overlayImage(overlayImage > 1) = 1;
    overlayImage(overlayImage < 0) = 0;
elseif strcmp(type, 'mean')
    overlayImage = .5 * overlayImage + .5 * colors;
elseif strcmp(type, 'addDiff')
    oi1 = overlayImage(:,:,1);
    oi2 = overlayImage(:,:,2);
    oi3 = overlayImage(:,:,3);
    
    oi1(labels > 0) = (1-max(color)) .* oi1(labels > 0) + colors1(labels > 0);
    oi2(labels > 0) = (1-max(color)) .* oi2(labels > 0) + colors2(labels > 0);
    oi3(labels > 0) = (1-max(color)) .* oi3(labels > 0) + colors3(labels > 0);

    overlayImage(:,:,1) = oi1;
    overlayImage(:,:,2) = oi2;
    overlayImage(:,:,3) = oi3;
elseif strcmp(type, 'addInv')
    oi1 = overlayImage(:,:,1);
    oi2 = overlayImage(:,:,2);
    oi3 = overlayImage(:,:,3);
    
    oi1(labels > 0) = (1-max(color)) .* oi1(labels > 0) + colors1(labels > 0);
    oi2(labels > 0) = (1-max(color)) .* oi2(labels > 0) + colors2(labels > 0);
    oi3(labels > 0) = (1-max(color)) .* oi3(labels > 0) + colors3(labels > 0);
    oi1(labels == 0) = (1-max(color)) .* oi1(labels == 0) + max(color) * (1-colors1(labels == 0));
    oi2(labels == 0) = (1-max(color)) .* oi2(labels == 0) + max(color) * (1-colors2(labels == 0));
    oi3(labels == 0) = (1-max(color)) .* oi3(labels == 0) + max(color) * (1-colors3(labels == 0));

    overlayImage(:,:,1) = oi1;
    overlayImage(:,:,2) = oi2;
    overlayImage(:,:,3) = oi3;
elseif strcmp(type, 'colorize')
    overlayImage = overlayImage + colors;
    overlayImage(overlayImage > 1) = 1;
    overlayImage(overlayImage < 0) = 0;
    
elseif strcmp(type, 'colorizeInv')
    overlayImage = overlayImage + colors;
    overlayImage(overlayImage > 1) = 1;
    overlayImage(overlayImage < 0) = 0;
end

end