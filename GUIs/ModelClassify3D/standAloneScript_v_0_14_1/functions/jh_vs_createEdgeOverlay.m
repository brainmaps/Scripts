function [overlay, boundaries] = jh_vs_createEdgeOverlay(im, mask, debug, nameRun, nameParam)
% 
% INPUT
%   im: image
%   mask: mask which defines the classes
%
% OUTPUT
%   overlay: A 3D RGB image
%   boundaries: Edges of the objects from the mask matrix

fprintf('    Calculation: Edge overlay... ');
tic;

overlay = zeros(size(im,1), size(im,2), 3, size(im,3));
boundaries = zeros(size(im));
for i = 1:size(im,3)
    [o, b] = jh_createEdgeOverlay(im(:,:,i), mask(:,:,i), 0, 2);
    overlay(:,:,:,i) = o;
    boundaries(:,:,i) = b;
end
overlay = permute(overlay, [1,2,4,3]);

% Debug
if debug
    saveImageAsTiff3D(overlay, [nameRun '_' nameParam '.TIFF'], 'rgb');
end

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end
