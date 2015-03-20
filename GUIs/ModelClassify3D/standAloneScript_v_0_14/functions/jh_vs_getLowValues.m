function lv = jh_vs_getLowValues(im, p, debug, nameRun, nameParam)
% 
% INPUT
%   im: image
%   p: percentage of intensity values which are within range
%
% OUTPUT
%   lv: low values of the matrix

fprintf('    Calculation: Low values... ');
tic;

lv = jh_getValues(im, p, 'fromMin');

% Debug
if debug
    saveImageAsTiff3D(lv, [nameRun '_' nameParam '.TIFF']);
end

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end