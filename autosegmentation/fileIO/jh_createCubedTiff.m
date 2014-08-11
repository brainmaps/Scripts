
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path = 'D:\Julian\Synapse segmentation\Datasets\Ivo\';
name = 'Ivo';
imageName = 'labels';
cubeSize = [128 128 128]; % [r c d]
padValue = 0;
padOrientation = [0 0 1]; % [r c d]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FileTif='F:\c0.tif';
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);

FinalImage=zeros(512,512,384,'double');
for i=1:384
    disp([num2str(i) '/' num2str(NumberImages)]);
    tIm = double(imread(FileTif,'Index',i));
   FinalImage(:,:,i)=tIm(1:512, 1:512);
   
end

im = jh_normalizeMatrix(FinalImage);


clear FinalImage
% im = double(h5read([path name '.h5'], ['/' imageName])) ./ 255;
% im = im(1:200, 1:200, :);

n = size(im);

nc = [ceil(n(1)/cubeSize(1)), ceil(n(2)/cubeSize(2)), ceil(n(3)/cubeSize(3))];

% Pad image
paddedImage = ones(nc .* cubeSize) * padValue;
np = size(paddedImage);
from = zeros(3,1);
to = zeros(3,1);
for i = 1:3
   
    switch padOrientation(i)
        case -1
            from(i) = np(i) - n(i) + 1;
        case 0
            from(i) = round(np(i)/2) - round(n(i)/2) + 1;
        case 1
            from(i) = 1;
    end
    to(i) = from(i) + n(i) - 1;

end
clear i
paddedImage(from(1):to(1), from(2):to(2), from(3):to(3)) = im;
% clear im;

clear n imageName padValue padOrientation np from to

%% Write cubed image to files

% Create the main folder
mkdir(path, ['cubed_' name]);

% Divide image into cubes
for x = 1:nc(2)
    
    px = ['x' sprintf('%04d', x-1)];
    mkdir([path 'cubed_' name], px);
    cx = 1+cubeSize(2)*(x-1);
    
    for y = 1:nc(1)
        
        py = ['y' sprintf('%04d', y-1)];
        mkdir([path 'cubed_' name '\' px], py);
        cy = 1+cubeSize(1)*(y-1);
        
        for z = 1:nc(3)
            
            pz = ['z' sprintf('%04d', z-1)];
            mkdir([path 'cubed_' name '\' px '\' py], pz);
            cz = 1+cubeSize(3)*(z-1);
            
            saveImage =  paddedImage(cy:cy+cubeSize(2)-1, cx:cx+cubeSize(1)-1, cz:cz+cubeSize(3)-1);
            saveImageAsTiff3D(saveImage, [path 'cubed_' name '\' px '\' py '\' pz '\' name '_' px '_' py '_' pz '.TIFF'], 'gray');
            clear saveImage;
%             cubedImage{x, y, z} =
            
        end
    end
end
clear x y z cx cy cz px py pz
% clear paddedImage

clear path name cubeSize nc

