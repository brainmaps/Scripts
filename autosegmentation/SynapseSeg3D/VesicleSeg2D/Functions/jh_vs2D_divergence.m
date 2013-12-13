function div = jh_vs2D_divergence(GF, sigma, debug, nameRun, nameParam)
% 
% INPUT
%   GF: gradient field
%   sigma: Gaussian sigma used for calculation of the derivatives
%
% OUTPUT
%   div: divergence of the gradient field

fprintf('    Calculation: Divergence of gradient... ');
tic;

div = zeros(size(GF,1), size(GF,2), size(GF,3));
GF = permute(GF, [1,2,4,3]);
for i = 1:size(GF,4)

    div(:,:,i) = jh_divergenceFromGradient2D(GF(:,:,:,i), sigma); 
    div(:,:,i) = div(:,:,i) - min(min(div(:,:,i)));
    div(:,:,i) = div(:,:,i) / max(max(div(:,:,i)));
    div(:,:,i) = 1-div(:,:,i);

end

% Debug
if debug
    saveImageAsTiff3D(div, [nameRun '_' nameParam '.TIFF']);
end

clear type;

elapsedTime = toc;
fprintf('Done in %.2G seconds!\n', elapsedTime);

end
