function div = jh_vs_divergence(GF, sigma, debug, nameRun, nameParam)
% 
% INPUT
%   GF: gradient field
%   sigma: Gaussian sigma used for calculation of the derivatives
%
% OUTPUT
%   div: divergence of the gradient field

fprintf('    Calculation: Divergence of gradient... ');
tic;

div = jh_normalizeMatrix(jh_divergenceFromGradient3D(GF, sigma)); 
div = 1-div;

% Debug
if debug
    saveImageAsTiff3D(div, [nameRun '_' nameParam '.TIFF']);
end

clear type;

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end

