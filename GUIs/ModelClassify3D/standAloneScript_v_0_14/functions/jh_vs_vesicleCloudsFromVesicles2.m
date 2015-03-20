function vc = jh_vs_vesicleCloudsFromVesicles2(im, vesicles, seeds, prefType)

[n1, n2, n3] = size(im);
n = n1*n2*n3;
%% Image gradient 

vc = vesicles;
clear vesicles

conn = 2;
maxDepth = 1;
maxSize = 10;
hess = jh_dip_hessian3D(im, 2, 3, [1 1 3]); % sigma = 2
dipSeeds = minima(hess, conn, 0);
WS_hess = im2mat(jh_dip_waterseed(dipSeeds, hess, conn, maxDepth, maxSize));
clear hess conn maxDepth maxSize dipSeeds


[nh, ~] = jh_getNeighborhood3D(0, 1); 
vc = jh_regionGrowing3D(vc, WS_hess, nh, 0, 'l', 'prefType', 'single', 'iterations', 0);

CC = bwconncomp(vc, 18);
excludeSmall = find(cellfun(@length, CC.PixelIdxList) > 1000);
CC.NumObjects = length(excludeSmall);
CC.PixelIdxList = CC.PixelIdxList(excludeSmall);
clear excludeSmall

vc = single(labelmatrix(CC));

vc(WS_hess == 0) = 0;
clear WS_hess


vc = jh_normalizeMatrix(vc);


end

