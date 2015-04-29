function jh_saveImageAsTiff3D(image, fileName, varargin)
%jh_saveImageAsTiff3D saves a 3D matrix as 8 bit 3D TIFF file.
%
% SYNOPSIS
%   jh_saveImageAsTiff3D(image, fileName)
%   jh_saveImageAsTiff3D(___, type)
%   jh_saveImageAsTiff3D(___, 'bitsPerSample', bitsPerSample)
%
% INPUT
%   image: 3D matrix which will be saved
%       The following formats are supported:
%           single, double, float: image values from 0 to 1
%           int8, int16, uint8, uint16: bitsPerSample is automatically set
%               to the corresponding bit depth, even if specified otherwise
%   fileName: the path and file name, the extension '.tif' or '.TIFF' has
%       to be supplied
%   type: 'gray' for grayscale image; 'rgb' for RGB-image
%   bitsPerSample: Set the bit-depth of the image, 8 (default) or 16 bit
%
%   

%% Check input

% Defaults
type = 'gray';
bitsPerSample = 8;

% Check input
i = 0;
while i < length(varargin)
    i = i+1;
    
    if strcmp(varargin{i}, 'gray')
        type = 'gray';
    elseif strcmp(varargin{i}, 'rgb')
        type = 'rgb';
    elseif strcmp(varargin{i}, 'bitsPerSample')
        bitsPerSample = varargin{i+1};
        i = i+1;
    end
    
end


%% Convert image to correct format

if isa(image, 'single') || isa(image, 'double') || isa(image, 'float')
    
    if bitsPerSample == 8
        image = uint8(image * 255);
    elseif bitsPerSample == 16
        image = uint16(image * 65535);
    end
    
elseif isa(image, 'int8') || isa(image, 'uint8')
    
    if isa(image, 'int8')
        image = jh_typeCastMatrix(image, 'uint8');
    end
    bitsPerSample = 8;
    
elseif isa(image, 'int16') || isa(image, 'uint16')
    
    if isa(image, 'int16')
        image = jh_typeCastMatrix(image, 'uint16');
    end
    bitsPerSample = 16;
    
end

%% Save image

if strcmp(type, 'gray')
    
%     image = image/max(max(max(image)));
    
    imwrite(image(:,:,1), fileName)

    for i = 2:size(image,3)
        imwrite(image(:,:,i), fileName, 'writemode', 'append')
    end
    
elseif strcmp(type, 'rgb')

    t = Tiff(fileName,'w');
    for i = 1:size(image,3)
        tagstruct.ImageLength = size(image,1);
        tagstruct.ImageWidth = size(image,2);
        tagstruct.Photometric = Tiff.Photometric.RGB;
        tagstruct.BitsPerSample = bitsPerSample;
        tagstruct.SamplesPerPixel = 3;
        tagstruct.RowsPerStrip = 16;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software = 'MATLAB';
        t.setTag(tagstruct);
%         im = uint8(image(:,:,i,:) * 255);
        im = image(:,:,i,:);
        im = permute(im, [1,2,4,3]);
        t.write(im);
        t.writeDirectory;
    end
    t.close;
end

end
