function vc = jh_vs_vesicleCloudsFromVesicles(im, vesicles, seeds, prefType)

[n1, n2, n3] = size(im);
n = n1*n2*n3;
%% Image gradient 

[GF, mag] = jh_dip_imageGradient3D(im, 2, 3, [1 1 3]);
mag = mag(:,:,:,ones(3,1));

rGF = round(GF./mag);
clear GF mag

rGF11 = rGF(1,:,:,1);
rGF11(rGF11 < 0) = 0;
rGF(1,:,:,1) = rGF11;
clear rGF11
rGF1end = rGF(end,:,:,1);
rGF1end(rGF1end > 0) = 0;
rGF(end,:,:,1) = rGF1end;
clear rGF1end

rGF21 = rGF(:,1,:,2);
rGF21(rGF21 < 0) = 0;
rGF(:,1,:,2) = rGF21;
clear rGF21
rGF2end = rGF(:,end,:,2);
rGF2end(rGF2end > 0) = 0;
rGF(:,end,:,2) = rGF2end;
clear rGF2end

rGF31 = rGF(:,:,1,3);
rGF31(rGF31 < 0) = 0;
rGF(:,:,1,3) = rGF31;
clear rGF31
rGF3end = rGF(:,:,end,3);
rGF3end(rGF3end > 0) = 0;
rGF(:,:,end,3) = rGF3end;
clear rGF3end

% figure, imshow(jh_normalizeMatrix(data.image(:,:,58)));
% hold on
% quiver(rGF(:,:,58,2), rGF(:,:,58,1));
% hold off

lin_rGF = rGF(:,:,:,1) + n1*rGF(:,:,:,2) + n1*n2*rGF(:,:,:,3);
clear rGF
lin_rGF = reshape(1:n, n1,n2,n3) + lin_rGF;


vesicleClouds = zeros(n1,n2,n3, prefType);
vesicleClouds(vesicles > 0) = 1;

for i = 1:10
    
    tVC = vesicleClouds;
    vesicleClouds(lin_rGF) = vesicleClouds;
    vesicleClouds(tVC > 0) = tVC(tVC > 0);
    
end

clear lin_rGF

%% Gaussian-smoothed image
% vcGauss = jh_dip_gaussianFilter3D(im, 1, 3, [1 1 3], 'normalizeKernel');
% 
% [GF, mag] = jh_dip_imageGradient3D(data.image, 1.5, 3, [1 1 3]);
% div = jh_dip_divergenceFromGradient3D(GF, 1, 3, [1 1 3]);

% mask = vcGauss;
% 
% %% Region growing (connection of WS regions)
% vesicleClouds = zeros(n1,n2,n3, data.prefType);
% vesicleClouds(classificationResult{2} > 0) = 1;
% 
% % figure, imagesc(vesicleClouds(:,:,30))
% 
% % [nh, ~] = jh_getNeighborhood3D(0,1, 'anisotropic', [1 1 3]);
% % [nh, ~] = jh_getNeighborhood2D(0,1);
% % vesicleClouds = jh_advancedRegionGrowing3D(vesicleClouds, mask, nh, 20, 'l', 'prefType', 'single', 'iterations', 1);
% % vesicleClouds = imdilate(vesicleClouds, nh);
% 
% %% Labelling
% % vesicleClouds = single(bwlabeln(vesicleClouds, 6));
% 
% % for i = 1:n3
% %    
% %     vesicleClouds(:,:,i) = imfill(vesicleClouds(:,:,i));
% %     
% % end
% % figure, imagesc(vesicleClouds(:,:,30))
% 

vesicleClouds = single(bwlabeln(vesicleClouds, 6));


%% Second, larger growing step


% 
% [nh, ~] = jh_getNeighborhood3D(0,1, 'anisotropic', [1 1 3]);
% vesicleClouds = jh_advancedRegionGrowing3D(vesicleClouds, mask, nh, 10, 'l', 'prefType', 'single', 'iterations', 1);

[nh, ~] = jh_getNeighborhood3D(0,3, 'anisotropic', [1 1 3]);
vesicleClouds = imdilate(vesicleClouds, nh);

% for i = 1:n3
%    
%     vesicleClouds(:,:,i) = imfill(vesicleClouds(:,:,i));
%     
% end

%% Exclusion of regions with few vesicles
for i = 1:max(max(max(vesicleClouds)))
    
    if ~isempty(find(vesicleClouds == i, 1))
        
        region = seeds(vesicleClouds == i);
        if length(find(region > 0)) <= 10
            vesicleClouds(vesicleClouds == i) = 0;
        end

    end
    
end


vc = jh_normalizeMatrix(vesicleClouds);


end

