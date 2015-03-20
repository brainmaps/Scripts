function jh_saveImageAsTiff3D(image, fileName, varargin)
%jh_saveImageAsTiff3D saves a 3D matrix as 3D TIFF file.
%
% SYNOPSIS
%   jh_saveImageAsTiff3D(image, fileName)
%   jh_saveImageAsTiff3D(image, fileName, type)
%
% INPUT
%   image: 3D matrix which will be saved
%   fileName: the path and file name, the extension '.tif' or '.TIFF' has
%       to be supplied
%   type: 'gray' for grayscale image; 'rgb' for RGB-image

%% Check input

% Defaults
type = 'gray';
% Check input
if ~isempty(varargin)
    type = varargin{1};
end

%%

if strcmp(type, 'gray')
    
    image = image/max(max(max(image)));

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
        tagstruct.BitsPerSample = 8;
        tagstruct.SamplesPerPixel = 3;
        tagstruct.RowsPerStrip = 16;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software = 'MATLAB';
        t.setTag(tagstruct);
        im = uint8(image(:,:,i,:) * 255);
        im = permute(im, [1,2,4,3]);
        t.write(im);
        t.writeDirectory;
    end
    t.close;
end

end

