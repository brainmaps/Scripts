function hm = jh_vs_hMax(im, h, conn, invert, debug, nameRun, nameParam)
%
% INPUT
%   im: image used to calculate the h-maximum transform
%   h: parameter h for the h-maximum
%   conn: connectivity
%   invert: when true the image is inverted (needs normalized image)
%
% OUTPUT
%   hm: h-maximum

fprintf('    Calculation: h-maximum... ');
tic;

if invert
    im = 1-im;
end

% H-maximum from divergence of normalized gradient
hm = imhmax(im, h, conn);
hm = im - hm;
hm = hm/max(max(max(hm)));

% Debug
if debug
    saveImageAsTiff3D(hm, [nameRun '_' nameParam '.TIFF']);
end

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end

