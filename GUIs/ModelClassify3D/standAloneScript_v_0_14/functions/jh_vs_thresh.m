function th = jh_vs_thresh(im, thresh, debug, nameRun, nameParam)
% 
% INPUT
%   im: image
%   thresh: Threshold 
%
% OUTPUT
%   th: binary representation

fprintf('    Calculation: Threshold... ');
tic;

th = zeros(size(im));
th(im > thresh) = 1;

th = opening(th, 8, 'elliptic');
th = closing(th, 8, 'elliptic');
th = im2mat(th);

% Debug
if debug
    saveImageAsTiff3D(th, [nameRun '_' nameParam '.TIFF']);
end

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end