function [GF, mag] = jh_vs2D_imageGradient(im, sigma, debug, nameRun, nameParam)
% 
% INPUT
%   im: image used to calculate the gradient
%   sigma: Gaussian sigma used for calculation of the derivatives
%
% OUTPUT
%   GF: gradient field
%   mag: the magnitude of the gradient field

fprintf('    Calculation: Gradient field... ');
tic;

GF = zeros(size(im,1), size(im,2), 2, size(im,3));
mag = zeros(size(im));
for i = 1:size(im,3)
    
    [GF(:,:,:,i), mag(:,:,i)] = jh_imageGradient2D(im(:,:,i), sigma);
    
end
GF = permute(GF, [1,2,4,3]);

% Debug
if debug
    saveImageAsTiff3D(mag, [nameRun '_' nameParam '.TIFF']);
end

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end
