function [vesicleClouds, vesicles] = GUI_vesicleClouds(classificationResult, data, WS)


[n1, n2, n3] = size(data.image);
n = n1*n2*n3;

%% Determine solitary regions for exclusion

[solitaryMin, solitaryWS] = GUI_findSolitary(classificationResult, data, WS);
classificationResult{2}(solitaryWS > 0) = 0;
classificationResult{1}(solitaryMin > 0) = 0;


%%

% vesicleClouds = jh_vs_vesicleCloudsFromVesicles(data.image, vesicles{2}, WS.results{2}, data.prefType);



vesiclePositions = classificationResult{1};
vesiclesWS = classificationResult{2};

conn = 2;
maxDepth = 1;
maxSize = 20;
hess = jh_dip_hessian3D(data.image, 2, 3, [1 1 3]);
dipSeeds = minima(hess, conn, 0);
WS_hess = im2mat(jh_dip_waterseed(dipSeeds, hess, conn, maxDepth, maxSize));
clear hess

% CC = bwconncomp(WS_hess,18); 
% 
% % Contains the positions of the watershed basins for each included voxel
% listedWS.positions = permute(CC.PixelIdxList, [2 1]);
% clear CC
% 
% listedVesicles = find(vesiclePositions > 0);

nh = [1, 1, 1; 1, 1, 1; 1, 1, 1];
vesCloudsWS = jh_regionGrowing3D(vesiclesWS, WS_hess, nh, 0, 'l', 'prefType', 'single', 'iterations', 0);

vesicleClouds = vesCloudsWS;
clear vesCloudsWS
vesicles{2} = vesiclesWS;
vesicles{1} = vesiclePositions;
clear vesiclesWS

vesicleClouds = single(bwlabeln(vesicleClouds, 6));

%% Exclusion of regions with few vesicles
for i = 1:max(max(max(vesicleClouds)))
    
    if ~isempty(find(vesicleClouds == i, 1))
        
        region = WS.results{2}(vesicleClouds == i);
        if length(find(region > 0)) <= 10
            vesicleClouds(vesicleClouds == i) = 0;
        end

    end
    
end

[nh, ~] = jh_getNeighborhood3D(0,1, 'anisotropic', [1 1 3]);
vesicleClouds = imdilate(vesicleClouds, nh);


vesicleClouds = jh_normalizeMatrix(vesicleClouds);



end