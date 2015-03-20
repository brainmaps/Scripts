function [vc, vesicles] = jh_vs_calculateVesicleClouds_v3(im, classScores, classVesiclePredict, labWS, labMin, prefType)

[nh, ~] = jh_getNeighborhood3D(0, 1); 
classScoresMin = classScores;
classScoresMin = imdilate(classScoresMin, nh);

% classScoresMin(labMin == 0) = -10;
classScoresMin(classScoresMin > 0) = classScoresMin(classScoresMin > 0) + 10;
% classScoresMin(classScoresMin < -10) = -10;

% [kernel, ~] = jh_getNeighborhood3D(1, 12, 'anisotropic', [1 1 3]);
% kernel = kernel / sum(sum(sum(kernel)));
% 
% vesicleScore = im2mat(convolve(classScoresMin, kernel));

% t = ones(size(im)+20) * -10;
t = ones(size(im)+20) * min(min(min(classScoresMin)));

t(11:end-10, 11:end-10, 11:end-10) = classScoresMin;
t = jh_dip_gaussianFilter3D(t, 2, 3, [1 1 3], 'normalizeKernel');
% t = jh_dip_gaussianXsq3D(t, 2, 3, [1 1 3], 'normalizeKernel');

vesicleScore = t(11:end-10, 11:end-10, 11:end-10);

pvesicles = vesicleScore;
% level = graythresh(vesicleScore);
level = 10;
pvesicles(vesicleScore >= level) = 1; %level = 8
pvesicles(vesicleScore < level) = 0;

vesicles = pvesicles;
vesicles(labMin == 0) = 0;

[nh, ~] = jh_getNeighborhood2D(0, 1); 
vesicles = jh_regionGrowing3D(vesicles, labWS, nh, 0, 'l', 'iterations', 0);
vesicles(classScores < 0) = 0;

% vc = jh_normalizeMatrix(pvesicles);
vc = jh_vs_vesicleCloudsFromVesicles2(im, vesicles, labMin, prefType);
vesicles = jh_normalizeMatrix(vesicleScore);


end

% 
% conn = 2;
% maxDepth = 0;
% maxSize = 0;
% % hess = jh_dip_hessian3D(im, 1.2, 3, [1 1 3]); % sigma = 2
% % dipSeeds = minima(hess, conn, 0);
% % WS_hess = im2mat(jh_dip_waterseed(dipSeeds, hess, conn, maxDepth, maxSize));
% gauss = jh_dip_gaussianFilter3D(im, 1.0, 3, [1 1 3]);
% dipSeeds = minima(gauss, conn, 0);
% labMinWS = im2mat(dipSeeds);
% WS_gauss = im2mat(jh_dip_waterseed(dipSeeds, gauss, conn, maxDepth, maxSize));
% clear hess conn maxDepth maxSize dipSeeds
% 
% CC = bwconncomp(WS_gauss, 18);
% 
% % Contains the positions of the watershed basins for each included voxel
% listedWS.positions = permute(CC.PixelIdxList, [2 1]);
% % Create a list of the labels of each basin
% listedWS.labels = cellfun(@(v) v(1), listedWS.positions(:));
% listedWS.labels = WS_gauss(listedWS.labels);
% % Sort the basins according their label
% [listedWS.labels, index] = sort(listedWS.labels);
% listedWS.positions = listedWS.positions(index);
% 
% % Find the seeds 
% listedSeeds.positions = find(labMinWS > 0);
% % Create reference label vector again to sort the entries according to
% % above
% listedSeeds.labels = WS_gauss(listedSeeds.positions);
% [listedSeeds.labels, index] = sort(listedSeeds.labels);
% listedSeeds.positions = listedSeeds.positions(index);
% 
% % [nh, ~] = jh_getNeighborhood3D(0, 1); 
% % vc = jh_regionGrowing3D(vc, WS_gauss, nh, 0, 'l', 'prefType', 'single', 'iterations', 0);
% % 
% % CC = bwconncomp(vc, 6);
% % excludeSmall = find(cellfun(@length, CC.PixelIdxList) > 1000);
% % CC.NumObjects = length(excludeSmall);
% % CC.PixelIdxList = CC.PixelIdxList(excludeSmall);
% % clear excludeSmall
% 
% % vc = single(labelmatrix(CC));
% 
% 
% 
% minScores = min(min(min(classScores)));
% scores = classScores - minScores +1;
% scores(labWS == 0) = 0;
% 
% [nh, ~, ~] = jh_getNeighborhood3D(0, 1);
% dilScores = imdilate(scores, nh) + minScores -1;
% 
% % Get score values within basins
% pvcList = cellfun(@(x) {dilScores(x)}, listedWS.positions);
% meanVcList = cellfun(@mean, pvcList);
% 
% pvc = zeros(size(im), prefType);
% pvc(listedSeeds.positions) = meanVcList;
% 
% 
% [nh, ~, ~] = jh_getNeighborhood3D(0, 1);
% 
% minPvc = min(min(min(pvc)));
% pvc = pvc - minPvc + 1;
% pvc(labMinWS == 0) = 0;
% pvc = jh_regionGrowing3D(pvc, WS_gauss, nh, 0, 'l', 'iterations', 0) + minPvc - 1;
% pvc(WS_gauss == 0) = 0;
% 
% % Threshold
% vc = zeros(size(pvc));
% vc(pvc > 1) = 1;
% 
% vc = imdilate(vc, nh);
% 
% CC = bwconncomp(vc, 18);
% 
% excludeSmall = find(cellfun(@length, CC.PixelIdxList) > 1000);
% CC.NumObjects = length(excludeSmall);
% CC.PixelIdxList = CC.PixelIdxList(excludeSmall);
% clear excludeSmall
% 
% vc = jh_normalizeMatrix(single(labelmatrix(CC)));
% 
% % 
% % pvc(pvc<-10) = -10;
% % 
% % vc = zeros(size(pvc), prefType);
% % vc(pvc > 1) = 1;
% % % [nh, ~, ~] = jh_getNeighborhood3D(0, 1);
% % % vc = imdilate(jh_normalizeMatrix(single(WS_gauss)),nh);
% % 
% % vc = jh_normalizeMatrix(vc);
% % % vc(WS_gauss == 0) = 0;
% 
% 
% 
% vesicles = classVesiclePredict;
% 
% end