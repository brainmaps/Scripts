function dilated = jh_vs_dilate(im, radius, debug, nameRun, nameParam)
% 
% INPUT
%   im: Image
%   radius: Radius of the structural element
%
% OUTPUT
%   dilated: Dilated image

fprintf('    Calculation: Dilate... ');
tic;

[nh, ~] = jh_getNeighborhood3D(0,radius);
dilated = imdilate(im,nh);

% Debug
if debug
    saveImageAsTiff3D(dilated, [nameRun '_' nameParam '.TIFF']);
end

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end