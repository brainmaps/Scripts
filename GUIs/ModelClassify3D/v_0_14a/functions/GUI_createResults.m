function [data, features] = GUI_createFeatureIntensities(data, features)

for i = 1:length(features.inUse)
    
    % Calculate features
    if strcmp(features.inUse, 'Divergence')
        [output, ~, ~] = GUI_divergence(data.im, features.parameters{i});
    elseif strcmp(features.inUse, 'Gaussian')
        output = GUI_gaussian(data.im, features.parameters{i});
    elseif strcmp(features.inUse, 'Hessian: iL1L2L3')
        [~,~,~,~,output] = GUI_hessian(data.im, features.parameters{i});
    elseif strcmp(features.inUse, 'DiffSimVes')
        p.thresh = features.parameters{i}{1};
        p.sMex = features.parameters{i}{5};
        p.sGauss = features.parameters{i}{4};
        pGF.sigma = features.parameters{i}{2};
        pGF.mult = 3;
        pDiv.sigma = features.parameters{i}{3};
        pDiv.mult = 3;
        [~,~,output] = jh_vs_simVes( ...
            data.im, p, pGF, pDiv, ...
            'WS', data.S3.labMin, data.S3.labWS, ...
            'anisotropic', [1 1 3], 'prefType', features.prefType);
    end
    
    % Expand the information to the whole WS basins
    [~, features.intensities{i}] = jh_vs_createResult( ...
    output, data.S3.labMin, data.S3.labWS, features.parameters{i}{1}, ...
    'prefType', features.prefType);

end

end