function [vc, vesicles] = jh_vs_calculateVesicleClouds(im, classScores, classVesiclePredict, labWS, labMin, prefType)

classifiedMin = zeros(size(classVesiclePredict), prefType);
classifiedMin(labMin > 0) = classVesiclePredict(labMin > 0);


[kernel, ~] = jh_getNeighborhood3D(1, 12, 'anisotropic', [1 1 3]);

score = im2mat(convolve(classifiedMin > 0, kernel));

% t = zeros(size(im)+20);
% 
% t(11:end-10, 11:end-10, 11:end-10) = (classifiedMin > 0);
% t = jh_dip_gaussianFilter3D(t, 15, 3, [1 1 3], 'normalizeKernel');
% % t = jh_dip_gaussianXsq3D(t, 2, 3, [1 1 3], 'normalizeKernel');
% 
% score = t(11:end-10, 11:end-10, 11:end-10);



clear kernel;
tScore = zeros(size(score), prefType);
tScore(score < 7) = 1;
solitaryMin = zeros(size(score), prefType);
solitaryMin(classifiedMin > 0) = tScore(classifiedMin > 0);
% clear score tscore;

% solitaryWS = jh_vs_createResult(solitary, WS.results{2}, WS.results{1}, .1, 'larger', 'prefType', data.prefType);
nh = [1, 1, 1; 1, 1, 1; 1, 1, 1];
solitaryWS = jh_regionGrowing3D(solitaryMin, labWS, nh, 0, 'l', 'prefType', 'single', 'iterations', 0);
clear nh;

classVesiclePredict(solitaryWS > 0) = 0;
% classifiedMin(solitaryMin > 0) = 0;
clear solitaryMin solitaryWS

vesicleClouds = jh_vs_vesicleCloudsFromVesicles2(im, classVesiclePredict, labMin, prefType);

vc = vesicleClouds;
vesicles = classVesiclePredict;
clear vesicleClouds

score(score > 9) = 9;
score(score < 5) = 5;
vesicles = jh_normalizeMatrix(score);
end