function m = jh_vs_meanFilter(im, radius, debug, nameRun, nameParam)
% 
% INPUT
%   im: image
%   radius: Radius of the structural element used to calculate the mean
%       filter
%
% OUTPUT
%   m: the mean filtered image

fprintf(['    Calculation: Mean, r = ' num2str(radius) '... ']);
tic;

[nh,~] = jh_getNeighborhood3D(0, radius);
nh = nh / size(find(nh == 1), 1);
m = imfilter(im, nh);

% Debug
if debug
    saveImageAsTiff3D(m, [nameRun '_' nameParam '.TIFF']);
end

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end