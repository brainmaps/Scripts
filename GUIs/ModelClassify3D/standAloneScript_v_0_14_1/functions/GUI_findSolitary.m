function [result, resultWS] = GUI_findSolitary(classificationResult, data, WS)

[kernel, ~] = jh_getNeighborhood3D(1, 12, 'anisotropic', [1 1 3]);
% [kernel, ~] = jh_getNeighborhood2D(1, 10);
% kernel = kernel(:, :, ones(5,1));

score = im2mat(convolve(classificationResult{1} > 0, kernel));
tScore = zeros(size(score), data.prefType);
tScore(score < 8) = 1;
result = zeros(size(score), data.prefType);
result(classificationResult{1} > 0) = tScore(classificationResult{1} > 0);

resultWS = jh_vs_createResult(result, WS.results{2}, WS.results{1}, .1, 'larger', 'prefType', data.prefType);

end